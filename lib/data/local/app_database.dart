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

  @override
  Set<Column> get primaryKey => {id};
}

class ChapterProgressTable extends Table {
  TextColumn get chapterId => text()();
  TextColumn get mangaId => text()();
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
  int get schemaVersion => 1;

  // Library queries
  Future<List<MangaTableData>> getLibrary() =>
      select(mangaTable).get();

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

  // Progress queries
  Future<void> saveProgress(ChapterProgressTableCompanion progress) =>
      into(chapterProgressTable).insertOnConflictUpdate(progress);

  Future<ChapterProgressTableData?> getProgress(String chapterId) =>
      (select(chapterProgressTable)
        ..where((t) => t.chapterId.equals(chapterId)))
          .getSingleOrNull();

  Future<List<ChapterProgressTableData>> getHistory() =>
      (select(chapterProgressTable)
        ..orderBy([(t) => OrderingTerm.desc(t.readAt)])
        ..limit(50))
          .get();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'shiori.db'));
    return NativeDatabase.createInBackground(file);
  });
}