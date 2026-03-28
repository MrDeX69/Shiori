import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';

final hapticEnabledProvider =
StateNotifierProvider<BoolSettingNotifier, bool>(
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

  Future<void> _clearCache(BuildContext context) async {
    await DefaultCacheManager().emptyCache();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache cleared successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometrics not available on this device'),
              behavior: SnackBarBehavior.floating,
            ),
          );
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
        await ref
            .read(biometricEnabledProvider.notifier)
            .toggle(!currentValue);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                currentValue
                    ? 'Biometric lock disabled'
                    : 'Biometric lock enabled',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentMode = ref.read(themeModeProvider);
    final cs = Theme.of(context).colorScheme;
    final accent = ref.read(accentColorProvider);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.surfaceContainerHighest,
        title: Text('Choose Theme',
            style: TextStyle(color: cs.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
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
            return ListTile(
              leading: Icon(icon,
                  color: isSelected ? accent : cs.onSurface.withOpacity(0.54)),
              title: Text(
                label,
                style: TextStyle(
                  color: isSelected ? accent : cs.onSurface,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: accent)
                  : null,
              onTap: () {
                ref.read(themeModeProvider.notifier).setTheme(mode);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAccentDialog(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.surfaceContainerHighest,
        title: Text('Accent Color',
            style: TextStyle(color: cs.onSurface)),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AccentColorNotifier.presets.map((color) {
            final isSelected = ref.read(accentColorProvider) == color;
            return GestureDetector(
              onTap: () {
                ref.read(accentColorProvider.notifier).setColor(color);
                Navigator.pop(context);
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(Icons.check,
                    color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
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

    final themeName = switch (themeMode) {
      AppThemeMode.dark => 'Dark',
      AppThemeMode.amoled => 'AMOLED Black',
      AppThemeMode.light => 'Light',
    };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            snap: true,
            title: Text('Settings'),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _sectionHeader('Appearance', accent),
              _settingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: themeName,
                accent: accent,
                cs: cs,
                onTap: () => _showThemeDialog(context, ref),
              ),
              _settingsTile(
                icon: Icons.color_lens_outlined,
                title: 'Accent Color',
                subtitle: 'Customize app color',
                accent: accent,
                cs: cs,
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                onTap: () => _showAccentDialog(context, ref),
              ),
              _sectionHeader('Reader', accent),
              _settingsTile(
                icon: Icons.vibration_outlined,
                title: 'Haptic Feedback',
                subtitle: 'Vibrate on page turn',
                accent: accent,
                cs: cs,
                trailing: Switch(
                  value: hapticEnabled,
                  onChanged: (val) =>
                      ref.read(hapticEnabledProvider.notifier).toggle(val),
                  activeColor: accent,
                ),
                onTap: () => ref
                    .read(hapticEnabledProvider.notifier)
                    .toggle(!hapticEnabled),
              ),
              _sectionHeader('Privacy', accent),
              _settingsTile(
                icon: Icons.fingerprint_outlined,
                title: 'Biometric Lock',
                subtitle: biometricEnabled
                    ? 'App is locked with fingerprint'
                    : 'Lock app with fingerprint',
                accent: accent,
                cs: cs,
                trailing: Switch(
                  value: biometricEnabled,
                  onChanged: (_) =>
                      _toggleBiometric(context, ref, biometricEnabled),
                  activeColor: accent,
                ),
                onTap: () =>
                    _toggleBiometric(context, ref, biometricEnabled),
              ),
              _settingsTile(
                icon: Icons.visibility_off_outlined,
                title: 'Incognito Mode',
                subtitle: incognitoEnabled
                    ? 'History is not being saved'
                    : "Don't save reading history",
                accent: accent,
                cs: cs,
                trailing: Switch(
                  value: incognitoEnabled,
                  onChanged: (val) {
                    ref
                        .read(incognitoEnabledProvider.notifier)
                        .toggle(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val
                            ? 'Incognito mode enabled'
                            : 'Incognito mode disabled'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  activeColor: accent,
                ),
                onTap: () {},
              ),
              _sectionHeader('Storage', accent),
              _settingsTile(
                icon: Icons.delete_outline,
                title: 'Clear Cache',
                subtitle: 'Free up storage space',
                accent: accent,
                cs: cs,
                onTap: () => _clearCache(context),
              ),
              _sectionHeader('About', accent),
              _settingsTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: '1.0.1',
                accent: accent,
                cs: cs,
                onTap: () {},
              ),
              _settingsTile(
                icon: Icons.code_outlined,
                title: 'GitHub',
                subtitle: 'github.com/MrDeX69/Shiori',
                accent: accent,
                cs: cs,
                onTap: () async {
                  final uri =
                  Uri.parse('https://github.com/MrDeX69/Shiori');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const SizedBox(height: 32),
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

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required ColorScheme cs,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: accent, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: cs.onSurface.withOpacity(0.38),
          fontSize: 12,
        ),
      ),
      trailing: trailing ??
          Icon(Icons.chevron_right,
              color: cs.onSurface.withOpacity(0.24)),
      onTap: onTap,
    );
  }
}