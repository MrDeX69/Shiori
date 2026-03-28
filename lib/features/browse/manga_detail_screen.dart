import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../core/theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    _extractColor();
  }

  @override
  void didPopNext() {
    ref.invalidate(lastReadChapterProvider(widget.manga.id));
  }

  Future<void> _extractColor() async {
    if (widget.manga.coverUrl == null) return;
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(widget.manga.coverUrl!),
        size: const Size(100, 150),
      );
      final color = palette.dominantColor?.color ??
          palette.vibrantColor?.color ??
          const Color(0xFF0A0A0F);
      if (mounted) {
        setState(() {
          _dominantColor = color.withOpacity(0.6);
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(chaptersProvider(widget.manga.id));
    final lastReadAsync = ref.watch(lastReadChapterProvider(widget.manga.id));
    final accent = ref.watch(accentColorProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0A0A0F) : cs.surface;
    final gradientEnd = isDark ? const Color(0xFF0A0A0F) : cs.surface;
    final titleColor = isDark ? Colors.white : cs.onSurface;
    final subtitleColor = isDark ? Colors.white54 : cs.onSurface.withOpacity(0.54);
    final descColor = isDark ? Colors.white60 : cs.onSurface.withOpacity(0.6);
    final tagBgColor = isDark ? const Color(0xFF1C1C28) : cs.surfaceContainerHighest;
    final tagTextColor = isDark ? Colors.white70 : cs.onSurface.withOpacity(0.7);
    final chapterTitleColor = isDark ? Colors.white : cs.onSurface;
    final chapterSubtitleColor = isDark ? Colors.white38 : cs.onSurface.withOpacity(0.38);
    final chevronColor = isDark ? Colors.white24 : cs.onSurface.withOpacity(0.24);

    return Scaffold(
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
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.transparent,
                actions: [
                  Consumer(
                    builder: (context, ref, _) {
                      final isInLibraryAsync = ref
                          .watch(isMangaInLibraryProvider(widget.manga.id));
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
                                isMangaInLibraryProvider(widget.manga.id));
                          },
                        ),
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (widget.manga.coverUrl != null)
                        Hero(
                          tag: 'manga_cover_${widget.manga.id}',
                          child: Image.network(
                            widget.manga.coverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF1C1C28),
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              gradientEnd,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                            color: _statusColor(widget.manga.status!)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _statusColor(widget.manga.status!)
                                  .withOpacity(0.5),
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
                          onTap: () => setState(() =>
                          _descriptionExpanded = !_descriptionExpanded),
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
                          if (lastRead == null) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final chapters = await ref.read(
                                      chaptersProvider(widget.manga.id)
                                          .future);
                                  final chapter = chapters.firstWhere(
                                        (c) => c.id == lastRead.chapterId,
                                    orElse: () => chapters.first,
                                  );
                                  if (context.mounted) {
                                    await context.push('/reader', extra: {
                                      'chapter': chapter,
                                      'manga': widget.manga,
                                    });
                                    ref.invalidate(lastReadChapterProvider(
                                        widget.manga.id));
                                  }
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: Text(
                                  'Continue Reading • Page ${lastRead.lastPage + 1}',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                      Text(
                        'Chapters',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              chaptersAsync.when(
                data: (chapters) => SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final chapter = chapters[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        title: Text(
                          chapter.chapterNumber != null
                              ? 'Chapter ${chapter.chapterNumber}'
                              : chapter.title ?? 'No title',
                          style: TextStyle(
                            color: chapterTitleColor,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: chapter.scanlationGroup != null
                            ? Text(
                          chapter.scanlationGroup!,
                          style: TextStyle(
                            color: chapterSubtitleColor,
                            fontSize: 12,
                          ),
                        )
                            : null,
                        trailing: Icon(
                          Icons.chevron_right,
                          color: chevronColor,
                        ),
                        onTap: () async {
                          await context.push('/reader', extra: {
                            'chapter': chapter,
                            'manga': widget.manga,
                          });
                          ref.invalidate(
                              lastReadChapterProvider(widget.manga.id));
                        },
                      );
                    },
                    childCount: chapters.length,
                  ),
                ),
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
                          Icon(Icons.wifi_off_outlined,
                              color: cs.onSurface.withOpacity(0.24),
                              size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load chapters',
                            style: TextStyle(
                                color: cs.onSurface.withOpacity(0.54)),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(
                                chaptersProvider(widget.manga.id)),
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