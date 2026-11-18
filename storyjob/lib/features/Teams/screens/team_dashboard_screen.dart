import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/story_pulse_status_bar.dart';
import 'package:storyjob/features/Teams/screens/teams_dna_screen.dart';
import 'package:storyjob/features/Teams/screens/team_talent_pool_screen.dart';
import 'package:storyjob/features/messages/screens/story_dialog_screen.dart';
import 'package:storyjob/features/teams/screens/company_public_profile_screen.dart'; // NEU: Alpha-Tier Schaufenster

class TeamDashboardScreen extends StatefulWidget {
  final String teamId;

  const TeamDashboardScreen({
    super.key,
    this.teamId = 'team_demo',
  });

  @override
  State<TeamDashboardScreen> createState() => _TeamDashboardScreenState();
}

class _TeamDashboardScreenState extends State<TeamDashboardScreen> {
  String get _effectiveTeamId {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    return (currentUid != null && currentUid.isNotEmpty) ? currentUid : widget.teamId;
  }

  void _openTeamIdentity() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TeamsDnaScreen(),
      ),
    );
  }

  // NEU: Öffnet die Live-Vorschau des öffentlichen Alpha-Tier-Schaufensters
  void _openPublicShowcase() {
    HapticFeedback.lightImpact();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CompanyPublicProfileScreen(
          companyId: _effectiveTeamId, // Die Firmen-ID
          teamId: _effectiveTeamId,    // Das Team
          talentUid: currentUserId,    // Das angemeldete Talent (falls Admin testet)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('companies')
              .doc(_effectiveTeamId)
              .snapshots(),
          builder: (context, teamSnapshot) {
            final teamData = teamSnapshot.data?.data() as Map<String, dynamic>?;
            final teamName = teamData?['name'] as String? ?? 'Team';

            return ListView(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 110.0),
              physics: const BouncingScrollPhysics(),
              children: [
                // Top App Bar / Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.asset(
                            'assets/branding/app_icon_dark.png',
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.corporate_fare_rounded,
                                color: StoryJobTheme.cyanAccent,
                                size: 28,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                            children: [
                              TextSpan(
                                text: 'Story',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'Job',
                                style: TextStyle(color: StoryJobTheme.cyanAccent),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Unternehmens-DNA',
                          icon: const Icon(Icons.tune_rounded, color: StoryJobTheme.cyanAccent),
                          onPressed: _openTeamIdentity,
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: StoryJobTheme.textSecondary),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const StoryDialogScreen(
                                  chatId: 'team_dialogs',
                                  targetName: 'Team-Dialoge',
                                  roleContext: 'Aktive Gespräche mit Machern',
                                  matchScore: 'StoryJob Teams',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Live Pulse Status Bar
                const StoryPulseStatusBar(
                  isteam: true,
                  currentUserName: 'Euer Team',
                ),
                const SizedBox(height: 18),

                // Begrüßung im exakten Talent-Stil
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

                // Primary Action Button (Firmen-DNA definieren)
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

                // NEU: Sekundärer Action Button (Öffentliches Schaufenster ansehen)
                SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23),
                      ),
                    ),
                    onPressed: _openPublicShowcase,
                    icon: const Icon(Icons.visibility_rounded, size: 18, color: StoryJobTheme.cyanAccent),
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

                // Sektion: In deiner Wellenlänge / Talent-Pool Vorschau
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
                      onPressed: () {
                        // Wechsel zum Talent-Pool Tab
                      },
                      child: const Text(
                        'Alle anzeigen',
                        style: TextStyle(color: StoryJobTheme.cyanAccent, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Info-Card analog zum Talent-Screen
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
                              color: StoryJobTheme.cyanAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.people_rounded, color: StoryJobTheme.cyanAccent, size: 20),
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
                            side: const BorderSide(color: StoryJobTheme.cardBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            // Aktion
                          },
                          child: const Text('Talente ansehen', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}