// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChapterImpl _$$ChapterImplFromJson(Map<String, dynamic> json) =>
    _$ChapterImpl(
      id: json['id'] as String,
      mangaId: json['mangaId'] as String,
      title: json['title'] as String?,
      chapterNumber: (json['chapterNumber'] as num?)?.toDouble(),
      volumeNumber: (json['volumeNumber'] as num?)?.toInt(),
      pageUrls:
          (json['pageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      scanlationGroup: json['scanlationGroup'] as String?,
      language: json['language'] as String?,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      lastReadPage: (json['lastReadPage'] as num?)?.toInt() ?? 0,
      isRead: json['isRead'] as bool? ?? false,
    );

Map<String, dynamic> _$$ChapterImplToJson(_$ChapterImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mangaId': instance.mangaId,
      'title': instance.title,
      'chapterNumber': instance.chapterNumber,
      'volumeNumber': instance.volumeNumber,
      'pageUrls': instance.pageUrls,
      'scanlationGroup': instance.scanlationGroup,
      'language': instance.language,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'isDownloaded': instance.isDownloaded,
      'lastReadPage': instance.lastReadPage,
      'isRead': instance.isRead,
    };
