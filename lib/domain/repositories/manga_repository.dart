import '../models/manga.dart';
import '../models/chapter.dart';

abstract class MangaRepository {
  // Search & Browse
  Future<List<Manga>> searchManga(String query, {int page = 0});
  Future<List<Manga>> getTrendingManga({int page = 0});
  Future<List<Manga>> getLatestUpdates({int page = 0});
  Future<Manga> getMangaDetail(String mangaId);

  // Chapters
  Future<List<Chapter>> getChapters(String mangaId, {String language = 'en'});
  Future<List<String>> getPageUrls(String chapterId);

  // Library
  Future<List<Manga>> getLibrary();
  Future<void> addToLibrary(Manga manga);
  Future<void> removeFromLibrary(String mangaId);
  Future<void> updateReadingStatus(String mangaId, ReadingStatus status);

  // Progress
  Future<void> saveReadingProgress(String chapterId, int page);
  Future<int> getReadingProgress(String chapterId);
  Future<List<Chapter>> getReadingHistory();
}