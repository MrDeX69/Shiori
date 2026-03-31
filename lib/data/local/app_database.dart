import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'app_database.g.dart';

// ── Tables ────────────────────────────────────────────────────────────────────

class MangaTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  TextColumn get authors => text().withDefault(const Constant('[]'))();
  TextColumn get status => text().nullable()();
  IntColumn get chapterCount => integer().withDefault(const Constant(0))();
  TextColumn get readingStatus => text().nullable()();
  IntColumn get lastReadChapter => integer().nullable()();
  TextColumn get readingMode => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ChapterProgressTable extends Table {
  TextColumn get chapterId => text()();
  TextColumn get mangaId => text()();
  TextColumn get mangaTitle => text().withDefault(const Constant(''))();
  TextColumn get mangaCoverUrl => text().nullable()();
  TextColumn get chapterNumber => text().nullable()();
  IntColumn get lastPage => integer().withDefault(const Constant(0))();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get readAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {chapterId};
}

/// Lightweight local chapter index — stores only what we need for unread counts.
/// Never stores page URLs (those come from the source at read time).
class LocalChapterTable extends Table {
  TextColumn get chapterId => text()();
  TextColumn get mangaId => text()();
  TextColumn get chapterNumber => text().nullable()();

  @override
  Set<Column> get primaryKey => {chapterId};
}

