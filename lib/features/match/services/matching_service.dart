// lib/features/match/services/matching_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class MatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

  /// Registriert ein Resonanz-Signal auf eine Story oder Initiative
  Future<bool> registerResonanceInterest({
    required String targetEntityId,
    required String storyId,
    String resonanceLevel = 'Hohe Resonanz ✨',
    List<String> sharedValues = const [],
    String resonanceReason = 'Gemeinsame Werte und Haltung.',
  }) async {
    try {
      final docId = _currentUserId.compareTo(targetEntityId) < 0
          ? '${_currentUserId}_$targetEntityId'
          : '${targetEntityId}_$_currentUserId';

      final matchDocRef = _firestore.collection('resonances').doc(docId);
      final existingDoc = await matchDocRef.get();

      final existingData = existingDoc.data() ?? {};
      final bool otherPartyInterested = existingData['initiatedBy'] != _currentUserId &&
          existingData['hasInterestedParty'] == true;

      if (existingDoc.exists && otherPartyInterested) {
        // Beidseitige Resonanz entstanden!
        final batch = _firestore.batch();

        batch.set(
          matchDocRef,
          {
            'participantA': _currentUserId,
            'participantB': targetEntityId,
            'storyId': storyId,
            'isMutualResonance': true,
            'connectedAt': FieldValue.serverTimestamp(),
            'resonanceLevel': resonanceLevel,
            'sharedValues': sharedValues,
            'resonanceReason': resonanceReason,
          },
          SetOptions(merge: true),
        );

        final chatId = 'dialog_$docId';
        final dialogRef = _firestore.collection('dialogs').doc(chatId);

        batch.set(
          dialogRef,
          {
            'chatId': chatId,
            'participants': [_currentUserId, targetEntityId],
            'resonanceLevel': resonanceLevel,
            'sharedValues': sharedValues,
            'resonanceReason': resonanceReason,
            'createdAt': FieldValue.serverTimestamp(),
            'lastMessage': 'Werte-Resonanz entdeckt ✨ Startet euren Dialog auf Augenhöhe.',
            'lastMessageTimestamp': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        await batch.commit();
        return true;
      } else {
        // Erstes Signal speichern
        await matchDocRef.set({
          'participantA': _currentUserId,
          'participantB': targetEntityId,
          'initiatedBy': _currentUserId,
          'hasInterestedParty': true,
          'storyId': storyId,
          'isMutualResonance': false,
          'signaledAt': FieldValue.serverTimestamp(),
          'resonanceLevel': resonanceLevel,
          'sharedValues': sharedValues,
          'resonanceReason': resonanceReason,
        }, SetOptions(merge: true));

        return false;
      }
    } catch (e) {
      debugPrint('Fehler bei registerResonanceInterest: $e');
      return false;
    }
  }

  /// Abwärtskompatibilitäts-Methode für bestehende Aufrufe
  Future<bool> registerTalentInterest({
    required String targetCompanyId,
    required String jobStoryId,
    required String matchScore,
    List<String> sharedValues = const [],
    String resonanceReason = 'Gemeinsame Werte und Haltung.',
  }) async {
    return registerResonanceInterest(
      targetEntityId: targetCompanyId,
      storyId: jobStoryId,
      resonanceLevel: matchScore,
      sharedValues: sharedValues,
      resonanceReason: resonanceReason,
    );
  }

  /// Stream aller aktiven Dialoge des aktuellen Nutzers
  Stream<QuerySnapshot<Map<String, dynamic>>> getDialogsStream() {
    return _firestore
        .collection('dialogs')
        .where('participants', arrayContains: _currentUserId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }
}