// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chapter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Chapter _$ChapterFromJson(Map<String, dynamic> json) {
  return _Chapter.fromJson(json);
}

/// @nodoc
mixin _$Chapter {
  String get id => throw _privateConstructorUsedError;
  String get mangaId => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  double? get chapterNumber => throw _privateConstructorUsedError;
  int? get volumeNumber => throw _privateConstructorUsedError;
  List<String> get pageUrls => throw _privateConstructorUsedError;
  String? get scanlationGroup => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  DateTime? get publishedAt => throw _privateConstructorUsedError;
  bool get isDownloaded => throw _privateConstructorUsedError;
  int get lastReadPage => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;

  /// Serializes this Chapter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Chapter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChapterCopyWith<Chapter> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChapterCopyWith<$Res> {
  factory $ChapterCopyWith(Chapter value, $Res Function(Chapter) then) =
      _$ChapterCopyWithImpl<$Res, Chapter>;
  @useResult
  $Res call({
    String id,
    String mangaId,
    String? title,
    double? chapterNumber,
    int? volumeNumber,
    List<String> pageUrls,
    String? scanlationGroup,
    String? language,
    DateTime? publishedAt,
    bool isDownloaded,
    int lastReadPage,
    bool isRead,
  });
}

/// @nodoc
class _$ChapterCopyWithImpl<$Res, $Val extends Chapter>
    implements $ChapterCopyWith<$Res> {
  _$ChapterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Chapter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mangaId = null,
    Object? title = freezed,
    Object? chapterNumber = freezed,
    Object? volumeNumber = freezed,
    Object? pageUrls = null,
    Object? scanlationGroup = freezed,
    Object? language = freezed,
    Object? publishedAt = freezed,
    Object? isDownloaded = null,
    Object? lastReadPage = null,
    Object? isRead = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            mangaId: null == mangaId
                ? _value.mangaId
                : mangaId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            chapterNumber: freezed == chapterNumber
                ? _value.chapterNumber
                : chapterNumber // ignore: cast_nullable_to_non_nullable
                      as double?,
            volumeNumber: freezed == volumeNumber
                ? _value.volumeNumber
                : volumeNumber // ignore: cast_nullable_to_non_nullable
                      as int?,
            pageUrls: null == pageUrls
                ? _value.pageUrls
                : pageUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            scanlationGroup: freezed == scanlationGroup
                ? _value.scanlationGroup
                : scanlationGroup // ignore: cast_nullable_to_non_nullable
                      as String?,
            language: freezed == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String?,
            publishedAt: freezed == publishedAt
                ? _value.publishedAt
                : publishedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isDownloaded: null == isDownloaded
                ? _value.isDownloaded
                : isDownloaded // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastReadPage: null == lastReadPage
                ? _value.lastReadPage
                : lastReadPage // ignore: cast_nullable_to_non_nullable
                      as int,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChapterImplCopyWith<$Res> implements $ChapterCopyWith<$Res> {
  factory _$$ChapterImplCopyWith(
    _$ChapterImpl value,
    $Res Function(_$ChapterImpl) then,
  ) = __$$ChapterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String mangaId,
    String? title,
    double? chapterNumber,
    int? volumeNumber,
    List<String> pageUrls,
    String? scanlationGroup,
    String? language,
    DateTime? publishedAt,
    bool isDownloaded,
    int lastReadPage,
    bool isRead,
  });
}

