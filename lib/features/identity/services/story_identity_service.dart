// lib/features/identity/services/story_identity_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:storyjob/features/identity/models/story_identity.dart';

class StoryResonanceAnalysis {
  final int sharedValuesCount;
  final List<String> sharedValues;
  final List<String> sharedCommunities;
  final String resonanceReason;

  const StoryResonanceAnalysis({
    this.sharedValuesCount = 0,
    this.sharedValues = const [],
    this.sharedCommunities = const [],
    this.resonanceReason = 'Gemeinsame Werte & Haltung',
  });

  bool get hasResonance => sharedValues.isNotEmpty || sharedCommunities.isNotEmpty;
}

class StoryIdentityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lädt die Identität eines Nutzers einmalig per Future
  Future<StoryIdentity?> getIdentity(String userId) async {
    try {
      final doc = await _firestore.collection('user_identities').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return StoryIdentity.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('StoryIdentityService.getIdentity Fehler: $e');
      return null;
    }
  }

  /// Alias für Screens, die loadIdentity erwarten
  Future<StoryIdentity?> loadIdentity(String userId) async {
    return getIdentity(userId);
  }

  /// Echtzeit-Stream für Screens, die auf Identitäts-Änderungen lauschen
  Stream<StoryIdentity?> getIdentityStream(String userId) {
    return _firestore
        .collection('user_identities')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return StoryIdentity.fromFirestore(snapshot);
    });
  }

  /// Speichert die StoryJob DNA™ konsistent ab und synchronisiert den Entfaltungsgrad
  Future<void> saveIdentity(String userId, StoryIdentity identity) async {
    try {
      final completeness = identity.completenessPercent;

      // 1. Primäre Speicherung in user_identities
      await _firestore.collection('user_identities').doc(userId).set(
            identity.toMap(),
            SetOptions(merge: true),
          );

      // 2. Synchronisation der Kern-Tags & Entfaltungsgrad in users/{userId}
      await _firestore.collection('users').doc(userId).set({
        'values': identity.values,
        'interests': identity.interests,
        'strengths': identity.strengths,
        'workstyle': identity.workstyle,
        'communities': identity.communities,
        'impactVision': identity.impactVision,
        'dnaCompleteness': completeness,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('StoryIdentityService.saveIdentity Fehler: $e');
      rethrow;
    }
  }

  /// Vergleicht zwei Identitäten und gibt die menschlichen Resonanzpunkte zurück
  Future<StoryResonanceAnalysis> calculateResonanceBetween({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final myIdentity = await getIdentity(currentUserId);
      final targetIdentity = await getIdentity(targetUserId);

      if (myIdentity == null || targetIdentity == null) {
        return const StoryResonanceAnalysis();
      }

      final sharedValues = myIdentity.findSharedValues(targetIdentity);
      final sharedCommunities = myIdentity.findSharedCommunities(targetIdentity);

      String reason = 'Gleiche Wellenlänge im Team';
      if (sharedValues.isNotEmpty && sharedCommunities.isNotEmpty) {
        reason = 'Geteilte Werte (${sharedValues.first}) & gemeinsame Initiative';
      } else if (sharedValues.isNotEmpty) {
        reason = 'Verbindung über Werte: ${sharedValues.take(2).join(', ')}';
      } else if (sharedCommunities.isNotEmpty) {
        reason = 'Gemeinsame Verwurzelung: ${sharedCommunities.first}';
      }

      return StoryResonanceAnalysis(
        sharedValuesCount: sharedValues.length,
        sharedValues: sharedValues,
        sharedCommunities: sharedCommunities,
        resonanceReason: reason,
      );
    } catch (e) {
      debugPrint('StoryIdentityService.calculateResonanceBetween Fehler: $e');
      return const StoryResonanceAnalysis();
    }
  }
}