import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../domain/models/manga.dart';

class MangaCard extends StatelessWidget {
  final Manga manga;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int index;
  final int? unreadCount;
  final bool isSelected;
  final bool selectionMode;
  final int crossAxisCount;

  const MangaCard({
    super.key,
    required this.manga,
    required this.onTap,
    this.onLongPress,
    this.index = 0,
    this.unreadCount,
    this.isSelected = false,
    this.selectionMode = false,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: accent, width: 2.5)
                  : Border.all(color: Colors.transparent, width: 2.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'manga_cover_${manga.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: manga.coverUrl != null
                              ? Image.network(
                                  manga.coverUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  frameBuilder:
                                      (
                                        context,
                                        child,
                                        frame,
                                        wasSynchronouslyLoaded,
                                      ) {
                                        if (wasSynchronouslyLoaded ||
                                            frame != null) {
                                          return child;
                                        }
                                        return Shimmer.fromColors(
                                          baseColor: const Color(0xFF1C1C28),
                                          highlightColor: const Color(
                                            0xFF2A2A3A,
                                          ),
                                          child: Container(
                                            color: const Color(0xFF1C1C28),
                                          ),
                                        );
                                      },
                                  errorBuilder: (_, _, _) => _placeholder(),
                                )
                              : _placeholder(),
                        ),
                      ),
                      // Unread badge
                      if (unreadCount != null && unreadCount! > 0)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              unreadCount! > 999 ? '999+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      // Selection checkmark
                      if (selectionMode)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: isSelected
                                ? Container(
                                    key: const ValueKey('checked'),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: accent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  )
                                : Container(
                                    key: const ValueKey('unchecked'),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black45,
                                      border: Border.all(
                                        color: Colors.white54,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      // Bottom gradient for title readability
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  manga.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: crossAxisCount == 2 ? 12 : 11,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: (index * 40).clamp(0, 400)),
          duration: 350.ms,
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          delay: Duration(milliseconds: (index * 40).clamp(0, 400)),
          duration: 350.ms,
        );
  }

  Widget _placeholder() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1C1C28),
      highlightColor: const Color(0xFF2A2A3A),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C28),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class MangaCardShimmer extends StatelessWidget {
  const MangaCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Shimmer.fromColors(
            baseColor: const Color(0xFF1C1C28),
            highlightColor: const Color(0xFF2A2A3A),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C28),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Shimmer.fromColors(
          baseColor: const Color(0xFF1C1C28),
          highlightColor: const Color(0xFF2A2A3A),
          child: Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C28),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Shimmer.fromColors(
          baseColor: const Color(0xFF1C1C28),
          highlightColor: const Color(0xFF2A2A3A),
          child: Container(
            height: 10,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C28),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
