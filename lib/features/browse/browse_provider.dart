import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../data/remote/mangadex_api.dart';
import '../../domain/models/manga.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final trendingMangaProvider = FutureProvider<List<Manga>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final api = getIt<MangaDexApi>();

  if (query.isEmpty) {
    return api.getTrendingManga();
  }

  // Debounce 600ms
  await Future.delayed(const Duration(milliseconds: 600));

  return api.searchManga(query);
});