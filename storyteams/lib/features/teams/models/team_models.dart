// lib/features/teams/models/team_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storyteams/features/teams/models/team_role.dart';

class TeamUnit {
  final String id;
  final String name;
  final String type; // Feuerwehr, BRK / Rettungsdienst, THW, Verein, Unternehmen, Projekt
  final String location;
  final String inviteCode;
  final String motto;
  final String teamStory;
  final String leaderUid;
  final bool isVerified; // Offizielles Organisations-Verifikations-Badge
  final List<String> cultureValues; // Team-Werte für StoryDNA-Abgleich
  final List<String> openRoles; // Offene Aufgaben / Nachwuchs-Plätze
  final List<String> memberUids;

  const TeamUnit({
    required this.id,
    required this.name,
    required this.type,
    this.location = '',
    required this.inviteCode,
    this.motto = 'Echte Kameradschaft. Kompakt organisiert.',
    this.teamStory = '',
    this.leaderUid = '',
    this.isVerified = false,
    this.cultureValues = const ['Teamgeist', 'Verlässlichkeit', 'Augenhöhe'],
    this.openRoles = const [],
    this.memberUids = const [],
  });

  int get memberCount => memberUids.length;

  int calculateDnaMatchPercent(List<String> userDnaValues) {
    if (cultureValues.isEmpty || userDnaValues.isEmpty) return 78;
    final teamSet = cultureValues.map((v) => v.trim().toLowerCase()).toSet();
    final matches = userDnaValues
        .where((v) => teamSet.contains(v.trim().toLowerCase()))
        .length;
    if (matches == 0) return 70;
    final ratio = matches / teamSet.length;
    return (74 + (ratio * 26)).round().clamp(70, 99);
  }

  List<String> findSharedValues(List<String> userDnaValues) {
    if (cultureValues.isEmpty || userDnaValues.isEmpty) return const [];
    final userSet = userDnaValues.map((v) => v.trim().toLowerCase()).toSet();
    return cultureValues
        .where((v) => userSet.contains(v.trim().toLowerCase()))
        .toList();
  }

  TeamUnit copyWith({
    String? id,
    String? name,
    String? type,
    String? location,
    String? inviteCode,
    String? motto,
    String? teamStory,
    String? leaderUid,
    bool? isVerified,
    List<String>? cultureValues,
    List<String>? openRoles,
    List<String>? memberUids,
  }) {
    return TeamUnit(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      inviteCode: inviteCode ?? this.inviteCode,
      motto: motto ?? this.motto,
      teamStory: teamStory ?? this.teamStory,
      leaderUid: leaderUid ?? this.leaderUid,
      isVerified: isVerified ?? this.isVerified,
      cultureValues: cultureValues ?? this.cultureValues,
      openRoles: openRoles ?? this.openRoles,
      memberUids: memberUids ?? this.memberUids,
    );
  }

  factory TeamUnit.fromMap(Map<String, dynamic> map, String id) {
    return TeamUnit(
      id: id,
      name: map['name']?.toString() ?? 'StoryTeams Einheit',
      type: map['type']?.toString() ?? 'Hilfsorganisation',
      location: map['location']?.toString() ?? '',
      inviteCode: map['inviteCode']?.toString() ?? 'SJ2026',
      motto: map['motto']?.toString() ?? 'Echte Kameradschaft. Kompakt organisiert.',
      teamStory: map['teamStory']?.toString() ?? '',
      leaderUid: map['leaderUid']?.toString() ?? '',
      isVerified: map['isVerified'] == true,
      cultureValues: (map['cultureValues'] is List)
          ? List<String>.from(map['cultureValues'])
          : const ['Teamgeist', 'Verlässlichkeit', 'Augenhöhe'],
      openRoles: (map['openRoles'] is List)
          ? List<String>.from(map['openRoles'])
          : const [],
      memberUids: (map['memberUids'] is List)
          ? List<String>.from(map['memberUids'])
          : const [],
    );
  }

