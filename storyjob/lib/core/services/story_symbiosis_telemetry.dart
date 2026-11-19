// lib/core/services/story_symbiosis_telemetry.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class EcosystemInvestorSnapshot {
  final int activeStoriesCount;
  final int teamStoriesCount;
  final int talentStoriesCount;
  final int careerChangerFriendlyTeams;
  final int openOrientationTalents;
  final int totalImpulses;
  final int totalDialogs;

  const EcosystemInvestorSnapshot({
    required this.activeStoriesCount,
    required this.teamStoriesCount,
    required this.talentStoriesCount,
    required this.careerChangerFriendlyTeams,
    required this.openOrientationTalents,
    required this.totalImpulses,
    required this.totalDialogs,
  });

  double get impulseToDialogConversionPercent {
    if (totalImpulses <= 0) return 0.0;
    return ((totalDialogs / totalImpulses) * 100).clamp(0.0, 100.0);
  }
}

class StorySymbiosisTelemetry {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> recordEcosystemEvent({
    required String eventName,
    required String roleContext,
    String targetId = '',
    String category = '',
    List<String> sharedValues = const [],
    bool isCareerChangerBridge = false,
    bool isOrientationRadarActive = false,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      await _db.collection('ecosystem_telemetry_events').add({
        'eventName': eventName,
        'roleContext': roleContext,
        'actorId': currentUser?.uid ?? 'guest_user',
        'targetId': targetId,
        'category': category,
        'sharedValuesCount': sharedValues.length,
        'sharedValues': sharedValues,
        'isCareerChangerBridge': isCareerChangerBridge,
        'isOrientationRadarActive': isOrientationRadarActive,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('StorySymbiosisTelemetry Fehler ($eventName): $e');
    }
  }

  static Future<EcosystemInvestorSnapshot> loadInvestorSnapshot() async {
    final storiesSnap = await _db.collection('stories').limit(200).get();
    final teamsSnap = await _db.collection('companies').limit(200).get();
    final identitiesSnap =
        await _db.collection('story_identities').limit(200).get();
    final dialogsSnap = await _db.collection('dialogs').limit(200).get();

    int teamStories = 0;
    int talentStories = 0;
    int impulses = 0;

    for (final doc in storiesSnap.docs) {
      final data = doc.data();
      final org = (data['organizationName'] as String?)?.trim() ?? '';
      final likes = (data['likesCount'] as num?)?.toInt() ?? 0;
      impulses += likes;
      if (org.isNotEmpty) {
        teamStories++;
      } else {
        talentStories++;
      }
    }

    int bridgeTeams = 0;
    for (final doc in teamsSnap.docs) {
      final data = doc.data();
      if (data['welcomesCareerChangers'] == true) {
        bridgeTeams++;
      }
    }

    int openTalents = 0;
    for (final doc in identitiesSnap.docs) {
      final data = doc.data();
      if (data['isOpenForNewPaths'] == true) {
        openTalents++;
      }
    }

    return EcosystemInvestorSnapshot(
      activeStoriesCount: storiesSnap.docs.length,
      teamStoriesCount: teamStories,
      talentStoriesCount: talentStories,
      careerChangerFriendlyTeams: bridgeTeams,
      openOrientationTalents: openTalents,
      totalImpulses: impulses,
      totalDialogs: dialogsSnap.docs.length,
    );
  }
}