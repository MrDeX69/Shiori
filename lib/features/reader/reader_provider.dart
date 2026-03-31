import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../data/local/app_database.dart';
import '../../domain/sources/base_source.dart';

// ── Page URL provider (uses registered [BaseSource] only) ────────────────────
final readerPagesProvider = FutureProvider.family<List<String>, String>((
  ref,
  chapterId,
) async {
  final source = resolveSourceForChapterId(chapterId);
  if (source == null) {
    throw StateError(
      'No BaseSource registered for chapter "$chapterId". '
      'Register a source before opening the reader.',
    );
  }
  final nativeId = nativeChapterId(chapterId);
  return source.getPageUrls(nativeId);
});

// ── Preload next chapter page list (Riverpod cache → instant append) ─────────
final preloadChapterProvider = FutureProvider.family<List<String>, String>((
  ref,
  chapterId,
) async {
  final source = resolveSourceForChapterId(chapterId);
  if (source == null) return [];
  final nativeId = nativeChapterId(chapterId);
  try {
    return await source.getPageUrls(nativeId);
  } catch (_) {
    return [];
  }
});

// ── Reading progress helpers ─────────────────────────────────────────────────
final readerProgressProvider = FutureProvider.family<int, String>((
  ref,
  chapterId,
) async {
  final db = getIt<AppDatabase>();
  final progress = await db.getProgress(chapterId);
  return progress?.lastPage ?? 0;
});
