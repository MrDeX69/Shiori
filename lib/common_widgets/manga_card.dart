import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../domain/models/manga.dart';

class MangaCard extends StatelessWidget {
  final Manga manga;
  final VoidCallback onTap;

  const MangaCard({
    super.key,
    required this.manga,
    required this.onTap,
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
                borderRadius: BorderRadius.circular(8),
                child: manga.coverUrl != null
                    ? Image.network(
                  manga.coverUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
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
          const SizedBox(height: 4),
          Text(
            manga.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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