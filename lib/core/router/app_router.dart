import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/manga.dart';
import '../../features/library/library_screen.dart';
import '../../features/browse/browse_screen.dart';
import '../../features/browse/manga_detail_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/downloads/downloads_screen.dart';
import '../../features/reader/reader_screen.dart';
import '../../features/settings/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/library',
    debugLogDiagnostics: false,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/browse',
            builder: (context, state) => const BrowseScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/downloads',
            builder: (context, state) => const DownloadsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/manga/:id',
        builder: (context, state) {
          final manga = state.extra as Manga;
          return MangaDetailScreen(manga: manga);
        },
      ),
      GoRoute(
        path: '/reader',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final chapter = extra['chapter'] as Chapter;
          final manga = extra['manga'] as Manga?;
          return ReaderScreen(chapter: chapter, manga: manga);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final accent = ref.watch(accentColorProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locations = ['/library', '/browse', '/history', '/downloads'];

    int currentIndex = 0;
    for (int i = 0; i < locations.length; i++) {
      if (location.startsWith(locations[i])) {
        currentIndex = i;
        break;
      }
    }

    final isLight = themeMode == AppThemeMode.light;
    final navBgColor = isLight
        ? Colors.white.withOpacity(0.85)
        : const Color(0xFF12121A).withOpacity(0.85);
    final borderColor = isLight
        ? Colors.black.withOpacity(0.08)
        : Colors.white.withOpacity(0.08);
    final unselectedColor = isLight
        ? const Color(0xFF999999)
        : const Color(0xFF666677);

    return Scaffold(
      extendBody: false,
      body: child,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: navBgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(
                  color: borderColor,
                  width: 0.5,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) => context.go(locations[index]),
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: accent.withOpacity(0.15),
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.collections_bookmark_outlined,
                      color: unselectedColor),
                  selectedIcon: Icon(Icons.collections_bookmark,
                      color: accent),
                  label: 'Library',
                ),
                NavigationDestination(
                  icon: Icon(Icons.explore_outlined,
                      color: unselectedColor),
                  selectedIcon: Icon(Icons.explore, color: accent),
                  label: 'Browse',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_outlined,
                      color: unselectedColor),
                  selectedIcon: Icon(Icons.history, color: accent),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(Icons.download_outlined,
                      color: unselectedColor),
                  selectedIcon: Icon(Icons.download, color: accent),
                  label: 'Downloads',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}