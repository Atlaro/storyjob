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
    String location = '',
    String motto = 'Echte Kameradschaft. Kompakt organisiert.',
    String teamStory = '',
    List<String> cultureValues = const ['Teamgeist', 'Verlässlichkeit', 'Augenhöhe'],
  }) async {
    try {
      final teamRef = _db.collection('teams').doc();
      final code = _generateInviteCode();

      final team = TeamUnit(
        id: teamRef.id,
        name: name.trim(),
        type: type,
        location: location.trim(),
        inviteCode: code,
        motto: motto.trim(),
        teamStory: teamStory.trim(),
        leaderUid: currentUid,
        isVerified: true,
        cultureValues: cultureValues,
        memberUids: [currentUid],
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
        'isEngagementVerified': true,
        'verifiedBadgeTitle': 'Teamleitung • ${name.trim()}',
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
      await teamDoc.reference.update({
        'memberUids': FieldValue.arrayUnion([currentUid]),
      });

      await teamDoc.reference.collection('members').doc(currentUid).set({
        'displayName': currentUserName,
        'role': TeamRolle.neuling.key,
        'status': AvailabilityStatus.einsatzbereit.key,
        'isEngagementVerified': false,
        'verifiedBadgeTitle': '',
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
      final payload = <String, dynamic>{
        'status': status.key,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (note != null) {
        payload['statusNote'] = note.trim();
      }

      await _db
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(currentUid)
          .set(payload, SetOptions(merge: true));
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

  /// Vergibt oder entzieht das offizielle Engagement-Verifikations-Badge
  /// und synchronisiert die Bestätigung ins gemeinsame User-Profil (Single Source of Truth)
  Future<void> setMemberEngagementVerification({
    required String teamId,
    required String teamName,
    required String memberUid,
    required bool verified,
    String? badgeTitle,
  }) async {
    try {
      final finalTitle = (badgeTitle != null && badgeTitle.trim().isNotEmpty)
          ? badgeTitle.trim()
          : 'Verifiziertes Engagement • $teamName';

      await _db
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(memberUid)
          .set({
        'isEngagementVerified': verified,
        'verifiedBadgeTitle': verified ? finalTitle : '',
        'verifiedAt': verified ? FieldValue.serverTimestamp() : FieldValue.delete(),
      }, SetOptions(merge: true));

      final userRef = _db.collection('users').doc(memberUid);
      if (verified) {
        await userRef.set({
          'verifiedTeams': FieldValue.arrayUnion([
            {
              'teamId': teamId,
              'teamName': teamName,
              'badgeTitle': finalTitle,
            }
          ]),
        }, SetOptions(merge: true));
      } else {
        final userSnap = await userRef.get();
        final existing = userSnap.data()?['verifiedTeams'];
        if (existing is List) {
          final updated = existing
              .where((item) => item is Map && item['teamId'] != teamId)
              .toList();
          await userRef.set({'verifiedTeams': updated}, SetOptions(merge: true));
        }
      }
    } catch (e) {
      debugPrint('TeamsFirestoreService.setMemberEngagementVerification error: $e');
    }
  }

  /// Aktualisiert die Qualifikationen eines Mitglieds (z. B. Atemschutz, RDH, Gruppenführer)
  Future<void> updateMemberQualifications({
    required String teamId,
    required String memberUid,
    required List<String> qualifications,
  }) async {
    try {
      await _db
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(memberUid)
          .set({
        'qualifications': qualifications,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('TeamsFirestoreService.updateMemberQualifications error: $e');
    }
  }

  /// Erstellt einen Dienst-, Übungs- oder Einsatztermin im Team
  Future<void> createTeamEvent({
    required String teamId,
    required String title,
    required String category,
    required String dateLabel,
    required String location,
    String description = '',
  }) async {
    try {
      await _db.collection('teams').doc(teamId).collection('events').add({
        'title': title.trim(),
        'category': category,
        'dateLabel': dateLabel.trim(),
        'location': location.trim(),
        'description': description.trim(),
        'acceptedUids': [currentUid],
        'declinedUids': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('TeamsFirestoreService.createTeamEvent error: $e');
    }
  }

  /// Zu- oder Absage für einen Team-Termin
  Future<void> respondToEvent({
    required String teamId,
    required String eventId,
    required bool accept,
  }) async {
    try {
      final ref = _db.collection('teams').doc(teamId).collection('events').doc(eventId);
      if (accept) {
        await ref.update({
          'acceptedUids': FieldValue.arrayUnion([currentUid]),
          'declinedUids': FieldValue.arrayRemove([currentUid]),
        });
      } else {
        await ref.update({
          'declinedUids': FieldValue.arrayUnion([currentUid]),
          'acceptedUids': FieldValue.arrayRemove([currentUid]),
        });
      }
    } catch (e) {
      debugPrint('TeamsFirestoreService.respondToEvent error: $e');
    }
  }

  /// Aktualisiert Team-Werte & Kultur-Motto
  Future<void> updateTeamCulture({
    required String teamId,
    required String motto,
    required String teamStory,
    required List<String> cultureValues,
  }) async {
    try {
      await _db.collection('teams').doc(teamId).set({
        'motto': motto.trim(),
        'teamStory': teamStory.trim(),
        'cultureValues': cultureValues,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('TeamsFirestoreService.updateTeamCulture error: $e');
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