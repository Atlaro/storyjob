import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/story_pulse_status_bar.dart';
import 'package:storyjob/features/Teams/screens/teams_dna_screen.dart';
import 'package:storyjob/features/teams/screens/company_public_profile_screen.dart';

class TeamDashboardScreen extends StatefulWidget {
  final String teamId;
  final VoidCallback? onOpenTalentPool;

  const TeamDashboardScreen({
    super.key,
    this.teamId = 'team_demo',
    this.onOpenTalentPool,
  });

  @override
  State<TeamDashboardScreen> createState() => _TeamDashboardScreenState();
}

class _TeamDashboardScreenState extends State<TeamDashboardScreen> {
  String get _effectiveTeamId {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    return (currentUid != null && currentUid.isNotEmpty)
        ? currentUid
        : widget.teamId;
  }

  void _openTeamIdentity() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TeamsDnaScreen(),
      ),
    );
  }

  void _openPublicShowcase() {
    HapticFeedback.lightImpact();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CompanyPublicProfileScreen(
          companyId: _effectiveTeamId,
          teamId: _effectiveTeamId,
          talentUid: currentUserId,
        ),
      ),
    );
  }

  void _goToTalentPool() {
    HapticFeedback.selectionClick();
    widget.onOpenTalentPool?.call();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight + 12;

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('companies')
            .doc(_effectiveTeamId)
            .snapshots(),
        builder: (context, teamSnapshot) {
          final teamData =
              teamSnapshot.data?.data() as Map<String, dynamic>?;
          final teamName = teamData?['name'] as String? ?? 'Team';

          return ListView(
            padding: EdgeInsets.fromLTRB(16.0, topInset, 16.0, 110.0),
            physics: const BouncingScrollPhysics(),
            children: [
              const StoryPulseStatusBar(
                isteam: true,
                currentUserName: 'Euer Team',
              ),
              const SizedBox(height: 18),
              Text(
                'Guten Tag,\n$teamName 👋',
                style: const TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Präsentiere eure Kultur und finde passende Macher auf Augenhöhe.',
                style: TextStyle(
                  color: StoryJobTheme.textSecondary,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoryJobTheme.cyanAccent,
                    foregroundColor: StoryJobTheme.backgroundBase,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: _openTeamIdentity,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                  label: const Text(
                    'Firmen-DNA & Werte definieren ✨',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: StoryJobTheme.cyanAccent.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23),
                    ),
                  ),
                  onPressed: _openPublicShowcase,
                  icon: const Icon(
                    Icons.visibility_rounded,
                    size: 18,
                    color: StoryJobTheme.cyanAccent,
                  ),
                  label: const Text(
                    'Öffentliches Schaufenster ansehen 👁️',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Passende Macher',
                    style: TextStyle(
                      color: StoryJobTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  TextButton(
                    onPressed: _goToTalentPool,
                    child: const Text(
                      'Alle anzeigen',
                      style: TextStyle(
                        color: StoryJobTheme.cyanAccent,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurfaceElevated,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: StoryJobTheme.cyanAccent
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.people_rounded,
                            color: StoryJobTheme.cyanAccent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            '3 neue Werte-Matches im Pool',
                            style: TextStyle(
                              color: StoryJobTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Macher aus deiner Region teilen deine Haltung zu Teamgeist & Eigenverantwortung.',
                      style: TextStyle(
                        color: StoryJobTheme.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: StoryJobTheme.textPrimary,
                          side: const BorderSide(
                            color: StoryJobTheme.cardBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _goToTalentPool,
                        child: const Text(
                          'Talente ansehen',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}