// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MangaTableTable extends MangaTable
    with TableInfo<$MangaTableTable, MangaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _authorsMeta = const VerificationMeta(
    'authors',
  );
  @override
  late final GeneratedColumn<String> authors = GeneratedColumn<String>(
    'authors',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chapterCountMeta = const VerificationMeta(
    'chapterCount',
  );
  @override
  late final GeneratedColumn<int> chapterCount = GeneratedColumn<int>(
    'chapter_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _readingStatusMeta = const VerificationMeta(
    'readingStatus',
  );
  @override
  late final GeneratedColumn<String> readingStatus = GeneratedColumn<String>(
    'reading_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReadChapterMeta = const VerificationMeta(
    'lastReadChapter',
  );
  @override
  late final GeneratedColumn<int> lastReadChapter = GeneratedColumn<int>(
    'last_read_chapter',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    coverUrl,
    tags,
    authors,
    status,
    chapterCount,
    readingStatus,
    lastReadChapter,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manga_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MangaTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('authors')) {
      context.handle(
        _authorsMeta,
        authors.isAcceptableOrUnknown(data['authors']!, _authorsMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('chapter_count')) {
      context.handle(
        _chapterCountMeta,
        chapterCount.isAcceptableOrUnknown(
          data['chapter_count']!,
          _chapterCountMeta,
        ),
      );
    }
    if (data.containsKey('reading_status')) {
      context.handle(
        _readingStatusMeta,
        readingStatus.isAcceptableOrUnknown(
          data['reading_status']!,
          _readingStatusMeta,
        ),
      );
    }
    if (data.containsKey('last_read_chapter')) {
      context.handle(
        _lastReadChapterMeta,
        lastReadChapter.isAcceptableOrUnknown(
          data['last_read_chapter']!,
          _lastReadChapterMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MangaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      authors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authors'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      chapterCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_count'],
      )!,
      readingStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading_status'],
      ),
      lastReadChapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_read_chapter'],
      ),
    );
  }

  @override
  $MangaTableTable createAlias(String alias) {
    return $MangaTableTable(attachedDatabase, alias);
  }
}

class MangaTableData extends DataClass implements Insertable<MangaTableData> {
  final String id;
  final String title;
  final String? description;
  final String? coverUrl;
  final String tags;
  final String authors;
  final String? status;
  final int chapterCount;
  final String? readingStatus;
  final int? lastReadChapter;
  const MangaTableData({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    required this.tags,
    required this.authors,
    this.status,
    required this.chapterCount,
    this.readingStatus,
    this.lastReadChapter,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    map['tags'] = Variable<String>(tags);
    map['authors'] = Variable<String>(authors);
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['chapter_count'] = Variable<int>(chapterCount);
    if (!nullToAbsent || readingStatus != null) {
      map['reading_status'] = Variable<String>(readingStatus);
    }
    if (!nullToAbsent || lastReadChapter != null) {
      map['last_read_chapter'] = Variable<int>(lastReadChapter);
    }
    return map;
  }

  MangaTableCompanion toCompanion(bool nullToAbsent) {
    return MangaTableCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      tags: Value(tags),
      authors: Value(authors),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      chapterCount: Value(chapterCount),
      readingStatus: readingStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(readingStatus),
      lastReadChapter: lastReadChapter == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadChapter),
    );
  }

  factory MangaTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      tags: serializer.fromJson<String>(json['tags']),
      authors: serializer.fromJson<String>(json['authors']),
      status: serializer.fromJson<String?>(json['status']),
      chapterCount: serializer.fromJson<int>(json['chapterCount']),
      readingStatus: serializer.fromJson<String?>(json['readingStatus']),
      lastReadChapter: serializer.fromJson<int?>(json['lastReadChapter']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'tags': serializer.toJson<String>(tags),
      'authors': serializer.toJson<String>(authors),
      'status': serializer.toJson<String?>(status),
      'chapterCount': serializer.toJson<int>(chapterCount),
      'readingStatus': serializer.toJson<String?>(readingStatus),
      'lastReadChapter': serializer.toJson<int?>(lastReadChapter),
    };
  }

  MangaTableData copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> coverUrl = const Value.absent(),
    String? tags,
    String? authors,
    Value<String?> status = const Value.absent(),
    int? chapterCount,
    Value<String?> readingStatus = const Value.absent(),
    Value<int?> lastReadChapter = const Value.absent(),
  }) => MangaTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    tags: tags ?? this.tags,
    authors: authors ?? this.authors,
    status: status.present ? status.value : this.status,
    chapterCount: chapterCount ?? this.chapterCount,
    readingStatus: readingStatus.present
        ? readingStatus.value
        : this.readingStatus,
    lastReadChapter: lastReadChapter.present
        ? lastReadChapter.value
        : this.lastReadChapter,
  );
  MangaTableData copyWithCompanion(MangaTableCompanion data) {
    return MangaTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      tags: data.tags.present ? data.tags.value : this.tags,
      authors: data.authors.present ? data.authors.value : this.authors,
      status: data.status.present ? data.status.value : this.status,
      chapterCount: data.chapterCount.present
          ? data.chapterCount.value
          : this.chapterCount,
      readingStatus: data.readingStatus.present
          ? data.readingStatus.value
          : this.readingStatus,
      lastReadChapter: data.lastReadChapter.present
          ? data.lastReadChapter.value
          : this.lastReadChapter,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('tags: $tags, ')
          ..write('authors: $authors, ')
          ..write('status: $status, ')
          ..write('chapterCount: $chapterCount, ')
          ..write('readingStatus: $readingStatus, ')
          ..write('lastReadChapter: $lastReadChapter')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    coverUrl,
    tags,
    authors,
    status,
    chapterCount,
    readingStatus,
    lastReadChapter,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.coverUrl == this.coverUrl &&
          other.tags == this.tags &&
          other.authors == this.authors &&
          other.status == this.status &&
          other.chapterCount == this.chapterCount &&
          other.readingStatus == this.readingStatus &&
          other.lastReadChapter == this.lastReadChapter);
}

