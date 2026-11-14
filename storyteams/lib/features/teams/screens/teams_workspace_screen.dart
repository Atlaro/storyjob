// lib/features/teams/screens/teams_workspace_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            TeamRolle myRole = TeamRolleInfo.fromKey(memberData['role']?.toString());
            if (team.leaderUid == _service.currentUid) {
              myRole = TeamRolle.leitung;
            }

            final pages = [
              RosterPulseTab(team: team, myRole: myRole, service: _service),
              ScheduleEventsTab(team: team, myRole: myRole, service: _service),
              TeamDnaBridgeTab(team: team, myRole: myRole),
            ];

            return Scaffold(
              backgroundColor: StoryJobTheme.backgroundBase,
              appBar: AppBar(
                backgroundColor: StoryJobTheme.bg0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            team.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (team.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            color: StoryJobTheme.goldAccent,
                            size: 17,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${team.type} • Rolle: ${myRole.titel}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: StoryJobTheme.cyanAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                actions: [
                  if (team.inviteCode.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: team.inviteCode));
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: StoryJobTheme.cardSurfaceElevated,
                            content: Text('Einladungscode "${team.inviteCode}" kopiert!'),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: StoryJobTheme.goldAccent.withValues(alpha: 0.14),
                          border: Border.all(
                            color: StoryJobTheme.goldAccent.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.copy_rounded,
                              size: 13,
                              color: StoryJobTheme.goldAccent,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              team.inviteCode,
                              style: const TextStyle(
                                color: StoryJobTheme.goldAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              body: IndexedStack(index: _selectedIndex, children: pages),
              bottomNavigationBar: NavigationBar(
                backgroundColor: StoryJobTheme.cardSurfaceElevated,
                indicatorColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.18),
                selectedIndex: _selectedIndex,
                onDestinationSelected: (idx) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedIndex = idx);
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.traffic_outlined),
                    selectedIcon: Icon(Icons.traffic_rounded, color: StoryJobTheme.cyanAccent),
                    label: 'Status & Roster',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.event_available_outlined),
                    selectedIcon: Icon(Icons.event_available_rounded, color: StoryJobTheme.cyanAccent),
                    label: 'Dienstplan',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.fingerprint_outlined),
                    selectedIcon: Icon(Icons.fingerprint_rounded, color: StoryJobTheme.cyanAccent),
                    label: 'Team-DNA',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}