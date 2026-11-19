// lib/features/Teams/models/teams_dna.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storyjob/features/identity/models/story_identity.dart';

class TeamDna {
  final String teamId;
  final String name;
  final String website;
  final String industry;
  final String location;
  final String missionQuote;
  final String purposeVision;
  final String teamSpiritQuote;
  final List<String> values;
  final List<String> workstyle;
  final List<String> communities;
  final List<String> benefits;
  final bool welcomesCareerChangers;
  final String careerChangerBridgeText;
  final String introVideoTitle;
  final String? logoUrl;
  final String? videoStoryUrl;
  final String? audioStoryUrl;
  final bool isVerified;

  const TeamDna({
    required this.teamId,
    required this.name,
    required this.website,
    required this.industry,
    this.location = '',
    required this.missionQuote,
    required this.purposeVision,
    this.teamSpiritQuote = '',
    this.values = const [],
    this.workstyle = const [],
    this.communities = const [],
    this.benefits = const [],
    this.welcomesCareerChangers = true,
    this.careerChangerBridgeText = '',
    this.introVideoTitle = '',
    this.logoUrl,
    this.videoStoryUrl,
    this.audioStoryUrl,
    this.isVerified = false,
  });

  bool get hasIntroVideo =>
      videoStoryUrl != null && videoStoryUrl!.trim().isNotEmpty;

  bool get hasAudioStory =>
      audioStoryUrl != null && audioStoryUrl!.trim().isNotEmpty;

  bool get hasMediaStory => hasIntroVideo || hasAudioStory;

  List<String> sharedValuesWith(StoryIdentity identity) {
    final teamSet = values.map((e) => e.trim().toLowerCase()).toSet();
    return identity.values
        .where((v) => teamSet.contains(v.trim().toLowerCase()))
        .toList();
  }

  List<String> sharedCommunitiesWith(StoryIdentity identity) {
    final teamSet = communities.map((e) => e.trim().toLowerCase()).toSet();
    return identity.communities
        .where((c) => teamSet.contains(c.trim().toLowerCase()))
        .toList();
  }

  List<String> sharedWorkstyleWith(StoryIdentity identity) {
    final teamSet = workstyle.map((e) => e.trim().toLowerCase()).toSet();
    return identity.workstyle
        .where((w) => teamSet.contains(w.trim().toLowerCase()))
        .toList();
  }

  int resonanceScoreWith(StoryIdentity identity) {
    final sharedVals = sharedValuesWith(identity).length;
    final sharedComms = sharedCommunitiesWith(identity).length;
    final sharedWork = sharedWorkstyleWith(identity).length;
    final orientationBonus =
        (welcomesCareerChangers && identity.isOpenForNewPaths) ? 1 : 0;

    final totalAnchors =
        (values.length + communities.length + workstyle.length).clamp(1, 24);
    final weightedHits =
        (sharedVals * 2.0) + sharedComms + sharedWork + orientationBonus;

    final rawScore = 50 + ((weightedHits / totalAnchors) * 49).round();
    return rawScore.clamp(50, 99);
  }

  String bridgeSummaryFor(StoryIdentity identity) {
    final sharedVals = sharedValuesWith(identity);
    if (sharedVals.isNotEmpty) {
      final joined = sharedVals.take(3).join(' • ');
      if (welcomesCareerChangers) {
        return 'Gemeinsame Werte: $joined – offen für Quereinstieg & echte Haltung.';
      }
      return 'Gemeinsame Werte: $joined – starke Basis für Zusammenarbeit.';
    }
    if (welcomesCareerChangers) {
      return careerChangerBridgeText.trim().isNotEmpty
          ? careerChangerBridgeText.trim()
          : 'Offen für Quereinsteiger & Neuorientierung – Haltung zählt vor Papier.';
    }
    return missionQuote.trim().isNotEmpty
        ? missionQuote.trim()
        : 'Kultur & Zusammenarbeit auf Augenhöhe.';
  }

  TeamDna copyWith({
    String? teamId,
    String? name,
    String? website,
    String? industry,
    String? location,
    String? missionQuote,
    String? purposeVision,
    String? teamSpiritQuote,
    List<String>? values,
    List<String>? workstyle,
    List<String>? communities,
    List<String>? benefits,
    bool? welcomesCareerChangers,
    String? careerChangerBridgeText,
    String? introVideoTitle,
    String? logoUrl,
    String? videoStoryUrl,
    String? audioStoryUrl,
    bool? isVerified,
  }) {
    return TeamDna(
      teamId: teamId ?? this.teamId,
      name: name ?? this.name,
      website: website ?? this.website,
      industry: industry ?? this.industry,
      location: location ?? this.location,
      missionQuote: missionQuote ?? this.missionQuote,
      purposeVision: purposeVision ?? this.purposeVision,
      teamSpiritQuote: teamSpiritQuote ?? this.teamSpiritQuote,
      values: values ?? this.values,
      workstyle: workstyle ?? this.workstyle,
      communities: communities ?? this.communities,
      benefits: benefits ?? this.benefits,
      welcomesCareerChangers:
          welcomesCareerChangers ?? this.welcomesCareerChangers,
      careerChangerBridgeText:
          careerChangerBridgeText ?? this.careerChangerBridgeText,
      introVideoTitle: introVideoTitle ?? this.introVideoTitle,
      logoUrl: logoUrl ?? this.logoUrl,
      videoStoryUrl: videoStoryUrl ?? this.videoStoryUrl,
      audioStoryUrl: audioStoryUrl ?? this.audioStoryUrl,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  static List<String> _parseList(dynamic raw) {
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  factory TeamDna.fromMap(Map<String, dynamic> map, String id) {
    return TeamDna(
      teamId: id,
      name: map['name'] ?? '',
      website: map['website'] ?? '',
      industry: map['industry'] ?? '',
      location: map['location'] ?? '',
      missionQuote: map['missionQuote'] ?? '',
      purposeVision: map['purposeVision'] ?? '',
      teamSpiritQuote: map['teamSpiritQuote'] ?? '',
      values: _parseList(map['values']),
      workstyle: _parseList(map['workstyle']),
      communities: _parseList(map['communities']),
      benefits: _parseList(map['benefits']),
      welcomesCareerChangers: map['welcomesCareerChangers'] ?? true,
      careerChangerBridgeText: map['careerChangerBridgeText'] ?? '',
      introVideoTitle: map['introVideoTitle'] ?? '',
      logoUrl: map['logoUrl'],
      videoStoryUrl: map['videoStoryUrl'],
      audioStoryUrl: map['audioStoryUrl'],
      isVerified: map['isVerified'] ?? false,
    );
  }

  factory TeamDna.fromFirestore(DocumentSnapshot doc) {
    final rawData = doc.data();
    final Map<String, dynamic> data =
        (rawData is Map<String, dynamic>) ? rawData : {};
    return TeamDna.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'website': website,
      'industry': industry,
      'location': location,
      'missionQuote': missionQuote,
      'purposeVision': purposeVision,
      'teamSpiritQuote': teamSpiritQuote,
      'values': values,
      'workstyle': workstyle,
      'communities': communities,
      'benefits': benefits,
      'welcomesCareerChangers': welcomesCareerChangers,
      'careerChangerBridgeText': careerChangerBridgeText,
      'introVideoTitle': introVideoTitle,
      'logoUrl': logoUrl,
      'videoStoryUrl': videoStoryUrl,
      'audioStoryUrl': audioStoryUrl,
      'isVerified': isVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}