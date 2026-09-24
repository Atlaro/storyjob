import 'package:flutter/material.dart';

class StoryJobTheme {
  static const Color backgroundBase = Color(0xFF0F111A);
  static const Color cardSurface = Color(0xFF1A1D2E);
  static const Color cardSurfaceLight = Color(0xFF252A41);
  static const Color cardBorder = Color(0xFF2A2F4C);
  static const Color primaryViolet = Color(0xFF7C3AED);
  static const Color neonPink = Color(0xFFEC4899);
  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundBase,
      primaryColor: primaryViolet,
      colorScheme: const ColorScheme.dark(
        primary: primaryViolet,
        secondary: neonPink,
        surface: cardSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundBase,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}