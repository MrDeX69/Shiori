import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../data/local/app_database.dart';
import '../../data/remote/mangadex_api.dart';

final readerPagesProvider =
FutureProvider.family<List<String>, String>((ref, chapterId) async {
  final api = getIt<MangaDexApi>();
  return api.getPageUrls(chapterId);
});

Future<void> saveProgress(
    String chapterId, String mangaId, int page) async {
  final db = getIt<AppDatabase>();
  await db.saveProgress(
    ChapterProgressTableCompanion(
      chapterId: Value(chapterId),
      mangaId: Value(mangaId),
      lastPage: Value(page),
      isRead: Value(false),
      readAt: Value(DateTime.now()),
    ),
  );
}