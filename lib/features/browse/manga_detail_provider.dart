import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../data/local/app_database.dart';
import '../../data/remote/mangadex_api.dart';
import '../../domain/models/chapter.dart';

final chaptersProvider = FutureProvider.family<List<Chapter>, String>((
    ref,
    mangaId,
    ) async {
  final api = getIt<MangaDexApi>();
  final chapters = await api.getChapters(mangaId);

  // ── Populate local chapter index for offline unread counts ────────────────
  // Fire-and-forget — does not block chapter display.
  final db = getIt<AppDatabase>();
  db.storeChapters(
    mangaId,
    chapters
        .map((c) => (id: c.id, number: c.chapterNumber?.toString()))
        .toList(),
  );

  return chapters;
});

final lastReadChapterProvider =
FutureProvider.family<ChapterProgressTableData?, String>((
    ref,
    mangaId,
    ) async {
  final db = getIt<AppDatabase>();
  return db.getLastReadForManga(mangaId);
});

final readChapterIdsProvider = FutureProvider.family<Set<String>, String>((
    ref,
    mangaId,
    ) async {
  final db = getIt<AppDatabase>();
  return db.getReadChapterIds(mangaId);
});