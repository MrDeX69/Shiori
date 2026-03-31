import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../domain/models/manga.dart';
import '../library/library_provider.dart';
import 'manga_detail_provider.dart';

class MangaDetailScreen extends ConsumerStatefulWidget {
  final Manga manga;
  const MangaDetailScreen({super.key, required this.manga});

  @override
  ConsumerState<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends ConsumerState<MangaDetailScreen>
    with RouteAware {
  Color _dominantColor = const Color(0xFF0A0A0F);
  bool _descriptionExpanded = false;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};
  int _lastSelectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _extractColor();
  }

  @override
  void didPopNext() {
    ref.invalidate(lastReadChapterProvider(widget.manga.id));
    ref.invalidate(readChapterIdsProvider(widget.manga.id));
  }

  Future<void> _extractColor() async {
    if (widget.manga.coverUrl == null) return;
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(widget.manga.coverUrl!),
        size: const Size(100, 150),
      );
      final color =
          palette.dominantColor?.color ??
          palette.vibrantColor?.color ??
          const Color(0xFF0A0A0F);
      if (mounted) {
        setState(() => _dominantColor = color.withValues(alpha: 0.6));
      }
    } catch (_) {}
  }

  void _enterSelectionMode(int index, String chapterId) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectionMode = true;
      _selectedIds.add(chapterId);
      _lastSelectedIndex = index;
    });
  }

  void _exitSelectionMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
      _lastSelectedIndex = -1;
    });
  }

  void _toggleSelection(int index, String chapterId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedIds.contains(chapterId)) {
        _selectedIds.remove(chapterId);
        if (_selectedIds.isEmpty) {
          _selectionMode = false;
          _lastSelectedIndex = -1;
        }
      } else {
        _selectedIds.add(chapterId);
        _lastSelectedIndex = index;
      }
    });
  }

  void _rangeSelect(int index, List chapters) {
    HapticFeedback.mediumImpact();
    if (_lastSelectedIndex == -1) {
      _toggleSelection(index, chapters[index].id);
      return;
    }
    final start = _lastSelectedIndex < index ? _lastSelectedIndex : index;
    final end = _lastSelectedIndex < index ? index : _lastSelectedIndex;
    setState(() {
      for (int i = start; i <= end; i++) {
        _selectedIds.add(chapters[i].id);
      }
      _lastSelectedIndex = index;
    });
  }

  void _selectAll(List chapters) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_selectedIds.length == chapters.length) {
        _selectedIds.clear();
        _selectionMode = false;
        _lastSelectedIndex = -1;
      } else {
        _selectedIds.addAll(chapters.map((c) => c.id as String));
        _lastSelectedIndex = chapters.length - 1;
      }
    });
  }

  void _showSelectCountDialog(BuildContext context, List chapters) {
    final controller = TextEditingController(
      text: _selectedIds.length.toString(),
    );
    final accent = ref.read(accentColorProvider);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C28),
        title: const Text(
          'Select chapters',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter number of chapters to select (1 - ${chapters.length})',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Number of chapters',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF0A0A0F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              final count = int.tryParse(controller.text) ?? 0;
              if (count > 0 && count <= chapters.length) {
                HapticFeedback.mediumImpact();
                setState(() {
                  _selectedIds.clear();
                  for (int i = 0; i < count; i++) {
                    _selectedIds.add(chapters[i].id as String);
                  }
                  _lastSelectedIndex = count - 1;
                });
              }
              Navigator.pop(dialogContext);
            },
            child: Text(
              'Select',
              style: TextStyle(color: accent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markSelectedAs(bool isRead, List chapters) async {
    HapticFeedback.lightImpact();
    final db = getIt<AppDatabase>();
    for (final chapterId in List<String>.from(_selectedIds)) {
      final idx = chapters.indexWhere((c) => c.id == chapterId);
      if (idx == -1) continue;
      final chapter = chapters[idx];
      await db.markChapterRead(
        chapterId,
        widget.manga.id,
        widget.manga.title,
        widget.manga.coverUrl,
        chapter.chapterNumber?.toString(),
        isRead,
      );
    }
    ref.invalidate(readChapterIdsProvider(widget.manga.id));
    ref.invalidate(lastReadChapterProvider(widget.manga.id));
    _exitSelectionMode();
  }

  String _formatChapterNumber(String? number) {
    if (number == null || number.isEmpty) return '';
    final d = double.tryParse(number);
    if (d == null) return number;
    if (d == d.truncateToDouble()) return d.toInt().toString();
    return number;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(chaptersProvider(widget.manga.id));
    final lastReadAsync = ref.watch(lastReadChapterProvider(widget.manga.id));
    final readIdsAsync = ref.watch(readChapterIdsProvider(widget.manga.id));
    final accent = ref.watch(accentColorProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0A0A0F) : cs.surface;
    final gradientEnd = isDark ? const Color(0xFF0A0A0F) : cs.surface;
    final titleColor = isDark ? Colors.white : cs.onSurface;
    final subtitleColor = isDark
        ? Colors.white54
        : cs.onSurface.withValues(alpha: 0.54);
    final descColor = isDark
        ? Colors.white60
        : cs.onSurface.withValues(alpha: 0.6);
    final tagBgColor = isDark
        ? const Color(0xFF1C1C28)
        : cs.surfaceContainerHighest;
    final tagTextColor = isDark
        ? Colors.white70
        : cs.onSurface.withValues(alpha: 0.7);
    final chapterSubtitleColor = isDark
        ? Colors.white38
        : cs.onSurface.withValues(alpha: 0.38);

    return PopScope(
      canPop: !_selectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectionMode) _exitSelectionMode();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_dominantColor, gradientEnd],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: _selectionMode ? 0 : 300,
                  pinned: true,
                  backgroundColor: _selectionMode
                      ? const Color(0xFF1C1C28)
                      : Colors.transparent,
                  leading: _selectionMode
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _exitSelectionMode,
                        )
                      : null,
                  title: _selectionMode
                      ? chaptersAsync.when(
                          data: (chapters) => GestureDetector(
                            onTap: () =>
                                _showSelectCountDialog(context, chapters),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                '${_selectedIds.length}',
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          loading: () => const SizedBox(),
                          error: (_, _) => const SizedBox(),
                        )
                      : null,
                  titleSpacing: 0,
                  actions: _selectionMode
                      ? [
                          chaptersAsync.when(
                            data: (chapters) {
                              final readIds = readIdsAsync.value ?? <String>{};
                              final allSelectedRead =
                                  _selectedIds.isNotEmpty &&
                                  _selectedIds.every(
                                    (id) => readIds.contains(id),
                                  );
                              return Row(
                                children: [
                                  IconButton(
                                    tooltip: allSelectedRead
                                        ? 'Mark as unread'
                                        : 'Mark as read',
                                    icon: Icon(
                                      allSelectedRead
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => _markSelectedAs(
                                      !allSelectedRead,
                                      chapters,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip:
                                        _selectedIds.length == chapters.length
                                        ? 'Deselect all'
                                        : 'Select all',
                                    icon: Icon(
                                      _selectedIds.length == chapters.length
                                          ? Icons.deselect
                                          : Icons.select_all,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => _selectAll(chapters),
                                  ),
                                ],
                              );
                            },
                            loading: () => const SizedBox(),
                            error: (_, _) => const SizedBox(),
                          ),
                        ]
                      : [
                          Consumer(
                            builder: (context, ref, _) {
                              final isInLibraryAsync = ref.watch(
                                isMangaInLibraryProvider(widget.manga.id),
                              );
                              return isInLibraryAsync.when(
                                data: (isInLibrary) => IconButton(
                                  icon: Icon(
                                    isInLibrary
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isInLibrary ? accent : Colors.white,
                                  ),
                                  onPressed: () async {
                                    if (isInLibrary) {
                                      await removeFromLibrary(widget.manga.id);
                                    } else {
                                      await addToLibrary(widget.manga);
                                    }
                                    ref.invalidate(
                                      isMangaInLibraryProvider(widget.manga.id),
                                    );
                                  },
                                ),
                                loading: () => const SizedBox(),
                                error: (_, _) => const SizedBox(),
                              );
                            },
                          ),
                        ],
                  flexibleSpace: _selectionMode
                      ? null
                      : FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (widget.manga.coverUrl != null)
                                Hero(
                                  tag: 'manga_cover_${widget.manga.id}',
                                  child: Image.network(
                                    widget.manga.coverUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      color: const Color(0xFF1C1C28),
                                    ),
                                  ),
                                ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, gradientEnd],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                if (!_selectionMode)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.manga.title,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.manga.authors.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.manga.authors.join(', '),
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          if (widget.manga.status != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(
                                  widget.manga.status!,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _statusColor(
                                    widget.manga.status!,
                                  ).withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                widget.manga.status!.name.toUpperCase(),
                                style: TextStyle(
                                  color: _statusColor(widget.manga.status!),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (widget.manga.tags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: widget.manga.tags.take(8).map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tagBgColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      color: tagTextColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          if (widget.manga.description != null) ...[
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => setState(
                                () => _descriptionExpanded =
                                    !_descriptionExpanded,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedCrossFade(
                                    firstChild: Text(
                                      widget.manga.description!,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: descColor,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                    secondChild: Text(
                                      widget.manga.description!,
                                      style: TextStyle(
                                        color: descColor,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                    crossFadeState: _descriptionExpanded
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                    duration: const Duration(milliseconds: 250),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        _descriptionExpanded
                                            ? 'Show less'
                                            : 'Show more',
                                        style: TextStyle(
                                          color: accent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Icon(
                                        _descriptionExpanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: accent,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          lastReadAsync.when(
                            data: (lastRead) {
                              if (lastRead == null) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final chapters = await ref.read(
                                        chaptersProvider(
                                          widget.manga.id,
                                        ).future,
                                      );
                                      final readIds = await ref.read(
                                        readChapterIdsProvider(
                                          widget.manga.id,
                                        ).future,
                                      );
                                      final firstUnread = chapters.firstWhere(
                                        (c) => !readIds.contains(c.id),
                                        orElse: () => chapters.firstWhere(
                                          (c) => c.id == lastRead.chapterId,
                                          orElse: () => chapters.first,
                                        ),
                                      );
                                      if (context.mounted) {
                                        await context.push(
                                          '/reader',
                                          extra: {
                                            'chapter': firstUnread,
                                            'manga': widget.manga,
                                          },
                                        );
                                        ref.invalidate(
                                          lastReadChapterProvider(
                                            widget.manga.id,
                                          ),
                                        );
                                        ref.invalidate(
                                          readChapterIdsProvider(
                                            widget.manga.id,
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.play_arrow),
                                    label: Text(
                                      lastRead.chapterNumber != null
                                          ? 'Continue • Ch. ${_formatChapterNumber(lastRead.chapterNumber)}'
                                          : 'Continue Reading',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            loading: () => const SizedBox(),
                            error: (_, _) => const SizedBox(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Chapters',
                                style: TextStyle(
                                  color: titleColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              chaptersAsync.when(
                                data: (chapters) {
                                  final readIds =
                                      readIdsAsync.value ?? <String>{};
                                  final readCount = chapters
                                      .where((c) => readIds.contains(c.id))
                                      .length;
                                  return Text(
                                    '$readCount / ${chapters.length}',
                                    style: TextStyle(
                                      color: cs.onSurface.withValues(
                                        alpha: 0.38,
                                      ),
                                      fontSize: 12,
                                    ),
                                  );
                                },
                                loading: () => const SizedBox(),
                                error: (_, _) => const SizedBox(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                chaptersAsync.when(
                  data: (chapters) {
                    final readIds = readIdsAsync.value ?? <String>{};
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final chapter = chapters[index];
                        final isRead = readIds.contains(chapter.id);
                        final isSelected = _selectedIds.contains(chapter.id);

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          color: isSelected
                              ? accent.withValues(alpha: 0.15)
                              : Colors.transparent,
                          child: InkWell(
                            onLongPress: () => _selectionMode
                                ? _rangeSelect(index, chapters)
                                : _enterSelectionMode(index, chapter.id),
                            onTap: _selectionMode
                                ? () => _toggleSelection(index, chapter.id)
                                : () async {
                                    await context.push(
                                      '/reader',
                                      extra: {
                                        'chapter': chapter,
                                        'manga': widget.manga,
                                      },
                                    );
                                    ref.invalidate(
                                      lastReadChapterProvider(widget.manga.id),
                                    );
                                    ref.invalidate(
                                      readChapterIdsProvider(widget.manga.id),
                                    );
                                  },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  if (_selectionMode) ...[
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: isSelected
                                          ? Container(
                                              key: const ValueKey('checked'),
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                color: accent,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            )
                                          : Container(
                                              key: const ValueKey('unchecked'),
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white38,
                                                  width: 1.5,
                                                ),
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          chapter.chapterNumber != null
                                              ? 'Chapter ${_formatChapterNumber(chapter.chapterNumber.toString())}'
                                              : chapter.title ?? 'No title',
                                          style: TextStyle(
                                            color: isRead && !_selectionMode
                                                ? cs.onSurface.withValues(
                                                    alpha: 0.35,
                                                  )
                                                : titleColor,
                                            fontSize: 14,
                                            fontWeight:
                                                isRead && !_selectionMode
                                                ? FontWeight.normal
                                                : FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            if (chapter.scanlationGroup !=
                                                null) ...[
                                              Text(
                                                chapter.scanlationGroup!,
                                                style: TextStyle(
                                                  color: chapterSubtitleColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                ' • ',
                                                style: TextStyle(
                                                  color: chapterSubtitleColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                            if (chapter.publishedAt != null)
                                              Text(
                                                _formatDate(
                                                  chapter.publishedAt!,
                                                ),
                                                style: TextStyle(
                                                  color: chapterSubtitleColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!_selectionMode)
                                    isRead
                                        ? Icon(
                                            Icons.check_circle,
                                            color: accent.withValues(
                                              alpha: 0.5,
                                            ),
                                            size: 16,
                                          )
                                        : Icon(
                                            Icons.chevron_right,
                                            color: cs.onSurface.withValues(
                                              alpha: 0.24,
                                            ),
                                          ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }, childCount: chapters.length),
                    );
                  },
                  loading: () => SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: accent),
                      ),
                    ),
                  ),
                  error: (err, _) => SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.wifi_off_outlined,
                              color: cs.onSurface.withValues(alpha: 0.24),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load chapters',
                              style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.54),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref.invalidate(
                                chaptersProvider(widget.manga.id),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(MangaStatus status) {
    switch (status) {
      case MangaStatus.ongoing:
        return Colors.green;
      case MangaStatus.completed:
        return Colors.blue;
      case MangaStatus.hiatus:
        return Colors.orange;
      case MangaStatus.cancelled:
        return Colors.red;
    }
  }
}
