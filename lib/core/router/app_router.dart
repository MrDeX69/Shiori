import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
        builder: (context, state, child) {
          return MainShell(child: child);
        },
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
          final chapter = state.extra as Chapter;
          return ReaderScreen(chapter: chapter);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final _locations = ['/library', '/browse', '/history', '/downloads'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: widget.child,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF12121A).withOpacity(0.75),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.08),
                  width: 0.5,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
                context.go(_locations[index]);
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: const Color(0xFFE85D75).withOpacity(0.15),
              destinations: const [
                NavigationDestination(
                  icon: Icon(
                    Icons.collections_bookmark_outlined,
                    color: Color(0xFF666677),
                  ),
                  selectedIcon: Icon(
                    Icons.collections_bookmark,
                    color: Color(0xFFE85D75),
                  ),
                  label: 'Library',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.explore_outlined,
                    color: Color(0xFF666677),
                  ),
                  selectedIcon: Icon(
                    Icons.explore,
                    color: Color(0xFFE85D75),
                  ),
                  label: 'Browse',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.history_outlined,
                    color: Color(0xFF666677),
                  ),
                  selectedIcon: Icon(
                    Icons.history,
                    color: Color(0xFFE85D75),
                  ),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.download_outlined,
                    color: Color(0xFF666677),
                  ),
                  selectedIcon: Icon(
                    Icons.download,
                    color: Color(0xFFE85D75),
                  ),
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