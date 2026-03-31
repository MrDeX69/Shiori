import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../core/image/reader_isolate_warmup.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/manga.dart';
import '../../core/di/injection.dart';
import '../../data/local/app_database.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/library/library_provider.dart';
import '../browse/manga_detail_provider.dart';
import 'preload_manager.dart';
import 'reader_provider.dart';

enum ReaderMode { leftToRight, rightToLeft, webtoon }

enum TransitionSpeed { instant, fast, normal, slow }

sealed class _WebtoonItem {}

class _PageItem extends _WebtoonItem {
  final String url;
  _PageItem(this.url);
}

class _SeparatorItem extends _WebtoonItem {
  final String label;
  _SeparatorItem(this.label);
}

class ReaderScreen extends ConsumerStatefulWidget {
  final Chapter chapter;
  final Manga? manga;

  const ReaderScreen({super.key, required this.chapter, this.manga});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  PageController? _pageController;
  int _currentPage = 0;

  final ScrollController _webtoonController = ScrollController();
  final List<_WebtoonItem> _webtoonItems = [];
  final List<Chapter> _loadedChapters = [];

  bool _loadingNextChapter = false;
  bool _reachedWebtoonEnd = false;
  bool _webtoonSeeded = false;

  bool _autoScroll = false;
  late final ScrollController _autoScrollController = _webtoonController;
  Timer? _autoScrollTimer;

  bool _showControls = true;
  ReaderMode _mode = ReaderMode.rightToLeft;
  bool _progressLoaded = false;
  bool _chapterMarkedRead = false;
  bool _navigatingToNext = false;
  bool _preloadTriggered = false;
  double _brightness = 1.0;

  bool _showTransitionOverlay = false;
  bool _autoTransitionEnabled = true;
  TransitionSpeed _transitionSpeed = TransitionSpeed.normal;
  Timer? _autoTransitionTimer;
  int _autoTransitionCountdown = 3;

  Timer? _scrollBubbleTimer;
  bool _showWebtoonPageBubble = false;
  bool _webtoonChapterPrecacheDone = false;
  bool _webtoonEndHapticSent = false;
  List<String> _currentChapterPageUrls = [];
  Color _readerPaletteTint = const Color(0xFF1A1A24);

  bool _readerShowWebtoonSidebar = true;
  bool _webtoonSidebarIdleHidden = false;
  Timer? _readerChromeIdleTimer;

  int get _transitionSeconds {
    switch (_transitionSpeed) {
      case TransitionSpeed.instant:
        return 0;
      case TransitionSpeed.fast:
        return 1;
      case TransitionSpeed.normal:
        return 3;
      case TransitionSpeed.slow:
        return 5;
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();
    _loadProgress();
    _webtoonController.addListener(_onWebtoonScroll);
    _scheduleReaderPalette();
    unawaited(warmReaderImageWorker());
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _autoTransitionTimer?.cancel();
    _scrollBubbleTimer?.cancel();
    _readerChromeIdleTimer?.cancel();
    _pageController?.dispose();
    _webtoonController.removeListener(_onWebtoonScroll);
    _webtoonController.dispose();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _scheduleReaderPalette() async {
    final cover = widget.manga?.coverUrl;
    if (cover == null || !mounted) return;
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(cover),
        size: const Size(64, 96),
      );
      final c = palette.vibrantColor?.color ??
          palette.dominantColor?.color ??
          palette.mutedColor?.color;
      if (c != null && mounted) {
        setState(() => _readerPaletteTint = c.withValues(alpha: 0.85));
      }
    } catch (_) {}
  }

