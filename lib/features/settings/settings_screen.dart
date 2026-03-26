import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _clearCache(BuildContext context) async {
    await DefaultCacheManager().emptyCache();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache cleared successfully'),
          backgroundColor: Color(0xFF1C1C28),
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
              backgroundColor: Color(0xFF1C1C28),
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
        await ref.read(biometricEnabledProvider.notifier).toggle(!currentValue);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                currentValue
                    ? 'Biometric lock disabled'
                    : 'Biometric lock enabled',
              ),
              backgroundColor: const Color(0xFF1C1C28),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticEnabled = ref.watch(hapticEnabledProvider);
    final incognitoEnabled = ref.watch(incognitoEnabledProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Color(0xFF0A0A0F),
            title: Text('Settings'),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _sectionHeader('Appearance'),
              _settingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: 'Dark',
                onTap: () {},
              ),
              _settingsTile(
                icon: Icons.color_lens_outlined,
                title: 'Dynamic Color',
                subtitle: 'Extract color from manga covers',
                trailing: Switch(
                  value: true,
                  onChanged: (_) {},
                  activeColor: const Color(0xFFE85D75),
                ),
                onTap: () {},
              ),
              _sectionHeader('Reader'),
              _settingsTile(
                icon: Icons.menu_book_outlined,
                title: 'Default Reading Mode',
                subtitle: 'Right to Left',
                onTap: () {},
              ),
              _settingsTile(
                icon: Icons.vibration_outlined,
                title: 'Haptic Feedback',
                subtitle: 'Vibrate on page turn',
                trailing: Switch(
                  value: hapticEnabled,
                  onChanged: (val) {
                    ref.read(hapticEnabledProvider.notifier).toggle(val);
                  },
                  activeColor: const Color(0xFFE85D75),
                ),
                onTap: () {},
              ),
              _settingsTile(
                icon: Icons.download_outlined,
                title: 'Preload Pages',
                subtitle: 'Load ahead for faster reading',
                trailing: Switch(
                  value: true,
                  onChanged: (_) {},
                  activeColor: const Color(0xFFE85D75),
                ),
                onTap: () {},
              ),
              _sectionHeader('Privacy'),
              _settingsTile(
                icon: Icons.fingerprint_outlined,
                title: 'Biometric Lock',
                subtitle: biometricEnabled
                    ? 'App is locked with fingerprint'
                    : 'Lock app with fingerprint',
                trailing: Switch(
                  value: biometricEnabled,
                  onChanged: (_) =>
                      _toggleBiometric(context, ref, biometricEnabled),
                  activeColor: const Color(0xFFE85D75),
                ),
                onTap: () => _toggleBiometric(context, ref, biometricEnabled),
              ),
              _settingsTile(
                icon: Icons.visibility_off_outlined,
                title: 'Incognito Mode',
                subtitle: incognitoEnabled
                    ? 'History is not being saved'
                    : 'Don\'t save reading history',
                trailing: Switch(
                  value: incognitoEnabled,
                  onChanged: (val) {
                    ref.read(incognitoEnabledProvider.notifier).toggle(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          val
                              ? 'Incognito mode enabled'
                              : 'Incognito mode disabled',
                        ),
                        backgroundColor: const Color(0xFF1C1C28),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  activeColor: const Color(0xFFE85D75),
                ),
                onTap: () {},
              ),
              _sectionHeader('Storage'),
              _settingsTile(
                icon: Icons.delete_outline,
                title: 'Clear Cache',
                subtitle: 'Free up storage space',
                onTap: () => _clearCache(context),
              ),
              _settingsTile(
                icon: Icons.folder_outlined,
                title: 'Downloads Location',
                subtitle: 'Internal Storage',
                onTap: () {},
              ),
              _sectionHeader('About'),
              _settingsTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: '1.0.0',
                onTap: () {},
              ),
              _settingsTile(
                icon: Icons.code_outlined,
                title: 'GitHub',
                subtitle: 'View source code',
                onTap: () {},
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFE85D75),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
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
          color: const Color(0xFF1C1C28),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFE85D75),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 12,
        ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right,
            color: Colors.white24,
          ),
      onTap: onTap,
    ).animate().fadeIn(duration: 300.ms);
  }
}