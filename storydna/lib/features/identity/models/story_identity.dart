// lib/features/identity/models/story_identity.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ResonanceEcho {
  final String id;
  final String fromName;
  final String contextTag; // z. B. "StoryJob Teams • Einsatz" oder "Projektpartner"
  final String valueBadge; // z. B. "Verlässlichkeit"
  final String message;
  final String timeAgo;

  const ResonanceEcho({
    required this.id,
    required this.fromName,
    required this.contextTag,
    required this.valueBadge,
    required this.message,
    required this.timeAgo,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'fromName': fromName,
        'contextTag': contextTag,
        'valueBadge': valueBadge,
        'message': message,
        'timeAgo': timeAgo,
      };

  factory ResonanceEcho.fromMap(Map<String, dynamic> map) {
    return ResonanceEcho(
      id: map['id']?.toString() ?? '',
      fromName: map['fromName']?.toString() ?? 'Wegbegleiter',
      contextTag: map['contextTag']?.toString() ?? 'Netzwerk',
      valueBadge: map['valueBadge']?.toString() ?? 'Werte-Match',
      message: map['message']?.toString() ?? '',
      timeAgo: map['timeAgo']?.toString() ?? 'Kürzlich',
    );
  }
}

class StoryIdentity {
  final String userId;
  final String displayName;
  final String headline;
  final String visibilityScope; // 'network', 'teams', 'private'
  final List<String> values;
  final List<String> interests;
  final List<String> strengths;
  final List<String> motivators;
  final List<String> goals;
  final List<String> workstyle;
  final List<String> communities; // Engagement, Vereine, Initiativen
  final List<String> learningInterests;
  final String impactVision;
  final List<ResonanceEcho> echoes;

  const StoryIdentity({
    this.userId = '',
    this.displayName = 'Mitglied',
    this.headline = 'Macher, Teamplayer & Brückenbauer',
    this.visibilityScope = 'network',
    this.values = const [],
    this.interests = const [],
    this.strengths = const [],
    this.motivators = const [],
    this.goals = const [],
    this.workstyle = const [],
    this.communities = const [],
    this.learningInterests = const [],
    this.impactVision = '',
    this.echoes = const [],
  });

  bool get isEmpty =>
      values.isEmpty &&
      interests.isEmpty &&
      strengths.isEmpty &&
      motivators.isEmpty &&
      goals.isEmpty &&
      workstyle.isEmpty &&
      communities.isEmpty &&
      learningInterests.isEmpty &&
      impactVision.isEmpty;

  bool get isNotEmpty => !isEmpty;

  int get completenessPercent {
    int score = 0;
    if (values.isNotEmpty) score += 25;
    if (interests.isNotEmpty || strengths.isNotEmpty) score += 20;
    if (workstyle.isNotEmpty || motivators.isNotEmpty) score += 20;
    if (communities.isNotEmpty) score += 15;
    if (learningInterests.isNotEmpty) score += 10;
    if (impactVision.trim().isNotEmpty) score += 10;
    return score.clamp(0, 100);
  }

  List<String> findSharedValues(StoryIdentity other) {
    final otherSet = other.values.map((v) => v.trim().toLowerCase()).toSet();
    return values
        .where((v) => otherSet.contains(v.trim().toLowerCase()))
        .toList();
  }

  List<String> findSharedCommunities(StoryIdentity other) {
    final otherSet = other.communities.map((c) => c.trim().toLowerCase()).toSet();
    return communities
        .where((c) => otherSet.contains(c.trim().toLowerCase()))
        .toList();
  }

  StoryIdentity copyWith({
    String? userId,
    String? displayName,
    String? headline,
    String? visibilityScope,
    List<String>? values,
    List<String>? interests,
    List<String>? strengths,
    List<String>? motivators,
    List<String>? goals,
    List<String>? workstyle,
    List<String>? communities,
    List<String>? learningInterests,
    String? impactVision,
    List<ResonanceEcho>? echoes,
  }) {
    return StoryIdentity(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      headline: headline ?? this.headline,
      visibilityScope: visibilityScope ?? this.visibilityScope,
      values: values ?? this.values,
      interests: interests ?? this.interests,
      strengths: strengths ?? this.strengths,
      motivators: motivators ?? this.motivators,
      goals: goals ?? this.goals,
      workstyle: workstyle ?? this.workstyle,
      communities: communities ?? this.communities,
      learningInterests: learningInterests ?? this.learningInterests,
      impactVision: impactVision ?? this.impactVision,
      echoes: echoes ?? this.echoes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'headline': headline,
      'visibilityScope': visibilityScope,
      'values': values,
      'interests': interests,
      'strengths': strengths,
      'motivators': motivators,
      'goals': goals,
      'workstyle': workstyle,
      'communities': communities,
      'learningInterests': learningInterests,
      'impactVision': impactVision,
      'echoes': echoes.map((e) => e.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static List<String> _parseList(dynamic list) {
    if (list is List) {
      return list.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }

  factory StoryIdentity.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawEchoes = map['echoes'];
    final List<ResonanceEcho> parsedEchoes = (rawEchoes is List)
        ? rawEchoes
            .whereType<Map<String, dynamic>>()
            .map((e) => ResonanceEcho.fromMap(e))
            .toList()
        : const [];

    return StoryIdentity(
      userId: id ?? map['userId'] ?? '',
      displayName: map['displayName'] as String? ?? 'Mitglied',
      headline: map['headline'] as String? ?? 'Macher, Teamplayer & Brückenbauer',
      visibilityScope: map['visibilityScope'] as String? ?? 'network',
      values: _parseList(map['values']),
      interests: _parseList(map['interests']),
      strengths: _parseList(map['strengths']),
      motivators: _parseList(map['motivators']),
      goals: _parseList(map['goals']),
      workstyle: _parseList(map['workstyle']),
      communities: _parseList(map['communities']),
      learningInterests: _parseList(map['learningInterests']),
      impactVision: map['impactVision'] as String? ?? '',
      echoes: parsedEchoes,
    );
  }

  factory StoryIdentity.fromFirestore(DocumentSnapshot doc) {
    final rawData = doc.data();
    final Map<String, dynamic> data = (rawData is Map<String, dynamic>) ? rawData : {};
    return StoryIdentity.fromMap(data, id: doc.id);
  }
}