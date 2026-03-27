import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common_widgets/manga_card.dart';
import 'library_provider.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: const Color(0xFF0A0A0F),
            title: const Text('Library'),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                ),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          libraryAsync.when(
            data: (mangaList) {
              if (mangaList.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.collections_bookmark_outlined,
                          size: 64,
                          color: Colors.white24,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Your library is empty',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Browse and add manga to your library',
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
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final manga = mangaList[index];
                      return MangaCard(
                        manga: manga,
                        onTap: () => context.push(
                          '/manga/${manga.id}',
                          extra: manga,
                        ),
                      );
                    },
                    childCount: mangaList.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}