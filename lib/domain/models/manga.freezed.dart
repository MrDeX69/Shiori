// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manga.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Manga _$MangaFromJson(Map<String, dynamic> json) {
  return _Manga.fromJson(json);
}

/// @nodoc
mixin _$Manga {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get coverUrl => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  List<String> get authors => throw _privateConstructorUsedError;
  MangaStatus? get status => throw _privateConstructorUsedError;
  int get chapterCount => throw _privateConstructorUsedError;
  ReadingStatus? get readingStatus => throw _privateConstructorUsedError;
  int? get lastReadChapter => throw _privateConstructorUsedError;

  /// Serializes this Manga to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MangaCopyWith<Manga> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MangaCopyWith<$Res> {
  factory $MangaCopyWith(Manga value, $Res Function(Manga) then) =
      _$MangaCopyWithImpl<$Res, Manga>;
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String? coverUrl,
    List<String> tags,
    List<String> authors,
    MangaStatus? status,
    int chapterCount,
    ReadingStatus? readingStatus,
    int? lastReadChapter,
  });
}

/// @nodoc
class _$MangaCopyWithImpl<$Res, $Val extends Manga>
    implements $MangaCopyWith<$Res> {
  _$MangaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? coverUrl = freezed,
    Object? tags = null,
    Object? authors = null,
    Object? status = freezed,
    Object? chapterCount = null,
    Object? readingStatus = freezed,
    Object? lastReadChapter = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            coverUrl: freezed == coverUrl
                ? _value.coverUrl
                : coverUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            authors: null == authors
                ? _value.authors
                : authors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MangaStatus?,
            chapterCount: null == chapterCount
                ? _value.chapterCount
                : chapterCount // ignore: cast_nullable_to_non_nullable
                      as int,
            readingStatus: freezed == readingStatus
                ? _value.readingStatus
                : readingStatus // ignore: cast_nullable_to_non_nullable
                      as ReadingStatus?,
            lastReadChapter: freezed == lastReadChapter
                ? _value.lastReadChapter
                : lastReadChapter // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MangaImplCopyWith<$Res> implements $MangaCopyWith<$Res> {
  factory _$$MangaImplCopyWith(
    _$MangaImpl value,
    $Res Function(_$MangaImpl) then,
  ) = __$$MangaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String? coverUrl,
    List<String> tags,
    List<String> authors,
    MangaStatus? status,
    int chapterCount,
    ReadingStatus? readingStatus,
    int? lastReadChapter,
  });
}

/// @nodoc
class __$$MangaImplCopyWithImpl<$Res>
    extends _$MangaCopyWithImpl<$Res, _$MangaImpl>
    implements _$$MangaImplCopyWith<$Res> {
  __$$MangaImplCopyWithImpl(
    _$MangaImpl _value,
    $Res Function(_$MangaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? coverUrl = freezed,
    Object? tags = null,
    Object? authors = null,
    Object? status = freezed,
    Object? chapterCount = null,
    Object? readingStatus = freezed,
    Object? lastReadChapter = freezed,
  }) {
    return _then(
      _$MangaImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        coverUrl: freezed == coverUrl
            ? _value.coverUrl
            : coverUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        authors: null == authors
            ? _value._authors
            : authors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MangaStatus?,
        chapterCount: null == chapterCount
            ? _value.chapterCount
            : chapterCount // ignore: cast_nullable_to_non_nullable
                  as int,
        readingStatus: freezed == readingStatus
            ? _value.readingStatus
            : readingStatus // ignore: cast_nullable_to_non_nullable
                  as ReadingStatus?,
        lastReadChapter: freezed == lastReadChapter
            ? _value.lastReadChapter
            : lastReadChapter // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MangaImpl implements _Manga {
  const _$MangaImpl({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    final List<String> tags = const [],
    final List<String> authors = const [],
    this.status,
    this.chapterCount = 0,
    this.readingStatus,
    this.lastReadChapter,
  }) : _tags = tags,
       _authors = authors;

  factory _$MangaImpl.fromJson(Map<String, dynamic> json) =>
      _$$MangaImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? coverUrl;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<String> _authors;
  @override
  @JsonKey()
  List<String> get authors {
    if (_authors is EqualUnmodifiableListView) return _authors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_authors);
  }

  @override
  final MangaStatus? status;
  @override
  @JsonKey()
  final int chapterCount;
  @override
  final ReadingStatus? readingStatus;
  @override
  final int? lastReadChapter;

  @override
  String toString() {
    return 'Manga(id: $id, title: $title, description: $description, coverUrl: $coverUrl, tags: $tags, authors: $authors, status: $status, chapterCount: $chapterCount, readingStatus: $readingStatus, lastReadChapter: $lastReadChapter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MangaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(other._authors, _authors) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.chapterCount, chapterCount) ||
                other.chapterCount == chapterCount) &&
            (identical(other.readingStatus, readingStatus) ||
                other.readingStatus == readingStatus) &&
            (identical(other.lastReadChapter, lastReadChapter) ||
                other.lastReadChapter == lastReadChapter));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    coverUrl,
    const DeepCollectionEquality().hash(_tags),
    const DeepCollectionEquality().hash(_authors),
    status,
    chapterCount,
    readingStatus,
    lastReadChapter,
  );

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MangaImplCopyWith<_$MangaImpl> get copyWith =>
      __$$MangaImplCopyWithImpl<_$MangaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MangaImplToJson(this);
  }
}

abstract class _Manga implements Manga {
  const factory _Manga({
    required final String id,
    required final String title,
    final String? description,
    final String? coverUrl,
    final List<String> tags,
    final List<String> authors,
    final MangaStatus? status,
    final int chapterCount,
    final ReadingStatus? readingStatus,
    final int? lastReadChapter,
  }) = _$MangaImpl;

  factory _Manga.fromJson(Map<String, dynamic> json) = _$MangaImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  String? get coverUrl;
  @override
  List<String> get tags;
  @override
  List<String> get authors;
  @override
  MangaStatus? get status;
  @override
  int get chapterCount;
  @override
  ReadingStatus? get readingStatus;
  @override
  int? get lastReadChapter;

  /// Create a copy of Manga
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MangaImplCopyWith<_$MangaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
