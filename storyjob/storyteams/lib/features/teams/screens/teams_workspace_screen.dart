// lib/features/teams/screens/teams_workspace_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:storyteams/core/theme/storyjob_theme.dart';
import 'package:storyteams/features/teams/models/team_models.dart';
import 'package:storyteams/features/teams/models/team_role.dart';
import 'package:storyteams/features/teams/screens/tabs/roster_pulse_tab.dart';
import 'package:storyteams/features/teams/screens/tabs/schedule_events_tab.dart';
import 'package:storyteams/features/teams/screens/tabs/team_dna_bridge_tab.dart';
import 'package:storyteams/features/teams/services/teams_firestore_service.dart';

class TeamsWorkspaceScreen extends StatefulWidget {
  final String teamId;

  const TeamsWorkspaceScreen({super.key, required this.teamId});

  @override
  State<TeamsWorkspaceScreen> createState() => _TeamsWorkspaceScreenState();
}

class _TeamsWorkspaceScreenState extends State<TeamsWorkspaceScreen> {
  final TeamsFirestoreService _service = TeamsFirestoreService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('teams').doc(widget.teamId).snapshots(),
      builder: (context, teamSnap) {
        final rawTeam = teamSnap.data?.data();
        final teamData = (rawTeam is Map<String, dynamic>) ? rawTeam : <String, dynamic>{};
        final team = TeamUnit.fromMap(teamData, widget.teamId);

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('teams')
              .doc(widget.teamId)
              .collection('members')
              .doc(_service.currentUid)
              .snapshots(),
          builder: (context, memberSnap) {
            final rawMember = memberSnap.data?.data();
            final memberData = (rawMember is Map<String, dynamic>) ? rawMember : <String, dynamic>{};
            final myRole = TeamRolleInfo.fromKey(memberData['role']?.toString());

            final pages = [
              RosterPulseTab(team: team, myRole: myRole, service: _service),
              ScheduleEventsTab(team: team, myRole: myRole, service: _service),
              TeamDnaBridgeTab(team: team, myRole: myRole),
            ];

            return Scaffold(
              backgroundColor: StoryJobTheme.backgroundBase,
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(team.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    Text(
                      '${team.type} • Rolle: ${myRole.titel}',
                      style: const TextStyle(fontSize: 11.5, color: StoryJobTheme.cyanAccent),
                    ),
                  ],
                ),
              ),
              body: IndexedStack(index: _selectedIndex, children: pages),
              bottomNavigationBar: NavigationBar(
                backgroundColor: StoryJobTheme.cardSurfaceElevated,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.traffic_rounded), label: 'Status & Roster'),
                  NavigationDestination(icon: Icon(Icons.event_available_rounded), label: 'Dienstplan'),
                  NavigationDestination(icon: Icon(Icons.fingerprint_rounded), label: 'Team-DNA'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}