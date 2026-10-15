// lib/features/growth/models/growth_journey.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

enum GrowthCategory {
  storyDna,       // StoryJob DNA™ Entfaltung
  voiceStory,     // Eigene Stimme & Audio-Impulse
  coreValues,     // Werte, Haltung & Miteinander (virdrun 'values')
  community,      // Ehrenamt, Vereine & Initiativen
  dialog,         // Direkter Austausch & Resonanz
}

extension GrowthCategoryExtension on GrowthCategory {
  String toKey() {
    switch (this) {
      case GrowthCategory.storyDna:
        return 'story_dna';
      case GrowthCategory.voiceStory:
        return 'voice_story';
      case GrowthCategory.coreValues:
        return 'values';
      case GrowthCategory.community:
        return 'community';
      case GrowthCategory.dialog:
        return 'dialog';
    }
  }

  static GrowthCategory fromKey(String? key) {
    switch (key) {
      case 'voice_story':
        return GrowthCategory.voiceStory;
      case 'values':
      case 'core_values':
        return GrowthCategory.coreValues;
      case 'community':
        return GrowthCategory.community;
      case 'dialog':
        return GrowthCategory.dialog;
      case 'story_dna':
      default:
        return GrowthCategory.storyDna;
    }
  }

  String get label {
    switch (this) {
      case GrowthCategory.storyDna:
        return 'StoryJob DNA™';
      case GrowthCategory.voiceStory:
        return 'Stimme & Story';
      case GrowthCategory.coreValues:
        return 'Werte & Haltung';
      case GrowthCategory.community:
        return 'Gemeinschaft & Engagement';
      case GrowthCategory.dialog:
        return 'Resonanz & Dialog';
    }
  }

  Color get accentColor {
    switch (this) {
      case GrowthCategory.storyDna:
        return StoryJobTheme.primaryViolet;
      case GrowthCategory.voiceStory:
        return StoryJobTheme.cyanAccent;
      case GrowthCategory.coreValues:
        return StoryJobTheme.champagneGold;
      case GrowthCategory.community:
        return const Color(0xFF34D399); // Natürliches Smaragdgrün
      case GrowthCategory.dialog:
        return const Color(0xFF38BDF8); // Sanftes Cyan-Blau
    }
  }

  IconData get icon {
    switch (this) {
      case GrowthCategory.storyDna:
        return Icons.auto_awesome_rounded;
      case GrowthCategory.voiceStory:
        return Icons.mic_rounded;
      case GrowthCategory.coreValues:
        return Icons.favorite_rounded;
      case GrowthCategory.community:
        return Icons.volunteer_activism_rounded;
      case GrowthCategory.dialog:
        return Icons.chat_bubble_rounded;
    }
  }
}

class GrowthJourney {
  final String id;
  final String userId;
  final String title;
  final String description;
  final GrowthCategory category;
  final String actionPrompt; // z.B. "30s Audio-Spark einsprechen"
  final int currentStep;
  final int totalSteps;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? createdAt;

  const GrowthJourney({
    required this.id,
    this.userId = '',
    required this.title,
    required this.description,
    this.category = GrowthCategory.storyDna,
    this.actionPrompt = 'Jetzt vertiefen',
    this.currentStep = 0,
    this.totalSteps = 1,
    this.isCompleted = false,
    this.completedAt,
    this.createdAt,
  });

  /// Gibt den prozentualen Fortschritt (0.0 bis 1.0) zurück
  double get progressRatio {
    if (isCompleted) return 1.0;
    if (totalSteps <= 0) return 0.0;
    return (currentStep / totalSteps).clamp(0.0, 1.0);
  }

  GrowthJourney copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    GrowthCategory? category,
    String? actionPrompt,
    int? currentStep,
    int? totalSteps,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return GrowthJourney(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      actionPrompt: actionPrompt ?? this.actionPrompt,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category.toKey(),
      'actionPrompt': actionPrompt,
      'currentStep': currentStep,
      'totalSteps': totalSteps,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory GrowthJourney.fromMap(Map<String, dynamic> map, {String? documentId}) {
    final int current = (map['currentStep'] as num?)?.toInt() ?? 0;
    final int total = (map['totalSteps'] as num?)?.toInt() ?? 1;
    final bool completed = map['isCompleted'] ?? (current >= total && total > 0);

    return GrowthJourney(
      id: (map['id'] as String?)?.isNotEmpty == true ? map['id'] : (documentId ?? ''),
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: GrowthCategoryExtension.fromKey(map['category'] as String?),
      actionPrompt: map['actionPrompt'] ?? 'Jetzt vertiefen',
      currentStep: current,
      totalSteps: total,
      isCompleted: completed,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory GrowthJourney.fromFirestore(DocumentSnapshot doc) {
    final rawData = doc.data();
    final Map<String, dynamic> data = (rawData is Map<String, dynamic>) ? rawData : {};
    return GrowthJourney.fromMap(data, documentId: doc.id);
  }
}