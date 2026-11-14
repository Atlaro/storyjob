enum TeamRolle {
  leitung,
  vorstand,
  mitglied,
  anwaerter,
  neuling,
}

extension TeamRolleInfo on TeamRolle {
  String get key => name;

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