  void _bumpWebtoonScrollBubble() {
    if (_mode != ReaderMode.webtoon) return;
    if (!_showWebtoonPageBubble && mounted) {
      setState(() => _showWebtoonPageBubble = true);
    }
    _scrollBubbleTimer?.cancel();
    _scrollBubbleTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showWebtoonPageBubble = false);
    });
  }

  Future<void> _maybePrecacheWebtoonAhead() async {
    if (_mode != ReaderMode.webtoon || !mounted) return;
    if (_currentChapterPageUrls.isEmpty) return;
    if (!_webtoonController.hasClients) return;
    final pos = _webtoonController.position;
    if (!pos.hasContentDimensions) return;
    final n = _currentChapterPageUrls.length;
    final viewH = MediaQuery.sizeOf(context).height;
    final estPageH = (viewH * 0.92).clamp(240.0, 2000.0);
    final idx = (pos.pixels / estPageH).floor().clamp(0, n - 1);
    final threshold = (n * 0.7).floor();
    if (idx < threshold) return;
    if (_webtoonChapterPrecacheDone) return;
    _webtoonChapterPrecacheDone = true;
    if (!context.mounted) return;
    final pm = PreloadManager.fromContext(context);
    await pm.prefetchUrls(context, _currentChapterPageUrls,
        startIndex: idx + 1, count: 3);
    if (widget.manga != null) {
      try {
        final chapters =
        await ref.read(chaptersProvider(widget.manga!.id).future);
        final anchorId = _loadedChapters.isNotEmpty
            ? _loadedChapters.last.id
            : widget.chapter.id;
        final cur = chapters.indexWhere((c) => c.id == anchorId);
        if (cur != -1 && cur < chapters.length - 1) {
          ref.read(preloadChapterProvider(chapters[cur + 1].id));
        }
      } catch (_) {}
    }
  }

  void _armWebtoonSidebarIdleTimer() {
    _readerChromeIdleTimer?.cancel();
    if (_mode != ReaderMode.webtoon ||
        !_showControls ||
        !_readerShowWebtoonSidebar) return;
    _readerChromeIdleTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _webtoonSidebarIdleHidden = true);
    });
  }

  void _onWebtoonScrollActivity() {
    if (_mode != ReaderMode.webtoon ||
        !_showControls ||
        !_readerShowWebtoonSidebar) return;
    if (_webtoonSidebarIdleHidden) {
      setState(() => _webtoonSidebarIdleHidden = false);
    }
    _armWebtoonSidebarIdleTimer();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final showSidebar = prefs.getBool('reader_webtoon_show_sidebar') ?? true;

    final db = getIt<AppDatabase>();
    final progress = await db.getProgress(widget.chapter.id);
    String? savedMode;
    if (widget.manga != null) {
      savedMode = await db.getReadingMode(widget.manga!.id);
    }

    final startPage =
    (progress != null && progress.lastPage > 0) ? progress.lastPage : 0;

    ReaderMode mode = ReaderMode.rightToLeft;
    if (savedMode != null) {
      mode = ReaderMode.values.firstWhere(
            (m) => m.name == savedMode,
        orElse: () => ReaderMode.rightToLeft,
      );
    }

    if (!mounted) return;
    setState(() {
      _currentPage = startPage;
      _mode = mode;
      _pageController = PageController(initialPage: startPage);
      _progressLoaded = true;
      _readerShowWebtoonSidebar = showSidebar;
    });

    await _markPreviousChaptersRead();
  }

  void _initWebtoon(List<String> pages) {
    if (_webtoonSeeded) return;
    _webtoonSeeded = true;
    _currentChapterPageUrls = List<String>.from(pages);
    _webtoonChapterPrecacheDone = false;
    _loadedChapters.add(widget.chapter);
    _webtoonItems.add(_SeparatorItem(_chapterLabel(widget.chapter)));
    for (final url in pages) {
      _webtoonItems.add(_PageItem(url));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pm = PreloadManager.fromContext(context);
      unawaited(pm.prefetchUrls(context, pages, startIndex: 0, count: 3));
    });
  }

  int get _webtoonPageItemCount =>
      _webtoonItems.whereType<_PageItem>().length;

  void _onWebtoonScroll() {
    if (_mode != ReaderMode.webtoon) return;
    if (!_webtoonController.hasClients) return;

    final pos = _webtoonController.position;
    if (!pos.hasContentDimensions) return;

    _bumpWebtoonScrollBubble();
    unawaited(_maybePrecacheWebtoonAhead());
    _onWebtoonScrollActivity();

    if (pos.maxScrollExtent > 0) {
      if (pos.pixels >= pos.maxScrollExtent - 3) {
        if (!_webtoonEndHapticSent) {
          _webtoonEndHapticSent = true;
          HapticFeedback.lightImpact();
        }
      } else if (pos.pixels < pos.maxScrollExtent - 56) {
        _webtoonEndHapticSent = false;
      }
    }

    if (_loadingNextChapter || _reachedWebtoonEnd) return;
    if (pos.maxScrollExtent <= 0) return;
    if (pos.pixels / pos.maxScrollExtent >= 0.70) {
      _appendNextChapter();
    }
  }

  Future<void> _appendNextChapter() async {
    if (_loadingNextChapter || widget.manga == null) return;
    setState(() => _loadingNextChapter = true);

    try {
      final chapters =
      await ref.read(chaptersProvider(widget.manga!.id).future);
      final lastIdx =
      chapters.indexWhere((c) => c.id == _loadedChapters.last.id);

      if (lastIdx == -1 || lastIdx >= chapters.length - 1) {
        _reachedWebtoonEnd = true;
        _markCurrentChapterRead();
        HapticFeedback.lightImpact();
        if (mounted) setState(() => _loadingNextChapter = false);
        return;
      }

      final next = chapters[lastIdx + 1];
      final pages = await ref.read(readerPagesProvider(next.id).future);

      if (!mounted) return;
      setState(() {
        _loadedChapters.add(next);
        _webtoonItems.add(_SeparatorItem(_chapterLabel(next)));
        for (final url in pages) {
          _webtoonItems.add(_PageItem(url));
        }
        _currentChapterPageUrls = List<String>.from(pages);
        _webtoonChapterPrecacheDone = false;
        _loadingNextChapter = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final pm = PreloadManager.fromContext(context);
        unawaited(pm.prefetchUrls(context, pages, startIndex: 0, count: 3));
      });
    } catch (_) {
      if (mounted) setState(() => _loadingNextChapter = false);
    }
  }

  void _toggleAutoScroll() {
    if (_autoScroll) {
      _autoScrollTimer?.cancel();
      setState(() => _autoScroll = false);
    } else {
      setState(() => _autoScroll = true);
      _runAutoScroll();
    }
  }

  void _runAutoScroll() {
    _autoScrollTimer?.cancel();
    if (!mounted || !_autoScroll) return;
    if (!_autoScrollController.hasClients) return;
    final scrollPos = _autoScrollController.position;
    if (!scrollPos.hasContentDimensions) return;

    final remaining =
        scrollPos.maxScrollExtent - _autoScrollController.offset;
    if (remaining <= 0) {
      setState(() => _autoScroll = false);
      return;
    }

    final duration =
    Duration(milliseconds: (remaining / 100 * 1000).toInt());

    _autoScrollController
        .animateTo(scrollPos.maxScrollExtent,
        duration: duration, curve: Curves.linear)
        .then((_) {
      if (mounted && _autoScroll) setState(() => _autoScroll = false);
    });

    _autoScrollTimer = Timer(const Duration(seconds: 2), _runAutoScroll);
  }

  void _maybePreloadNext(
      BuildContext context, int index, List<String> pages) {
    if (_preloadTriggered || widget.manga == null) return;
    final total = pages.length;
    if (total == 0 || (index + 1) / total < 0.70) return;
    _preloadTriggered = true;
    ref.read(chaptersProvider(widget.manga!.id).future).then((chapters) {
      final idx = chapters.indexWhere((c) => c.id == widget.chapter.id);
      if (idx == -1 || idx >= chapters.length - 1) return;
      ref.read(preloadChapterProvider(chapters[idx + 1].id));
    }).catchError((_) {});
    final next = index + 1;
    if (next < pages.length && context.mounted) {
      final pm = PreloadManager.fromContext(context);
      unawaited(
          pm.prefetchUrls(context, pages, startIndex: next, count: 3));
    }
  }

  Future<void> _markPreviousChaptersRead() async {
    if (widget.manga == null) return;
    if (ref.read(incognitoEnabledProvider)) return;
    try {
      final chapters =
      await ref.read(chaptersProvider(widget.manga!.id).future);
      final idx = chapters.indexWhere((c) => c.id == widget.chapter.id);
      if (idx <= 0) return;
      final db = getIt<AppDatabase>();
      for (int i = 0; i < idx; i++) {
        final ch = chapters[i];
        if (!ch.isRead) {
          await db.markChapterRead(ch.id, widget.manga!.id,
              widget.manga!.title, widget.manga!.coverUrl,
              ch.chapterNumber?.toString(), true);
        }
      }
    } catch (_) {}
  }

  Future<void> _markCurrentChapterRead() async {
    if (_chapterMarkedRead) return;
    _chapterMarkedRead = true;
    if (ref.read(incognitoEnabledProvider)) return;
    await markChapterAsRead(
      widget.chapter.id,
      widget.chapter.mangaId,
      widget.manga?.title ?? '',
      widget.manga?.coverUrl,
      widget.chapter.chapterNumber?.toString(),
    );
  }

  void _triggerTransitionOverlay() {
    if (_showTransitionOverlay) return;
    if (widget.manga == null) return;
    if (_mode == ReaderMode.webtoon) return;

    if (_autoTransitionEnabled &&
        _transitionSpeed == TransitionSpeed.instant) {
      _goToNextChapter();
      return;
    }

    setState(() {
      _showTransitionOverlay = true;
      _autoTransitionCountdown = _transitionSeconds;
    });

    if (_autoTransitionEnabled) {
      _autoTransitionTimer?.cancel();
      _autoTransitionTimer =
          Timer.periodic(const Duration(seconds: 1), (timer) {
            if (!mounted) {
              timer.cancel();
              return;
            }
            setState(() => _autoTransitionCountdown--);
            if (_autoTransitionCountdown <= 0) {
              timer.cancel();
              _goToNextChapter();
            }
          });
    }
  }

  void _cancelAutoTransition() {
    _autoTransitionTimer?.cancel();
    setState(() => _autoTransitionCountdown = _transitionSeconds);
  }

  void _dismissTransitionOverlay() {
    _autoTransitionTimer?.cancel();
    setState(() {
      _showTransitionOverlay = false;
      _autoTransitionCountdown = _transitionSeconds;
    });
  }

  Future<void> _goToNextChapter() async {
    if (widget.manga == null || _navigatingToNext) return;
    _navigatingToNext = true;
    try {
      final chapters =
      await ref.read(chaptersProvider(widget.manga!.id).future);
      final idx = chapters.indexWhere((c) => c.id == widget.chapter.id);
      if (idx == -1 || idx >= chapters.length - 1) {
        _navigatingToNext = false;
        _dismissTransitionOverlay();
        return;
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ReaderScreen(chapter: chapters[idx + 1], manga: widget.manga),
        ),
      );
    } catch (_) {
      _navigatingToNext = false;
      _dismissTransitionOverlay();
    }
  }

  Future<void> _goToPreviousChapter() async {
    if (widget.manga == null) return;
    try {
      final chapters =
      await ref.read(chaptersProvider(widget.manga!.id).future);
      final idx = chapters.indexWhere((c) => c.id == widget.chapter.id);
      if (idx <= 0) return;
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ReaderScreen(chapter: chapters[idx - 1], manga: widget.manga),
        ),
      );
    } catch (_) {}
  }

  Future<void> _saveReadingMode(ReaderMode mode) async {
    if (widget.manga == null) return;
    await getIt<AppDatabase>().saveReadingMode(widget.manga!.id, mode.name);
  }

  void _saveProgress(int index, bool incognito) {
    saveProgress(
      widget.chapter.id,
      widget.chapter.mangaId,
      index,
      mangaTitle: widget.manga?.title ?? '',
      mangaCoverUrl: widget.manga?.coverUrl,
      chapterNumber: widget.chapter.chapterNumber?.toString(),
      incognitoEnabled: incognito,
    );
  }

  String _chapterLabel(Chapter ch) => ch.chapterNumber != null
      ? 'Chapter ${ch.chapterNumber}'
      : ch.title ?? 'Chapter';

  String _buildPageText(int total) {
    if (_mode == ReaderMode.webtoon || total == 0 || _currentPage >= total)
      return '';
    return '${_currentPage + 1} / $total';
  }

  // ── Image widgets ─────────────────────────────────────────────────────────

  Widget _readerImagePlaceholder(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return SizedBox(
      width: double.infinity,
      height: h,
      child: const ColoredBox(
        color: Color(0xFF0D0D12),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
                color: Colors.white24, strokeWidth: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _readerImageError(BuildContext context, String url) {
    final h = MediaQuery.sizeOf(context).height;
    return SizedBox(
      width: double.infinity,
      height: h,
      child: ColoredBox(
        color: const Color(0xFF0D0D12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image_outlined,
                color: Colors.white24, size: 32),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                await CachedNetworkImage.evictFromCache(url);
                if (mounted) setState(() {});
              },
              child: const Text('Retry',
                  style: TextStyle(color: Colors.white38)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _webtoonPageImage(BuildContext context, String url) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final slotH = mq.size.height;
    final dpr = mq.devicePixelRatio;
    final memW = (w * dpr).round().clamp(1, 8192);
    final memH = (slotH * dpr).round().clamp(256, 8192);

    return ColoredBox(
      color: Colors.black,
      child: SizedBox(
        width: w,
        child: CachedNetworkImage(
          imageUrl: url,
          width: w,
          memCacheWidth: memW,
          memCacheHeight: memH,
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
          filterQuality: FilterQuality.medium,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          placeholder: (c, _) => _readerImagePlaceholder(context),
          imageBuilder: (context, imageProvider) => Image(
            image: imageProvider,
            width: w,
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
            isAntiAlias: false,
          ),
          errorWidget: (ctx, o, e) => _readerImageError(ctx, url),
        ),
      ),
    );
  }

  Widget _cachedPageImage(BuildContext context, String url) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final slotH = mq.size.height;
    final dpr = mq.devicePixelRatio;
    final memW = (w * dpr).round().clamp(1, 8192);
    final memH = (slotH * dpr).round().clamp(256, 8192);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: slotH, minWidth: w),
        child: CachedNetworkImage(
          imageUrl: url,
          width: w,
          fit: BoxFit.fitWidth,
          memCacheWidth: memW,
          memCacheHeight: memH,
          filterQuality: FilterQuality.medium,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          placeholder: (c, _) => _readerImagePlaceholder(context),
          imageBuilder: (context, imageProvider) => Image(
            image: imageProvider,
            width: w,
            fit: BoxFit.fitWidth,
            alignment: Alignment.center,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
          ),
          errorWidget: (ctx, o, e) => _readerImageError(ctx, url),
        ),
      ),
    );
  }

  // ── Webtoon list ──────────────────────────────────────────────────────────

  Widget _buildWebtoonList(Color accent, List<String> initialPages) {
    if (!_webtoonSeeded) _initWebtoon(initialPages);

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: ListView.builder(
        controller: _webtoonController,
        padding: EdgeInsets.zero,
        physics:
        const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        clipBehavior: Clip.hardEdge,
        cacheExtent: 3200,
        itemCount: _webtoonItems.length + (_reachedWebtoonEnd ? 1 : 0),
        itemBuilder: (context, index) {
          if (_reachedWebtoonEnd && index == _webtoonItems.length) {
            return _AllCaughtUpFooter(accent: accent);
          }
          final item = _webtoonItems[index];
          if (item is _SeparatorItem) {
            return _ChapterSeparator(label: item.label, accent: accent);
          }
          if (item is _PageItem) return _webtoonPageImage(context, item.url);
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── Paged view ────────────────────────────────────────────────────────────

  Widget _buildPagedView(
      BuildContext context, List<String> pages, bool incognito) {
    return PageView.builder(
      controller: _pageController,
      reverse: _mode == ReaderMode.rightToLeft,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (index) {
        setState(() => _currentPage = index);
        HapticFeedback.lightImpact();
        _saveProgress(index, incognito);
        _maybePreloadNext(context, index, pages);
        if (index == pages.length - 1) {
          _markCurrentChapterRead();
          Future.delayed(
              const Duration(milliseconds: 400), _triggerTransitionOverlay);
        }
      },
      itemCount: pages.length,
      itemBuilder: (_, index) => InteractiveViewer(
        minScale: 1.0,
        maxScale: 5.0,
        child: _cachedPageImage(context, pages[index]),
      ),
    );
  }

  // ── Transition overlay ────────────────────────────────────────────────────

  Widget _buildTransitionOverlay(Color accent) {
    return GestureDetector(
      onVerticalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) > 300) _dismissTransitionOverlay();
      },
      child: Container(
        color: Colors.black.withValues(alpha: 0.92),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: accent.withValues(alpha: 0.35), width: 1.5),
                  ),
                  child: Icon(Icons.check_rounded, color: accent, size: 36),
                ),
                const SizedBox(height: 20),
                Text('Finished',
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text(_chapterLabel(widget.chapter),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 48),
                if (_autoTransitionEnabled && _autoTransitionCountdown > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            value: _transitionSeconds > 0
                                ? _autoTransitionCountdown / _transitionSeconds
                                : 0,
                            color: accent,
                            backgroundColor: accent.withValues(alpha: 0.15),
                            strokeWidth: 2.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('Next chapter in $_autoTransitionCountdown…',
                            style: TextStyle(
                                color: accent.withValues(alpha: 0.85),
                                fontSize: 13)),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _cancelAutoTransition,
                          child: const Text('Cancel',
                              style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _cancelAutoTransition();
                      _goToNextChapter();
                    },
                    icon: const Icon(Icons.skip_next_rounded),
                    label: const Text('Next Chapter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _cancelAutoTransition();
                      context.pop();
                    },
                    icon: const Icon(Icons.format_list_bulleted_rounded),
                    label: const Text('Chapter List'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _dismissTransitionOverlay,
                  child: const Text('Back to Reading',
                      style: TextStyle(color: Colors.white38, fontSize: 13)),
                ),
                const SizedBox(height: 8),
                const Text('Swipe down to dismiss',
                    style: TextStyle(color: Colors.white24, fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Settings sheet ────────────────────────────────────────────────────────

  void _showSettingsSheet(BuildContext context) {
    final accent = ref.read(accentColorProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12121A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Reader Settings',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                const Text('Reading Mode',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 12),
                Row(children: [
                  _modeBtn(ctx, setSheet, accent, ReaderMode.rightToLeft,
                      'R→L', Icons.arrow_back),
                  const SizedBox(width: 8),
                  _modeBtn(ctx, setSheet, accent, ReaderMode.leftToRight,
                      'L→R', Icons.arrow_forward),
                  const SizedBox(width: 8),
                  _modeBtn(ctx, setSheet, accent, ReaderMode.webtoon,
                      'Webtoon', Icons.swap_vert),
                ]),
                const SizedBox(height: 24),
                const Text('Brightness',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.brightness_low,
                      color: Colors.white38, size: 20),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: accent,
                        inactiveTrackColor: Colors.white12,
                        thumbColor: accent,
                        overlayColor: accent.withValues(alpha: 0.12),
                      ),
                      child: Slider(
                        value: _brightness,
                        min: 0.1,
                        max: 1.0,
                        onChanged: (val) {
                          setState(() => _brightness = val);
                          setSheet(() {});
                        },
                      ),
                    ),
                  ),
                  const Icon(Icons.brightness_high,
                      color: Colors.white70, size: 20),
                ]),
                if (_mode != ReaderMode.webtoon) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Auto Next Chapter',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 13)),
                      Switch(
                        value: _autoTransitionEnabled,
                        onChanged: (val) {
                          setState(() => _autoTransitionEnabled = val);
                          setSheet(() {});
                        },
                        activeThumbColor: accent,
                      ),
                    ],
                  ),
                  if (_autoTransitionEnabled) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: TransitionSpeed.values.map((speed) {
                        final sel = _transitionSpeed == speed;
                        final label = switch (speed) {
                          TransitionSpeed.instant => 'Instant',
                          TransitionSpeed.fast => '1s',
                          TransitionSpeed.normal => '3s',
                          TransitionSpeed.slow => '5s',
                        };
                        final icon = switch (speed) {
                          TransitionSpeed.instant => Icons.bolt,
                          TransitionSpeed.fast => Icons.fast_forward,
                          TransitionSpeed.normal => Icons.play_arrow,
                          TransitionSpeed.slow => Icons.slow_motion_video,
                        };
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _transitionSpeed = speed;
                                _autoTransitionCountdown = _transitionSeconds;
                              });
                              setSheet(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding:
                              const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: sel
                                    ? accent.withValues(alpha: 0.2)
                                    : const Color(0xFF1C1C28),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: sel ? accent : Colors.transparent),
                              ),
                              child: Column(children: [
                                Icon(icon,
                                    color: sel ? accent : Colors.white38,
                                    size: 18),
                                const SizedBox(height: 4),
                                Text(label,
                                    style: TextStyle(
                                      color: sel ? accent : Colors.white38,
                                      fontSize: 11,
                                      fontWeight: sel
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                    )),
                              ]),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _transitionSpeed == TransitionSpeed.instant
                          ? 'Instantly jumps to next chapter'
                          : 'Auto-loads next chapter after ${_transitionSeconds}s',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ],
                if (_mode == ReaderMode.webtoon) ...[
                  const SizedBox(height: 24),
                  const Text('Webtoon Options',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Expanded(
                      child: Text('Show Sidebar',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 13)),
                    ),
                    Switch(
                      value: _readerShowWebtoonSidebar,
                      onChanged: (v) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool(
                            'reader_webtoon_show_sidebar', v);
                        setState(() {
                          _readerShowWebtoonSidebar = v;
                          if (!v) {
                            _readerChromeIdleTimer?.cancel();
                            _webtoonSidebarIdleHidden = false;
                          } else if (_showControls) {
                            _armWebtoonSidebarIdleTimer();
                          }
                        });
                        setSheet(() {});
                      },
                      activeThumbColor: accent,
                    ),
                  ]),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      _toggleAutoScroll();
                      setSheet(() {});
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: _autoScroll
                            ? accent.withValues(alpha: 0.2)
                            : const Color(0xFF1C1C28),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _autoScroll ? accent : Colors.transparent),
                      ),
                      child: Row(children: [
                        Icon(Icons.play_circle_outline,
                            color: _autoScroll ? accent : Colors.white54,
                            size: 22),
                        const SizedBox(width: 12),
                        Text(
                          _autoScroll ? 'Auto Scroll: ON' : 'Auto Scroll: OFF',
                          style: TextStyle(
                            color: _autoScroll ? accent : Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _autoScroll,
                          onChanged: (_) {
                            _toggleAutoScroll();
                            setSheet(() {});
                            Navigator.pop(ctx);
                          },
                          activeThumbColor: accent,
                        ),
                      ]),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeBtn(BuildContext ctx, StateSetter setSheet, Color accent,
      ReaderMode mode, String label, IconData icon) {
    final sel = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_mode == mode) {
            Navigator.pop(ctx);
            return;
          }
          _autoScrollTimer?.cancel();
          _autoTransitionTimer?.cancel();
          _readerChromeIdleTimer?.cancel();
          _dismissTransitionOverlay();
          setState(() {
            _mode = mode;
            _webtoonSidebarIdleHidden = false;
            _autoScroll = false;
            _reachedWebtoonEnd = false;
            _webtoonSeeded = false;
            _loadingNextChapter = false;
            _preloadTriggered = false;
            for (final item in _webtoonItems) {
              if (item is _PageItem) {
                unawaited(CachedNetworkImage.evictFromCache(item.url));
              }
            }
            _webtoonItems.clear();
            _loadedChapters.clear();
            _currentChapterPageUrls = [];
            _webtoonChapterPrecacheDone = false;
          });
          _saveReadingMode(mode);
          setSheet(() {});
          Navigator.pop(ctx);
          if (mode == ReaderMode.webtoon && _showControls) {
            _armWebtoonSidebarIdleTimer();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color:
            sel ? accent.withValues(alpha: 0.2) : const Color(0xFF1C1C28),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? accent : Colors.transparent),
          ),
          child: Column(children: [
            Icon(icon, color: sel ? accent : Colors.white54, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                  color: sel ? accent : Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                )),
          ]),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pagesAsync = ref.watch(readerPagesProvider(widget.chapter.id));
    final incognito = ref.watch(incognitoEnabledProvider);
    final accent = ref.watch(accentColorProvider);

    if (!_progressLoaded) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: ColorFiltered(
        colorFilter: ColorFilter.matrix([
          _brightness, 0, 0, 0, 0,
          0, _brightness, 0, 0, 0,
          0, 0, _brightness, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Content ──────────────────────────────────────────────
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_showTransitionOverlay) return;
                setState(() {
                  _showControls = !_showControls;
                  if (_showControls) {
                    _webtoonSidebarIdleHidden = false;
                    _armWebtoonSidebarIdleTimer();
                  } else {
                    _readerChromeIdleTimer?.cancel();
                    _webtoonSidebarIdleHidden = false;
                  }
                });
              },
              child: pagesAsync.when(
                data: (pages) {
                  if (pages.isEmpty) {
                    return const Center(
                      child: Text('No pages found',
                          style: TextStyle(color: Colors.white)),
                    );
                  }
                  if (_mode == ReaderMode.webtoon) {
                    return _buildWebtoonList(accent, pages);
                  }
                  return _buildPagedView(context, pages, incognito);
                },
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
                error: (_, __) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_outlined,
                          color: Colors.white24, size: 64),
                      const SizedBox(height: 16),
                      const Text('Failed to load pages',
                          style: TextStyle(color: Colors.white54)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(
                            readerPagesProvider(widget.chapter.id)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Progress bar (paged only) ─────────────────────────────
            if (pagesAsync.asData?.value != null &&
                pagesAsync.asData!.value.isNotEmpty &&
                _mode != ReaderMode.webtoon &&
                !_showTransitionOverlay)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: LinearProgressIndicator(
                  value: (_currentPage + 1) /
                      pagesAsync.asData!.value.length,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                  minHeight: 2,
                ),
              ),

            // ── Top bar — clean gradient, no blur ─────────────────────
            if (_showControls && !_showTransitionOverlay)
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.80),
                        _readerPaletteTint.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.manga != null)
                              Text(widget.manga!.title,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            Text(_chapterLabel(widget.chapter),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      if (_mode == ReaderMode.webtoon && _autoScroll)
                        GestureDetector(
                          onTap: _toggleAutoScroll,
                          child: Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: accent.withValues(alpha: 0.5)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.pause, color: accent, size: 14),
                                  const SizedBox(width: 4),
                                  Text('Auto',
                                      style: TextStyle(
                                          color: accent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                ]),
                          ),
                        ),
                      if (incognito)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(Icons.visibility_off_outlined,
                              color: Colors.white38, size: 18),
                        ),
                      IconButton(
                        icon: const Icon(Icons.settings,
                            color: Colors.white),
                        onPressed: () => _showSettingsSheet(context),
                      ),
                    ]),
                  ),
                ),
              ),

            // ── Bottom bar — clean gradient, no blur ──────────────────
            if (_showControls && !_showTransitionOverlay)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.80),
                        _readerPaletteTint.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.40, 1.0],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      child: pagesAsync.asData != null
                          ? Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _goToPreviousChapter,
                            child: const Icon(Icons.skip_previous,
                                color: Colors.white38, size: 20),
                          ),
                          Text(
                            _buildPageText(
                                pagesAsync.asData!.value.length),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          GestureDetector(
                            onTap: _goToNextChapter,
                            child: const Icon(Icons.skip_next,
                                color: Colors.white38, size: 20),
                          ),
                        ],
                      )
                          : const SizedBox(),
                    ),
                  ),
                ),
              ),

            // ── Webtoon sidebar (no blur) ─────────────────────────────
            if (_mode == ReaderMode.webtoon &&
                _readerShowWebtoonSidebar &&
                _showControls &&
                !_webtoonSidebarIdleHidden &&
                _webtoonPageItemCount > 0 &&
                !_showTransitionOverlay)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: ListenableBuilder(
                    listenable: _webtoonController,
                    builder: (context, _) {
                      final total = _webtoonPageItemCount;
                      final mq = MediaQuery.of(context);
                      final h = mq.size.height;
                      double progress = 0;
                      if (_webtoonController.hasClients) {
                        final pos = _webtoonController.position;
                        if (pos.hasContentDimensions &&
                            pos.maxScrollExtent > 0) {
                          progress =
                              (pos.pixels / pos.maxScrollExtent).clamp(0.0, 1.0);
                        }
                      }
                      final estH = (h * 0.92).clamp(240.0, 2000.0);
                      final idx = _webtoonController.hasClients && total > 0
                          ? (() {
                        final p = _webtoonController.position;
                        if (!p.hasContentDimensions) return 0;
                        return (p.pixels / estH)
                            .floor()
                            .clamp(0, total - 1);
                      })()
                          : 0;
                      final barTop = mq.padding.top + 72;
                      final barBottom = mq.padding.bottom + 96;

                      return Stack(children: [
                        // Scrollbar track + thumb — no blur
                        Positioned(
                          right: 4,
                          top: barTop,
                          bottom: barBottom,
                          width: 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: ColoredBox(
                              color: Colors.white.withValues(alpha: 0.08),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: progress.clamp(0.02, 1.0),
                                  widthFactor: 1,
                                  alignment: Alignment.bottomCenter,
                                  child: ColoredBox(
                                    color: Color.lerp(
                                        accent, _readerPaletteTint, 0.38) ??
                                        accent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Page bubble
                        if (_showWebtoonPageBubble)
                          Positioned(
                            right: 16,
                            top: h * 0.36,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.60),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                    color: accent.withValues(alpha: 0.4)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                child: Text('${idx + 1} / $total',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                      ]);
                    },
                  ),
                ),
              ),

            // ── Transition overlay ────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _showTransitionOverlay
                  ? _buildTransitionOverlay(accent)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _ChapterSeparator extends StatelessWidget {
  final String label;
  final Color accent;
  const _ChapterSeparator({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0A0A0F),
      child: SizedBox(
        width: double.infinity,
        height: 28,
        child: Row(children: [
          Expanded(
              child: Divider(
                  height: 1,
                  thickness: 1,
                  color: accent.withValues(alpha: 0.2))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(label,
                style: TextStyle(
                  color: accent.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                )),
          ),
          Expanded(
              child: Divider(
                  height: 1,
                  thickness: 1,
                  color: accent.withValues(alpha: 0.2))),
        ]),
      ),
    );
  }
}

class _AllCaughtUpFooter extends StatelessWidget {
  final Color accent;
  const _AllCaughtUpFooter({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      color: const Color(0xFF0A0A0F),
      child: Column(children: [
        Icon(Icons.done_all_rounded,
            color: accent.withValues(alpha: 0.6), size: 40),
        const SizedBox(height: 12),
        Text("You're all caught up",
            style: TextStyle(
                color: Colors.white54,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('No more chapters available',
            style: TextStyle(color: Colors.white24, fontSize: 12)),
      ]),
    );
  }
}