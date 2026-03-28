import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme mode provider
final themeModeProvider =
StateNotifierProvider<ThemeModeNotifier, AppThemeMode>(
      (ref) => ThemeModeNotifier(),
);

// Accent color provider
final accentColorProvider =
StateNotifierProvider<AccentColorNotifier, Color>(
      (ref) => AccentColorNotifier(),
);

enum AppThemeMode { dark, amoled, light }

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier() : super(AppThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_mode') ?? 0;
    state = AppThemeMode.values[index];
  }

  Future<void> setTheme(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    state = mode;
  }
}

class AccentColorNotifier extends StateNotifier<Color> {
  AccentColorNotifier() : super(const Color(0xFFE85D75)) {
    _load();
  }

  static const List<Color> presets = [
    Color(0xFFE85D75), // Rose — default
    Color(0xFF5D7BE8), // Blue
    Color(0xFF5DE87B), // Green
    Color(0xFFE8C45D), // Gold
    Color(0xFFBE5DE8), // Purple
    Color(0xFFE8875D), // Orange
  ];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue =
        prefs.getInt('accent_color') ?? const Color(0xFFE85D75).value;
    state = Color(colorValue);
  }

  Future<void> setColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent_color', color.value);
    state = color;
  }
}

class AppTheme {
  static ThemeData build(AppThemeMode mode, Color accent) {
    switch (mode) {
      case AppThemeMode.dark:
        return _dark(accent);
      case AppThemeMode.amoled:
        return _amoled(accent);
      case AppThemeMode.light:
        return _light(accent);
    }
  }

  static ThemeData dark([Color accent = const Color(0xFFE85D75)]) =>
      _dark(accent);

  static ThemeData _dark(Color accent) {
    const background = Color(0xFF0A0A0F);
    const surface = Color(0xFF12121A);
    const surfaceVariant = Color(0xFF1C1C28);
    const outline = Color(0xFF2A2A3A);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.dark(
        primary: accent,
        onPrimary: Colors.white,
        surface: surface,
        onSurface: const Color(0xFFCCCCD8),
        surfaceContainerHighest: surfaceVariant,
        outline: outline,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFFEEEEF5),
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Color(0xFFEEEEF5)),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData _amoled(Color accent) {
    const background = Color(0xFF000000);
    const surface = Color(0xFF0A0A0A);
    const surfaceVariant = Color(0xFF111111);
    const outline = Color(0xFF1A1A1A);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.dark(
        primary: accent,
        onPrimary: Colors.white,
        surface: surface,
        onSurface: const Color(0xFFCCCCD8),
        surfaceContainerHighest: surfaceVariant,
        outline: outline,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFFEEEEF5),
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Color(0xFFEEEEF5)),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData _light(Color accent) {
    const background = Color(0xFFF5F5F8);
    const surface = Color(0xFFFFFFFF);
    const surfaceVariant = Color(0xFFEEEEF5);
    const outline = Color(0xFFDDDDE8);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: accent,
        onPrimary: Colors.white,
        surface: surface,
        onSurface: const Color(0xFF1A1A2E),
        surfaceContainerHighest: surfaceVariant,
        outline: outline,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}