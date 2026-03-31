import 'package:freezed_annotation/freezed_annotation.dart';

part 'manga.freezed.dart';
part 'manga.g.dart';

@freezed
class Manga with _$Manga {
  const factory Manga({
    required String id,
    required String title,
    String? description,
    String? coverUrl,
    @Default([]) List<String> tags,
    @Default([]) List<String> authors,
    MangaStatus? status,
    @Default(0) int chapterCount,
    ReadingStatus? readingStatus,
    int? lastReadChapter,
  }) = _Manga;

  factory Manga.fromJson(Map<String, dynamic> json) => _$MangaFromJson(json);
}

enum MangaStatus { ongoing, completed, hiatus, cancelled }

enum ReadingStatus { reading, planToRead, completed, dropped, onHold }
