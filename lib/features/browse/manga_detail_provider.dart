import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../data/remote/mangadex_api.dart';
import '../../domain/models/chapter.dart';

final chaptersProvider =
FutureProvider.family<List<Chapter>, String>((ref, mangaId) async {
  final api = getIt<MangaDexApi>();
  return api.getChapters(mangaId);
});