import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/di/injection.dart';
import '../../data/local/app_database.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Color(0xFF0A0A0F),
            title: Text('History'),
          ),
          SliverFutureBuilder(
            future: getIt<AppDatabase>().getHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final history = snapshot.data ?? [];
              if (history.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.history_outlined,
                          size: 64,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No reading history',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Start reading to see your history here',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final item = history[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C28),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.menu_book_outlined,
                          color: Color(0xFFE85D75),
                        ),
                      ),
                      title: Text(
                        item.chapterId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Page ${item.lastPage + 1}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.white24,
                      ),
                    ).animate().fadeIn(
                      delay: Duration(milliseconds: index * 50),
                      duration: 300.ms,
                    );
                  },
                  childCount: history.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SliverFutureBuilder<T> extends StatefulWidget {
  final Future<T> future;
  final Widget Function(BuildContext, AsyncSnapshot<T>) builder;

  const SliverFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
  });

  @override
  State<SliverFutureBuilder<T>> createState() =>
      _SliverFutureBuilderState<T>();
}

class _SliverFutureBuilderState<T> extends State<SliverFutureBuilder<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: widget.builder,
    );
  }
}