// ── Database ──────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [MangaTable, ChapterProgressTable, LocalChapterTable])
@singleton
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(
          chapterProgressTable,
          chapterProgressTable.mangaTitle,
        );
        await migrator.addColumn(
          chapterProgressTable,
          chapterProgressTable.mangaCoverUrl,
        );
        await migrator.addColumn(
          chapterProgressTable,
          chapterProgressTable.chapterNumber,
        );
      }
      if (from < 3) {
        await migrator.addColumn(mangaTable, mangaTable.readingMode);
      }
      if (from < 4) {
        await migrator.createTable(localChapterTable);
      }
    },
  );

  // ── Manga ─────────────────────────────────────────────────────────────────

  Future<List<MangaTableData>> getLibrary() => select(mangaTable).get();

  Future<void> insertManga(MangaTableCompanion manga) =>
      into(mangaTable).insertOnConflictUpdate(manga);

  Future<void> deleteManga(String id) =>
      (delete(mangaTable)..where((t) => t.id.equals(id))).go();

  Future<bool> isMangaInLibrary(String id) async {
    final result = await (select(mangaTable)
      ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return result != null;
  }

  Future<String?> getReadingMode(String mangaId) async {
    final result = await (select(mangaTable)
      ..where((t) => t.id.equals(mangaId)))
        .getSingleOrNull();
    return result?.readingMode;
  }

  Future<void> saveReadingMode(String mangaId, String mode) async {
    await (update(mangaTable)..where((t) => t.id.equals(mangaId))).write(
      MangaTableCompanion(readingMode: Value(mode)),
    );
  }

  // ── Local chapter index ───────────────────────────────────────────────────
  // Called by manga_detail_provider after fetching chapters from the source.
  // Gives us a local count without a network round-trip.

  Future<void> storeChapters(
      String mangaId,
      List<({String id, String? number})> chapters,
      ) async {
    await batch((b) {
      for (final ch in chapters) {
        b.insert(
          localChapterTable,
          LocalChapterTableCompanion(
            chapterId: Value(ch.id),
            mangaId: Value(mangaId),
            chapterNumber: Value(ch.number),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Future<int> getStoredChapterCount(String mangaId) async {
    final count = countAll();
    final query = selectOnly(localChapterTable)
      ..addColumns([count])
      ..where(localChapterTable.mangaId.equals(mangaId));
    final row = await query.getSingleOrNull();
    return row?.read(count) ?? 0;
  }

  // ── Chapter progress ──────────────────────────────────────────────────────

  Future<void> saveProgress(ChapterProgressTableCompanion progress) =>
      into(chapterProgressTable).insertOnConflictUpdate(progress);

  Future<ChapterProgressTableData?> getProgress(String chapterId) =>
      (select(chapterProgressTable)
        ..where((t) => t.chapterId.equals(chapterId)))
          .getSingleOrNull();

  Future<ChapterProgressTableData?> getLastReadForManga(
      String mangaId,
      ) async {
    final all = await (select(chapterProgressTable)
      ..where((t) => t.mangaId.equals(mangaId)))
        .get();
    if (all.isEmpty) return null;

    // Priority 1: highest numbered read chapter
    final readChapters = all
        .where((r) => r.isRead && r.chapterNumber != null)
        .toList();
    if (readChapters.isNotEmpty) {
      readChapters.sort((a, b) {
        final numA = double.tryParse(a.chapterNumber ?? '') ?? 0;
        final numB = double.tryParse(b.chapterNumber ?? '') ?? 0;
        return numB.compareTo(numA);
      });
      return readChapters.first;
    }

    // Priority 2: in-progress by recency
    final inProgress = all
        .where((r) => !r.isRead && r.readAt != null)
        .toList();
    if (inProgress.isNotEmpty) {
      inProgress.sort(
            (a, b) =>
            (b.readAt ?? DateTime(0)).compareTo(a.readAt ?? DateTime(0)),
      );
      return inProgress.first;
    }

    return all.first;
  }

  Future<Set<String>> getReadChapterIds(String mangaId) async {
    final results = await (select(chapterProgressTable)
      ..where(
            (t) => t.mangaId.equals(mangaId) & t.isRead.equals(true),
      ))
        .get();
    return results.map((r) => r.chapterId).toSet();
  }

  Future<void> markChapterRead(
      String chapterId,
      String mangaId,
      String mangaTitle,
      String? mangaCoverUrl,
      String? chapterNumber,
      bool isRead,
      ) async {
    await into(chapterProgressTable).insertOnConflictUpdate(
      ChapterProgressTableCompanion(
        chapterId: Value(chapterId),
        mangaId: Value(mangaId),
        mangaTitle: Value(mangaTitle),
        mangaCoverUrl: Value(mangaCoverUrl),
        chapterNumber: Value(chapterNumber),
        isRead: Value(isRead),
        readAt: Value(isRead ? DateTime.now() : null),
        lastPage: const Value(0),
      ),
    );
  }

  Future<void> markAllChaptersRead(
      String mangaId,
      String mangaTitle,
      String? mangaCoverUrl,
      List<Map<String, String?>> chapters,
      ) async {
    final now = DateTime.now();
    await batch((b) {
      for (int i = 0; i < chapters.length; i++) {
        final ch = chapters[i];
        b.insert(
          chapterProgressTable,
          ChapterProgressTableCompanion(
            chapterId: Value(ch['id']!),
            mangaId: Value(mangaId),
            mangaTitle: Value(mangaTitle),
            mangaCoverUrl: Value(mangaCoverUrl),
            chapterNumber: Value(ch['number']),
            isRead: const Value(true),
            readAt: Value(now.add(Duration(milliseconds: i))),
            lastPage: const Value(0),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  // ── History ───────────────────────────────────────────────────────────────

  Future<List<ChapterProgressTableData>> getHistory() =>
      (select(chapterProgressTable)
        ..orderBy([(t) => OrderingTerm.desc(t.readAt)])
        ..limit(50))
          .get();

  Future<void> clearHistory() => delete(chapterProgressTable).go();

  // ── Statistics ────────────────────────────────────────────────────────────

  Future<ReadingStats> getReadingStats() async {
    final allRead = await (select(chapterProgressTable)
      ..where((t) => t.isRead.equals(true)))
        .get();

    final library = await getLibrary();
    final totalManga = library.length;
    final totalChapters = allRead.length;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayChapters = allRead
        .where((r) => r.readAt != null && r.readAt!.isAfter(todayStart))
        .length;

    final streak = _calculateStreak(allRead);

    final mangaReadCount = <String, MangaReadData>{};
    for (final r in allRead) {
      if (!mangaReadCount.containsKey(r.mangaId)) {
        mangaReadCount[r.mangaId] = MangaReadData(
          mangaId: r.mangaId,
          title: r.mangaTitle,
          coverUrl: r.mangaCoverUrl,
          count: 0,
        );
      }
      mangaReadCount[r.mangaId]!.count++;
    }
    final topManga = mangaReadCount.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final weekActivity = <int>[];
    for (int i = 6; i >= 0; i--) {
      final day = todayStart.subtract(Duration(days: i));
      final nextDay = day.add(const Duration(days: 1));
      final count = allRead
          .where(
            (r) =>
        r.readAt != null &&
            r.readAt!.isAfter(day) &&
            r.readAt!.isBefore(nextDay),
      )
          .length;
      weekActivity.add(count);
    }

    return ReadingStats(
      totalChapters: totalChapters,
      totalManga: totalManga,
      todayChapters: todayChapters,
      streak: streak,
      topManga: topManga.take(5).toList(),
      weekActivity: weekActivity,
    );
  }

  int _calculateStreak(List<ChapterProgressTableData> allRead) {
    if (allRead.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final readDays = allRead
        .where((r) => r.readAt != null)
        .map(
          (r) => DateTime(r.readAt!.year, r.readAt!.month, r.readAt!.day),
    )
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    if (readDays.isEmpty) return 0;
    final yesterday = today.subtract(const Duration(days: 1));
    if (readDays.first != today && readDays.first != yesterday) return 0;
    int streak = 0;
    DateTime expected = readDays.first;
    for (final day in readDays) {
      if (day == expected) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}

// ── Model classes ─────────────────────────────────────────────────────────────

class MangaReadData {
  final String mangaId;
  final String title;
  final String? coverUrl;
  int count;

  MangaReadData({
    required this.mangaId,
    required this.title,
    required this.coverUrl,
    required this.count,
  });
}

class ReadingStats {
  final int totalChapters;
  final int totalManga;
  final int todayChapters;
  final int streak;
  final List<MangaReadData> topManga;
  final List<int> weekActivity;

  ReadingStats({
    required this.totalChapters,
    required this.totalManga,
    required this.todayChapters,
    required this.streak,
    required this.topManga,
    required this.weekActivity,
  });
}

// ── Connection ────────────────────────────────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'shiori.db'));
    return NativeDatabase.createInBackground(file);
  });
}