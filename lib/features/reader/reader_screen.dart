import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/chapter.dart';
import 'reader_provider.dart';

enum ReaderMode { leftToRight, rightToLeft, webtoon }

class ReaderScreen extends ConsumerStatefulWidget {
  final Chapter chapter;
  const ReaderScreen({super.key, required this.chapter});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late PageController _pageController;
  final ScrollController _webtoonController = ScrollController();
  int _currentPage = 0;
  bool _showControls = true;
  ReaderMode _mode = ReaderMode.rightToLeft;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _webtoonController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
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
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _modeButton(
                    context,
                    setSheetState,
                    ReaderMode.rightToLeft,
                    'R→L',
                    Icons.arrow_back,
                  ),
                  const SizedBox(width: 8),
                  _modeButton(
                    context,
                    setSheetState,
                    ReaderMode.leftToRight,
                    'L→R',
                    Icons.arrow_forward,
                  ),
                  const SizedBox(width: 8),
                  _modeButton(
                    context,
                    setSheetState,
                    ReaderMode.webtoon,
                    'Webtoon',
                    Icons.swap_vert,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeButton(
      BuildContext context,
      StateSetter setSheetState,
      ReaderMode mode,
      String label,
      IconData icon,
      ) {
    final isSelected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _mode = mode);
          setSheetState(() {});
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFE85D75).withOpacity(0.2)
                : const Color(0xFF1C1C28),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFE85D75)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFFE85D75)
                    : Colors.white54,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFE85D75)
                      : Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagesAsync = ref.watch(readerPagesProvider(widget.chapter.id));

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          fit: StackFit.expand,
          children: [
            pagesAsync.when(
              data: (pages) {
                if (pages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No pages found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                if (_mode == ReaderMode.webtoon) {
                  return ListView.builder(
                    controller: _webtoonController,
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
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
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white24,
                            ),
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
                    HapticFeedback.lightImpact();
                    saveProgress(
                      widget.chapter.id,
                      widget.chapter.mangaId,
                      index,
                    );
                  },
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
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
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white24,
                            size: 48,
                          ),
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
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: Colors.red),
                ),
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
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            widget.chapter.chapterNumber != null
                                ? 'Chapter ${widget.chapter.chapterNumber}'
                                : widget.chapter.title ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
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
                      padding: const EdgeInsets.all(16),
                      child: pagesAsync.value != null
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_currentPage + 1} / ${pagesAsync.value?.length ?? 0}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
    );
  }
}