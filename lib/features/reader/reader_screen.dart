import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/manga.dart';
import '../../core/di/injection.dart';
import '../../data/local/app_database.dart';
import '../../features/settings/settings_screen.dart';
import '../browse/manga_detail_provider.dart';
import 'reader_provider.dart';

enum ReaderMode { leftToRight, rightToLeft, webtoon }

class ReaderScreen extends ConsumerStatefulWidget {
  final Chapter chapter;
  final Manga? manga;
  const ReaderScreen({super.key, required this.chapter, this.manga});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  PageController? _pageController;
  final ScrollController _webtoonController = ScrollController();
  int _currentPage = 0;
  bool _showControls = true;
  ReaderMode _mode = ReaderMode.rightToLeft;
  bool _progressLoaded = false;
  bool _navigatingToNext = false;
  bool _autoScroll = false;
  Timer? _autoScrollTimer;
  double _brightness = 1.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final db = getIt<AppDatabase>();
    final progress = await db.getProgress(widget.chapter.id);

    String? savedMode;
    if (widget.manga != null) {
      savedMode = await db.getReadingMode(widget.manga!.id);
    }

    int startPage = 0;
    if (progress != null && progress.lastPage > 0) {
      startPage = progress.lastPage;
    }

    ReaderMode mode = ReaderMode.rightToLeft;
    if (savedMode != null) {
      mode = ReaderMode.values.firstWhere(
            (m) => m.name == savedMode,
        orElse: () => ReaderMode.rightToLeft,
      );
    }

