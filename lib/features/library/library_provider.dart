import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../core/di/injection.dart';
import '../../data/local/app_database.dart';
import '../../domain/models/manga.dart';

// ── Library stream ────────────────────────────────────────────────────────────

final libraryProvider = StreamProvider<List<Manga>>((ref) {
  final db = getIt<AppDatabase>();
  return db
      .select(db.mangaTable)
      .watch()
      .map((rows) => rows.map(_rowToManga).toList());
});

// ── Library checks ────────────────────────────────────────────────────────────

final isMangaInLibraryProvider = FutureProvider.family<bool, String>((
    ref,
    mangaId,
    ) async {
  final db = getIt<AppDatabase>();
  return db.isMangaInLibrary(mangaId);
});

// ── Unread count provider ─────────────────────────────────────────────────────
// Returns the number of chapters that are NOT yet read for a given manga.
// Uses only local DB — no network call.
// Invalidated automatically when `chaptersProvider` or markChapterRead fires.
final unreadCountProvider = FutureProvider.family<int, String>((
    ref,
    mangaId,
    ) async {
  final db = getIt<AppDatabase>();
  // Total chapters stored locally from last fetch
  final totalStored = await db.getStoredChapterCount(mangaId);
  // Chapters marked read
  final readIds = await db.getReadChapterIds(mangaId);
  // Unread = total - read (floor at 0)
  return (totalStored - readIds.length).clamp(0, totalStored);
});

// ── Mutations ─────────────────────────────────────────────────────────────────

Future<void> addToLibrary(Manga manga) async {
  final db = getIt<AppDatabase>();
  await db.insertManga(
    MangaTableCompanion(
      id: Value(manga.id),
      title: Value(manga.title),
      description: Value(manga.description),
      coverUrl: Value(manga.coverUrl),
      tags: Value(jsonEncode(manga.tags)),
      authors: Value(jsonEncode(manga.authors)),
      status: Value(manga.status?.name),
    ),
  );
}

Future<void> removeFromLibrary(String mangaId) async {
  final db = getIt<AppDatabase>();
  await db.deleteManga(mangaId);
}

Future<void> saveProgress(
    String chapterId,
    String mangaId,
    int page, {
      required String mangaTitle,
      String? mangaCoverUrl,
      String? chapterNumber,
      required bool incognitoEnabled,
    }) async {
  if (incognitoEnabled) return;
  final db = getIt<AppDatabase>();
  await db.saveProgress(
    ChapterProgressTableCompanion(
      chapterId: Value(chapterId),
      mangaId: Value(mangaId),
      mangaTitle: Value(mangaTitle),
      mangaCoverUrl: Value(mangaCoverUrl),
      chapterNumber: Value(chapterNumber),
      lastPage: Value(page),
      readAt: Value(DateTime.now()),
    ),
  );
}

Future<void> markChapterAsRead(
    String chapterId,
    String mangaId,
    String mangaTitle,
    String? mangaCoverUrl,
    String? chapterNumber,
    ) async {
  final db = getIt<AppDatabase>();
  await db.markChapterRead(
    chapterId,
    mangaId,
    mangaTitle,
    mangaCoverUrl,
    chapterNumber,
    true,
  );
}

// ── Row mapper ────────────────────────────────────────────────────────────────

Manga _rowToManga(MangaTableData row) {
  List<String> tags = [];
  List<String> authors = [];
  try {
    tags = List<String>.from(jsonDecode(row.tags));
    authors = List<String>.from(jsonDecode(row.authors));
  } catch (_) {}

  MangaStatus? status;
  if (row.status != null) {
    status = MangaStatus.values.firstWhere(
          (e) => e.name == row.status,
      orElse: () => MangaStatus.ongoing,
    );
  }

  return Manga(
    id: row.id,
    title: row.title,
    description: row.description,
    coverUrl: row.coverUrl,
    tags: tags,
    authors: authors,
    status: status,
  );
}