  factory TeamUnit.fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data();
    final map = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};
    return TeamUnit.fromMap(map, doc.id);
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        'location': location,
        'inviteCode': inviteCode.toUpperCase(),
        'motto': motto,
        'teamStory': teamStory,
        'leaderUid': leaderUid,
        'isVerified': isVerified,
        'cultureValues': cultureValues,
        'openRoles': openRoles,
        'memberUids': memberUids,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

class TeamMember {
  final String uid;
  final String displayName;
  final TeamRolle role;
  final AvailabilityStatus status;
  final bool isEngagementVerified; // Offizielles Verifikations-Badge vom Vorstand/Leiter
  final String verifiedBadgeTitle; // z. B. "Aktives Einsatzmitglied • FF Hartkirchen"
  final List<String> qualifications; // z. B. Atemschutz, RDH, Gruppenführer
  final String statusNote;

  const TeamMember({
    required this.uid,
    required this.displayName,
    required this.role,
    required this.status,
    this.isEngagementVerified = false,
    this.verifiedBadgeTitle = '',
    this.qualifications = const [],
    this.statusNote = '',
  });

  TeamMember copyWith({
    String? uid,
    String? displayName,
    TeamRolle? role,
    AvailabilityStatus? status,
    bool? isEngagementVerified,
    String? verifiedBadgeTitle,
    List<String>? qualifications,
    String? statusNote,
  }) {
    return TeamMember(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      status: status ?? this.status,
      isEngagementVerified: isEngagementVerified ?? this.isEngagementVerified,
      verifiedBadgeTitle: verifiedBadgeTitle ?? this.verifiedBadgeTitle,
      qualifications: qualifications ?? this.qualifications,
      statusNote: statusNote ?? this.statusNote,
    );
  }

  factory TeamMember.fromMap(Map<String, dynamic> map, String uid) {
    return TeamMember(
      uid: uid,
      displayName: map['displayName']?.toString() ?? 'Team-Mitglied',
      role: TeamRolleInfo.fromKey(map['role']?.toString()),
      status: AvailabilityInfo.fromKey(map['status']?.toString()),
      isEngagementVerified: map['isEngagementVerified'] == true,
      verifiedBadgeTitle: map['verifiedBadgeTitle']?.toString() ?? '',
      qualifications: (map['qualifications'] is List)
          ? List<String>.from(map['qualifications'])
          : const [],
      statusNote: map['statusNote']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'role': role.key,
        'status': status.key,
        'isEngagementVerified': isEngagementVerified,
        'verifiedBadgeTitle': verifiedBadgeTitle,
        'qualifications': qualifications,
        'statusNote': statusNote,
      };
}

class TeamEvent {
  final String id;
  final String title;
  final String category; // Übung, Einsatz, Dienst, Versammlung
  final String dateLabel;
  final String location;
  final String description;
  final List<String> acceptedUids;
  final List<String> declinedUids;

  const TeamEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.dateLabel,
    required this.location,
    this.description = '',
    this.acceptedUids = const [],
    this.declinedUids = const [],
  });

  int get acceptedCount => acceptedUids.length;
  int get declinedCount => declinedUids.length;

  factory TeamEvent.fromMap(Map<String, dynamic> map, String id) {
    return TeamEvent(
      id: id,
      title: map['title']?.toString() ?? 'Team-Termin',
      category: map['category']?.toString() ?? 'Übung',
      dateLabel: map['dateLabel']?.toString() ?? 'Demnächst',
      location: map['location']?.toString() ?? 'Gerätehaus / Treffpunkt',
      description: map['description']?.toString() ?? '',
      acceptedUids: (map['acceptedUids'] is List)
          ? List<String>.from(map['acceptedUids'])
          : const [],
      declinedUids: (map['declinedUids'] is List)
          ? List<String>.from(map['declinedUids'])
          : const [],
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'category': category,
        'dateLabel': dateLabel,
        'location': location,
        'description': description,
        'acceptedUids': acceptedUids,
        'declinedUids': declinedUids,
      };
}