// lib/features/recruiter/models/job_story.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class JobStory {
  final String id;
  final String companyId;
  final String companyName;
  final String title;
  final String roleCategory;
  final String location;
  final String employmentType; // Vollzeit, Teilzeit, Remote
  final String missionSummary;
  final String transcript;
  final String duration;
  final String timeAgo;
  final String? audioStoryUrl;
  final String? videoStoryUrl;
  final List<String> requiredValues;
  final List<String> cultureHighlights;
  final List<String> benefits;
  final int matchScore;
  final bool isActive;
  final DateTime? createdAt;

  const JobStory({
    required this.id,
    this.companyId = '',
    this.companyName = '',
    required this.title,
    this.roleCategory = 'Macher & Gestalter',
    this.location = 'Hybrid / Remote',
    this.employmentType = 'Vollzeit',
    this.missionSummary = '',
    this.transcript = '',
    this.duration = '0:30 Min.',
    this.timeAgo = 'Gerade eben',
    this.audioStoryUrl,
    this.videoStoryUrl,
    this.requiredValues = const [],
    this.cultureHighlights = const [],
    this.benefits = const [],
    this.matchScore = 90,
    this.isActive = true,
    this.createdAt,
  });

  // Komfort-Getter für Talent-Feed-Kompatibilität
  String get author => companyName.isNotEmpty ? companyName : 'StoryJob Partner';
  String get authorRole => roleCategory;
  String get category => roleCategory;
  String? get audioPath => audioStoryUrl;
  List<String> get values => requiredValues;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyId': companyId,
      'companyName': companyName,
      'title': title,
      'roleCategory': roleCategory,
      'location': location,
      'employmentType': employmentType,
      'missionSummary': missionSummary,
      'transcript': transcript,
      'duration': duration,
      'timeAgo': timeAgo,
      'audioStoryUrl': audioStoryUrl ?? '',
      'audioPitchUrl': audioStoryUrl ?? '',
      'videoStoryUrl': videoStoryUrl ?? '',
      'videoPitchUrl': videoStoryUrl ?? '',
      'requiredValues': requiredValues,
      'values': requiredValues,
      'cultureHighlights': cultureHighlights,
      'benefits': benefits,
      'matchScore': matchScore,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory JobStory.fromMap(Map<String, dynamic> map, String docId) {
    final rawAudio = map['audioStoryUrl'] ?? map['audioPitchUrl'] ?? map['audioPath'];
    final rawVideo = map['videoStoryUrl'] ?? map['videoPitchUrl'];

    DateTime? parsedDate;
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedDate = DateTime.tryParse(map['createdAt'] as String);
    }

    final valuesList = (map['requiredValues'] ?? map['values'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    return JobStory(
      id: docId,
      companyId: map['companyId'] as String? ?? '',
      companyName: map['companyName'] as String? ?? map['author'] as String? ?? '',
      title: map['title'] as String? ?? 'Team- & Werte-Impuls',
      roleCategory: map['roleCategory'] as String? ?? map['authorRole'] as String? ?? map['category'] as String? ?? 'Macher',
      location: map['location'] as String? ?? 'Hybrid / Vor Ort',
      employmentType: map['employmentType'] as String? ?? 'Vollzeit',
      missionSummary: map['missionSummary'] as String? ?? '',
      transcript: map['transcript'] as String? ?? '',
      duration: map['duration'] as String? ?? '0:30 Min.',
      timeAgo: map['timeAgo'] as String? ?? 'Gerade eben',
      audioStoryUrl: (rawAudio as String?)?.isNotEmpty == true ? rawAudio : null,
      videoStoryUrl: (rawVideo as String?)?.isNotEmpty == true ? rawVideo : null,
      requiredValues: valuesList,
      cultureHighlights: List<String>.from(map['cultureHighlights'] ?? []),
      benefits: List<String>.from(map['benefits'] ?? []),
      matchScore: (map['matchScore'] as num?)?.toInt() ?? 90,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: parsedDate,
    );
  }

  factory JobStory.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return JobStory.fromMap(data, doc.id);
  }

  factory JobStory.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return JobStory.fromMap(data, doc.id);
  }

  /// Berechnet die prozentuale Werte-Resonanz zu den Werten eines Talents
  int calculateResonanceWith(List<String> talentValues) {
    if (requiredValues.isEmpty || talentValues.isEmpty) return 70;

    final talentSet = talentValues.map((v) => v.toLowerCase().trim()).toSet();
    final matches = requiredValues.where((val) => talentSet.contains(val.toLowerCase().trim())).length;

    final ratio = matches / requiredValues.length;
    return (65 + (ratio * 33)).round().clamp(60, 98);
  }

  JobStory copyWith({
    String? id,
    String? companyId,
    String? companyName,
    String? title,
    String? roleCategory,
    String? location,
    String? employmentType,
    String? missionSummary,
    String? transcript,
    String? duration,
    String? timeAgo,
    String? audioStoryUrl,
    String? videoStoryUrl,
    List<String>? requiredValues,
    List<String>? cultureHighlights,
    List<String>? benefits,
    int? matchScore,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return JobStory(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      title: title ?? this.title,
      roleCategory: roleCategory ?? this.roleCategory,
      location: location ?? this.location,
      employmentType: employmentType ?? this.employmentType,
      missionSummary: missionSummary ?? this.missionSummary,
      transcript: transcript ?? this.transcript,
      duration: duration ?? this.duration,
      timeAgo: timeAgo ?? this.timeAgo,
      audioStoryUrl: audioStoryUrl ?? this.audioStoryUrl,
      videoStoryUrl: videoStoryUrl ?? this.videoStoryUrl,
      requiredValues: requiredValues ?? this.requiredValues,
      cultureHighlights: cultureHighlights ?? this.cultureHighlights,
      benefits: benefits ?? this.benefits,
      matchScore: matchScore ?? this.matchScore,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Vollständige Rückwärtskompatibilität
typedef JobPitch = JobStory;