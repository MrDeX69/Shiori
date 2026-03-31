/// Contract for any remote (or local) manga image server. The reader and
/// providers depend only on this — never on a concrete API client.
abstract class BaseSource {
  String get sourceId;

  /// Resolved native chapter id (without `sourceId::` prefix).
  Future<List<String>> getPageUrls(String chapterId);
}

/// Global registry for built-in sources and future extensions.
class SourceRegistry {
  SourceRegistry._();
  static final SourceRegistry instance = SourceRegistry._();

  final Map<String, BaseSource> _sources = {};

  void register(BaseSource source) {
    _sources[source.sourceId] = source;
  }

  BaseSource? get(String sourceId) => _sources[sourceId];

  BaseSource? get first => _sources.isEmpty ? null : _sources.values.first;
}

/// `chapterId` format: `sourceId::nativeId` or legacy plain `nativeId`.
BaseSource? resolveSourceForChapterId(String chapterId) {
  if (chapterId.contains('::')) {
    final sourceId = chapterId.split('::').first;
    return SourceRegistry.instance.get(sourceId);
  }
  return SourceRegistry.instance.first;
}

String nativeChapterId(String chapterId) {
  if (chapterId.contains('::')) {
    return chapterId.split('::').skip(1).join('::');
  }
  return chapterId;
}
