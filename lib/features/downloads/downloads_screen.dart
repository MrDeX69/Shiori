import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final accent = ref.watch(accentColorProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            snap: true,
            title: Text('Downloads'),
          ),
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.download_outlined,
                                size: 28,
                                color: accent,
                              ),
                            ),
                          ],
                        )
                        .animate()
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 400.ms),
                    const SizedBox(height: 28),
                    Text(
                      'Downloads',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Download manga chapters for offline reading — coming in the next update',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.38),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                    const SizedBox(height: 32),
                    // Feature preview pills
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children:
                          [
                                _featurePill(
                                  'Wi-Fi only',
                                  Icons.wifi_outlined,
                                  accent,
                                ),
                                _featurePill(
                                  'Background',
                                  Icons.downloading_outlined,
                                  accent,
                                ),
                                _featurePill(
                                  'Offline reader',
                                  Icons.menu_book_outlined,
                                  accent,
                                ),
                                _featurePill(
                                  'Auto-download',
                                  Icons.schedule_outlined,
                                  accent,
                                ),
                              ]
                              .asMap()
                              .entries
                              .map(
                                (e) => e.value
                                    .animate()
                                    .fadeIn(
                                      delay: Duration(
                                        milliseconds: 300 + e.key * 80,
                                      ),
                                      duration: 300.ms,
                                    )
                                    .slideY(
                                      begin: 0.3,
                                      end: 0,
                                      delay: Duration(
                                        milliseconds: 300 + e.key * 80,
                                      ),
                                      duration: 300.ms,
                                    ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featurePill(String label, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
