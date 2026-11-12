// lib/features/teams/models/team_role.dart
import 'package:flutter/material.dart';
import 'package:storyteams/core/theme/storyjob_theme.dart';

enum TeamRolle {
  leitung,
  vorstand,
  mitglied,
  anwaerter,
  neuling,
}

extension TeamRolleInfo on TeamRolle {
  String get key => name;

  static TeamRolle fromKey(String? raw) {
    return TeamRolle.values.firstWhere(
      (r) => r.name == raw,
      orElse: () => TeamRolle.neuling,
    );
  }

  String get titel {
    switch (this) {
      case TeamRolle.leitung:
        return 'Leitung';
      case TeamRolle.vorstand:
        return 'Vorstand';
      case TeamRolle.mitglied:
        return 'Mitglied';
      case TeamRolle.anwaerter:
        return 'Anwärter';
      case TeamRolle.neuling:
        return 'Neuling';
    }
  }

  String get beschreibung {
    switch (this) {
      case TeamRolle.leitung:
        return 'Volle Kontrolle, Teamverwaltung & höchste Verantwortung';
      case TeamRolle.vorstand:
        return 'Operative Führung, Einteilungen & Mitglieder-Freigabe';
      case TeamRolle.mitglied:
        return 'Aktive Teilnahme, Status-Ampel & Einsatz-/Dienstplan';
      case TeamRolle.anwaerter:
        return 'In Ausbildung oder Probezeit mit Zugriff auf Übungen';
      case TeamRolle.neuling:
        return 'Neu beigetreten per Code, wartet auf interne Freigabe';
    }
  }

  bool get darfVerwalten => this == TeamRolle.leitung || this == TeamRolle.vorstand;
  bool get istAktiv => this != TeamRolle.neuling;
}

enum AvailabilityStatus {
  einsatzbereit,
  bedingt,
  abwesend,
}

extension AvailabilityInfo on AvailabilityStatus {
  String get key => name;

  static AvailabilityStatus fromKey(String? raw) {
    return AvailabilityStatus.values.firstWhere(
      (s) => s.name == raw,
      orElse: () => AvailabilityStatus.einsatzbereit,
    );
  }

  String get label {
    switch (this) {
      case AvailabilityStatus.einsatzbereit:
        return 'Einsatzbereit';
      case AvailabilityStatus.bedingt:
        return 'Bedingt abkömmlich';
      case AvailabilityStatus.abwesend:
        return 'Abwesend / Ruhe';
    }
  }

  Color get color {
    switch (this) {
      case AvailabilityStatus.einsatzbereit:
        return StoryJobTheme.mintSuccess;
      case AvailabilityStatus.bedingt:
        return StoryJobTheme.amberEnergy;
      case AvailabilityStatus.abwesend:
        return const Color(0xFFEF4444);
    }
  }
}