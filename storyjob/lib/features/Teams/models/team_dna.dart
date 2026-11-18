// lib/features/Teams/models/teams_dna.dart
class TeamDna {
  final String teamId;
  final String name;
  final String website;
  final String industry;
  final String missionQuote;
  final String purposeVision;
  final String? logoUrl;
  final String? videoStoryUrl;
  final String? audioStoryUrl;
  final bool isVerified;

  TeamDna({
    required this.teamId,
    required this.name,
    required this.website,
    required this.industry,
    required this.missionQuote,
    required this.purposeVision,
    this.logoUrl,
    this.videoStoryUrl,
    this.audioStoryUrl,
    this.isVerified = false,
  });

  factory TeamDna.fromMap(Map<String, dynamic> map, String id) {
    return TeamDna(
      teamId: id,
      name: map['name'] ?? '',
      website: map['website'] ?? '',
      industry: map['industry'] ?? '',
      missionQuote: map['missionQuote'] ?? '',
      purposeVision: map['purposeVision'] ?? '',
      logoUrl: map['logoUrl'],
      videoStoryUrl: map['videoStoryUrl'],
      audioStoryUrl: map['audioStoryUrl'],
      isVerified: map['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'website': website,
      'industry': industry,
      'missionQuote': missionQuote,
      'purposeVision': purposeVision,
      'logoUrl': logoUrl,
      'videoStoryUrl': videoStoryUrl,
      'audioStoryUrl': audioStoryUrl,
      'isVerified': isVerified,
    };
  }
}