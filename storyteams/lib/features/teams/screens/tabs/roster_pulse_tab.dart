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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35)),
        ),
        title: const Text(
          '24h Team-Impuls senden',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'z. B. Heute 19:00 Uhr Übung am Gerätehaus – alle willkommen! 🚒',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen', style: TextStyle(color: StoryJobTheme.textSecondary)),
          ),
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

  void _openVerifyMemberDialog(BuildContext context, TeamMember member) {
    final titleCtrl = TextEditingController(
      text: member.verifiedBadgeTitle.isNotEmpty
          ? member.verifiedBadgeTitle
          : 'Aktives Engagement • ${team.name}',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: StoryJobTheme.cardSurfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: StoryJobTheme.goldAccent.withValues(alpha: 0.45)),
        ),
        title: Row(
          children: [
            const Icon(Icons.verified_rounded, color: StoryJobTheme.goldAccent, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                member.isEngagementVerified
                    ? 'Verifikation anpassen'
                    : 'Engagement verifizieren',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bestätige das ehrenamtliche oder aktive Engagement von ${member.displayName} offiziell für StoryDNA & StoryJob.',
              style: const TextStyle(
                color: StoryJobTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: const InputDecoration(
                hintText: 'Badge-Bezeichnung (z. B. Aktiver Feuerwehrmann)',
                prefixIcon: Icon(Icons.workspace_premium_outlined, size: 19),
              ),
            ),
          ],
        ),
        actions: [
          if (member.isEngagementVerified)
            TextButton(
              onPressed: () async {
                await service.setMemberEngagementVerification(
                  teamId: team.id,
                  teamName: team.name,
                  memberUid: member.uid,
                  verified: false,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Entziehen', style: TextStyle(color: Colors.redAccent)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen', style: TextStyle(color: StoryJobTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              await service.setMemberEngagementVerification(
                teamId: team.id,
                teamName: team.name,
                memberUid: member.uid,
                verified: true,
                badgeTitle: titleCtrl.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: StoryJobTheme.goldAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Verifizieren', style: TextStyle(fontWeight: FontWeight.w700)),
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
                            style: TextStyle(
                              color: st.color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: member.status.color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: member.status.color.withValues(alpha: 0.45),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            member.displayName,
                                            style: const TextStyle(
                                              color: StoryJobTheme.textPrimary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        if (member.isEngagementVerified) ...[
                                          const SizedBox(width: 6),
                                          const Tooltip(
                                            message: 'Offiziell verifiziertes Engagement',
                                            child: Icon(
                                              Icons.verified_rounded,
                                              color: StoryJobTheme.goldAccent,
                                              size: 17,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      '${member.role.titel} • ${member.status.label}',
                                      style: const TextStyle(
                                        color: StoryJobTheme.textSecondary,
                                        fontSize: 12,
                                      ),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    minimumSize: Size.zero,
                                  ),
                                  child: const Text(
                                    'Freischalten',
                                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                  ),
                                )
                              else if (myRole.darfVerifizieren && member.role.istAktiv)
                                IconButton(
                                  tooltip: member.isEngagementVerified
                                      ? 'Verifikation bearbeiten'
                                      : 'Engagement verifizieren',
                                  onPressed: () => _openVerifyMemberDialog(context, member),
                                  icon: Icon(
                                    member.isEngagementVerified
                                        ? Icons.verified_rounded
                                        : Icons.verified_outlined,
                                    color: member.isEngagementVerified
                                        ? StoryJobTheme.goldAccent
                                        : StoryJobTheme.textSecondary,
                                    size: 21,
                                  ),
                                ),
                            ],
                          ),
                          if (member.qualifications.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: member.qualifications.map((q) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: StoryJobTheme.primaryViolet.withValues(alpha: 0.16),
                                    border: Border.all(
                                      color: StoryJobTheme.primaryViolet.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    q,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
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