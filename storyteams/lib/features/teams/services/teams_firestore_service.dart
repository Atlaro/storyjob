// lib/features/teams/services/teams_firestore_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:storyteams/features/teams/models/team_models.dart';
import 'package:storyteams/features/teams/models/team_role.dart';

class TeamsFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser?.uid ?? 'guest_user';
  String get currentUserName {
    final name = _auth.currentUser?.displayName;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    return 'Mitglied';
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  /// Erstellt ein neues Team und setzt den Gründer automatisch als Leitung
  Future<String?> createTeam({
    required String name,
    required String type,
  }) async {
    try {
      final teamRef = _db.collection('teams').doc();
      final code = _generateInviteCode();

      final team = TeamUnit(
        id: teamRef.id,
        name: name.trim(),
        type: type,
        inviteCode: code,
      );

      await teamRef.set({
        ...team.toMap(),
        'createdBy': currentUid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Gründer als Leitung eintragen
      await teamRef.collection('members').doc(currentUid).set({
        'displayName': currentUserName,
        'role': TeamRolle.leitung.key,
        'status': AvailabilityStatus.einsatzbereit.key,
        'qualifications': ['Leitung', 'Koordination'],
        'statusNote': 'Team gegründet & bereit',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Aktives Team beim User hinterlegen
      await _db.collection('users').doc(currentUid).set({
        'activeTeamId': teamRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return teamRef.id;
    } catch (e) {
      debugPrint('TeamsFirestoreService.createTeam error: $e');
      return null;
    }
  }

  /// Beitritt über 6-stelligen Einladungscode (startet sicher als Neuling)
  Future<String?> joinTeamByCode(String rawCode) async {
    try {
      final code = rawCode.trim().toUpperCase();
      final query = await _db
          .collection('teams')
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final teamDoc = query.docs.first;
      await teamDoc.reference.collection('members').doc(currentUid).set({
        'displayName': currentUserName,
        'role': TeamRolle.neuling.key,
        'status': AvailabilityStatus.einsatzbereit.key,
        'qualifications': <String>[],
        'statusNote': 'Neu beigetreten – wartet auf Freigabe',
        'joinedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _db.collection('users').doc(currentUid).set({
        'activeTeamId': teamDoc.id,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return teamDoc.id;
    } catch (e) {
      debugPrint('TeamsFirestoreService.joinTeamByCode error: $e');
      return null;
    }
  }

  /// Aktualisiert die eigene Einsatz-Ampel & Notiz
  Future<void> updateMyStatus({
    required String teamId,
    required AvailabilityStatus status,
    String? note,
  }) async {
    try {
      await _db
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(currentUid)
          .set({
        'status': status.key,
        'statusNote': ?note,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('TeamsFirestoreService.updateMyStatus error: $e');
    }
  }

  /// Leitung / Vorstand gibt einen Neuling frei oder ändert eine Rolle
  Future<void> updateMemberRole({
    required String teamId,
    required String memberUid,
    required TeamRolle newRole,
  }) async {
    try {
      await _db
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(memberUid)
          .update({'role': newRole.key});
    } catch (e) {
      debugPrint('TeamsFirestoreService.updateMemberRole error: $e');
    }
  }

  /// Veröffentlicht einen Team-Impuls in die gemeinsame 24h-Pulse-Leiste (StoryJob + DNA)
  Future<void> publishTeamPulse({
    required String teamName,
    required String teamType,
    required String message,
  }) async {
    try {
      await _db.collection('pulse_statuses').doc(currentUid).set({
        'authorId': currentUid,
        'authorRole': 'recruiter',
        'name': teamName,
        'roleOrTag': '$teamType • StoryJob Teams',
        'message': message.trim(),
        'ecosystemBadge': 'StoryJob Teams',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('TeamsFirestoreService.publishTeamPulse error: $e');
    }
  }
}