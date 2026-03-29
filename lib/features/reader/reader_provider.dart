import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../data/remote/mangadex_api.dart';

final readerPagesProvider =
FutureProvider.family<List<String>, String>((ref, chapterId) async {
  final api = getIt<MangaDexApi>();
  return api.getPageUrls(chapterId);
});