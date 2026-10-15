// lib/features/profile/screens/my_story_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:storyjob/core/services/audio_service.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/features/profile/screens/personal_data_screen.dart';
import 'package:storyjob/features/settings/screens/settings_screen.dart';
import 'package:storyjob/features/record/screens/story_recording_screen.dart';

class MyStoryScreen extends StatefulWidget {
  const MyStoryScreen({super.key});

  @override
  State<MyStoryScreen> createState() => _MyStoryScreenState();
}

class _MyStoryScreenState extends State<MyStoryScreen> {
  bool _isPlayingAudio = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  Future<void> _toggleAudio(String? audioUrl) async {
    HapticFeedback.lightImpact();
    if (_isPlayingAudio) {
      await AudioService.stopAudio();
      if (mounted) setState(() => _isPlayingAudio = false);
    } else {
      if (audioUrl != null && audioUrl.isNotEmpty) {
        await AudioService.playAudio(audioUrl);
        if (mounted) setState(() => _isPlayingAudio = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Noch keine Audio-Story hinterlegt.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            backgroundColor: StoryJobTheme.cardSurfaceElevated,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: StoryJobTheme.cardBorder),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    AudioService.stopAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _currentUser?.uid;

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: uid != null
              ? FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
              : null,
          builder: (context, snapshot) {
            final data = snapshot.data?.data() ?? {};

            final name = data['displayName'] ?? data['name'] ?? _currentUser?.displayName ?? 'Peter Alt';
            final handle = data['handle'] ?? '@peteralt';
            final bio = data['bio'] ??
                'Hands-on Macher mit Fokus auf Menschlichkeit, Eigenverantwortung & moderne Teamkultur.';
            final audioUrl = data['audioStoryUrl'] as String?;
            final durationSec = data['audioDurationSeconds'] as int? ?? 30;
            final values = List<String>.from(
              data['values'] ?? ['Teamgeist', 'Verlässlichkeit', 'Eigenverantwortung', 'Sinnstiftung'],
            );
            final communities = List<String>.from(
              data['communities'] ?? ['BRK Katastrophenschutz', 'Feuerwehr Hartkirchen'],
            );
            final profileVisibility = (data['profileVisibilityPercent'] as num?)?.toDouble() ?? 95.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // =============================================================
                // 1. APP-HEADER MIT LOGO & SETTINGS
                // =============================================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: StoryJobTheme.cardSurfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: StoryJobTheme.cardBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: StoryJobTheme.cyanAccent,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'StoryJob',
                              style: TextStyle(
                                color: StoryJobTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: StoryJobTheme.cardSurfaceElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: StoryJobTheme.cardBorder,
                            ),
                          ),
                          child: const Icon(
                            Icons.settings_outlined,
                            color: StoryJobTheme.textSecondary,
                            size: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // =============================================================
                // 2. TITELBEREICH (Exakt wie auf dem Mockup)
                // =============================================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Deine StoryJob DNA',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: StoryJobTheme.textSecondary,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Dein Werteprofil',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: StoryJobTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // =============================================================
                // 3. SCROLLBARER INHALT
                // =============================================================
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18.0, 4.0, 18.0, 100.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // PROFIL-ÜBERSICHT
                        GlassCard(
                          borderRadius: 22,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: StoryJobTheme.primaryViolet.withValues(alpha: 0.16),
                                      border: Border.all(
                                        color: StoryJobTheme.primaryViolet.withValues(alpha: 0.50),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: StoryJobTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          handle,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: StoryJobTheme.cyanAccent,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: const BoxDecoration(
                                                color: StoryJobTheme.mintSuccess,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Text(
                                              'StoryJob DNA aktiv',
                                              style: TextStyle(
                                                color: StoryJobTheme.textSecondary,
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: StoryJobTheme.textSecondary,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      HapticFeedback.selectionClick();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const PersonalDataScreen()),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                              const SizedBox(height: 12),
                              Text(
                                bio,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: StoryJobTheme.textPrimary,
                                  height: 1.45,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // AUDIO-STORY MIT DOPPEL-WELLENFORM
                        GlassCard(
                          borderRadius: 22,
                          borderGradient: StoryJobTheme.dnaCardBorder,
                          hasNeonGlow: true,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _toggleAudio(audioUrl),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: StoryJobTheme.cyanAccent.withValues(alpha: 0.15),
                                            border: Border.all(
                                              color: StoryJobTheme.cyanAccent.withValues(alpha: 0.45),
                                            ),
                                          ),
                                          child: Icon(
                                            _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                            color: StoryJobTheme.cyanAccent,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '30-Sekunden Audio-Story (${durationSec}s)',
                                        style: const TextStyle(
                                          color: StoryJobTheme.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const StoryRecordingScreen()),
                                      );
                                    },
                                    child: Row(
                                      children: const [
                                        Text(
                                          'Neu',
                                          style: TextStyle(
                                            color: StoryJobTheme.textSecondary,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: StoryJobTheme.textSecondary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              // Erste Wellenlinie (Violett / Pink)
                              _buildNeonWaveform(
                                colors: [
                                  StoryJobTheme.primaryViolet,
                                  StoryJobTheme.pinkMagenta,
                                ],
                                heights: [6, 12, 18, 28, 38, 26, 16, 12, 10, 16, 24, 12],
                              ),
                              const SizedBox(height: 12),
                              // Zweite Wellenlinie (Pink / Cyan)
                              _buildNeonWaveform(
                                colors: [
                                  StoryJobTheme.pinkMagenta,
                                  StoryJobTheme.cyanAccent,
                                ],
                                heights: [10, 16, 22, 32, 20, 30, 24, 16, 12, 20, 14, 8],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // FIT-INDIKATOREN (Team-Fit & Werte-Match)
                        GlassCard(
                          borderRadius: 22,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildFitIndicator(
                                title: 'Werte-Match',
                                gradientColors: [
                                  StoryJobTheme.primaryViolet,
                                  StoryJobTheme.pinkMagenta,
                                ],
                              ),
                              _buildFitIndicator(
                                title: 'Team-Fit',
                                gradientColors: [
                                  StoryJobTheme.cyanAccent,
                                  StoryJobTheme.primaryViolet,
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // CORE VALUES GRID
                        GlassCard(
                          borderRadius: 22,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Core Values',
                                style: TextStyle(
                                  color: StoryJobTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildValueChip(
                                      icon: Icons.groups_rounded,
                                      iconColor: StoryJobTheme.primaryViolet,
                                      label: values.isNotEmpty ? values[0] : 'Teamgeist',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildValueChip(
                                      icon: Icons.verified_user_rounded,
                                      iconColor: StoryJobTheme.cyanAccent,
                                      label: values.length > 1 ? values[1] : 'Verlässlichkeit',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildValueChip(
                                      icon: Icons.bolt_rounded,
                                      iconColor: StoryJobTheme.amberEnergy,
                                      label: values.length > 2 ? values[2] : 'Eigenverantwortung',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildValueChip(
                                      icon: Icons.volunteer_activism_rounded,
                                      iconColor: StoryJobTheme.pinkMagenta,
                                      label: values.length > 3 ? values[3] : 'Sinnstiftung',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ENGAGEMENT & GEMEINSCHAFTEN (Falls vorhanden)
                        if (communities.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          GlassCard(
                            borderRadius: 20,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Gemeinschaften & Praxis',
                                  style: TextStyle(
                                    color: StoryJobTheme.textPrimary,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: communities.map((comm) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: StoryJobTheme.mintSuccess.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: StoryJobTheme.mintSuccess.withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.shield_outlined,
                                            size: 12,
                                            color: StoryJobTheme.mintSuccess,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            comm,
                                            style: const TextStyle(
                                              color: StoryJobTheme.textPrimary,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // DNA-ENTFALTUNG
                        GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DNA-Entfaltung',
                                style: TextStyle(
                                  color: StoryJobTheme.textPrimary,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${profileVisibility.toInt()}% von deinem Profil sichtbar',
                                style: const TextStyle(
                                  color: StoryJobTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  height: 7,
                                  width: double.infinity,
                                  color: Colors.white12,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: (profileVisibility / 100.0).clamp(0.0, 1.0),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              StoryJobTheme.cyanAccent,
                                              StoryJobTheme.pinkMagenta,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ACTION BUTTON (Aufnahme starten)
                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const StoryRecordingScreen()),
                              );
                            },
                            icon: const Icon(Icons.mic_rounded, size: 20),
                            label: const Text(
                              'Neue Audio-Story aufnehmen ✨',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: StoryJobTheme.primaryViolet,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // HILFS-WIDGETS
  // ===========================================================================

  static Widget _buildFitIndicator({
    required String title,
    required List<Color> gradientColors,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: StoryJobTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(colors: gradientColors),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                  decoration: const BoxDecoration(
                    color: StoryJobTheme.cardSurface,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 26,
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildValueChip({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StoryJobTheme.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: StoryJobTheme.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNeonWaveform({
    required List<Color> colors,
    required List<double> heights,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(colors: colors).createShader(bounds),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: heights.map((h) {
          return Container(
            width: 3.5,
            height: h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }).toList(),
      ),
    );
  }
}