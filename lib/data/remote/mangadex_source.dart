import '../../core/di/injection.dart';
import '../../domain/sources/base_source.dart';
import 'mangadex_api.dart';

/// MangaDex implementation of [BaseSource]. Network I/O stays in [MangaDexApi].
class MangaDexSource implements BaseSource {
  MangaDexSource._();
  static final MangaDexSource instance = MangaDexSource._();

  @override
  String get sourceId => 'mangadex';

  @override
  Future<List<String>> getPageUrls(String chapterId) {
    return getIt<MangaDexApi>().getPageUrls(chapterId);
  }
}