class MangaTableCompanion extends UpdateCompanion<MangaTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> coverUrl;
  final Value<String> tags;
  final Value<String> authors;
  final Value<String?> status;
  final Value<int> chapterCount;
  final Value<String?> readingStatus;
  final Value<int?> lastReadChapter;
  final Value<int> rowid;
  const MangaTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.tags = const Value.absent(),
    this.authors = const Value.absent(),
    this.status = const Value.absent(),
    this.chapterCount = const Value.absent(),
    this.readingStatus = const Value.absent(),
    this.lastReadChapter = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangaTableCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.tags = const Value.absent(),
    this.authors = const Value.absent(),
    this.status = const Value.absent(),
    this.chapterCount = const Value.absent(),
    this.readingStatus = const Value.absent(),
    this.lastReadChapter = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<MangaTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? coverUrl,
    Expression<String>? tags,
    Expression<String>? authors,
    Expression<String>? status,
    Expression<int>? chapterCount,
    Expression<String>? readingStatus,
    Expression<int>? lastReadChapter,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (tags != null) 'tags': tags,
      if (authors != null) 'authors': authors,
      if (status != null) 'status': status,
      if (chapterCount != null) 'chapter_count': chapterCount,
      if (readingStatus != null) 'reading_status': readingStatus,
      if (lastReadChapter != null) 'last_read_chapter': lastReadChapter,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MangaTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? coverUrl,
    Value<String>? tags,
    Value<String>? authors,
    Value<String?>? status,
    Value<int>? chapterCount,
    Value<String?>? readingStatus,
    Value<int?>? lastReadChapter,
    Value<int>? rowid,
  }) {
    return MangaTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      tags: tags ?? this.tags,
      authors: authors ?? this.authors,
      status: status ?? this.status,
      chapterCount: chapterCount ?? this.chapterCount,
      readingStatus: readingStatus ?? this.readingStatus,
      lastReadChapter: lastReadChapter ?? this.lastReadChapter,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (authors.present) {
      map['authors'] = Variable<String>(authors.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (chapterCount.present) {
      map['chapter_count'] = Variable<int>(chapterCount.value);
    }
    if (readingStatus.present) {
      map['reading_status'] = Variable<String>(readingStatus.value);
    }
    if (lastReadChapter.present) {
      map['last_read_chapter'] = Variable<int>(lastReadChapter.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangaTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('tags: $tags, ')
          ..write('authors: $authors, ')
          ..write('status: $status, ')
          ..write('chapterCount: $chapterCount, ')
          ..write('readingStatus: $readingStatus, ')
          ..write('lastReadChapter: $lastReadChapter, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChapterProgressTableTable extends ChapterProgressTable
    with TableInfo<$ChapterProgressTableTable, ChapterProgressTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mangaIdMeta = const VerificationMeta(
    'mangaId',
  );
  @override
  late final GeneratedColumn<String> mangaId = GeneratedColumn<String>(
    'manga_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPageMeta = const VerificationMeta(
    'lastPage',
  );
  @override
  late final GeneratedColumn<int> lastPage = GeneratedColumn<int>(
    'last_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    chapterId,
    mangaId,
    lastPage,
    isRead,
    readAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_progress_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterProgressTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('manga_id')) {
      context.handle(
        _mangaIdMeta,
        mangaId.isAcceptableOrUnknown(data['manga_id']!, _mangaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mangaIdMeta);
    }
    if (data.containsKey('last_page')) {
      context.handle(
        _lastPageMeta,
        lastPage.isAcceptableOrUnknown(data['last_page']!, _lastPageMeta),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chapterId};
  @override
  ChapterProgressTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterProgressTableData(
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      mangaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manga_id'],
      )!,
      lastPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_page'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
    );
  }

  @override
  $ChapterProgressTableTable createAlias(String alias) {
    return $ChapterProgressTableTable(attachedDatabase, alias);
  }
}

class ChapterProgressTableData extends DataClass
    implements Insertable<ChapterProgressTableData> {
  final String chapterId;
  final String mangaId;
  final int lastPage;
  final bool isRead;
  final DateTime? readAt;
  const ChapterProgressTableData({
    required this.chapterId,
    required this.mangaId,
    required this.lastPage,
    required this.isRead,
    this.readAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chapter_id'] = Variable<String>(chapterId);
    map['manga_id'] = Variable<String>(mangaId);
    map['last_page'] = Variable<int>(lastPage);
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    return map;
  }

  ChapterProgressTableCompanion toCompanion(bool nullToAbsent) {
    return ChapterProgressTableCompanion(
      chapterId: Value(chapterId),
      mangaId: Value(mangaId),
      lastPage: Value(lastPage),
      isRead: Value(isRead),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
    );
  }

  factory ChapterProgressTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterProgressTableData(
      chapterId: serializer.fromJson<String>(json['chapterId']),
      mangaId: serializer.fromJson<String>(json['mangaId']),
      lastPage: serializer.fromJson<int>(json['lastPage']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chapterId': serializer.toJson<String>(chapterId),
      'mangaId': serializer.toJson<String>(mangaId),
      'lastPage': serializer.toJson<int>(lastPage),
      'isRead': serializer.toJson<bool>(isRead),
      'readAt': serializer.toJson<DateTime?>(readAt),
    };
  }

  ChapterProgressTableData copyWith({
    String? chapterId,
    String? mangaId,
    int? lastPage,
    bool? isRead,
    Value<DateTime?> readAt = const Value.absent(),
  }) => ChapterProgressTableData(
    chapterId: chapterId ?? this.chapterId,
    mangaId: mangaId ?? this.mangaId,
    lastPage: lastPage ?? this.lastPage,
    isRead: isRead ?? this.isRead,
    readAt: readAt.present ? readAt.value : this.readAt,
  );
  ChapterProgressTableData copyWithCompanion(
    ChapterProgressTableCompanion data,
  ) {
    return ChapterProgressTableData(
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      mangaId: data.mangaId.present ? data.mangaId.value : this.mangaId,
      lastPage: data.lastPage.present ? data.lastPage.value : this.lastPage,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterProgressTableData(')
          ..write('chapterId: $chapterId, ')
          ..write('mangaId: $mangaId, ')
          ..write('lastPage: $lastPage, ')
          ..write('isRead: $isRead, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chapterId, mangaId, lastPage, isRead, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterProgressTableData &&
          other.chapterId == this.chapterId &&
          other.mangaId == this.mangaId &&
          other.lastPage == this.lastPage &&
          other.isRead == this.isRead &&
          other.readAt == this.readAt);
}

class ChapterProgressTableCompanion
    extends UpdateCompanion<ChapterProgressTableData> {
  final Value<String> chapterId;
  final Value<String> mangaId;
  final Value<int> lastPage;
  final Value<bool> isRead;
  final Value<DateTime?> readAt;
  final Value<int> rowid;
  const ChapterProgressTableCompanion({
    this.chapterId = const Value.absent(),
    this.mangaId = const Value.absent(),
    this.lastPage = const Value.absent(),
    this.isRead = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapterProgressTableCompanion.insert({
    required String chapterId,
    required String mangaId,
    this.lastPage = const Value.absent(),
    this.isRead = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : chapterId = Value(chapterId),
       mangaId = Value(mangaId);
  static Insertable<ChapterProgressTableData> custom({
    Expression<String>? chapterId,
    Expression<String>? mangaId,
    Expression<int>? lastPage,
    Expression<bool>? isRead,
    Expression<DateTime>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chapterId != null) 'chapter_id': chapterId,
      if (mangaId != null) 'manga_id': mangaId,
      if (lastPage != null) 'last_page': lastPage,
      if (isRead != null) 'is_read': isRead,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterProgressTableCompanion copyWith({
    Value<String>? chapterId,
    Value<String>? mangaId,
    Value<int>? lastPage,
    Value<bool>? isRead,
    Value<DateTime?>? readAt,
    Value<int>? rowid,
  }) {
    return ChapterProgressTableCompanion(
      chapterId: chapterId ?? this.chapterId,
      mangaId: mangaId ?? this.mangaId,
      lastPage: lastPage ?? this.lastPage,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (mangaId.present) {
      map['manga_id'] = Variable<String>(mangaId.value);
    }
    if (lastPage.present) {
      map['last_page'] = Variable<int>(lastPage.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChapterProgressTableCompanion(')
          ..write('chapterId: $chapterId, ')
          ..write('mangaId: $mangaId, ')
          ..write('lastPage: $lastPage, ')
          ..write('isRead: $isRead, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MangaTableTable mangaTable = $MangaTableTable(this);
  late final $ChapterProgressTableTable chapterProgressTable =
      $ChapterProgressTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    mangaTable,
    chapterProgressTable,
  ];
}

typedef $$MangaTableTableCreateCompanionBuilder =
    MangaTableCompanion Function({
      required String id,
      required String title,
      Value<String?> description,
      Value<String?> coverUrl,
      Value<String> tags,
      Value<String> authors,
      Value<String?> status,
      Value<int> chapterCount,
      Value<String?> readingStatus,
      Value<int?> lastReadChapter,
      Value<int> rowid,
    });
typedef $$MangaTableTableUpdateCompanionBuilder =
    MangaTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<String?> coverUrl,
      Value<String> tags,
      Value<String> authors,
      Value<String?> status,
      Value<int> chapterCount,
      Value<String?> readingStatus,
      Value<int?> lastReadChapter,
      Value<int> rowid,
    });

class $$MangaTableTableFilterComposer
    extends Composer<_$AppDatabase, $MangaTableTable> {
  $$MangaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterCount => $composableBuilder(
    column: $table.chapterCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readingStatus => $composableBuilder(
    column: $table.readingStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastReadChapter => $composableBuilder(
    column: $table.lastReadChapter,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MangaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MangaTableTable> {
  $$MangaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterCount => $composableBuilder(
    column: $table.chapterCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readingStatus => $composableBuilder(
    column: $table.readingStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastReadChapter => $composableBuilder(
    column: $table.lastReadChapter,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MangaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MangaTableTable> {
  $$MangaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get authors =>
      $composableBuilder(column: $table.authors, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get chapterCount => $composableBuilder(
    column: $table.chapterCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get readingStatus => $composableBuilder(
    column: $table.readingStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastReadChapter => $composableBuilder(
    column: $table.lastReadChapter,
    builder: (column) => column,
  );
}

class $$MangaTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MangaTableTable,
          MangaTableData,
          $$MangaTableTableFilterComposer,
          $$MangaTableTableOrderingComposer,
          $$MangaTableTableAnnotationComposer,
          $$MangaTableTableCreateCompanionBuilder,
          $$MangaTableTableUpdateCompanionBuilder,
          (
            MangaTableData,
            BaseReferences<_$AppDatabase, $MangaTableTable, MangaTableData>,
          ),
          MangaTableData,
          PrefetchHooks Function()
        > {
  $$MangaTableTableTableManager(_$AppDatabase db, $MangaTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MangaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MangaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MangaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> authors = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int> chapterCount = const Value.absent(),
                Value<String?> readingStatus = const Value.absent(),
                Value<int?> lastReadChapter = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MangaTableCompanion(
                id: id,
                title: title,
                description: description,
                coverUrl: coverUrl,
                tags: tags,
                authors: authors,
                status: status,
                chapterCount: chapterCount,
                readingStatus: readingStatus,
                lastReadChapter: lastReadChapter,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> authors = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int> chapterCount = const Value.absent(),
                Value<String?> readingStatus = const Value.absent(),
                Value<int?> lastReadChapter = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MangaTableCompanion.insert(
                id: id,
                title: title,
                description: description,
                coverUrl: coverUrl,
                tags: tags,
                authors: authors,
                status: status,
                chapterCount: chapterCount,
                readingStatus: readingStatus,
                lastReadChapter: lastReadChapter,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MangaTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MangaTableTable,
      MangaTableData,
      $$MangaTableTableFilterComposer,
      $$MangaTableTableOrderingComposer,
      $$MangaTableTableAnnotationComposer,
      $$MangaTableTableCreateCompanionBuilder,
      $$MangaTableTableUpdateCompanionBuilder,
      (
        MangaTableData,
        BaseReferences<_$AppDatabase, $MangaTableTable, MangaTableData>,
      ),
      MangaTableData,
      PrefetchHooks Function()
    >;
typedef $$ChapterProgressTableTableCreateCompanionBuilder =
    ChapterProgressTableCompanion Function({
      required String chapterId,
      required String mangaId,
      Value<int> lastPage,
      Value<bool> isRead,
      Value<DateTime?> readAt,
      Value<int> rowid,
    });
typedef $$ChapterProgressTableTableUpdateCompanionBuilder =
    ChapterProgressTableCompanion Function({
      Value<String> chapterId,
      Value<String> mangaId,
      Value<int> lastPage,
      Value<bool> isRead,
      Value<DateTime?> readAt,
      Value<int> rowid,
    });

class $$ChapterProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $ChapterProgressTableTable> {
  $$ChapterProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mangaId => $composableBuilder(
    column: $table.mangaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPage => $composableBuilder(
    column: $table.lastPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChapterProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ChapterProgressTableTable> {
  $$ChapterProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mangaId => $composableBuilder(
    column: $table.mangaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPage => $composableBuilder(
    column: $table.lastPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChapterProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChapterProgressTableTable> {
  $$ChapterProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get mangaId =>
      $composableBuilder(column: $table.mangaId, builder: (column) => column);

  GeneratedColumn<int> get lastPage =>
      $composableBuilder(column: $table.lastPage, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);
}

class $$ChapterProgressTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChapterProgressTableTable,
          ChapterProgressTableData,
          $$ChapterProgressTableTableFilterComposer,
          $$ChapterProgressTableTableOrderingComposer,
          $$ChapterProgressTableTableAnnotationComposer,
          $$ChapterProgressTableTableCreateCompanionBuilder,
          $$ChapterProgressTableTableUpdateCompanionBuilder,
          (
            ChapterProgressTableData,
            BaseReferences<
              _$AppDatabase,
              $ChapterProgressTableTable,
              ChapterProgressTableData
            >,
          ),
          ChapterProgressTableData,
          PrefetchHooks Function()
        > {
  $$ChapterProgressTableTableTableManager(
    _$AppDatabase db,
    $ChapterProgressTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterProgressTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChapterProgressTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ChapterProgressTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> chapterId = const Value.absent(),
                Value<String> mangaId = const Value.absent(),
                Value<int> lastPage = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterProgressTableCompanion(
                chapterId: chapterId,
                mangaId: mangaId,
                lastPage: lastPage,
                isRead: isRead,
                readAt: readAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chapterId,
                required String mangaId,
                Value<int> lastPage = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterProgressTableCompanion.insert(
                chapterId: chapterId,
                mangaId: mangaId,
                lastPage: lastPage,
                isRead: isRead,
                readAt: readAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChapterProgressTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChapterProgressTableTable,
      ChapterProgressTableData,
      $$ChapterProgressTableTableFilterComposer,
      $$ChapterProgressTableTableOrderingComposer,
      $$ChapterProgressTableTableAnnotationComposer,
      $$ChapterProgressTableTableCreateCompanionBuilder,
      $$ChapterProgressTableTableUpdateCompanionBuilder,
      (
        ChapterProgressTableData,
        BaseReferences<
          _$AppDatabase,
          $ChapterProgressTableTable,
          ChapterProgressTableData
        >,
      ),
      ChapterProgressTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MangaTableTableTableManager get mangaTable =>
      $$MangaTableTableTableManager(_db, _db.mangaTable);
  $$ChapterProgressTableTableTableManager get chapterProgressTable =>
      $$ChapterProgressTableTableTableManager(_db, _db.chapterProgressTable);
}
