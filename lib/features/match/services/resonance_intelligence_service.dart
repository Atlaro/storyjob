// lib/features/match/services/resonance_intelligence_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ResonancePairData {
  final String pairId;
  final int totalInteractions;
  final int voiceListenedSeconds;
  final int voiceExchangedCount;
  final int sparksCount;
  final String connectionStage; // 'discovered', 'in_dialog', 'call_scheduled', 'connected', 'collaborating'
  final int dialogDepth;

  const ResonancePairData({
    required this.pairId,
    required this.totalInteractions,
    required this.voiceListenedSeconds,
    required this.voiceExchangedCount,
    required this.sparksCount,
    required this.connectionStage,
    required this.dialogDepth,
  });

  factory ResonancePairData.fromFirestore(Map<String, dynamic> data) {
    return ResonancePairData(
      pairId: data['pairId'] ?? '',
      totalInteractions: data['totalInteractions'] ?? 0,
      voiceListenedSeconds: data['voiceListenedSeconds'] ?? 0,
      voiceExchangedCount: data['voiceExchangedCount'] ?? 0,
      sparksCount: data['sparksCount'] ?? 0,
      connectionStage: data['connectionStage'] ?? data['appointmentStage'] ?? 'discovered',
      dialogDepth: data['dialogDepth'] ?? data['funnelDepth'] ?? 1,
    );
  }

  /// Berechnet die Tiefe der menschlichen Verbindung (0 bis 100 %)
  int get relationshipStrength {
    int score = (dialogDepth * 15);
    score += (voiceExchangedCount * 10).clamp(0, 30);
    score += (sparksCount * 5).clamp(0, 15);
    if (connectionStage == 'connected' || connectionStage == 'confirmed') score += 25;
    if (connectionStage == 'collaborating' || connectionStage == 'hired') score = 100;
    return score.clamp(0, 100);
  }

  String get stageLabel {
    switch (connectionStage) {
      case 'collaborating':
      case 'hired':
        return 'Gemeinsam am Start ✨';
      case 'connected':
      case 'confirmed':
        return 'Persönlich verbunden';
      case 'call_scheduled':
        return 'Kennenlernen vereinbart';
      case 'in_dialog':
        return 'Im aktiven Austausch';
      case 'discovered':
      default:
        return 'Resonanz entdeckt';
    }
  }
}

class ResonanceIntelligenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

  String _generatePairId(String targetId) {
    final ids = [_currentUserId, targetId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Liefert einen Live-Stream der Resonanz- und Dialogstufe zwischen zwei Menschen
  Stream<ResonancePairData?> streamPairData(String targetId) {
    if (_currentUserId == 'guest_user' || targetId.isEmpty) {
      return Stream.value(null);
    }

    final pairId = _generatePairId(targetId);
    return _firestore
        .collection('resonance_pairs')
        .doc(pairId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) return null;
          return ResonancePairData.fromFirestore(snapshot.data()!);
        });
  }

  /// Erfasst einen getauschten Audio-Impuls oder Dialog-Moment
  Future<void> recordVoiceInteraction({
    required String targetId,
    int listenedSeconds = 0,
  }) async {
    if (_currentUserId == 'guest_user' || targetId.isEmpty) return;
    final pairId = _generatePairId(targetId);

    try {
      await _firestore.collection('resonance_pairs').doc(pairId).set({
        'pairId': pairId,
        'totalInteractions': FieldValue.increment(1),
        'voiceListenedSeconds': FieldValue.increment(listenedSeconds),
        'voiceExchangedCount': FieldValue.increment(1),
        'lastInteractionAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Fehler bei recordVoiceInteraction: $e');
    }
  }

  /// Hält den aktuellen Status des Kennenlernens fest
  Future<void> updateConnectionStage({
    required String targetId,
    required String stage, // 'in_dialog' | 'call_scheduled' | 'connected' | 'collaborating' | 'closed'
  }) async {
    final pairId = _generatePairId(targetId);
    try {
      await _firestore.collection('resonance_pairs').doc(pairId).set({
        'pairId': pairId,
        'connectionStage': stage,
        'stageUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('⚡ [ResonanceIntelligence] Stufe erfasst: $stage für Pair $pairId');
    } catch (e) {
      debugPrint('❌ Fehler beim Speichern der Verbindungsstufe: $e');
    }
  }

  /// Abwärtskompatibilitäts-Methode für bestehende Aufrufe
  Future<void> reportOutcome({
    required String targetId,
    required String status,
  }) async {
    final mappedStage = status == 'hired'
        ? 'collaborating'
        : (status == 'interview_passed' ? 'connected' : 'closed');
    return updateConnectionStage(targetId: targetId, stage: mappedStage);
  }
}