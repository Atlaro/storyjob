// lib/features/Teams/screens/team_dashboard_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/story_pulse_status_bar.dart';
import 'package:storyjob/features/Teams/screens/teams_dna_screen.dart';
import 'package:storyjob/features/messages/screens/story_dialog_screen.dart';

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

  void _manageTeamStory(String? currentVideoUrl) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: StoryJobTheme.cardSurfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cyanAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.videocam_rounded, color: StoryJobTheme.cyanAccent, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '60s Team- & Kultur-Impuls',
                            style: TextStyle(
                              color: StoryJobTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Zeigt Talenten und Machern eure gelebten Werte vorab.',
                            style: TextStyle(
                              color: StoryJobTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.video_call_rounded, color: StoryJobTheme.cyanAccent),
                  title: const Text(
                    'Impuls aufnehmen (max. 60 Sek.)',
                    style: TextStyle(color: StoryJobTheme.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Kamera nutzen für einen ungestellten, echten Einblick.',
                    style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  tileColor: StoryJobTheme.cardSurface,
                  onTap: () {
                    Navigator.pop(context);
                    _openTeamIdentity();
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.file_upload_outlined, color: StoryJobTheme.primaryViolet),
                  title: const Text(
                    'Bestehendes Video (MP4) hochladen',
                    style: TextStyle(color: StoryJobTheme.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Fertig bearbeitetes Team- oder Kultur-Video einbinden.',
                    style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 12),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  tileColor: StoryJobTheme.cardSurface,
                  onTap: () {
                    Navigator.pop(context);
                    _openTeamIdentity();
                  },
                ),
                if (currentVideoUrl != null && currentVideoUrl.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.play_circle_fill_rounded, color: StoryJobTheme.cyanAccent),
                    title: const Text(
                      'Aktuellen Impuls ansehen',
                      style: TextStyle(color: StoryJobTheme.textPrimary, fontWeight: FontWeight.w600),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tileColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.12),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
            final teamName = teamData?['name'] as String? ?? 'Team-Profil konfigurieren';
            final websiteUrl = teamData?['website'] as String? ?? 'Website & Werte verbinden';
            final logoUrl = teamData?['logoUrl'] as String?;
            final videoStoryUrl = teamData?['videoStoryUrl'] ?? teamData?['videoPitchUrl'] as String?;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 110.0),
              physics: const BouncingScrollPhysics(),
              children: [
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
                const StoryPulseStatusBar(
                  isteam: true,
                  currentUserName: 'Euer Team',
                ),
                const SizedBox(height: 18),
                const Text(
                  'Willkommen auf Augenhöhe',
                  style: TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: StoryJobTheme.cyanAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Aktive Werte-Matchen mit passenden Machern.',
                        style: TextStyle(
                          color: StoryJobTheme.cyanAccent,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: StoryJobTheme.cardSurfaceElevated,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: StoryJobTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _openTeamIdentity,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: StoryJobTheme.primaryViolet.withValues(alpha: 0.2),
                            border: Border.all(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.5), width: 1.5),
                          ),
                          child: ClipOval(
                            child: logoUrl != null && logoUrl.isNotEmpty
                                ? Image.network(
                                    logoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.business_rounded,
                                      color: StoryJobTheme.cyanAccent,
                                      size: 24,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: StoryJobTheme.cyanAccent,
                                    size: 22,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teamName,
                              style: const TextStyle(
                                color: StoryJobTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.link_rounded, size: 14, color: StoryJobTheme.cyanAccent),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    websiteUrl,
                                    style: const TextStyle(
                                      color: StoryJobTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: StoryJobTheme.cyanAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          backgroundColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _manageTeamStory(videoStoryUrl as String?),
                        icon: const Icon(Icons.videocam_rounded, size: 14),
                        label: const Text('Impuls', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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