    setState(() {
      _currentPage = startPage;
      _mode = mode;
      _pageController = PageController(initialPage: startPage);
      _progressLoaded = true;
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController?.dispose();
    _webtoonController.dispose();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _saveReadingMode(ReaderMode mode) async {
    if (widget.manga == null) return;
    final db = getIt<AppDatabase>();
    await db.saveReadingMode(widget.manga!.id, mode.name);
  }

  void _toggleAutoScroll() {
    setState(() => _autoScroll = !_autoScroll);
    if (_autoScroll) {
      _autoScrollTimer = Timer.periodic(
        const Duration(milliseconds: 16),
            (_) {
          if (!mounted || !_autoScroll) return;
          if (_webtoonController.hasClients) {
            final current = _webtoonController.offset;
            final max = _webtoonController.position.maxScrollExtent;
            if (current >= max) {
              _autoScrollTimer?.cancel();
              setState(() => _autoScroll = false);
              _goToNextChapter();
            } else {
              _webtoonController.jumpTo(current + 1.2);
            }
          }
        },
      );
    } else {
      _autoScrollTimer?.cancel();
    }
  }

  Future<void> _goToNextChapter() async {
    if (widget.manga == null || _navigatingToNext) return;
    _navigatingToNext = true;
    try {
      final chapters =
      await ref.read(chaptersProvider(widget.manga!.id).future);
      final currentIndex =
      chapters.indexWhere((c) => c.id == widget.chapter.id);
      if (currentIndex == -1 || currentIndex >= chapters.length - 1) {
        _navigatingToNext = false;
        return;
      }
      final nextChapter = chapters[currentIndex + 1];
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReaderScreen(
              chapter: nextChapter,
              manga: widget.manga,
            ),
          ),
        );
      }
    } catch (_) {
      _navigatingToNext = false;
    }
  }

  Future<void> _goToPreviousChapter() async {
    if (widget.manga == null) return;
    try {
      final chapters =
      await ref.read(chaptersProvider(widget.manga!.id).future);
      final currentIndex =
      chapters.indexWhere((c) => c.id == widget.chapter.id);
      if (currentIndex <= 0) return;
      final prevChapter = chapters[currentIndex - 1];
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReaderScreen(
              chapter: prevChapter,
              manga: widget.manga,
            ),
          ),
        );
      }
    } catch (_) {}
  }

  String _buildPageText(List<String>? pages) {
    if (_mode == ReaderMode.webtoon) return '';
    if (pages == null || pages.isEmpty) return '';
    if (_currentPage >= pages.length) return 'End';
    return '${_currentPage + 1} / ${pages.length}';
  }

  void _showSettingsSheet(BuildContext context) {
    final accent = ref.read(accentColorProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reader Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Reading Mode',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _modeButton(context, setSheetState, accent,
                      ReaderMode.rightToLeft, 'R→L', Icons.arrow_back),
                  const SizedBox(width: 8),
                  _modeButton(context, setSheetState, accent,
                      ReaderMode.leftToRight, 'L→R', Icons.arrow_forward),
                  const SizedBox(width: 8),
                  _modeButton(context, setSheetState, accent,
                      ReaderMode.webtoon, 'Webtoon', Icons.swap_vert),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Brightness',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.brightness_low,
                      color: Colors.white38, size: 20),
                  Expanded(
                    child: Slider(
                      value: _brightness,
                      min: 0.1,
                      max: 1.0,
                      activeColor: accent,
                      inactiveColor: Colors.white12,
                      onChanged: (val) {
                        setState(() => _brightness = val);
                        setSheetState(() {});
                      },
                    ),
                  ),
                  const Icon(Icons.brightness_high,
                      color: Colors.white70, size: 20),
                ],
              ),
              if (_mode == ReaderMode.webtoon) ...[
                const SizedBox(height: 16),
                const Text(
                  'Webtoon Options',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    _toggleAutoScroll();
                    setSheetState(() {});
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: _autoScroll
                          ? accent.withOpacity(0.2)
                          : const Color(0xFF1C1C28),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _autoScroll ? accent : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.play_circle_outline,
                            color: _autoScroll ? accent : Colors.white54,
                            size: 22),
                        const SizedBox(width: 12),
                        Text(
                          _autoScroll
                              ? 'Auto Scroll: ON'
                              : 'Auto Scroll: OFF',
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
                            setSheetState(() {});
                            Navigator.pop(context);
                          },
                          activeColor: accent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeButton(
      BuildContext context,
      StateSetter setSheetState,
      Color accent,
      ReaderMode mode,
      String label,
      IconData icon,
      ) {
    final isSelected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _autoScrollTimer?.cancel();
          setState(() {
            _mode = mode;
            _autoScroll = false;
          });
          _saveReadingMode(mode);
          setSheetState(() {});
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withOpacity(0.2)
                : const Color(0xFF1C1C28),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accent : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? accent : Colors.white54,
                  size: 22),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                    color: isSelected ? accent : Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProgress(int index, bool incognitoEnabled) {
    saveProgress(
      widget.chapter.id,
      widget.chapter.mangaId,
      index,
      mangaTitle: widget.manga?.title ?? '',
      mangaCoverUrl: widget.manga?.coverUrl,
      chapterNumber: widget.chapter.chapterNumber?.toString(),
      incognitoEnabled: incognitoEnabled,
    );
  }

  Widget _buildTransitionPage(Color accent) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: accent.withOpacity(0.4), width: 1.5),
                ),
                child: Icon(Icons.check_circle_outline,
                    color: accent, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'Chapter Finished',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.chapter.chapterNumber != null
                    ? 'Chapter ${widget.chapter.chapterNumber}'
                    : '',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              if (widget.manga != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _goToNextChapter,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Next Chapter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.list),
                    label: const Text('Chapter List'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagesAsync = ref.watch(readerPagesProvider(widget.chapter.id));
    final incognitoEnabled = ref.watch(incognitoEnabledProvider);
    final accent = ref.watch(accentColorProvider);

    if (!_progressLoaded) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: CircularProgressIndicator(color: Colors.white)),
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
        child: GestureDetector(
          onTap: () => setState(() => _showControls = !_showControls),
          child: Stack(
            fit: StackFit.expand,
            children: [
              pagesAsync.when(
                data: (pages) {
                  if (pages.isEmpty) {
                    return const Center(
                      child: Text('No pages found',
                          style: TextStyle(color: Colors.white)),
                    );
                  }

                  if (_mode == ReaderMode.webtoon) {
                    return ListView.builder(
                      controller: _webtoonController,
                      itemCount: pages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == pages.length) {
                          return _buildTransitionPage(accent);
                        }
                        return Image.network(
                          pages[index],
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              height: 400,
                              color: Colors.black,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                      : null,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            height: 400,
                            color: Colors.black12,
                            child: const Center(
                              child: Icon(Icons.broken_image_outlined,
                                  color: Colors.white24),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return PageView.builder(
                    controller: _pageController,
                    reverse: _mode == ReaderMode.rightToLeft,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      if (index < pages.length) {
                        HapticFeedback.lightImpact();
                        _saveProgress(index, incognitoEnabled);
                      }
                    },
                    itemCount: pages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == pages.length) {
                        return _buildTransitionPage(accent);
                      }
                      return InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Image.network(
                          pages[index],
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image_outlined,
                                color: Colors.white24, size: 48),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                error: (err, _) => Center(
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
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),

              // Progress bar
              if (pagesAsync.value != null &&
                  pagesAsync.value!.isNotEmpty &&
                  _mode != ReaderMode.webtoon)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / pagesAsync.value!.length,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                    minHeight: 2,
                  ),
                ),

              if (_showControls) ...[
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
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
                                  Text(
                                    widget.manga!.title,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                Text(
                                  widget.chapter.chapterNumber != null
                                      ? 'Chapter ${widget.chapter.chapterNumber}'
                                      : widget.chapter.title ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_mode == ReaderMode.webtoon && _autoScroll)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: GestureDetector(
                                onTap: _toggleAutoScroll,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: accent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: accent.withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.pause,
                                          color: accent, size: 14),
                                      const SizedBox(width: 4),
                                      Text('Auto',
                                          style: TextStyle(
                                              color: accent,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (incognitoEnabled)
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
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding:
                        const EdgeInsets.fromLTRB(16, 16, 16, 20),
                        child: pagesAsync.value != null
                            ? Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.manga != null)
                              GestureDetector(
                                onTap: _goToPreviousChapter,
                                child: const Icon(
                                    Icons.skip_previous,
                                    color: Colors.white38,
                                    size: 20),
                              )
                            else
                              const SizedBox(width: 20),
                            Text(
                              _buildPageText(pagesAsync.value),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (widget.manga != null)
                              GestureDetector(
                                onTap: _goToNextChapter,
                                child: const Icon(Icons.skip_next,
                                    color: Colors.white38,
                                    size: 20),
                              )
                            else
                              const SizedBox(width: 20),
                          ],
                        )
                            : const SizedBox(),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}