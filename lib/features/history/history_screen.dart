import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../domain/models/chapter.dart';
import '../reader/reader_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with WidgetsBindingObserver {
  List<ChapterProgressTableData> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadHistory();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadHistory();
  }

  Future<void> _loadHistory() async {
    final db = getIt<AppDatabase>();
    final history = await db.getHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _loading = false;
      });
    }
  }

  Map<String, List<ChapterProgressTableData>> _groupByDate() {
    final Map<String, List<ChapterProgressTableData>> grouped = {};
    for (final item in _history) {
      final key = _dateKey(item.readAt);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  String _dateKey(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == yesterday) return 'Yesterday';
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

  String _timeAgo(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _removeItem(ChapterProgressTableData item) async {
    HapticFeedback.lightImpact();
    setState(() {
      _history.removeWhere((h) => h.chapterId == item.chapterId);
    });
    final db = getIt<AppDatabase>();
    await (db.delete(
      db.chapterProgressTable,
    )..where((t) => t.chapterId.equals(item.chapterId))).go();
  }

  Future<void> _clearHistory() async {
    final db = getIt<AppDatabase>();
    await db.clearHistory();
    if (mounted) {
      setState(() => _history = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = ref.watch(accentColorProvider);

    final grouped = _groupByDate();
    final dateKeys = grouped.keys.toList();

    final List<dynamic> flatList = [];
    for (final key in dateKeys) {
      flatList.add(key);
      flatList.addAll(grouped[key]!);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('History'),
            actions: [
              if (_history.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.delete_sweep_outlined,
                    color: cs.onSurface.withValues(alpha: 0.54),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        backgroundColor: cs.surfaceContainerHighest,
                        title: Text(
                          'Clear History',
                          style: TextStyle(color: cs.onSurface),
                        ),
                        content: Text(
                          'Are you sure you want to clear all reading history?',
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.54),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.54),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: Text(
                              'Clear',
                              style: TextStyle(color: accent),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      HapticFeedback.mediumImpact();
                      await _clearHistory();
                    }
                  },
                ),
            ],
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_history.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: accent.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.history_outlined,
                            size: 48,
                            color: accent,
                          ),
                        )
                        .animate()
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          duration: 500.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 300.ms),
                    const SizedBox(height: 24),
                    Text(
                      'No reading history',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Start reading to see your history here',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.38),
                        fontSize: 13,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = flatList[index];

                if (item is String) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text(
                      item,
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                }

                final entry = item as ChapterProgressTableData;
                return Dismissible(
                  key: Key(entry.chapterId),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _removeItem(entry),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red.withValues(alpha: 0.8),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  child: InkWell(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final chapter = Chapter(
                        id: entry.chapterId,
                        mangaId: entry.mangaId,
                        chapterNumber: entry.chapterNumber != null
                            ? double.tryParse(entry.chapterNumber!)
                            : null,
                      );
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ReaderScreen(chapter: chapter, manga: null),
                        ),
                      );
                      _loadHistory();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: entry.mangaCoverUrl != null
                                ? Image.network(
                                    entry.mangaCoverUrl!,
                                    width: 44,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        _placeholder(cs, accent),
                                  )
                                : _placeholder(cs, accent),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.mangaTitle.isNotEmpty
                                      ? entry.mangaTitle
                                      : 'Unknown Manga',
                                  style: TextStyle(
                                    color: cs.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.chapterNumber != null &&
                                          entry.chapterNumber!.isNotEmpty
                                      ? 'Chapter ${entry.chapterNumber}'
                                      : 'Unknown Chapter',
                                  style: TextStyle(
                                    color: accent.withValues(alpha: 0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      entry.isRead
                                          ? Icons.check_circle_outline
                                          : Icons.bookmark_outline,
                                      size: 12,
                                      color: cs.onSurface.withValues(
                                        alpha: 0.38,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      entry.isRead
                                          ? 'Completed'
                                          : 'Page ${entry.lastPage + 1}',
                                      style: TextStyle(
                                        color: cs.onSurface.withValues(
                                          alpha: 0.38,
                                        ),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _timeAgo(entry.readAt),
                                style: TextStyle(
                                  color: cs.onSurface.withValues(alpha: 0.38),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Icon(
                                Icons.play_circle_outline,
                                color: accent.withValues(alpha: 0.6),
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: index * 30),
                  duration: 250.ms,
                );
              }, childCount: flatList.length),
            ),
        ],
      ),
    );
  }

  Widget _placeholder(ColorScheme cs, Color accent) {
    return Container(
      width: 44,
      height: 60,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(Icons.menu_book_outlined, color: accent, size: 20),
    );
  }
}
