import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../domain/models/manga.dart';

class MangaCard extends StatelessWidget {
  final Manga manga;
  final VoidCallback onTap;
  final int index;

  const MangaCard({
    super.key,
    required this.manga,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Hero(
              tag: 'manga_cover_${manga.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: manga.coverUrl != null
                    ? Image.network(
                  manga.coverUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  frameBuilder: (context, child, frame,
                      wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded || frame != null) {
                      return child;
                    }
                    return Shimmer.fromColors(
                      baseColor: const Color(0xFF1C1C28),
                      highlightColor: const Color(0xFF2A2A3A),
                      child: Container(
                        color: const Color(0xFF1C1C28),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
                    : _placeholder(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            manga.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
      delay: Duration(milliseconds: index * 50),
      duration: 400.ms,
    )
        .scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1.0, 1.0),
      delay: Duration(milliseconds: index * 50),
      duration: 400.ms,
    );
  }

  Widget _placeholder() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1C1C28),
      highlightColor: const Color(0xFF2A2A3A),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C28),
          borderRadius: BorderRadius.circular(10),
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