import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common_widgets/manga_card.dart';
import 'browse_provider.dart';
import 'manga_detail_screen.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trendingAsync = ref.watch(trendingMangaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: RefreshIndicator(
        color: const Color(0xFFE85D75),
        backgroundColor: const Color(0xFF1C1C28),
        onRefresh: () async {
          ref.invalidate(trendingMangaProvider);
          await ref.read(trendingMangaProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: const Color(0xFF0A0A0F),
              title: _isSearching
                  ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search manga...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    ref.read(searchQueryProvider.notifier).state = query;
                  }
                },
              )
                  : const Text('Browse'),
              actions: [
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      }
                    });
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  _isSearching ? 'Search Results' : 'Trending',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            trendingAsync.when(
              data: (mangaList) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MangaDetailScreen(manga: manga),
                            ),
                          );
                        },
                      );
                    },
                    childCount: mangaList.length,
                  ),
                ),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFE85D75),
                  ),
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wifi_off_outlined,
                        color: Colors.white24,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No connection',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () =>
                            ref.invalidate(trendingMangaProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE85D75),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}