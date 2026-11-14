import 'package:flutter/material.dart';

class StoryJobTheme {
  // Hintergrundfarben (Mystic Dark)
  static const Color bg0 = Color(0xFF070A12);
  static const Color bg1 = Color(0xFF0B1020);
  static const Color backgroundBase = bg0;
  static const Color cardDark = Color(0xFF111827);
  static const Color cardSurface = Color(0xFF0E1426);
  static const Color cardSurfaceElevated = Color(0xFF151E36);

  // Markenfarben & Akzente
  static const Color primaryViolet = Color(0xFF7C3AED); // Gemeinschaft & Kultur
  static const Color cyanAccent = Color(0xFF22D3EE);    // Team-Signal & Bewegung
  static const Color goldAccent = Color(0xFFF59E0B);    // Verifikations-Badge & Ehrenamt
  static const Color pinkMagenta = Color(0xFFEC4899);   // DNA-Resonanz-Akzent
  static const Color mintSuccess = Color(0xFF10B981);   // Status-Ampel: Einsatzbereit / Aktiv
  static const Color amberEnergy = Color(0xFFF59E0B);   // Status-Ampel: Bedingt / Hinweis

  // Textfarben
  static const Color textPrimary = Color(0xF0FFFFFF);
  static const Color textSecondary = Color(0xB8FFFFFF);
  static const Color textMuted = textSecondary;
  static const Color textSubtle = Color(0x85FFFFFF);

  // Glas-Effekte & Rahmen
  static const Color cardBorder = Color(0x1FFFFFFF);
  static Color glassBackground = Colors.white.withValues(alpha: 0.05);
  static Color glassBackgroundElevated = Colors.white.withValues(alpha: 0.08);
  static Color glassBorder = cardBorder;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg0,
      colorScheme: const ColorScheme.dark(
        primary: cyanAccent,
        secondary: primaryViolet,
        tertiary: goldAccent,
        surface: bg1,
        onPrimary: bg0,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: glassBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cyanAccent,
          foregroundColor: bg0,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        hintStyle: const TextStyle(color: textSubtle, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cyanAccent, width: 1.5),
        ),
      ),
    );
  }

  static BoxDecoration glassBox({
    double radius = 20,
    Color? borderColor,
    bool elevated = false,
  }) {
    return BoxDecoration(
      color: elevated ? glassBackgroundElevated : glassBackground,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? cardBorder,
        width: 1,
      ),
    );
  }
}