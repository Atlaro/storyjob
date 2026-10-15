// lib/features/growth/services/growth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:storyjob/features/growth/models/growth_journey.dart';

class GrowthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  /// Lädt die aktive Wachstumsreise des aktuellen Nutzers als Echtzeit-Stream
  Stream<GrowthJourney?> getJourneyStream({String? userId}) {
    final uid = userId ?? _currentUserId;
    if (uid == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('growth_journeys')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return GrowthJourney.fromFirestore(snapshot);
    });
  }

  /// Lädt alle Wachstums-Meilensteine des Nutzers
  Stream<List<GrowthJourney>> getJourneysListStream({String? userId}) {
    final uid = userId ?? _currentUserId;
    if (uid == null) {
      return Stream.value(const []);
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('journeys')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GrowthJourney.fromFirestore(doc))
          .toList();
    });
  }

  /// Speichert oder aktualisiert die primäre Wachstumsreise
  Future<void> saveGrowthJourney(GrowthJourney journey) async {
    final uid = _currentUserId;
    if (uid == null) return;

    try {
      final updatedJourney = journey.copyWith(userId: uid);
      await _firestore
          .collection('growth_journeys')
          .doc(uid)
          .set(updatedJourney.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('GrowthService.saveGrowthJourney Fehler: $e');
      rethrow;
    }
  }

  /// Erhöht den Fortschritt eines Schritts schrittweise (z. B. nach Audio-Aufnahme)
  Future<void> advanceStep({int incrementBy = 1}) async {
    final uid = _currentUserId;
    if (uid == null) return;

    final docRef = _firestore.collection('growth_journeys').doc(uid);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final journey = GrowthJourney.fromFirestore(snapshot);
        final newStep = journey.currentStep + incrementBy;
        final isFinished = newStep >= journey.totalSteps;

        transaction.update(docRef, {
          'currentStep': newStep,
          'isCompleted': isFinished,
          if (isFinished) 'completedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint('GrowthService.advanceStep Fehler: $e');
    }
  }

  /// Toggelt den Status der Reise (z. B. Meilenstein erreicht)
  Future<void> updateCompletionStatus(bool isCompleted) async {
    final uid = _currentUserId;
    if (uid == null) return;

    try {
      await _firestore.collection('growth_journeys').doc(uid).update({
        'isCompleted': isCompleted,
        'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
      });
    } catch (e) {
      debugPrint('GrowthService.updateCompletionStatus Fehler: $e');
    }
  }

  /// Lädt die Wachstumsreise eines Nutzers per Future
  Future<GrowthJourney?> fetchGrowthJourney(String userId) async {
    try {
      final doc = await _firestore.collection('growth_journeys').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return GrowthJourney.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('GrowthService.fetchGrowthJourney Fehler: $e');
      return null;
    }
  }
}