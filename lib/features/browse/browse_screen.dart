import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common_widgets/manga_card.dart';
import '../../core/theme/app_theme.dart';
import 'browse_provider.dart';

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
    final trendingAsync = ref.watch(trendingMangaProvider);
    final accent = ref.watch(accentColorProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        color: accent,
        backgroundColor: cs.surfaceContainerHighest,
        onRefresh: () async {
          ref.invalidate(trendingMangaProvider);
          await ref.read(trendingMangaProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              title: _isSearching
                  ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search manga...',
                  hintStyle: TextStyle(
                      color: cs.onSurface.withOpacity(0.54)),
                  border: InputBorder.none,
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    ref.read(searchQueryProvider.notifier).state =
                        query;
                  }
                },
              )
                  : const Text('Browse'),
              actions: [
                IconButton(
                  icon: Icon(
                    _isSearching ? Icons.close : Icons.search,
                    color: cs.onSurface,
                  ),
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
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.7),
                    fontSize: 16,
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
                        index: index,
                        onTap: () => context.push(
                          '/manga/${manga.id}',
                          extra: manga,
                        ),
                      );
                    },
                    childCount: mangaList.length,
                  ),
                ),
              ),
              loading: () => SliverPadding(
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
                        (context, index) => const MangaCardShimmer(),
                    childCount: 12,
                  ),
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off_outlined,
                          color: cs.onSurface.withOpacity(0.24),
                          size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'No connection',
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.54),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check your internet and try again',
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.38),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.invalidate(trendingMangaProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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