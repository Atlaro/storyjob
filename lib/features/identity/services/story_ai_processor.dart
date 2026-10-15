// lib/features/identity/services/story_ai_processor.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class StoryExtractionResult {
  final List<String> extractedCommunities;
  final List<String> extractedValues;
  final List<String> extractedWorkstyle;
  final List<String> extractedMotivators;

  const StoryExtractionResult({
    this.extractedCommunities = const [],
    this.extractedValues = const [],
    this.extractedWorkstyle = const [],
    this.extractedMotivators = const [],
  });

  bool get hasMatches =>
      extractedCommunities.isNotEmpty ||
      extractedValues.isNotEmpty ||
      extractedWorkstyle.isNotEmpty ||
      extractedMotivators.isNotEmpty;
}

class StoryAiProcessor {
  /// Analysiert Audio-Transkriptionen per Haltungs- und Sinn-Erkennung
  /// und speichert Werte, Arbeitsweisen & Engagement für das Resonanz-Matching.
  static Future<StoryExtractionResult> processAndTagProfile({
    required String userId,
    required String transcriptText,
  }) async {
    try {
      debugPrint('StoryAiProcessor: Starte wertebasierte Analyse für User: $userId');

      final Set<String> communities = {};
      final Set<String> values = {};
      final Set<String> workstyle = {};
      final Set<String> motivators = {};

      final lowerText = transcriptText.toLowerCase();

      // 1. Ehrenamt, Vereine & Einsatzwesen
      if (lowerText.contains('brk') ||
          lowerText.contains('rettungsdienst') ||
          lowerText.contains('sanitäter') ||
          lowerText.contains('notfall') ||
          lowerText.contains('katastrophenschutz')) {
        communities.add('Feuerwehr, THW & Rettungsdienst');
        values.add('Ruhe & Verlässlichkeit in Krisen');
      }
      if (lowerText.contains('feuerwehr') ||
          lowerText.contains('brandschutz') ||
          lowerText.contains('löschzug') ||
          lowerText.contains('thw')) {
        communities.add('Feuerwehr, THW & Rettungsdienst');
        values.add('Gemeinschaft & Zusammenhalt');
      }
      if (lowerText.contains('verein') ||
          lowerText.contains('sportverein') ||
          lowerText.contains('ehrenamt') ||
          lowerText.contains('jugendarbeit')) {
        communities.add('Sport- & Heimatvereine');
        values.add('Gemeinschaft & Zusammenhalt');
      }

      // 2. Macher, Praxis & Handwerk
      if (lowerText.contains('handwerk') ||
          lowerText.contains('baustelle') ||
          lowerText.contains('praxis') ||
          lowerText.contains('anpacken') ||
          lowerText.contains('hands-on') ||
          lowerText.contains('machen')) {
        communities.add('Handwerk, Macher & Gewerbe');
        values.add('Hands-on & Machen');
        workstyle.add('Vor Ort & Hands-on im Geschehen');
        motivators.add('Sichtbare Ergebnisse & echtes Handwerk');
      }

      // 3. Werte & menschliche Haltung
      if (lowerText.contains('verantwortung') ||
          lowerText.contains('führung') ||
          lowerText.contains('verlässlich') ||
          lowerText.contains('loyal')) {
        values.add('Verantwortung & Verlässlichkeit');
      }
      if (lowerText.contains('ehrlich') ||
          lowerText.contains('bodenständig') ||
          lowerText.contains('augenhöhe') ||
          lowerText.contains('respekt')) {
        values.add('Bodenständigkeit & Ehrlichkeit');
        values.add('Wertschätzung & Augenhöhe');
      }
      if (lowerText.contains('nachhaltigkeit') ||
          lowerText.contains('solar') ||
          lowerText.contains('klima') ||
          lowerText.contains('erneuerbar')) {
        communities.add('Klima, Natur & Nachhaltigkeit');
        values.add('Nachhaltigkeit & Respekt');
      }
      if (lowerText.contains('innovation') ||
          lowerText.contains('ki') ||
          lowerText.contains('technologie') ||
          lowerText.contains('zukunft') ||
          lowerText.contains('digital')) {
        values.add('Mut, Neugier & Innovation');
      }

      // 4. Arbeitsweise & Antrieb
      if (lowerText.contains('team') ||
          lowerText.contains('miteinander') ||
          lowerText.contains('zusammen')) {
        workstyle.add('Enge Teamabsprachen auf Augenhöhe');
        motivators.add('Zusammenhalt & verlässliche Gemeinschaft');
      }
      if (lowerText.contains('selbstständig') ||
          lowerText.contains('frei') ||
          lowerText.contains('eigenverantwortlich')) {
        workstyle.add('Eigenverantwortliche Gestaltung & Vertrauen');
        motivators.add('Freiheit & eigenverantwortliches Arbeiten');
      }
      if (lowerText.contains('sinn') ||
          lowerText.contains('wirkung') ||
          lowerText.contains('helfen')) {
        motivators.add('Sinnstiftende Aufgaben & echter Nutzen');
      }

      final result = StoryExtractionResult(
        extractedCommunities: communities.toList(),
        extractedValues: values.toList(),
        extractedWorkstyle: workstyle.toList(),
        extractedMotivators: motivators.toList(),
      );

      // Speicherung im Profil
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('users').doc(userId).set({
        'aiTagsEngagement': FieldValue.arrayUnion(result.extractedCommunities),
        'aiTagsValues': FieldValue.arrayUnion(result.extractedValues),
        'lastAiProcessedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Synchronisation in user_identities für die StoryJob DNA™
      if (result.hasMatches) {
        final Map<String, dynamic> identityUpdates = {
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (result.extractedValues.isNotEmpty) {
          identityUpdates['values'] = FieldValue.arrayUnion(result.extractedValues);
        }
        if (result.extractedCommunities.isNotEmpty) {
          identityUpdates['communities'] = FieldValue.arrayUnion(result.extractedCommunities);
        }
        if (result.extractedWorkstyle.isNotEmpty) {
          identityUpdates['workstyle'] = FieldValue.arrayUnion(result.extractedWorkstyle);
        }
        if (result.extractedMotivators.isNotEmpty) {
          identityUpdates['motivators'] = FieldValue.arrayUnion(result.extractedMotivators);
        }

        await firestore.collection('user_identities').doc(userId).set(
          identityUpdates,
          SetOptions(merge: true),
        );
      }

      debugPrint(
        'StoryAiProcessor: Erfolgreich abgeschlossen ('
        '${result.extractedValues.length} Werte, '
        '${result.extractedCommunities.length} Engagements, '
        '${result.extractedWorkstyle.length} Arbeitsweisen).',
      );

      return result;
    } catch (e) {
      debugPrint('StoryAiProcessor Fehler: $e');
      return const StoryExtractionResult();
    }
  }
}