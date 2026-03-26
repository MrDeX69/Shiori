import 'package:flutter/material.dart';

class AppTheme {
  static const Color _background = Color(0xFF0A0A0F);
  static const Color _surface = Color(0xFF12121A);
  static const Color _surfaceVariant = Color(0xFF1C1C28);
  static const Color _primary = Color(0xFFE85D75);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _onBackground = Color(0xFFEEEEF5);
  static const Color _onSurface = Color(0xFFCCCCD8);
  static const Color _outline = Color(0xFF2A2A3A);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        onPrimary: _onPrimary,
        surface: _surface,
        onSurface: _onSurface,
        surfaceContainerHighest: _surfaceVariant,
        outline: _outline,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _onBackground,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: _onBackground),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surface,
        selectedItemColor: _primary,
        unselectedItemColor: Color(0xFF666677),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: _surface,
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