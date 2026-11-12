// lib/features/teams/screens/tabs/roster_pulse_tab.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyteams/core/theme/storyjob_theme.dart';
import 'package:storyteams/core/widgets/glass_card.dart';
import 'package:storyteams/core/widgets/team_pulse_status_bar.dart';
import 'package:storyteams/features/teams/models/team_models.dart';
import 'package:storyteams/features/teams/models/team_role.dart';
import 'package:storyteams/features/teams/services/teams_firestore_service.dart';

class RosterPulseTab extends StatelessWidget {
  final TeamUnit team;
  final TeamRolle myRole;
  final TeamsFirestoreService service;

  const RosterPulseTab({
    super.key,
    required this.team,
    required this.myRole,
    required this.service,
  });

  void _openTeamPulseDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StoryJobTheme.cardSurfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('24h Team-Impuls senden', style: TextStyle(color: Colors.white, fontSize: 17)),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'z. B. Heute 19:00 Uhr Übung am Gerätehaus – alle willkommen! 🚒',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              await service.publishTeamPulse(
                teamName: team.name,
                teamType: team.type,
                message: ctrl.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Veröffentlichen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TeamPulseStatusBar(onAddPulseTap: () => _openTeamPulseDialog(context)),
          const SizedBox(height: 18),

          const Text(
            'DEINE LIVE-VERFÜGBARKEIT',
            style: TextStyle(
              color: StoryJobTheme.cyanAccent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: AvailabilityStatus.values.map((st) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        service.updateMyStatus(teamId: team.id, status: st);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        side: BorderSide(color: st.color.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.circle, color: st.color, size: 12),
                          const SizedBox(height: 4),
                          Text(
                            st.label.split(' ').first,
                            style: TextStyle(color: st.color, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'MANNSCHAFT & ROLLEN',
            style: TextStyle(
              color: StoryJobTheme.cyanAccent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('teams')
                .doc(team.id)
                .collection('members')
                .snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const GlassCard(
                  child: Text(
                    'Noch keine weiteren Mitglieder im Roster – teile oben euren Einladungscode!',
                    style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13),
                  ),
                );
              }

              return Column(
                children: docs.map((doc) {
                  final raw = doc.data();
                  final map = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};
                  final member = TeamMember.fromMap(map, doc.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: member.status.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.displayName,
                                  style: const TextStyle(
                                    color: StoryJobTheme.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${member.role.titel} • ${member.status.label}',
                                  style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (myRole.darfVerwalten && member.role == TeamRolle.neuling)
                            ElevatedButton(
                              onPressed: () => service.updateMemberRole(
                                teamId: team.id,
                                memberUid: member.uid,
                                newRole: TeamRolle.mitglied,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: StoryJobTheme.mintSuccess,
                                foregroundColor: Colors.black,
                              ),
                              child: const Text(
                                'Freischalten',
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}