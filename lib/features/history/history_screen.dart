import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';
import '../../domain/models/chapter.dart';

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
    if (state == AppLifecycleState.resumed) {
      _loadHistory();
    }
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = ref.watch(accentColorProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('History'),
            actions: [
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: cs.onSurface.withOpacity(0.54)),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: cs.surfaceContainerHighest,
                      title: Text('Clear History',
                          style: TextStyle(color: cs.onSurface)),
                      content: Text(
                        'Are you sure you want to clear all reading history?',
                        style: TextStyle(
                            color: cs.onSurface.withOpacity(0.54)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.54))),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Clear',
                              style: TextStyle(color: accent)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    final db = getIt<AppDatabase>();
                    await db.clearHistory();
                    _loadHistory();
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
                    Icon(Icons.history_outlined,
                        size: 64,
                        color: cs.onSurface.withOpacity(0.24)),
                    const SizedBox(height: 16),
                    Text('No reading history',
                        style: TextStyle(
                            color: cs.onSurface.withOpacity(0.54),
                            fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Start reading to see your history here',
                        style: TextStyle(
                            color: cs.onSurface.withOpacity(0.38),
                            fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final item = _history[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: item.mangaCoverUrl != null
                          ? Image.network(
                        item.mangaCoverUrl!,
                        width: 48,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _placeholder(cs, accent),
                      )
                          : _placeholder(cs, accent),
                    ),
                    title: Text(
                      item.mangaTitle.isNotEmpty
                          ? item.mangaTitle
                          : 'Unknown Manga',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      item.chapterNumber != null
                          ? 'Chapter ${item.chapterNumber} • Page ${item.lastPage + 1}'
                          : 'Page ${item.lastPage + 1}',
                      style: TextStyle(
                          color: cs.onSurface.withOpacity(0.38),
                          fontSize: 12),
                    ),
                    trailing: Icon(Icons.chevron_right,
                        color: cs.onSurface.withOpacity(0.24)),
                    onTap: () async {
                      final chapter = Chapter(
                        id: item.chapterId,
                        mangaId: item.mangaId,
                        chapterNumber: item.chapterNumber != null
                            ? double.tryParse(item.chapterNumber!)
                            : null,
                      );
                      await context.push('/reader', extra: {
                        'chapter': chapter,
                        'manga': null,
                      });
                      _loadHistory();
                    },
                  ).animate().fadeIn(
                    delay: Duration(milliseconds: index * 50),
                    duration: 300.ms,
                  );
                },
                childCount: _history.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder(ColorScheme cs, Color accent) {
    return Container(
      width: 48,
      height: 64,
      color: cs.surfaceContainerHighest,
      child: Icon(Icons.menu_book_outlined, color: accent, size: 20),
    );
  }
}