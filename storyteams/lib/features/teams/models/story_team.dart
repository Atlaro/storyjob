import 'package:cloud_firestore/cloud_firestore.dart';

class StoryTeam {
  final String id;
  final String name;
  final String category; // z. B. 'Feuerwehr', 'BRK / Rettungsdienst', 'THW', 'Verein', 'Unternehmen', 'Projekt'
  final String location;
  final String inviteCode;
  final String teamStory;
  final String liveStatus; // z. B. 'Einsatzbereit', 'Übungsabend 19:30', 'Nachwuchs gesucht'
  final String nextEvent; // z. B. 'Dienstabend Do. 19:30 Uhr • Gerätehaus'
  final String voiceIntroUrl; // Optionaler 30s Audio-Impuls der Teamleitung
  final bool isVerified; // Offizielles Verifikations-Badge für Engagement
  final String leaderUid;
  final List<String> values; // Team-Werte für DNA-Matching
  final List<String> openRoles; // Offene Aufgaben / Nachwuchs-Plätze
  final List<String> memberUids;
  final List<String> verifiedMemberUids;

  const StoryTeam({
    required this.id,
    required this.name,
    required this.category,
    this.location = '',
    this.inviteCode = '',
    this.teamStory = '',
    this.liveStatus = 'Aktiv & Offen',
    this.nextEvent = '',
    this.voiceIntroUrl = '',
    this.isVerified = false,
    this.leaderUid = '',
    this.values = const [],
    this.openRoles = const [],
    this.memberUids = const [],
    this.verifiedMemberUids = const [],
  });

  int get memberCount => memberUids.length;

  int get verifiedMemberCount => verifiedMemberUids.length;

  bool isMember(String uid) => uid.isNotEmpty && memberUids.contains(uid);

  bool isVerifiedMember(String uid) =>
      uid.isNotEmpty && verifiedMemberUids.contains(uid);

  bool isLeader(String uid) => uid.isNotEmpty && leaderUid == uid;

  List<String> findSharedValues(List<String> userDnaValues) {
    if (values.isEmpty || userDnaValues.isEmpty) return const [];
    final userSet = userDnaValues.map((v) => v.trim().toLowerCase()).toSet();
    return values
        .where((v) => userSet.contains(v.trim().toLowerCase()))
        .toList();
  }

  int calculateDnaMatchPercent(List<String> userDnaValues) {
    if (values.isEmpty || userDnaValues.isEmpty) return 75;
    final teamSet = values.map((v) => v.trim().toLowerCase()).toSet();
    final matches = userDnaValues
        .where((v) => teamSet.contains(v.trim().toLowerCase()))
        .length;
    if (matches == 0) return 68;
    final ratio = matches / teamSet.length;
    return (72 + (ratio * 28)).round().clamp(68, 99);
  }

  StoryTeam copyWith({
    String? id,
    String? name,
    String? category,
    String? location,
    String? inviteCode,
    String? teamStory,
    String? liveStatus,
    String? nextEvent,
    String? voiceIntroUrl,
    bool? isVerified,
    String? leaderUid,
    List<String>? values,
    List<String>? openRoles,
    List<String>? memberUids,
    List<String>? verifiedMemberUids,
  }) {
    return StoryTeam(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      location: location ?? this.location,
      inviteCode: inviteCode ?? this.inviteCode,
      teamStory: teamStory ?? this.teamStory,
      liveStatus: liveStatus ?? this.liveStatus,
      nextEvent: nextEvent ?? this.nextEvent,
      voiceIntroUrl: voiceIntroUrl ?? this.voiceIntroUrl,
      isVerified: isVerified ?? this.isVerified,
      leaderUid: leaderUid ?? this.leaderUid,
      values: values ?? this.values,
      openRoles: openRoles ?? this.openRoles,
      memberUids: memberUids ?? this.memberUids,
      verifiedMemberUids: verifiedMemberUids ?? this.verifiedMemberUids,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'location': location,
      'inviteCode': inviteCode.toUpperCase(),
      'teamStory': teamStory,
      'liveStatus': liveStatus,
      'nextEvent': nextEvent,
      'voiceIntroUrl': voiceIntroUrl,
      'isVerified': isVerified,
      'leaderUid': leaderUid,
      'values': values,
      'openRoles': openRoles,
      'memberUids': memberUids,
      'verifiedMemberUids': verifiedMemberUids,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static List<String> _parseList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }

  factory StoryTeam.fromMap(Map<String, dynamic> map, {required String id}) {
    return StoryTeam(
      id: id,
      name: map['name']?.toString() ?? 'Unbenanntes Team',
      category: map['category']?.toString() ?? 'Gemeinschaft',
      location: map['location']?.toString() ?? '',
      inviteCode: map['inviteCode']?.toString() ?? '',
      teamStory: map['teamStory']?.toString() ?? '',
      liveStatus: map['liveStatus']?.toString() ?? 'Aktiv',
      nextEvent: map['nextEvent']?.toString() ?? '',
      voiceIntroUrl: map['voiceIntroUrl']?.toString() ?? '',
      isVerified: map['isVerified'] == true,
      leaderUid: map['leaderUid']?.toString() ?? '',
      values: _parseList(map['values']),
      openRoles: _parseList(map['openRoles']),
      memberUids: _parseList(map['memberUids']),
      verifiedMemberUids: _parseList(map['verifiedMemberUids']),
    );
  }

  factory StoryTeam.fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data();
    final map = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};
    return StoryTeam.fromMap(map, id: doc.id);
  }
}