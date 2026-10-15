// lib/core/theme/storyjob_theme.dart
import 'package:flutter/material.dart';

class StoryJobTheme {
  // ============================================================================
  // BASISOOBERFLÄCHEN (Deep Space & Slate)
  // ============================================================================
  static const Color backgroundBase = Color(0xFF0A0B10);        // Tiefes Raum-Schwarz aus Mockups
  static const Color backgroundElevated = Color(0xFF13151F);    // Modale, Sheets & angehobene Layer
  static const Color cardSurface = Color(0xFF181B28);           // Glassmorphism-Kartenbasis
  static const Color cardSurfaceElevated = Color(0xFF222631);   // Bestehend: Angehobene Ebene
  static const Color cardSurfaceHighlight = Color(0xFF222638);  // Highlight-Fläche
  static const Color cardSurfaceLight = Color(0xFF2B303E);      // Bestehend: Subtile Highlight-Ebene
  static const Color cardBorder = Color(0x1AFFFFFF);            // 10% Weiß für 1px-Kanten
  static const Color dividerColor = Color(0x1FFFFFFF);

  // ============================================================================
  // DAS NEON-SPEKTRUM & AKZENTFARBEN
  // ============================================================================
  static const Color primaryViolet = Color(0xFF9B51E0);         // Cyber-Violett aus Mockups
  static const Color cyanAccent = Color(0xFF00F0FF);            // Elektrisches Neon-Cyan
  static const Color pinkMagenta = Color(0xFFFF2E93);           // Resonanz-Pink / Audio-Highlight
  static const Color neonPink = Color(0xFFFF2E93);              // Alias für Abwärtskompatibilität
  static const Color amberEnergy = Color(0xFFFF9F43);           // Warmes Gold für Macher / Aktivität
  static const Color mintSuccess = Color(0xFF00F5A0);           // Match-Bestätigung / Werte-Check
  
  // Bestehende Farb-Aliase (für vorhandene Screens)
  static const Color champagneGold = Color(0xFFE2C974);
  static const Color emeraldGreen = Color(0xFF00F5A0);
  static const Color champagneAccent = Color(0xFFE7C9A9);
  static const Color goldAccent = Color(0xFFD4A574);
  static const Color warmGold = Color(0xFFFFD700);

  // ============================================================================
  // TYPOGRAFIE-FARBEN (Hohe Lesbarkeit)
  // ============================================================================
  static const Color textPrimary = Color(0xFFFFFFFF);           // Klares Weiß
  static const Color textSecondary = Color(0xFFA5ABC0);         // Helles Schiefergrau für Subtexte
  static const Color textMuted = Color(0xFF6B728D);             // Diskrete Metadaten

  // ============================================================================
  // SUBTILE GLASSMORPHISM- & HIGHLIGHT-HILFSFARBEN
  // ============================================================================
  static Color get subtleBorder => Colors.white.withValues(alpha: 0.10);
  static Color get subtleHighlight => Colors.white.withValues(alpha: 0.05);

  // ============================================================================
  // ZENTRALE GRADIENTS (VERLÄUFE AUS DEN MOCKUPS)
  // ============================================================================
  
  // 1. Der Haupt-Hero-Gradient (Banner & Top-Bars wie in den Screenshots)
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

  // 2. Audio- & Resonanz-Welle (Pink bis Cyan)
  static const LinearGradient soundWaveGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF2E93),
      Color(0xFF9B51E0),
      Color(0xFF00F0FF),
    ],
  );

  // 3. DNA-Aura (Karten-Rahmen & Badges)
  static const LinearGradient dnaCardBorder = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x809B51E0),
      Color(0x3300F0FF),
      Color(0x66FF2E93),
    ],
  );

  // Bestehende Gradients erhalten
  static const LinearGradient brandGradient = LinearGradient(
    colors: [cyanAccent, primaryViolet, champagneGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient voiceGradient = LinearGradient(
    colors: [primaryViolet, cyanAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [
      Color(0x1F9B51E0),
      Color(0x0A00F0FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================================
  // GLOW- & SCHATTENEFFEKTE
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
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: cardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryViolet.withValues(alpha: 0.20),
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: primaryViolet.withValues(alpha: 0.40)),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: cardBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardSurfaceElevated,
        hintStyle: const TextStyle(color: textMuted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cyanAccent.withValues(alpha: 0.5)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardSurface,
        modalBackgroundColor: cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
    );
  }
}