import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/app_database.dart';

final statisticsProvider = FutureProvider<ReadingStats>((ref) async {
  final db = getIt<AppDatabase>();
  return db.getReadingStats();
});

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);
    final accent = ref.watch(accentColorProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Statistics'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          statsAsync.when(
            data: (stats) => SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),

                // ── 4 stat cards ──────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.menu_book_outlined,
                          value: '${stats.totalChapters}',
                          label: 'Chapters\nRead',
                          accent: accent,
                          isDark: isDark,
                          cs: cs,
                          delay: 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.collections_bookmark_outlined,
                          value: '${stats.totalManga}',
                          label: 'In\nLibrary',
                          accent: accent,
                          isDark: isDark,
                          cs: cs,
                          delay: 100,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.local_fire_department_outlined,
                          value: '${stats.streak}',
                          label: 'Day\nStreak',
                          accent: accent,
                          isDark: isDark,
                          cs: cs,
                          delay: 200,
                          highlight: stats.streak > 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.today_outlined,
                          value: '${stats.todayChapters}',
                          label: 'Read\nToday',
                          accent: accent,
                          isDark: isDark,
                          cs: cs,
                          delay: 300,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Weekly chart ──────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SectionHeader(label: 'This Week', accent: accent),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _WeeklyChart(
                    activity: stats.weekActivity,
                    accent: accent,
                    isDark: isDark,
                    cs: cs,
                  ),
                ),

                // ── Top manga ─────────────────────────────
                if (stats.topManga.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionHeader(label: 'Most Read', accent: accent),
                  ),
                  const SizedBox(height: 12),
                  ...stats.topManga.asMap().entries.map(
                    (e) => _TopMangaRow(
                      rank: e.key + 1,
                      title: e.value.title,
                      coverUrl: e.value.coverUrl,
                      chaptersRead: e.value.count,
                      accent: accent,
                      isDark: isDark,
                      cs: cs,
                      delay: e.key * 80,
                    ),
                  ),
                ],

                const SizedBox(height: 120),
              ]),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Failed to load statistics',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.54)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color accent;
  const _SectionHeader({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: accent,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final bool isDark;
  final ColorScheme cs;
  final int delay;
  final bool highlight;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    required this.isDark,
    required this.cs,
    required this.delay,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: highlight
                ? accent.withValues(alpha: 0.15)
                : isDark
                ? const Color(0xFF1C1C28)
                : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: highlight
                ? Border.all(color: accent.withValues(alpha: 0.4), width: 1.5)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: highlight ? accent : accent.withValues(alpha: 0.8),
                  size: 20,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: TextStyle(
                  color: highlight ? accent : cs.onSurface,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.45),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}

// ── Weekly bar chart ───────────────────────────────────────────────

class _WeeklyChart extends StatelessWidget {
  final List<int> activity;
  final Color accent;
  final bool isDark;
  final ColorScheme cs;

  const _WeeklyChart({
    required this.activity,
    required this.accent,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final todayIndex = now.weekday - 1; // 0=Mon … 6=Sun
    final maxVal = activity.isEmpty
        ? 1
        : activity.reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxVal == 0 ? 1 : maxVal;

    return Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C28)
                : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final count = i < activity.length ? activity[i] : 0;
                    final isToday = i == todayIndex;
                    // Minimalna visina 8px čak i kad je 0
                    // da bar uvijek bude vidljiv
                    final ratio = count > 0 ? (count / effectiveMax) : 0.0;
                    final barHeight = count > 0
                        ? (ratio * 88).clamp(12.0, 88.0)
                        : 8.0;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (count > 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '$count',
                                  style: TextStyle(
                                    color: isToday
                                        ? accent
                                        : cs.onSurface.withValues(alpha: 0.5),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 500 + i * 70),
                              curve: Curves.easeOut,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: isToday
                                    ? accent
                                    : count > 0
                                    ? accent.withValues(alpha: 0.5)
                                    : cs.onSurface.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(7, (i) {
                  final isToday = i == todayIndex;
                  return Expanded(
                    child: Text(
                      days[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isToday
                            ? accent
                            : cs.onSurface.withValues(alpha: 0.35),
                        fontSize: 10,
                        fontWeight: isToday
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 350.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
}

// ── Top manga row ──────────────────────────────────────────────────

class _TopMangaRow extends StatelessWidget {
  final int rank;
  final String title;
  final String? coverUrl;
  final int chaptersRead;
  final Color accent;
  final bool isDark;
  final ColorScheme cs;
  final int delay;

  const _TopMangaRow({
    required this.rank,
    required this.title,
    required this.coverUrl,
    required this.chaptersRead,
    required this.accent,
    required this.isDark,
    required this.cs,
    required this.delay,
  });

  Color get _rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return cs.onSurface.withValues(alpha: 0.38);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1C1C28)
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      color: _rankColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: coverUrl != null
                      ? Image.network(
                          coverUrl!,
                          width: 38,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholder(cs, accent),
                        )
                      : _placeholder(cs, accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$chaptersRead',
                      style: TextStyle(
                        color: accent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    Text(
                      'ch.',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.38),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 400 + delay),
          duration: 350.ms,
        )
        .slideX(
          begin: 0.08,
          end: 0,
          delay: Duration(milliseconds: 400 + delay),
          duration: 350.ms,
        );
  }

  Widget _placeholder(ColorScheme cs, Color accent) {
    return Container(
      width: 38,
      height: 52,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(Icons.menu_book_outlined, color: accent, size: 16),
    );
  }
}
