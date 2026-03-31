import 'package:injectable/injectable.dart';
import '../../core/network/dio_client.dart';
import '../../domain/models/manga.dart';
import '../../domain/models/chapter.dart';

@singleton
class MangaDexApi {
  final DioClient _client;

  MangaDexApi(this._client);

  Future<List<Manga>> searchManga(String query, {int page = 0}) async {
    final response = await _client.dio.get(
      '/manga',
      queryParameters: {
        'title': query,
        'limit': 20,
        'offset': page * 20,
        'includes[]': ['cover_art', 'author'],
        'availableTranslatedLanguage[]': ['en'],
        'order[relevance]': 'desc',
      },
    );

    final data = response.data['data'] as List;
    return data.map((e) => _parseManga(e)).toList();
  }

  Future<List<Manga>> getTrendingManga({int page = 0}) async {
    final response = await _client.dio.get(
      '/manga',
      queryParameters: {
        'limit': 20,
        'offset': page * 20,
        'includes[]': ['cover_art', 'author'],
        'availableTranslatedLanguage[]': ['en'],
        'order[followedCount]': 'desc',
        'status[]': ['ongoing', 'completed'],
      },
    );

    final data = response.data['data'] as List;
    return data.map((e) => _parseManga(e)).toList();
  }

  Future<Manga> getMangaDetail(String mangaId) async {
    final response = await _client.dio.get(
      '/manga/$mangaId',
      queryParameters: {
        'includes[]': ['cover_art', 'author', 'artist'],
      },
    );

    return _parseManga(response.data['data']);
  }

  Future<List<Chapter>> getChapters(
    String mangaId, {
    String language = 'en',
  }) async {
    List<Chapter> allChapters = [];
    int offset = 0;
    const int limit = 96;
    int total = 999;

    while (offset < total) {
      final response = await _client.dio.get(
        '/manga/$mangaId/feed',
        queryParameters: {
          'translatedLanguage[]': [language],
          'limit': limit,
          'offset': offset,
          'order[chapter]': 'asc',
          'includes[]': ['scanlation_group'],
        },
      );

      total = response.data['total'] as int? ?? 0;
      final data = response.data['data'] as List;
      if (data.isEmpty) break;

      allChapters.addAll(data.map((e) => _parseChapter(e, mangaId)));
      offset += limit;
    }

    final seen = <String>{};
    final deduped = <Chapter>[];
    for (final chapter in allChapters) {
      final key = chapter.chapterNumber?.toString() ?? chapter.id;
      if (!seen.contains(key)) {
        seen.add(key);
        deduped.add(chapter);
      }
    }

    return deduped;
  }

  Future<List<String>> getPageUrls(String chapterId) async {
    final response = await _client.dio.get('/at-home/server/$chapterId');

    final baseUrl = response.data['baseUrl'];
    final hash = response.data['chapter']['hash'];
    final pages = response.data['chapter']['data'] as List;

    return pages.map((page) => '$baseUrl/data/$hash/$page').toList();
  }

  Manga _parseManga(Map<String, dynamic> data) {
    final attributes = data['attributes'];
    final relationships = data['relationships'] as List? ?? [];

    String? coverUrl;
    final coverRel = relationships.firstWhere(
      (r) => r['type'] == 'cover_art',
      orElse: () => null,
    );
    if (coverRel != null) {
      final fileName = coverRel['attributes']?['fileName'];
      if (fileName != null) {
        coverUrl =
            'https://uploads.mangadex.org/covers/${data['id']}/$fileName.256.jpg';
      }
    }

    final authors = relationships
        .where((r) => r['type'] == 'author')
        .map<String>((r) => r['attributes']?['name'] ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    final tags = (attributes['tags'] as List? ?? [])
        .map<String>((t) => t['attributes']?['name']?['en'] ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    final statusStr = attributes['status'] as String?;
    MangaStatus? status;
    switch (statusStr) {
      case 'ongoing':
        status = MangaStatus.ongoing;
        break;
      case 'completed':
        status = MangaStatus.completed;
        break;
      case 'hiatus':
        status = MangaStatus.hiatus;
        break;
      case 'cancelled':
        status = MangaStatus.cancelled;
        break;
    }

    return Manga(
      id: data['id'],
      title:
          attributes['title']?['en'] ??
          attributes['title']?.values.first ??
          'Unknown',
      description: attributes['description']?['en'],
      coverUrl: coverUrl,
      tags: tags,
      authors: authors,
      status: status,
    );
  }

  Chapter _parseChapter(Map<String, dynamic> data, String mangaId) {
    final attributes = data['attributes'];
    final relationships = data['relationships'] as List? ?? [];

    final groupRel = relationships.firstWhere(
      (r) => r['type'] == 'scanlation_group',
      orElse: () => null,
    );
    final groupName = groupRel?['attributes']?['name'];

    final chapterStr = attributes['chapter'];
    double? chapterNumber;
    if (chapterStr != null) {
      chapterNumber = double.tryParse(chapterStr.toString());
    }

    final volumeStr = attributes['volume'];
    int? volumeNumber;
    if (volumeStr != null) {
      volumeNumber = int.tryParse(volumeStr.toString());
    }

    return Chapter(
      id: data['id'],
      mangaId: mangaId,
      title: attributes['title'],
      chapterNumber: chapterNumber,
      volumeNumber: volumeNumber,
      language: attributes['translatedLanguage'],
      scanlationGroup: groupName,
      publishedAt: attributes['publishAt'] != null
          ? DateTime.tryParse(attributes['publishAt'])
          : null,
    );
  }
}
