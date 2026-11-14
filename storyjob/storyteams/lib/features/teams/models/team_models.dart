// lib/features/teams/models/team_models.dart
import 'package:storyteams/features/teams/models/team_role.dart';

class TeamUnit {
  final String id;
  final String name;
  final String type; // Hilfsorganisation, Verein, Betrieb
  final String inviteCode;
  final String motto;
  final List<String> cultureValues;

  const TeamUnit({
    required this.id,
    required this.name,
    required this.type,
    required this.inviteCode,
    this.motto = 'Echte Kameradschaft. Kompakt organisiert.',
    this.cultureValues = const ['Teamgeist', 'Verlässlichkeit', 'Augenhöhe'],
  });

  factory TeamUnit.fromMap(Map<String, dynamic> map, String id) {
    return TeamUnit(
      id: id,
      name: map['name']?.toString() ?? 'StoryTeams Einheit',
      type: map['type']?.toString() ?? 'Hilfsorganisation',
      inviteCode: map['inviteCode']?.toString() ?? 'SJ2026',
      motto: map['motto']?.toString() ?? 'Echte Kameradschaft. Kompakt organisiert.',
      cultureValues: (map['cultureValues'] is List)
          ? List<String>.from(map['cultureValues'])
          : const ['Teamgeist', 'Verlässlichkeit', 'Augenhöhe'],
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        'inviteCode': inviteCode,
        'motto': motto,
        'cultureValues': cultureValues,
      };
}

class TeamMember {
  final String uid;
  final String displayName;
  final TeamRolle role;
  final AvailabilityStatus status;
  final List<String> qualifications; // z. B. Atemschutz, RDH, Gruppenführer
  final String statusNote;

  const TeamMember({
    required this.uid,
    required this.displayName,
    required this.role,
    required this.status,
    this.qualifications = const [],
    this.statusNote = '',
  });

  factory TeamMember.fromMap(Map<String, dynamic> map, String uid) {
    return TeamMember(
      uid: uid,
      displayName: map['displayName']?.toString() ?? 'Team-Mitglied',
      role: TeamRolleInfo.fromKey(map['role']?.toString()),
      status: AvailabilityInfo.fromKey(map['status']?.toString()),
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
  final List<String> acceptedUids;
  final List<String> declinedUids;

  const TeamEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.dateLabel,
    required this.location,
    this.acceptedUids = const [],
    this.declinedUids = const [],
  });

  factory TeamEvent.fromMap(Map<String, dynamic> map, String id) {
    return TeamEvent(
      id: id,
      title: map['title']?.toString() ?? 'Team-Termin',
      category: map['category']?.toString() ?? 'Übung',
      dateLabel: map['dateLabel']?.toString() ?? 'Demnächst',
      location: map['location']?.toString() ?? 'Gerätehaus / Treffpunkt',
      acceptedUids: (map['acceptedUids'] is List)
          ? List<String>.from(map['acceptedUids'])
          : const [],
      declinedUids: (map['declinedUids'] is List)
          ? List<String>.from(map['declinedUids'])
          : const [],
    );
  }
}