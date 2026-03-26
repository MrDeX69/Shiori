// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MangaImpl _$$MangaImplFromJson(Map<String, dynamic> json) => _$MangaImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  coverUrl: json['coverUrl'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  authors:
      (json['authors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  status: $enumDecodeNullable(_$MangaStatusEnumMap, json['status']),
  chapterCount: (json['chapterCount'] as num?)?.toInt() ?? 0,
  readingStatus: $enumDecodeNullable(
    _$ReadingStatusEnumMap,
    json['readingStatus'],
  ),
  lastReadChapter: (json['lastReadChapter'] as num?)?.toInt(),
);

Map<String, dynamic> _$$MangaImplToJson(_$MangaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'coverUrl': instance.coverUrl,
      'tags': instance.tags,
      'authors': instance.authors,
      'status': _$MangaStatusEnumMap[instance.status],
      'chapterCount': instance.chapterCount,
      'readingStatus': _$ReadingStatusEnumMap[instance.readingStatus],
      'lastReadChapter': instance.lastReadChapter,
    };

const _$MangaStatusEnumMap = {
  MangaStatus.ongoing: 'ongoing',
  MangaStatus.completed: 'completed',
  MangaStatus.hiatus: 'hiatus',
  MangaStatus.cancelled: 'cancelled',
};

const _$ReadingStatusEnumMap = {
  ReadingStatus.reading: 'reading',
  ReadingStatus.planToRead: 'planToRead',
  ReadingStatus.completed: 'completed',
  ReadingStatus.dropped: 'dropped',
  ReadingStatus.onHold: 'onHold',
};
