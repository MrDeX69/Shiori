import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'app_database.g.dart';

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

@DriftDatabase(tables: [MangaTable, ChapterProgressTable])
@singleton
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(
            chapterProgressTable, chapterProgressTable.mangaTitle);
        await migrator.addColumn(
            chapterProgressTable, chapterProgressTable.mangaCoverUrl);
        await migrator.addColumn(
            chapterProgressTable, chapterProgressTable.chapterNumber);
      }
      if (from < 3) {
        await migrator.addColumn(mangaTable, mangaTable.readingMode);
      }
    },
  );

  Future<List<MangaTableData>> getLibrary() => select(mangaTable).get();

  Future<void> insertManga(MangaTableCompanion manga) =>
      into(mangaTable).insertOnConflictUpdate(manga);

  Future<void> deleteManga(String id) =>
      (delete(mangaTable)..where((t) => t.id.equals(id))).go();

  Future<bool> isMangaInLibrary(String id) async {
    final result =
    await (select(mangaTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return result != null;
  }

  Future<void> saveProgress(ChapterProgressTableCompanion progress) =>
      into(chapterProgressTable).insertOnConflictUpdate(progress);

  Future<ChapterProgressTableData?> getProgress(String chapterId) =>
      (select(chapterProgressTable)
        ..where((t) => t.chapterId.equals(chapterId)))
          .getSingleOrNull();

  Future<ChapterProgressTableData?> getLastReadForManga(
      String mangaId) async {
    // Uzmi sve chapitere za ovu mangu koji imaju bilo kakav progress
    final all = await (select(chapterProgressTable)
      ..where((t) => t.mangaId.equals(mangaId)))
        .get();

    if (all.isEmpty) return null;

    // Prioritet 1: chapteri označeni kao read — uzmi najveći po broju
    final readChapters =
    all.where((r) => r.isRead && r.chapterNumber != null).toList();
    if (readChapters.isNotEmpty) {
      readChapters.sort((a, b) {
        final numA = double.tryParse(a.chapterNumber ?? '') ?? 0;
        final numB = double.tryParse(b.chapterNumber ?? '') ?? 0;
        return numB.compareTo(numA);
      });
      return readChapters.first;
    }

    // Prioritet 2: in-progress (čitanje bez oznake read) — zadnji po readAt
    final inProgress =
    all.where((r) => !r.isRead && r.readAt != null).toList();
    if (inProgress.isNotEmpty) {
      inProgress.sort((a, b) =>
          (b.readAt ?? DateTime(0)).compareTo(a.readAt ?? DateTime(0)));
      return inProgress.first;
    }

    // Prioritet 3: bilo šta što postoji
    return all.first;
  }

  Future<List<ChapterProgressTableData>> getHistory() =>
      (select(chapterProgressTable)
        ..orderBy([(t) => OrderingTerm.desc(t.readAt)])
        ..limit(50))
          .get();

  Future<void> clearHistory() => delete(chapterProgressTable).go();

  Future<String?> getReadingMode(String mangaId) async {
    final result =
    await (select(mangaTable)..where((t) => t.id.equals(mangaId)))
        .getSingleOrNull();
    return result?.readingMode;
  }

  Future<void> saveReadingMode(String mangaId, String mode) async {
    await (update(mangaTable)..where((t) => t.id.equals(mangaId)))
        .write(MangaTableCompanion(readingMode: Value(mode)));
  }

  Future<Set<String>> getReadChapterIds(String mangaId) async {
    final results = await (select(chapterProgressTable)
      ..where(
              (t) => t.mangaId.equals(mangaId) & t.isRead.equals(true)))
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

  Future<String?> getFirstUnreadChapterId(
      String mangaId, List<String> allChapterIds) async {
    final readIds = await getReadChapterIds(mangaId);
    for (final id in allChapterIds) {
      if (!readIds.contains(id)) return id;
    }
    return null;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'shiori.db'));
    return NativeDatabase.createInBackground(file);
  });
}