import 'package:flutter/material.dart';

class StoryJobTheme {
  // ============================================================================
  // BASISOOBERFLÄCHEN (Deep Space & Slate)
  // ============================================================================
  static const Color backgroundBase = Color(0xFF0A0B10);
  static const Color backgroundElevated = Color(0xFF13151F);
  static const Color cardSurface = Color(0xFF181B28);
  static const Color cardSurfaceElevated = Color(0xFF222631);
  static const Color cardSurfaceHighlight = Color(0xFF222638);
  static const Color cardSurfaceLight = Color(0xFF2B303E);
  static const Color cardBorder = Color(0x1AFFFFFF);
  static const Color dividerColor = Color(0x1FFFFFFF);

  // ============================================================================
  // DAS NEON-SPEKTRUM & AKZENTFARBEN
  // ============================================================================
  static const Color primaryViolet = Color(0xFF9B51E0);
  static const Color cyanAccent = Color(0xFF00F0FF);
  static const Color pinkMagenta = Color(0xFFFF2E93);
  static const Color neonPink = Color(0xFFFF2E93);
  static const Color amberEnergy = Color(0xFFFF9F43);
  static const Color mintSuccess = Color(0xFF00F5A0);
  static const Color champagneGold = Color(0xFFE2C974);

  // ============================================================================
  // TYPOGRAFIE-FARBEN
  // ============================================================================
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA5ABC0);
  static const Color textMuted = Color(0xFF6B728D);

  static Color get subtleBorder => Colors.white.withValues(alpha: 0.10);
  static Color get subtleHighlight => Colors.white.withValues(alpha: 0.05);

  // ============================================================================
  // GRADIENTS
  // ============================================================================
  static const LinearGradient heroBannerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF8A2BE2),
      Color(0xFF9B51E0),
      Color(0xFF00D2FF),
      Color(0xFF00F0FF),
    ],
  );

  static const LinearGradient soundWaveGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF2E93),
      Color(0xFF9B51E0),
      Color(0xFF00F0FF),
    ],
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [cyanAccent, primaryViolet, champagneGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================================
  // SCHATTEN & GLOW
  // ============================================================================
  static List<BoxShadow> neonGlow(Color color, {double intensity = 0.4}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: intensity * 0.7),
        blurRadius: 28,
        spreadRadius: 2,
      ),
      BoxShadow(
        color: color.withValues(alpha: intensity * 0.35),
        blurRadius: 55,
        spreadRadius: 6,
      ),
    ];
  }

  // ============================================================================
  // GLOBALES MATERIAL 3 THEME
  // ============================================================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundBase,
      primaryColor: primaryViolet,
      canvasColor: backgroundElevated,
      colorScheme: const ColorScheme.dark(
        primary: primaryViolet,
        secondary: cyanAccent,
        tertiary: pinkMagenta,
        surface: cardSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
      ),
    );
  }
}