/// @nodoc
class __$$ChapterImplCopyWithImpl<$Res>
    extends _$ChapterCopyWithImpl<$Res, _$ChapterImpl>
    implements _$$ChapterImplCopyWith<$Res> {
  __$$ChapterImplCopyWithImpl(
    _$ChapterImpl _value,
    $Res Function(_$ChapterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Chapter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mangaId = null,
    Object? title = freezed,
    Object? chapterNumber = freezed,
    Object? volumeNumber = freezed,
    Object? pageUrls = null,
    Object? scanlationGroup = freezed,
    Object? language = freezed,
    Object? publishedAt = freezed,
    Object? isDownloaded = null,
    Object? lastReadPage = null,
    Object? isRead = null,
  }) {
    return _then(
      _$ChapterImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        mangaId: null == mangaId
            ? _value.mangaId
            : mangaId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        chapterNumber: freezed == chapterNumber
            ? _value.chapterNumber
            : chapterNumber // ignore: cast_nullable_to_non_nullable
                  as double?,
        volumeNumber: freezed == volumeNumber
            ? _value.volumeNumber
            : volumeNumber // ignore: cast_nullable_to_non_nullable
                  as int?,
        pageUrls: null == pageUrls
            ? _value._pageUrls
            : pageUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        scanlationGroup: freezed == scanlationGroup
            ? _value.scanlationGroup
            : scanlationGroup // ignore: cast_nullable_to_non_nullable
                  as String?,
        language: freezed == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String?,
        publishedAt: freezed == publishedAt
            ? _value.publishedAt
            : publishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isDownloaded: null == isDownloaded
            ? _value.isDownloaded
            : isDownloaded // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastReadPage: null == lastReadPage
            ? _value.lastReadPage
            : lastReadPage // ignore: cast_nullable_to_non_nullable
                  as int,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChapterImpl implements _Chapter {
  const _$ChapterImpl({
    required this.id,
    required this.mangaId,
    this.title,
    this.chapterNumber,
    this.volumeNumber,
    final List<String> pageUrls = const [],
    this.scanlationGroup,
    this.language,
    this.publishedAt,
    this.isDownloaded = false,
    this.lastReadPage = 0,
    this.isRead = false,
  }) : _pageUrls = pageUrls;

  factory _$ChapterImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChapterImplFromJson(json);

  @override
  final String id;
  @override
  final String mangaId;
  @override
  final String? title;
  @override
  final double? chapterNumber;
  @override
  final int? volumeNumber;
  final List<String> _pageUrls;
  @override
  @JsonKey()
  List<String> get pageUrls {
    if (_pageUrls is EqualUnmodifiableListView) return _pageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pageUrls);
  }

  @override
  final String? scanlationGroup;
  @override
  final String? language;
  @override
  final DateTime? publishedAt;
  @override
  @JsonKey()
  final bool isDownloaded;
  @override
  @JsonKey()
  final int lastReadPage;
  @override
  @JsonKey()
  final bool isRead;

  @override
  String toString() {
    return 'Chapter(id: $id, mangaId: $mangaId, title: $title, chapterNumber: $chapterNumber, volumeNumber: $volumeNumber, pageUrls: $pageUrls, scanlationGroup: $scanlationGroup, language: $language, publishedAt: $publishedAt, isDownloaded: $isDownloaded, lastReadPage: $lastReadPage, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChapterImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mangaId, mangaId) || other.mangaId == mangaId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.chapterNumber, chapterNumber) ||
                other.chapterNumber == chapterNumber) &&
            (identical(other.volumeNumber, volumeNumber) ||
                other.volumeNumber == volumeNumber) &&
            const DeepCollectionEquality().equals(other._pageUrls, _pageUrls) &&
            (identical(other.scanlationGroup, scanlationGroup) ||
                other.scanlationGroup == scanlationGroup) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.isDownloaded, isDownloaded) ||
                other.isDownloaded == isDownloaded) &&
            (identical(other.lastReadPage, lastReadPage) ||
                other.lastReadPage == lastReadPage) &&
            (identical(other.isRead, isRead) || other.isRead == isRead));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    mangaId,
    title,
    chapterNumber,
    volumeNumber,
    const DeepCollectionEquality().hash(_pageUrls),
    scanlationGroup,
    language,
    publishedAt,
    isDownloaded,
    lastReadPage,
    isRead,
  );

  /// Create a copy of Chapter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChapterImplCopyWith<_$ChapterImpl> get copyWith =>
      __$$ChapterImplCopyWithImpl<_$ChapterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChapterImplToJson(this);
  }
}

abstract class _Chapter implements Chapter {
  const factory _Chapter({
    required final String id,
    required final String mangaId,
    final String? title,
    final double? chapterNumber,
    final int? volumeNumber,
    final List<String> pageUrls,
    final String? scanlationGroup,
    final String? language,
    final DateTime? publishedAt,
    final bool isDownloaded,
    final int lastReadPage,
    final bool isRead,
  }) = _$ChapterImpl;

  factory _Chapter.fromJson(Map<String, dynamic> json) = _$ChapterImpl.fromJson;

  @override
  String get id;
  @override
  String get mangaId;
  @override
  String? get title;
  @override
  double? get chapterNumber;
  @override
  int? get volumeNumber;
  @override
  List<String> get pageUrls;
  @override
  String? get scanlationGroup;
  @override
  String? get language;
  @override
  DateTime? get publishedAt;
  @override
  bool get isDownloaded;
  @override
  int get lastReadPage;
  @override
  bool get isRead;

  /// Create a copy of Chapter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChapterImplCopyWith<_$ChapterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
