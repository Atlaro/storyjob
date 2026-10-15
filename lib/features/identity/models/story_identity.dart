// lib/features/identity/models/story_identity.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StoryIdentity {
  final String userId;
  final List<String> values;
  final List<String> interests;
  final List<String> strengths;
  final List<String> motivators;
  final List<String> goals;
  final List<String> workstyle;
  final List<String> communities; // Engagement, Vereine, Initiativen
  final List<String> learningInterests;
  final String impactVision;

  const StoryIdentity({
    this.userId = '',
    this.values = const [],
    this.interests = const [],
    this.strengths = const [],
    this.motivators = const [],
    this.goals = const [],
    this.workstyle = const [],
    this.communities = const [],
    this.learningInterests = const [],
    this.impactVision = '',
  });

  /// Prüft, ob überhaupt Profilfacetten hinterlegt sind
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

  /// Ermittelt den Entfaltungsgrad der StoryJob DNA™ (0 bis 100 %)
  int get completenessPercent {
    int score = 0;
    if (values.isNotEmpty) score += 25; // Kernwerte definiert
    if (interests.isNotEmpty || strengths.isNotEmpty) score += 20; // Haltung & Interessen
    if (workstyle.isNotEmpty || motivators.isNotEmpty) score += 20; // Arbeitsweise & Antrieb
    if (communities.isNotEmpty) score += 15; // Engagement / Vereine
    if (learningInterests.isNotEmpty) score += 10; // Wachstumsfokus
    if (impactVision.trim().isNotEmpty) score += 10; // Vision / Wirkung
    return score.clamp(0, 100);
  }

  /// Ermittelt gemeinsame Kernwerte mit einem Zielprofil
  List<String> findSharedValues(StoryIdentity other) {
    final otherSet = other.values.map((v) => v.trim().toLowerCase()).toSet();
    return values
        .where((v) => otherSet.contains(v.trim().toLowerCase()))
        .toList();
  }

  /// Ermittelt gemeinsame Engagements oder Communities
  List<String> findSharedCommunities(StoryIdentity other) {
    final otherSet = other.communities.map((c) => c.trim().toLowerCase()).toSet();
    return communities
        .where((c) => otherSet.contains(c.trim().toLowerCase()))
        .toList();
  }

  StoryIdentity copyWith({
    String? userId,
    List<String>? values,
    List<String>? interests,
    List<String>? strengths,
    List<String>? motivators,
    List<String>? goals,
    List<String>? workstyle,
    List<String>? communities,
    List<String>? learningInterests,
    String? impactVision,
  }) {
    return StoryIdentity(
      userId: userId ?? this.userId,
      values: values ?? this.values,
      interests: interests ?? this.interests,
      strengths: strengths ?? this.strengths,
      motivators: motivators ?? this.motivators,
      goals: goals ?? this.goals,
      workstyle: workstyle ?? this.workstyle,
      communities: communities ?? this.communities,
      learningInterests: learningInterests ?? this.learningInterests,
      impactVision: impactVision ?? this.impactVision,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'values': values,
      'interests': interests,
      'strengths': strengths,
      'motivators': motivators,
      'goals': goals,
      'workstyle': workstyle,
      'communities': communities,
      'learningInterests': learningInterests,
      'impactVision': impactVision,
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
    return StoryIdentity(
      userId: id ?? map['userId'] ?? '',
      values: _parseList(map['values']),
      interests: _parseList(map['interests']),
      strengths: _parseList(map['strengths']),
      motivators: _parseList(map['motivators']),
      goals: _parseList(map['goals']),
      workstyle: _parseList(map['workstyle']),
      communities: _parseList(map['communities']),
      learningInterests: _parseList(map['learningInterests']),
      impactVision: map['impactVision'] as String? ?? '',
    );
  }

  factory StoryIdentity.fromFirestore(DocumentSnapshot doc) {
    final rawData = doc.data();
    final Map<String, dynamic> data = (rawData is Map<String, dynamic>) ? rawData : {};
    return StoryIdentity.fromMap(data, id: doc.id);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryIdentity &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          impactVision == other.impactVision &&
          values.length == other.values.length &&
          communities.length == other.communities.length;

  @override
  int get hashCode => userId.hashCode ^ impactVision.hashCode ^ values.length.hashCode;
}