// lib/features/profile/screens/profile_detail_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/services/audio_service.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/features/navigation/widgets/story_app_bar.dart';
import 'package:storyjob/features/messages/screens/story_dialog_screen.dart';
import 'package:storyjob/features/record/screens/video_recording_screen.dart';

class ProfileDetailScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? profileData;

  const ProfileDetailScreen({
    super.key,
    this.userId = 'default_user_01',
    this.profileData,
  });

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> with TickerProviderStateMixin {
  bool _isPlayingVoiceStory = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    AudioService.stopAudio();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _toggleVoiceStory(String? audioUrl) async {
    HapticFeedback.heavyImpact();

    if (_isPlayingVoiceStory) {
      await AudioService.stopAudio();
      setState(() {
        _isPlayingVoiceStory = false;
        _pulseController.stop();
        _waveController.stop();
      });
    } else {
      if (audioUrl != null && audioUrl.isNotEmpty) {
        await AudioService.playAudio(audioUrl);
      }
      setState(() {
        _isPlayingVoiceStory = true;
        _pulseController.repeat(reverse: true);
        _waveController.repeat();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.profileData?['name'] ?? widget.profileData?['displayName'] ?? 'Alex Weber';
    final String quote = widget.profileData?['quote'] ?? widget.profileData?['tagline'] ??
        'Ich möchte sinnstiftende Ideen und Technologie nachhaltig verbinden.';
    final String? audioUrl = widget.profileData?['audioPitchUrl'] ??
        widget.profileData?['audioStoryUrl'] ??
        widget.profileData?['audioUrl'];

    final int matchRate = widget.profileData?['matchRate'] ?? 88;
    final int visibilityPercent = widget.profileData?['visibilityPercent'] ?? 87;

    final List<String> sharedValues = (widget.profileData?['sharedValues'] as List<String>?) ??
        ['Eigenverantwortung', 'Teamfit', 'Nachhaltigkeit'];

    final List<String> strengths = (widget.profileData?['strengths'] as List<String>?) ??
        ['Produkt-Vision', 'Krisenfestigkeit', 'Analytische Klarheit'];
    final List<String> interests = (widget.profileData?['interests'] as List<String>?) ??
        ['KI', 'Nachhaltigkeit', 'Community', 'UX Design'];
    final List<String> values = (widget.profileData?['values'] as List<String>?) ??
        ['Verantwortung', 'Eigeninitiative', 'Transparenz'];
    final List<String> communities = (widget.profileData?['communities'] as List<String>?) ??
        ['Freiwillige Feuerwehr', 'Katastrophenschutz'];
    final List<String> goals = (widget.profileData?['goals'] as List<String>?) ??
        ['Etwas Sinnvolles bewegen', 'Menschzentrierte Systeme bauen'];
    final List<String> workstyle = [
      'Eigenverantwortliche Gestaltung',
      'Flexible Zusammenarbeit',
      'Offene Feedback-Kultur'
    ];

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: const StoryAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              Color(0xFF1D1438),
              StoryJobTheme.backgroundBase,
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===========================================================
                  // 1. KOPFZEILE (Titel & Untertitel)
                  // ===========================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Deine StoryJob DNA',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: StoryJobTheme.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Dein Werteprofil',
                          style: TextStyle(
                            fontSize: 13,
                            color: StoryJobTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ===========================================================
                  // 2. OBERES DUO (Audio-Shortcuts & Match-Ringe)
                  // ===========================================================
                  Row(
                    children: [
                      // Linke Kachel: 30s Audio Controls
                      Expanded(
                        child: GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => _toggleVoiceStory(audioUrl),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white12,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white24),
                                      ),
                                      child: Icon(
                                        _isPlayingVoiceStory ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '30 sec',
                                      style: TextStyle(
                                        color: StoryJobTheme.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.graphic_eq_rounded, color: StoryJobTheme.cyanAccent, size: 18),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '30 sec',
                                    style: TextStyle(
                                      color: StoryJobTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Rechte Kachel: Team-Fit & Wellenlänge
                      Expanded(
                        child: GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildMiniFitRing(
                                label: 'Team-Fit',
                                outerColor: StoryJobTheme.cyanAccent,
                                innerColor: StoryJobTheme.primaryViolet,
                              ),
                              _buildMiniFitRing(
                                label: 'Wellenlänge',
                                outerColor: StoryJobTheme.amberEnergy,
                                innerColor: StoryJobTheme.pinkMagenta,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ===========================================================
                  // 3. VIDEO-PITCH KARTE (Zentraler Video-Bereich)
                  // ===========================================================
                  GlassCard(
                    borderRadius: 24,
                    borderGradient: StoryJobTheme.dnaCardBorder,
                    hasNeonGlow: true,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Video-Vorschau / Avatar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                height: 260,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: StoryJobTheme.cardSurfaceElevated,
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/placeholder_pitch.png'),
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.2),
                                        Colors.black.withValues(alpha: 0.85),
                                      ],
                                      stops: const [0.3, 0.6, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Video Record / Replace Button
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const VideoRecordingScreen()),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 18),
                                ),
                              ),
                            ),

                            // Zentrales Play & Player-Steuerung
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.skip_previous_rounded, color: Colors.white70, size: 22),
                                    const SizedBox(width: 12),
                                    // Mini Audio Wave
                                    _buildFloatingWave(),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () => _toggleVoiceStory(audioUrl),
                                      child: Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withValues(alpha: 0.3),
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                        child: Icon(
                                          _isPlayingVoiceStory ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildFloatingWave(),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 22),
                                  ],
                                ),
                              ],
                            ),

                            // Werte-Tags direkt im Video unten
                            Positioned(
                              bottom: 12,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildVideoTag('Teamgeist'),
                                  const SizedBox(width: 8),
                                  _buildVideoTag('Sinnstiftung'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ===========================================================
                  // 4. DREIER-REIHE DER KERNWERTE
                  // ===========================================================
                  Row(
                    children: [
                      Expanded(
                        child: _buildValueCard(
                          icon: Icons.shield_outlined,
                          color: StoryJobTheme.primaryViolet,
                          title: 'Verlässlichkeit',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildValueCard(
                          icon: Icons.person_pin_rounded,
                          color: StoryJobTheme.amberEnergy,
                          title: 'Eigenverantwortung',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildValueCard(
                          icon: Icons.groups_rounded,
                          color: StoryJobTheme.cyanAccent,
                          title: 'Teamgeist',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ===========================================================
                  // 5. STATUS-KACHELN (DNA-Entfaltung & Sichtbarkeit)
                  // ===========================================================
                  Row(
                    children: [
                      // DNA-Entfaltung
                      Expanded(
                        child: GlassCard(
                          borderRadius: 18,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.fingerprint_rounded, color: StoryJobTheme.cyanAccent, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'DNA-Entfaltung',
                                      style: TextStyle(
                                        color: StoryJobTheme.textPrimary,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Personal Vibe',
                                      style: TextStyle(
                                        color: StoryJobTheme.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Sichtbarkeit mit Ring
                      Expanded(
                        child: GlassCard(
                          borderRadius: 18,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  value: visibilityPercent / 100.0,
                                  strokeWidth: 3,
                                  backgroundColor: Colors.white12,
                                  valueColor: const AlwaysStoppedAnimation<Color>(StoryJobTheme.mintSuccess),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$visibilityPercent% Sichtbarkeit',
                                      style: const TextStyle(
                                        color: StoryJobTheme.textPrimary,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Personal Vibe',
                                      style: TextStyle(
                                        color: StoryJobTheme.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ===========================================================
                  // 6. DETAIL-ABSCHNITTE (Bestehende Daten unversehrt erhalten)
                  // ===========================================================
                  _buildSectionCard(
                    title: 'Gelebte Werte & Haltung',
                    icon: Icons.favorite_border_rounded,
                    items: values,
                    chipColor: StoryJobTheme.champagneGold,
                  ),
                  const SizedBox(height: 12),

                  if (communities.isNotEmpty) ...[
                    _buildSectionCard(
                      title: 'Gemeinschaft & Engagement',
                      icon: Icons.volunteer_activism_rounded,
                      items: communities,
                      chipColor: StoryJobTheme.emeraldGreen,
                    ),
                    const SizedBox(height: 12),
                  ],

                  _buildSectionCard(
                    title: 'Themen & Interessen',
                    icon: Icons.interests_rounded,
                    items: interests,
                    chipColor: StoryJobTheme.cyanAccent,
                  ),
                  const SizedBox(height: 24),

                  // CTA BUTTON: Dialog auf Augenhöhe
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StoryJobTheme.primaryViolet,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        final cleanChatId = 'chat_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_')}';

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => StoryDialogScreen(
                              chatId: cleanChatId,
                              targetName: name,
                              roleContext: quote,
                              matchScore: '$matchRate%',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.forum_rounded, size: 18),
                      label: const Text(
                        'Dialog auf Augenhöhe starten ✨',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HILFS-WIDGETS FÜR DAS NEUE SCREEN-LAYOUT
  // ===========================================================================

  static Widget _buildMiniFitRing({
    required String label,
    required Color outerColor,
    required Color innerColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(colors: [outerColor, innerColor, outerColor]),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: StoryJobTheme.cardSurface,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: StoryJobTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static Widget _buildValueCard({
    required IconData icon,
    required Color color,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: StoryJobTheme.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildVideoTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static Widget _buildFloatingWave() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [6, 12, 18, 10, 14].map((h) {
        return Container(
          width: 2.5,
          height: h.toDouble(),
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<String> items,
    required Color chipColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StoryJobTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: chipColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: chipColor.withValues(alpha: 0.30)),
                ),
                child: Text(
                  item,
                  style: const TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}