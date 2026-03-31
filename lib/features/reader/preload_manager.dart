import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Centralized image prefetch for the reader (current chapter lookahead + warm cache).
class PreloadManager {
  PreloadManager({required this.memCacheWidth, required this.memCacheHeight});

  final int memCacheWidth;
  final int memCacheHeight;

  factory PreloadManager.fromContext(BuildContext context) {
    final mq = MediaQuery.of(context);
    final dpr = mq.devicePixelRatio;
    final w = (mq.size.width * dpr).round().clamp(1, 8192);
    final h = (mq.size.height * dpr).round().clamp(256, 8192);
    return PreloadManager(memCacheWidth: w, memCacheHeight: h);
  }

  /// Precache up to [count] URLs starting at [startIndex] (disk + Flutter image cache).
  Future<void> prefetchUrls(
    BuildContext context,
    List<String> urls, {
    int startIndex = 0,
    int count = 3,
  }) async {
    if (urls.isEmpty || !context.mounted) return;
    final from = startIndex.clamp(0, urls.length - 1);
    final to = (from + count).clamp(0, urls.length);
    for (var i = from; i < to; i++) {
      if (!context.mounted) return;
      await precacheImage(
        CachedNetworkImageProvider(
          urls[i],
          maxWidth: memCacheWidth,
          maxHeight: memCacheHeight,
        ),
        context,
      );
    }
  }
}
