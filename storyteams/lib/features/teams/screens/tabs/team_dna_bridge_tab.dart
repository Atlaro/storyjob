// lib/features/teams/screens/tabs/team_dna_bridge_tab.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyteams/core/theme/storyjob_theme.dart';
import 'package:storyteams/core/widgets/glass_card.dart';
import 'package:storyteams/features/teams/models/team_models.dart';
import 'package:storyteams/features/teams/models/team_role.dart';
import 'package:storyteams/features/teams/services/teams_firestore_service.dart';

class TeamDnaBridgeTab extends StatefulWidget {
  final TeamUnit team;
  final TeamRolle myRole;

  const TeamDnaBridgeTab({
    super.key,
    required this.team,
    required this.myRole,
  });

  @override
  State<TeamDnaBridgeTab> createState() => _TeamDnaBridgeTabState();
}

class _TeamDnaBridgeTabState extends State<TeamDnaBridgeTab> {
  final TeamsFirestoreService _service = TeamsFirestoreService();
  List<String> _userDnaValues = const ['Verlässlichkeit', 'Kameradschaft', 'Tatkraft'];

  @override
  void initState() {
    super.initState();
    _loadUserDna();
  }

  Future<void> _loadUserDna() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('identities').doc(uid).get();
      final data = doc.data();
      if (data != null && data['values'] is List && mounted) {
        final values = (data['values'] as List)
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (values.isNotEmpty) {
          setState(() => _userDnaValues = values);
        }
      }
    } catch (_) {
      // Fallback bleibt aktiv
    }
  }

  Future<void> _openEditCultureSheet() async {
    final mottoCtrl = TextEditingController(text: widget.team.motto);
    final storyCtrl = TextEditingController(text: widget.team.teamStory);
    final valuesCtrl = TextEditingController(text: widget.team.cultureValues.join(', '));

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: StoryJobTheme.cardSurfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: 22,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Team-Kultur & DNA bearbeiten',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: mottoCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Leitsatz / Motto',
                  prefixIcon: Icon(Icons.format_quote_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valuesCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Kultur-Werte (kommagetrennt)',
                  prefixIcon: Icon(Icons.favorite_border_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: storyCtrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Eure Team-Story: Wer seid ihr und wer passt zu euch?',
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Speichern'),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true) {
      final parsedValues = valuesCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await _service.updateTeamCulture(
        teamId: widget.team.id,
        motto: mottoCtrl.text,
        teamStory: storyCtrl.text,
        cultureValues: parsedValues.isNotEmpty
            ? parsedValues
            : const ['Teamgeist', 'Verlässlichkeit', 'Augenhöhe'],
      );
    }

    mottoCtrl.dispose();
    storyCtrl.dispose();
    valuesCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    final myRole = widget.myRole;
    final dnaMatch = team.calculateDnaMatchPercent(_userDnaValues);
    final sharedValues = team.findSharedValues(_userDnaValues);
    final currentUid = _service.currentUid;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Einladungscode & Rolle
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Text(
                  'EINLADUNGSCODE FÜR NEUE MITGLIEDER',
                  style: TextStyle(
                    color: StoryJobTheme.cyanAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  team.inviteCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Deine aktuelle Rolle: ${myRole.titel}',
                  style: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12.5),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: team.inviteCode));
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: StoryJobTheme.cardSurfaceElevated,
                        content: const Text('Einladungscode in die Zwischenablage kopiert ✨'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Code kopieren & teilen'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Offizielles Engagement-Verifikations-Badge (Live aus Member-Dok)
          if (currentUid.isNotEmpty)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('teams')
                  .doc(team.id)
                  .collection('members')
                  .doc(currentUid)
                  .snapshots(),
              builder: (context, snap) {
                final raw = snap.data?.data();
                final map = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};
                final member = TeamMember.fromMap(map, currentUid);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: member.isEngagementVerified
                                ? StoryJobTheme.goldAccent.withValues(alpha: 0.18)
                                : Colors.white.withValues(alpha: 0.06),
                            border: Border.all(
                              color: member.isEngagementVerified
                                  ? StoryJobTheme.goldAccent
                                  : StoryJobTheme.cardBorder,
                            ),
                          ),
                          child: Icon(
                            member.isEngagementVerified
                                ? Icons.verified_rounded
                                : Icons.verified_outlined,
                            color: member.isEngagementVerified
                                ? StoryJobTheme.goldAccent
                                : StoryJobTheme.textSecondary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.isEngagementVerified
                                    ? 'Engagement offiziell verifiziert'
                                    : 'Verifikations-Status ausstehend',
                                style: TextStyle(
                                  color: member.isEngagementVerified
                                      ? StoryJobTheme.goldAccent
                                      : Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                member.isEngagementVerified
                                    ? (member.verifiedBadgeTitle.isNotEmpty
                                        ? member.verifiedBadgeTitle
                                        : 'Sichtbar in deinem StoryDNA- & StoryJob-Profil')
                                    : 'Sobald Leitung oder Vorstand dich bestätigt, erscheint dein Badge im gesamten Ökosystem.',
                                style: const TextStyle(
                                  color: StoryJobTheme.textSecondary,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // StoryJob DNA Kultur-Brücke
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.fingerprint_rounded, color: StoryJobTheme.pinkMagenta, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'StoryJob DNA™ Kultur-Brücke',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: StoryJobTheme.pinkMagenta.withValues(alpha: 0.16),
                        border: Border.all(
                          color: StoryJobTheme.pinkMagenta.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        '$dnaMatch% DNA-Match',
                        style: const TextStyle(
                          color: StoryJobTheme.pinkMagenta,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  team.motto,
                  style: const TextStyle(
                    color: StoryJobTheme.goldAccent,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                if (team.teamStory.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    team.teamStory,
                    style: const TextStyle(
                      color: StoryJobTheme.textPrimary,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: team.cultureValues.map((val) {
                    final isShared = sharedValues
                        .any((s) => s.toLowerCase() == val.trim().toLowerCase());
                    return Chip(
                      label: Text(
                        isShared ? '✓ $val' : val,
                        style: TextStyle(
                          color: isShared ? StoryJobTheme.cyanAccent : StoryJobTheme.pinkMagenta,
                          fontSize: 12,
                          fontWeight: isShared ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      backgroundColor: isShared
                          ? StoryJobTheme.cyanAccent.withValues(alpha: 0.16)
                          : StoryJobTheme.pinkMagenta.withValues(alpha: 0.14),
                      side: BorderSide(
                        color: isShared
                            ? StoryJobTheme.cyanAccent
                            : StoryJobTheme.pinkMagenta.withValues(alpha: 0.4),
                      ),
                    );
                  }).toList(),
                ),
                if (myRole.darfVerwalten) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _openEditCultureSheet,
                    icon: const Icon(Icons.edit_outlined, size: 17),
                    label: const Text('Kultur, Motto & Werte bearbeiten'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}