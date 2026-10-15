// lib/features/recruiter/models/company_dna.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyDna {
  final String companyId;
  final String name;
  final String website;
  final String industry;
  final String location;
  final String missionQuote;
  final String purposeVision;
  final String? logoUrl;
  final String? audioStoryUrl;
  final String? videoStoryUrl;
  final bool isVerified;
  final List<String> coreValues;
  final List<String> cultureTags;
  final List<String> workstyleTags;
  final List<String> benefits;
  final DateTime? updatedAt;

  const CompanyDna({
    required this.companyId,
    required this.name,
    required this.website,
    required this.industry,
    this.location = '',
    this.missionQuote = '',
    this.purposeVision = '',
    this.logoUrl,
    this.audioStoryUrl,
    this.videoStoryUrl,
    this.isVerified = false,
    this.coreValues = const [],
    this.cultureTags = const [],
    this.workstyleTags = const [],
    this.benefits = const [],
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'name': name,
      'website': website,
      'industry': industry,
      'location': location,
      'missionQuote': missionQuote,
      'purposeVision': purposeVision,
      'logoUrl': logoUrl ?? '',
      'audioStoryUrl': audioStoryUrl ?? '',
      // Fallback-Kompatibilität für ältere Abfragen
      'audioPitchUrl': audioStoryUrl ?? '',
      'videoStoryUrl': videoStoryUrl ?? '',
      'videoPitchUrl': videoStoryUrl ?? '',
      'isVerified': isVerified,
      'coreValues': coreValues,
      'cultureTags': cultureTags,
      'workstyleTags': workstyleTags,
      'benefits': benefits,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory CompanyDna.fromMap(Map<String, dynamic> map, String docId) {
    final rawAudio = map['audioStoryUrl'] ?? map['audioPitchUrl'];
    final rawVideo = map['videoStoryUrl'] ?? map['videoPitchUrl'];

    return CompanyDna(
      companyId: docId,
      name: map['name'] ?? '',
      website: map['website'] ?? '',
      industry: map['industry'] ?? '',
      location: map['location'] ?? '',
      missionQuote: map['missionQuote'] ?? '',
      purposeVision: map['purposeVision'] ?? '',
      logoUrl: (map['logoUrl'] != null && (map['logoUrl'] as String).isNotEmpty)
          ? map['logoUrl']
          : null,
      audioStoryUrl: (rawAudio != null && (rawAudio as String).isNotEmpty)
          ? rawAudio
          : null,
      videoStoryUrl: (rawVideo != null && (rawVideo as String).isNotEmpty)
          ? rawVideo
          : null,
      isVerified: map['isVerified'] ?? map['isPremium'] ?? false,
      coreValues: List<String>.from(map['coreValues'] ?? []),
      cultureTags: List<String>.from(map['cultureTags'] ?? []),
      workstyleTags: List<String>.from(map['workstyleTags'] ?? []),
      benefits: List<String>.from(map['benefits'] ?? []),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory CompanyDna.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CompanyDna.fromMap(data, doc.id);
  }

  /// Berechnet gemeinsame Schnittmengen an Werten für den Resonanzabgleich
  List<String> getSharedValues(List<String> userValues) {
    final Set<String> targetSet = userValues.map((v) => v.toLowerCase().trim()).toSet();
    return coreValues
        .where((val) => targetSet.contains(val.toLowerCase().trim()))
        .toList();
  }

  CompanyDna copyWith({
    String? companyId,
    String? name,
    String? website,
    String? industry,
    String? location,
    String? missionQuote,
    String? purposeVision,
    String? logoUrl,
    String? audioStoryUrl,
    String? videoStoryUrl,
    bool? isVerified,
    List<String>? coreValues,
    List<String>? cultureTags,
    List<String>? workstyleTags,
    List<String>? benefits,
    DateTime? updatedAt,
  }) {
    return CompanyDna(
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      website: website ?? this.website,
      industry: industry ?? this.industry,
      location: location ?? this.location,
      missionQuote: missionQuote ?? this.missionQuote,
      purposeVision: purposeVision ?? this.purposeVision,
      logoUrl: logoUrl ?? this.logoUrl,
      audioStoryUrl: audioStoryUrl ?? this.audioStoryUrl,
      videoStoryUrl: videoStoryUrl ?? this.videoStoryUrl,
      isVerified: isVerified ?? this.isVerified,
      coreValues: coreValues ?? this.coreValues,
      cultureTags: cultureTags ?? this.cultureTags,
      workstyleTags: workstyleTags ?? this.workstyleTags,
      benefits: benefits ?? this.benefits,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}