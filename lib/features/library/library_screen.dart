import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../common_widgets/manga_card.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/manga.dart';
import 'library_provider.dart';

enum LibrarySortOption { title, lastRead, dateAdded, unreadCount }

enum LibraryViewMode { grid3, grid2, list }

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  LibrarySortOption _sort = LibrarySortOption.lastRead;
  LibraryViewMode _viewMode = LibraryViewMode.grid3;
  MangaStatus? _filterStatus;
  bool _unreadOnly = false;
  String _searchQuery = '';
  bool _isSearching = false;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Manga> _applyFiltersAndSort(
      List<Manga> mangaList,
      Map<String, int> unreadCounts,
      ) {
    var filtered = mangaList.where((m) {
      if (_searchQuery.isNotEmpty &&
          !m.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_filterStatus != null && m.status != _filterStatus) return false;
      if (_unreadOnly && (unreadCounts[m.id] ?? 0) == 0) return false;
      return true;
    }).toList();

    switch (_sort) {
      case LibrarySortOption.title:
        filtered.sort((a, b) => a.title.compareTo(b.title));
      case LibrarySortOption.lastRead:
        break; // DB order is already by readAt desc
      case LibrarySortOption.dateAdded:
        filtered = filtered.reversed.toList();
      case LibrarySortOption.unreadCount:
        filtered.sort(
              (a, b) =>
              (unreadCounts[b.id] ?? 0).compareTo(unreadCounts[a.id] ?? 0),
        );
    }
    return filtered;
  }

  void _enterSelectionMode(String mangaId) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectionMode = true;
      _selectedIds.add(mangaId);
    });
  }

  void _exitSelectionMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String mangaId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedIds.contains(mangaId)) {
        _selectedIds.remove(mangaId);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(mangaId);
      }
    });
  }

  Future<void> _removeSelected() async {
    HapticFeedback.mediumImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C28),
        title: const Text(
          'Remove from library',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove ${_selectedIds.length} manga from library?',
          style: const TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      for (final id in _selectedIds) {
        await removeFromLibrary(id);
      }
      ref.invalidate(libraryProvider);
      _exitSelectionMode();
    }
  }

  void _showSortFilterSheet(BuildContext context, Color accent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF12121A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx2, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Sort by',
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _sortTile(ctx, accent, LibrarySortOption.lastRead, 'Last Read',
                Icons.history_outlined),
            _sortTile(ctx, accent, LibrarySortOption.title, 'Title A→Z',
                Icons.sort_by_alpha_outlined),
            _sortTile(ctx, accent, LibrarySortOption.dateAdded, 'Date Added',
                Icons.calendar_today_outlined),
            _sortTile(ctx, accent, LibrarySortOption.unreadCount, 'Unread Count',
                Icons.bookmark_outline),
            const SizedBox(height: 24),
            const Divider(color: Colors.white12),
            const SizedBox(height: 24),
            Text(
              'Filter',
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _filterChip(ctx, accent, null, 'All'),
                _filterChip(ctx, accent, MangaStatus.ongoing, 'Ongoing'),
                _filterChip(ctx, accent, MangaStatus.completed, 'Completed'),
                _filterChip(ctx, accent, MangaStatus.hiatus, 'Hiatus'),
                _filterChip(ctx, accent, MangaStatus.cancelled, 'Cancelled'),
              ],
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setLocal) => GestureDetector(
                onTap: () {
                  setState(() => _unreadOnly = !_unreadOnly);
                  setLocal(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _unreadOnly
                        ? accent.withValues(alpha: 0.15)
                        : const Color(0xFF1C1C28),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _unreadOnly
                          ? accent.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list_outlined,
                          color: _unreadOnly ? accent : Colors.white54,
                          size: 20),
                      const SizedBox(width: 12),
                      Text('Unread only',
                          style: TextStyle(
                            color: _unreadOnly ? accent : Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          )),
                      const Spacer(),
                      Switch(
                        value: _unreadOnly,
                        onChanged: (v) {
                          setState(() => _unreadOnly = v);
                          setLocal(() {});
                        },
                        activeThumbColor: accent,
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

  Widget _sortTile(BuildContext ctx, Color accent, LibrarySortOption option,
      String label, IconData icon) {
    final sel = _sort == option;
    return GestureDetector(
      onTap: () {
        setState(() => _sort = option);
        Navigator.pop(ctx);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: sel
              ? accent.withValues(alpha: 0.15)
              : const Color(0xFF1C1C28),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: sel ? accent.withValues(alpha: 0.5) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: sel ? accent : Colors.white54, size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                  color: sel ? accent : Colors.white70,
                  fontSize: 14,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                )),
            const Spacer(),
            if (sel) Icon(Icons.check_circle, color: accent, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(BuildContext ctx, Color accent, MangaStatus? status,
      String label) {
    final sel = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? accent.withValues(alpha: 0.2) : const Color(0xFF1C1C28),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? accent : Colors.white24),
        ),
        child: Text(label,
            style: TextStyle(
              color: sel ? accent : Colors.white54,
              fontSize: 13,
              fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
            )),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(libraryProvider);
    final accent = ref.watch(accentColorProvider);
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_selectionMode && !_isSearching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (_selectionMode) _exitSelectionMode();
          if (_isSearching) {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
              _searchController.clear();
            });
          }
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor:
              _selectionMode ? const Color(0xFF1C1C28) : null,
              leading: _selectionMode
                  ? IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _exitSelectionMode,
              )
                  : null,
              title: _selectionMode
                  ? Text('${_selectedIds.length} selected',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600))
                  : _isSearching
                  ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search library...',
                  hintStyle: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.54)),
                  border: InputBorder.none,
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.close,
                        color: cs.onSurface
                            .withValues(alpha: 0.54),
                        size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
                  : const Text('Library'),
              actions: _selectionMode
                  ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent),
                  onPressed: _removeSelected,
                ),
              ]
                  : [
                IconButton(
                  icon: Icon(
                    _viewMode == LibraryViewMode.grid3
                        ? Icons.grid_view
                        : _viewMode == LibraryViewMode.grid2
                        ? Icons.grid_on
                        : Icons.view_list_outlined,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                  onPressed: () => setState(() {
                    _viewMode = LibraryViewMode.values[
                    (_viewMode.index + 1) %
                        LibraryViewMode.values.length];
                  }),
                ),
                IconButton(
                  icon: Icon(
                    _isSearching ? Icons.close : Icons.search,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                  onPressed: () => setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchQuery = '';
                      _searchController.clear();
                    }
                  }),
                ),
                IconButton(
                  icon: Icon(Icons.tune_outlined,
                      color: (_filterStatus != null || _unreadOnly)
                          ? accent
                          : cs.onSurface.withValues(alpha: 0.7)),
                  onPressed: () =>
                      _showSortFilterSheet(context, accent),
                ),
              ],
            ),
            libraryAsync.when(
              data: (mangaList) {
                // ── Collect unread counts from Riverpod providers ─────────
                // No DB calls in build(). Each unreadCountProvider is a
                // FutureProvider cached by Riverpod — only fetches once per
                // mangaId until invalidated.
                final unreadCounts = <String, int>{};
                for (final manga in mangaList) {
                  final countAsync =
                  ref.watch(unreadCountProvider(manga.id));
                  unreadCounts[manga.id] = countAsync.value ?? 0;
                }

                final filtered =
                _applyFiltersAndSort(mangaList, unreadCounts);

                if (mangaList.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accent.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.collections_bookmark_outlined,
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
                          Text('Your library is empty',
                              style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600))
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 400.ms),
                          const SizedBox(height: 8),
                          Text('Browse and add manga to your library',
                              style: TextStyle(
                                  color: cs.onSurface.withValues(alpha: 0.38),
                                  fontSize: 13))
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 400.ms),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/browse'),
                            icon: const Icon(Icons.explore_outlined),
                            label: const Text('Browse Manga'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                        ],
                      ),
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.filter_list_off,
                              size: 64,
                              color: cs.onSurface.withValues(alpha: 0.24)),
                          const SizedBox(height: 16),
                          Text('No manga matches your filters',
                              style: TextStyle(
                                  color: cs.onSurface.withValues(alpha: 0.54),
                                  fontSize: 15)),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => setState(() {
                              _filterStatus = null;
                              _unreadOnly = false;
                              _searchQuery = '';
                              _searchController.clear();
                            }),
                            child: Text('Clear filters',
                                style: TextStyle(color: accent)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (_viewMode == LibraryViewMode.list) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final manga = filtered[index];
                        final isSelected = _selectedIds.contains(manga.id);
                        return _ListItem(
                          manga: manga,
                          isSelected: isSelected,
                          selectionMode: _selectionMode,
                          unreadCount: unreadCounts[manga.id] ?? 0,
                          accent: accent,
                          cs: cs,
                          onTap: _selectionMode
                              ? () => _toggleSelection(manga.id)
                              : () => context.push('/manga/${manga.id}',
                              extra: manga),
                          onLongPress: () => _selectionMode
                              ? _toggleSelection(manga.id)
                              : _enterSelectionMode(manga.id),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  );
                }

                final crossAxisCount =
                _viewMode == LibraryViewMode.grid2 ? 2 : 3;
                return SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final manga = filtered[index];
                        final isSelected = _selectedIds.contains(manga.id);
                        return MangaCard(
                          manga: manga,
                          index: index,
                          isSelected: isSelected,
                          selectionMode: _selectionMode,
                          unreadCount: unreadCounts[manga.id],
                          crossAxisCount: crossAxisCount,
                          onTap: _selectionMode
                              ? () => _toggleSelection(manga.id)
                              : () => context.push('/manga/${manga.id}',
                              extra: manga),
                          onLongPress: () => _selectionMode
                              ? _toggleSelection(manga.id)
                              : _enterSelectionMode(manga.id),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
              loading: () => SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (_, __) => const MangaCardShimmer(),
                    childCount: 12,
                  ),
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          color: cs.onSurface.withValues(alpha: 0.24),
                          size: 64),
                      const SizedBox(height: 16),
                      Text('Something went wrong',
                          style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.54),
                              fontSize: 16)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => ref.invalidate(libraryProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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

// ── List item ─────────────────────────────────────────────────────────────────

class _ListItem extends StatelessWidget {
  final Manga manga;
  final bool isSelected;
  final bool selectionMode;
  final int unreadCount;
  final Color accent;
  final ColorScheme cs;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ListItem({
    required this.manga,
    required this.isSelected,
    required this.selectionMode,
    required this.unreadCount,
    required this.accent,
    required this.cs,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      color: isSelected ? accent.withValues(alpha: 0.12) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              if (selectionMode) ...[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSelected
                      ? Container(
                    key: const ValueKey('checked'),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                        color: accent, shape: BoxShape.circle),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 14),
                  )
                      : Container(
                    key: const ValueKey('unchecked'),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                      Border.all(color: Colors.white38, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: manga.coverUrl != null
                    ? Image.network(manga.coverUrl!,
                    width: 48,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(cs, accent))
                    : _placeholder(cs, accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(manga.title,
                        style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    if (manga.status != null)
                      Text(manga.status!.name.toUpperCase(),
                          style: TextStyle(
                              color: _statusColor(manga.status!),
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    if (manga.authors.isNotEmpty)
                      Text(manga.authors.join(', '),
                          style: TextStyle(
                              color: cs.onSurface.withValues(alpha: 0.38),
                              fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text('$unreadCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme cs, Color accent) => Container(
    width: 48,
    height: 64,
    color: cs.surfaceContainerHighest,
    child: Icon(Icons.menu_book_outlined, color: accent, size: 20),
  );

  Color _statusColor(MangaStatus status) => switch (status) {
    MangaStatus.ongoing => Colors.green,
    MangaStatus.completed => Colors.blue,
    MangaStatus.hiatus => Colors.orange,
    MangaStatus.cancelled => Colors.red,
  };
}