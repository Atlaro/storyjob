// lib/features/feed/models/story_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum StoryType {
  personalStory,
  dailySpark,
  teamPitch,
  communityProject,
}

extension StoryTypeExtension on StoryType {
  String toKey() {
    switch (this) {
      case StoryType.personalStory:
        return 'personal_story';
      case StoryType.dailySpark:
        return 'daily_spark';
      case StoryType.teamPitch:
        return 'team_pitch';
      case StoryType.communityProject:
        return 'community_project';
    }
  }

  static StoryType fromKey(String? key) {
    switch (key) {
      case 'daily_spark':
        return StoryType.dailySpark;
      case 'team_pitch':
        return StoryType.teamPitch;
      case 'community_project':
        return StoryType.communityProject;
      case 'personal_story':
      default:
        return StoryType.personalStory;
    }
  }

  String get label {
    switch (this) {
      case StoryType.personalStory:
        return 'Eigene Story';
      case StoryType.dailySpark:
        return 'Daily Spark';
      case StoryType.teamPitch:
        return 'Team-Einblick';
      case StoryType.communityProject:
        return 'Projekt & Verein';
    }
  }
}

class StoryModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String category;
  final String audioUrl;
  final int durationSeconds;
  final DateTime? createdAt;
  final int playsCount;
  final int likesCount;
  final List<String> tags; // Engagement, Aktivitäten, Interessen
  final List<String> values; // Kernwerte für den menschlichen Resonanz-Fit (z. B. Verlässlichkeit, Hands-on)
  final String? organizationName; // Name von Team, Verein, Initiative oder Betrieb
  final String? promptQuestion; // z. B. Daily Spark Frage: "Worauf legst du im Team Wert?"
  final StoryType type;

  const StoryModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.category,
    required this.audioUrl,
    required this.durationSeconds,
    this.createdAt,
    this.playsCount = 0,
    this.likesCount = 0,
    this.tags = const [],
    this.values = const [],
    this.organizationName,
    this.promptQuestion,
    this.type = StoryType.personalStory,
  });

  /// Gibt die Dauer im Format 'mm:ss' zurück (z. B. 00:30)
  String get formattedDuration {
    final minutes = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  StoryModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? category,
    String? audioUrl,
    int? durationSeconds,
    DateTime? createdAt,
    int? playsCount,
    int? likesCount,
    List<String>? tags,
    List<String>? values,
    String? organizationName,
    String? promptQuestion,
    StoryType? type,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      category: category ?? this.category,
      audioUrl: audioUrl ?? this.audioUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      createdAt: createdAt ?? this.createdAt,
      playsCount: playsCount ?? this.playsCount,
      likesCount: likesCount ?? this.likesCount,
      tags: tags ?? this.tags,
      values: values ?? this.values,
      organizationName: organizationName ?? this.organizationName,
      promptQuestion: promptQuestion ?? this.promptQuestion,
      type: type ?? this.type,
    );
  }

  factory StoryModel.fromFirestore(DocumentSnapshot doc) {
    final rawData = doc.data();
    final Map<String, dynamic> data = (rawData is Map<String, dynamic>) ? rawData : {};

    return StoryModel(
      id: data['id'] ?? doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? data['fullName'] ?? 'StoryJob Stimme',
      userAvatarUrl: data['userAvatarUrl'] ?? '',
      category: data['category'] ?? 'Werte & Miteinander',
      audioUrl: data['audioUrl'] ?? '',
      durationSeconds: (data['durationSeconds'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      playsCount: (data['playsCount'] as num?)?.toInt() ?? 0,
      likesCount: (data['likesCount'] as num?)?.toInt() ?? 0,
      tags: (data['tags'] is List)
          ? List<String>.from(data['tags'])
          : (data['engagement'] is List ? List<String>.from(data['engagement']) : const []),
      values: (data['values'] is List)
          ? List<String>.from(data['values'])
          : const [],
      organizationName: (data['organizationName'] ?? data['companyName']) as String?,
      promptQuestion: data['promptQuestion'] as String?,
      type: StoryTypeExtension.fromKey(data['type'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'category': category,
      'audioUrl': audioUrl,
      'durationSeconds': durationSeconds,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'playsCount': playsCount,
      'likesCount': likesCount,
      'tags': tags,
      'values': values,
      'type': type.toKey(),
      if (organizationName != null) 'organizationName': organizationName,
      if (promptQuestion != null) 'promptQuestion': promptQuestion,
    };
  }
}