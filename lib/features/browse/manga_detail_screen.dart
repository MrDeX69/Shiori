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

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_dominantColor, const Color(0xFF0A0A0F)],
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
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0xFF0A0A0F),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.manga.authors.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.manga.authors.join(', '),
                          style: const TextStyle(
                            color: Colors.white54,
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
                                color: const Color(0xFF1C1C28),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      if (widget.manga.description != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          widget.manga.description!,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            height: 1.5,
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
                      const Text(
                        'Chapters',
                        style: TextStyle(
                          color: Colors.white,
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: chapter.scanlationGroup != null
                            ? Text(
                          chapter.scanlationGroup!,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        )
                            : null,
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white24,
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
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: Color(0xFFE85D75),
                      ),
                    ),
                  ),
                ),
                error: (err, _) => SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(Icons.wifi_off_outlined,
                              color: Colors.white24, size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load chapters',
                            style: TextStyle(color: Colors.white54),
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