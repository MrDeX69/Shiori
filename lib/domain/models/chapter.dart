import 'package:freezed_annotation/freezed_annotation.dart';

part 'chapter.freezed.dart';
part 'chapter.g.dart';

@freezed
class Chapter with _$Chapter {
  const factory Chapter({
    required String id,
    required String mangaId,
    String? title,
    double? chapterNumber,
    int? volumeNumber,
    @Default([]) List<String> pageUrls,
    String? scanlationGroup,
    String? language,
    DateTime? publishedAt,
    @Default(false) bool isDownloaded,
    @Default(0) int lastReadPage,
    @Default(false) bool isRead,
  }) = _Chapter;

  factory Chapter.fromJson(Map<String, dynamic> json) =>
      _$ChapterFromJson(json);
}
