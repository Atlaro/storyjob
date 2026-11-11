// lib/features/match/services/story_resonance_engine.dart
import 'package:storyjob/features/identity/models/story_identity.dart';

class ResonanceResult {
  final int resonancePercentage;
  final String resonanceTitle;
  final String primaryResonanceFactor;
  final String resonanceExplanation;
  final List<String> matchingValues;
  final List<String> matchingInterests;
  final List<String> matchingCommunities;

  const ResonanceResult({
    required this.resonancePercentage,
    required this.resonanceTitle,
    required this.primaryResonanceFactor,
    this.resonanceExplanation = 'Gemeinsame Werte und Haltung im Miteinander.',
    required this.matchingValues,
    required this.matchingInterests,
    this.matchingCommunities = const [],
  });

  // Getter-Aliase zur Vermeidung von Fehlern in allen Feed- & Match-Screens
  List<String> get sharedValues => matchingValues;
  List<String> get sharedInterests => matchingInterests;
  List<String> get sharedCommunities => matchingCommunities;
  int get score => resonancePercentage;

  /// Liefert den Score als Dezimalwert zwischen 0.0 und 1.0 (z.B. für stories_feed_screen.dart)
  double get totalScore => (resonancePercentage / 100.0).clamp(0.0, 1.0);
}

class StoryResonanceEngine {
  /// Berechnet die menschliche Werte-Resonanz zwischen zwei Profilen, Werten, Engagement und Audio-Präsenz.
  static ResonanceResult calculateResonance({
    StoryIdentity? userIdentity,
    StoryIdentity? sourceIdentity,
    StoryIdentity? targetIdentity,
    List<String>? targetValues,
    List<String>? targetInterests,
    List<String>? targetCommunities,
    List<String>? companyValues,
    List<String>? companyFocusAreas,
    List<String>? candidateSkills,
    List<String>? requiredSkills,
    bool hasActiveAudioStory = true,
    bool hasVolunteerEngagement = false,
  }) {
    // 1. Quelle und Ziel zuordnen
    final source = sourceIdentity ?? userIdentity;
    final target = targetIdentity;

    final List<String> valList = targetValues ??
        companyValues ??
        target?.values ??
        [];

    final List<String> intList = targetInterests ??
        companyFocusAreas ??
        target?.interests ??
        [];

    final List<String> commList = targetCommunities ??
        target?.communities ??
        [];

    // Schnittmengen ermitteln
    final matchingValues = source?.values
            .where((v) => valList.any((t) => t.trim().toLowerCase() == v.trim().toLowerCase()))
            .toList() ??
        [];

    final matchingInterests = source?.interests
            .where((i) => intList.any((t) => t.trim().toLowerCase() == i.trim().toLowerCase()))
            .toList() ??
        [];

    final matchingCommunities = source?.communities
            .where((c) => commList.any((t) => t.trim().toLowerCase() == c.trim().toLowerCase()))
            .toList() ??
        [];

    // 2. Resonanz-Gewichtung berechnen
    double baseScore = 60.0;

    // Werte-Fundament (höchste Priorität, max +20)
    if (matchingValues.isNotEmpty) {
      baseScore += (matchingValues.length * 8).clamp(0, 20);
    }

    // Engagement & Gemeinschaft (Vereine, Ehrenamt, Region, max +12)
    final bool hasEngagementOverlap = matchingCommunities.isNotEmpty || hasVolunteerEngagement;
    if (hasEngagementOverlap) {
      baseScore += 10.0;
    }

    // Interessen & Wachstumsfelder (max +10)
    if (matchingInterests.isNotEmpty) {
      baseScore += (matchingInterests.length * 4).clamp(0, 10);
    }

    // Praxis & Macher-Passung (Abwärtskompatibilität für Skill-Listen)
    if (requiredSkills != null && requiredSkills.isNotEmpty && candidateSkills != null && candidateSkills.isNotEmpty) {
      int commonCount = candidateSkills
          .where((s) => requiredSkills.any((r) => r.trim().toLowerCase() == s.trim().toLowerCase()))
          .length;
      double ratio = commonCount / requiredSkills.length;
      baseScore += (ratio * 8.0);
    }

    // Lebendige Audio-Präsenz
    if (hasActiveAudioStory) {
      baseScore += 4.0;
    }

    int finalScore = baseScore.clamp(50.0, 98.0).toInt();

    // 3. Resonanz-Titel & Begründung erzeugen
    String primaryFactor = 'Kulturelle Wellenlänge & Haltung';
    String title = 'Hohe Werte-Resonanz ✨';
    String explanation = 'Geteilte Vorstellungen von Teamkultur, Verlässlichkeit und Zusammenarbeit auf Augenhöhe.';

    if (matchingValues.length >= 2 && matchingCommunities.isNotEmpty) {
      primaryFactor = 'Werte (${matchingValues.take(2).join(', ')}) & gemeinsame Initiative';
      title = 'Tiefe Werte-Resonanz ✨';
      explanation = 'Starke Verbindung über die Werte ${matchingValues.take(2).join(' und ')} sowie Engagement im Bereich ${matchingCommunities.first}.';
    } else if (matchingValues.length >= 2) {
      primaryFactor = 'Geteilte Werte (${matchingValues.take(2).join(', ')})';
      title = 'Werte-Harmonie ✨';
      explanation = 'Gemeinsames Fundament über gelebte Werte: ${matchingValues.take(3).join(', ')}.';
    } else if (matchingCommunities.isNotEmpty) {
      primaryFactor = 'Gemeinsame Verwurzelung (${matchingCommunities.first})';
      title = 'Gemeinschafts-Resonanz 🤝';
      explanation = 'Verbindung über geteilte Vereine, Initiativen oder regionale Verbundenheit.';
    } else if (matchingInterests.length >= 2) {
      primaryFactor = 'Fokusfelder (${matchingInterests.take(2).join(', ')})';
      title = 'Themen-Resonanz ✨';
      explanation = 'Große Schnittmenge bei aktuellen Projekten und Zukunftsthemen.';
    }

    return ResonanceResult(
      resonancePercentage: finalScore,
      resonanceTitle: title,
      primaryResonanceFactor: primaryFactor,
      resonanceExplanation: explanation,
      matchingValues: matchingValues,
      matchingInterests: matchingInterests,
      matchingCommunities: matchingCommunities,
    );
  }

  /// Kompatibilitäts-Alias für Company-spezifische Aufrufe
  static ResonanceResult calculateCompanyResonance({
    StoryIdentity? userIdentity,
    StoryIdentity? sourceIdentity,
    StoryIdentity? targetIdentity,
    List<String>? companyValues,
    List<String>? companyFocusAreas,
    List<String>? targetValues,
    List<String>? targetInterests,
    List<String>? targetCommunities,
    List<String>? candidateSkills,
    List<String>? requiredSkills,
    bool hasActiveAudioStory = true,
    bool hasVolunteerEngagement = false,
  }) {
    return calculateResonance(
      userIdentity: userIdentity,
      sourceIdentity: sourceIdentity,
      targetIdentity: targetIdentity,
      targetValues: companyValues ?? targetValues,
      targetInterests: companyFocusAreas ?? targetInterests,
      targetCommunities: targetCommunities,
      candidateSkills: candidateSkills,
      requiredSkills: requiredSkills,
      hasActiveAudioStory: hasActiveAudioStory,
      hasVolunteerEngagement: hasVolunteerEngagement,
    );
  }
}

// Typ-Aliase für bestehende Importe
typedef StoryResonanzEngine = StoryResonanceEngine;
typedef CompanyResonanceEngine = StoryResonanceEngine;