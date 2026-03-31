import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../statistics/statistics_screen.dart';

final hapticEnabledProvider = StateNotifierProvider<BoolSettingNotifier, bool>(
  (ref) => BoolSettingNotifier('haptic_enabled', true),
);

final incognitoEnabledProvider =
    StateNotifierProvider<BoolSettingNotifier, bool>(
      (ref) => BoolSettingNotifier('incognito_enabled', false),
    );

final biometricEnabledProvider =
    StateNotifierProvider<BoolSettingNotifier, bool>(
      (ref) => BoolSettingNotifier('biometric_enabled', false),
    );

class BoolSettingNotifier extends StateNotifier<bool> {
  final String key;
  final bool defaultValue;

  BoolSettingNotifier(this.key, this.defaultValue) : super(defaultValue) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(key) ?? defaultValue;
  }

  Future<void> toggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    state = value;
  }
}

final _localAuth = LocalAuthentication();

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showSnackBar(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF1C1C28) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _clearCache(BuildContext context) async {
    await DefaultCacheManager().emptyCache();
    if (context.mounted) _showSnackBar(context, 'Cache cleared');
  }

  Future<void> _toggleBiometric(
    BuildContext context,
    WidgetRef ref,
    bool currentValue,
  ) async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!canCheck && !isDeviceSupported) {
        if (context.mounted) {
          _showSnackBar(context, 'Biometrics not available');
        }
        return;
      }
      final authenticated = await _localAuth.authenticate(
        localizedReason: currentValue
            ? 'Authenticate to disable biometric lock'
            : 'Authenticate to enable biometric lock',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (authenticated) {
        await ref.read(biometricEnabledProvider.notifier).toggle(!currentValue);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error: $e');
      }
    }
  }

  void _showThemeSheet(BuildContext context, WidgetRef ref) {
    final accent = ref.read(accentColorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF12121A) : Colors.white;
    final itemBg = isDark ? const Color(0xFF1C1C28) : const Color(0xFFF0F0F5);
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final handleColor = isDark ? Colors.white24 : Colors.black12;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final currentMode = ref.read(themeModeProvider);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Theme',
                    style: TextStyle(
                      color: accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...AppThemeMode.values.map((mode) {
                    final isSelected = mode == currentMode;
                    final label = switch (mode) {
                      AppThemeMode.dark => 'Dark',
                      AppThemeMode.amoled => 'AMOLED Black',
                      AppThemeMode.light => 'Light',
                    };
                    final icon = switch (mode) {
                      AppThemeMode.dark => Icons.dark_mode_outlined,
                      AppThemeMode.amoled => Icons.brightness_2_outlined,
                      AppThemeMode.light => Icons.light_mode_outlined,
                    };
                    final desc = switch (mode) {
                      AppThemeMode.dark => 'Deep dark background',
                      AppThemeMode.amoled =>
                        'Pure black — saves battery on OLED',
                      AppThemeMode.light => 'Light background',
                    };
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(themeModeProvider.notifier).setTheme(mode);
                        setSheet(() {});
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accent.withValues(alpha: 0.15)
                              : itemBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? accent.withValues(alpha: 0.5)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? accent.withValues(alpha: 0.2)
                                    : (isDark
                                          ? Colors.white10
                                          : Colors.black.withValues(
                                              alpha: 0.06,
                                            )),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                icon,
                                color: isSelected
                                    ? accent
                                    : textColor.withValues(alpha: 0.6),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: TextStyle(
                                      color: isSelected ? accent : textColor,
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    desc,
                                    style: TextStyle(
                                      color: textColor.withValues(alpha: 0.4),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: accent, size: 18),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAccentSheet(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF12121A) : Colors.white;
    final handleColor = isDark ? Colors.white24 : Colors.black12;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final currentAccent = ref.read(accentColorProvider);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Accent Color',
                    style: TextStyle(
                      color: currentAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: AccentColorNotifier.presets.map((color) {
                      final isSelected = currentAccent == color;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(accentColorProvider.notifier)
                              .setColor(color);
                          setSheet(() {});
                          Navigator.pop(ctx);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : Border.all(
                                    color: Colors.transparent,
                                    width: 3,
                                  ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.5),
                                blurRadius: isSelected ? 20 : 6,
                                spreadRadius: isSelected ? 3 : 0,
                              ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 28,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticEnabled = ref.watch(hapticEnabledProvider);
    final incognitoEnabled = ref.watch(incognitoEnabledProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final accent = ref.watch(accentColorProvider);
    final themeMode = ref.watch(themeModeProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = themeMode != AppThemeMode.light;

    final themeName = switch (themeMode) {
      AppThemeMode.dark => 'Dark',
      AppThemeMode.amoled => 'AMOLED Black',
      AppThemeMode.light => 'Light',
    };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(bottom: false, child: const SizedBox(height: 16)),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.2),
                    accent.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accent.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '栞',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shiori',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Version 1.0.1',
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.38),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Premium',
                          style: TextStyle(
                            color: accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _sectionHeader('Appearance', accent),
              _tile(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: themeName,
                accent: accent,
                cs: cs,
                isDark: isDark,
                onTap: () => _showThemeSheet(context, ref),
              ),
              _tile(
                icon: Icons.color_lens_outlined,
                title: 'Accent Color',
                subtitle: 'Customize app accent',
                accent: accent,
                cs: cs,
                isDark: isDark,
                trailing: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                onTap: () => _showAccentSheet(context, ref),
              ),
              _sectionHeader('Reader', accent),
              _tile(
                icon: Icons.vibration_outlined,
                title: 'Haptic Feedback',
                subtitle: 'Vibrate on interactions',
                accent: accent,
                cs: cs,
                isDark: isDark,
                trailing: Switch(
                  value: hapticEnabled,
                  onChanged: (val) =>
                      ref.read(hapticEnabledProvider.notifier).toggle(val),
                  activeThumbColor: accent,
                ),
                onTap: () => ref
                    .read(hapticEnabledProvider.notifier)
                    .toggle(!hapticEnabled),
              ),
              _sectionHeader('Privacy', accent),
              _tile(
                icon: Icons.fingerprint_outlined,
                title: 'Biometric Lock',
                subtitle: biometricEnabled
                    ? 'Locked with fingerprint'
                    : 'Lock app with fingerprint',
                accent: accent,
                cs: cs,
                isDark: isDark,
                trailing: Switch(
                  value: biometricEnabled,
                  onChanged: (_) =>
                      _toggleBiometric(context, ref, biometricEnabled),
                  activeThumbColor: accent,
                ),
                onTap: () => _toggleBiometric(context, ref, biometricEnabled),
              ),
              _tile(
                icon: Icons.visibility_off_outlined,
                title: 'Incognito Mode',
                subtitle: incognitoEnabled
                    ? 'History paused'
                    : 'Pause reading history',
                accent: accent,
                cs: cs,
                isDark: isDark,
                trailing: Switch(
                  value: incognitoEnabled,
                  onChanged: (val) {
                    ref.read(incognitoEnabledProvider.notifier).toggle(val);
                    HapticFeedback.lightImpact();
                    if (context.mounted) {
                      _showSnackBar(
                        context,
                        val ? 'Incognito enabled' : 'Incognito disabled',
                      );
                    }
                  },
                  activeThumbColor: accent,
                ),
                onTap: () {},
              ),
              _sectionHeader('Storage', accent),
              _tile(
                icon: Icons.delete_sweep_outlined,
                title: 'Clear Cache',
                subtitle: 'Free up storage space',
                accent: accent,
                cs: cs,
                isDark: isDark,
                onTap: () => _clearCache(context),
              ),
              _sectionHeader('About', accent),
              _tile(
                icon: Icons.code_outlined,
                title: 'GitHub',
                subtitle: 'github.com/MrDeX69/Shiori',
                accent: accent,
                cs: cs,
                isDark: isDark,
                onTap: () async {
                  final uri = Uri.parse('https://github.com/MrDeX69/Shiori');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              _tile(
                icon: Icons.bar_chart_outlined,
                title: 'Statistics',
                subtitle: 'Reading activity & insights',
                accent: accent,
                cs: cs,
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                ),
              ),
              _tile(
                icon: Icons.gavel_outlined,
                title: 'License',
                subtitle: 'GPL v3',
                accent: accent,
                cs: cs,
                isDark: isDark,
                onTap: () async {
                  final uri = Uri.parse(
                    'https://github.com/MrDeX69/Shiori/blob/main/LICENSE',
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const SizedBox(height: 120),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required ColorScheme cs,
    required bool isDark,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isDark ? const Color(0xFF1C1C28) : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.38),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right,
                      color: cs.onSurface.withValues(alpha: 0.24),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
