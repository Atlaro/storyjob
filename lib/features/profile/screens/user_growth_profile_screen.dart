// lib/features/profile/screens/user_growth_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/features/identity/models/story_identity.dart';

class UserGrowthProfileScreen extends StatefulWidget {
  final String userId;
  final StoryIdentity identity;

  const UserGrowthProfileScreen({
    super.key,
    required this.userId,
    required this.identity,
  });

  @override
  State<UserGrowthProfileScreen> createState() => _UserGrowthProfileScreenState();
}

class _UserGrowthProfileScreenState extends State<UserGrowthProfileScreen> {
  bool _isSaving = false;

  // Praktische Kern-Fähigkeiten (Mockup: Handwerkliches Geschick, Kreative Gestaltung, etc.)
  double _skillHandwerk = 0.85;
  double _skillGestaltung = 0.70;
  double _skillProblemloesung = 0.90;
  double _skillPraktisch = 0.78;

  // Bestehende Entwicklungsbereiche
  late Map<String, double> _growthAreas;

  // Bestehende Meilensteine
  final List<Map<String, dynamic>> _milestones = [
    {'title': 'Erste Audio-Story geteilt', 'done': true, 'icon': Icons.mic_rounded},
    {'title': 'StoryJob DNA aktiviert', 'done': true, 'icon': Icons.fingerprint_rounded},
    {'title': 'Erstes Werte-Match entdeckt', 'done': true, 'icon': Icons.auto_awesome_rounded},
    {'title': 'Erster StoryDialog auf Augenhöhe', 'done': true, 'icon': Icons.forum_rounded},
    {'title': 'Persönliches Kennenlernen vereinbart', 'done': true, 'icon': Icons.event_available_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _growthAreas = {
      'Kommunikation auf Augenhöhe': 0.88,
      'Teamkultur & Miteinander': 0.92,
      'Verantwortung & Haltung': 0.95,
      'Gemeinwohl & Engagement': 0.90,
      'Agiles Gestalten & Führung': 0.78,
      'Fachliche Tatkraft': 0.92,
    };
  }

  Future<void> _saveGrowthData() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
        'practicalSkills': {
          'handwerklichesGeschick': _skillHandwerk,
          'kreativeGestaltung': _skillGestaltung,
          'problemloesung': _skillProblemloesung,
          'praktischesTalent': _skillPraktisch,
        },
        'growthAreas': _growthAreas,
        'impactVision': widget.identity.impactVision,
        'growthUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Fähigkeiten & Entwicklungsreise erfolgreich aktualisiert ✨',
            style: TextStyle(color: StoryJobTheme.textPrimary, fontWeight: FontWeight.w500),
          ),
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: StoryJobTheme.cardBorder),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Speichern: $e'),
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        title: const Text(
          'Praktisches Talent & Skills',
          style: TextStyle(
            color: StoryJobTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: StoryJobTheme.textPrimary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: StoryJobTheme.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===============================================================
              // 1. TITELBEREICH
              // ===============================================================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deine Skills',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: StoryJobTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Zeige, was du wirklich kannst – jenseits von Schulnoten',
                      style: TextStyle(
                        fontSize: 13,
                        color: StoryJobTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ===============================================================
              // 2. SKILL-REIHEN (Schieberegler mit Neon-Ringen)
              // ===============================================================
              GlassCard(
                borderRadius: 22,
                borderGradient: StoryJobTheme.dnaCardBorder,
                hasNeonGlow: true,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Column(
                  children: [
                    _buildSkillRow(
                      title: 'Handwerkliches Geschick',
                      value: _skillHandwerk,
                      colorA: StoryJobTheme.cyanAccent,
                      colorB: const Color(0xFF3B82F6),
                      onChanged: (val) => setState(() => _skillHandwerk = val),
                    ),
                    const SizedBox(height: 20),
                    _buildSkillRow(
                      title: 'Kreative Gestaltung',
                      value: _skillGestaltung,
                      colorA: StoryJobTheme.mintSuccess,
                      colorB: const Color(0xFF10B981),
                      onChanged: (val) => setState(() => _skillGestaltung = val),
                    ),
                    const SizedBox(height: 20),
                    _buildSkillRow(
                      title: 'Problemlösung',
                      value: _skillProblemloesung,
                      colorA: StoryJobTheme.pinkMagenta,
                      colorB: const Color(0xFFFB7185),
                      onChanged: (val) => setState(() => _skillProblemloesung = val),
                    ),
                    const SizedBox(height: 20),
                    _buildSkillRow(
                      title: 'Praktisches Talent',
                      value: _skillPraktisch,
                      colorA: StoryJobTheme.primaryViolet,
                      colorB: StoryJobTheme.cyanAccent,
                      onChanged: (val) => setState(() => _skillPraktisch = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ===============================================================
              // 3. PRAXIS-PROJEKTE GRID (2 Spalten wie im Mockup)
              // ===============================================================
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  'Praxis-Nachweise & Projekte',
                  style: TextStyle(
                    color: StoryJobTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GlassCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildBadgeIcon(Icons.carpenter_rounded, const Color(0xFFB45309)),
                              const SizedBox(width: 8),
                              _buildBadgeIcon(Icons.design_services_rounded, StoryJobTheme.pinkMagenta),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Design & Konzept',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: StoryJobTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildMiniAudioWave(StoryJobTheme.pinkMagenta),
                          const SizedBox(height: 12),
                          _buildTagPill('Kreativität'),
                          const SizedBox(height: 6),
                          _buildTagPill('Zuverlässigkeit'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildBadgeIcon(Icons.lightbulb_rounded, StoryJobTheme.amberEnergy),
                              const SizedBox(width: 8),
                              _buildBadgeIcon(Icons.work_outline_rounded, StoryJobTheme.cyanAccent),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Projektleitung',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: StoryJobTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildMiniAudioWave(StoryJobTheme.cyanAccent),
                          const SizedBox(height: 12),
                          _buildTagPill('Zuverlässigkeit'),
                          const SizedBox(height: 6),
                          _buildTagPill('Hands-on Macher'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ===============================================================
              // 4. VISION & HALTUNG (Bestehende Daten erhalten)
              // ===============================================================
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Text(
                  'IMPACT & VISION',
                  style: TextStyle(
                    color: StoryJobTheme.cyanAccent,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(18),
                child: Text(
                  widget.identity.impactVision.isNotEmpty
                      ? widget.identity.impactVision
                      : 'Ich möchte mit meiner Erfahrung und Haltung sinnstiftende Projekte mit echten Menschen voranbringen.',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: StoryJobTheme.textPrimary,
                    height: 1.45,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ===============================================================
              // 5. MEILENSTEINE AUF AUGENHÖHE
              // ===============================================================
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Text(
                  'MEILENSTEINE AUF AUGENHÖHE',
                  style: TextStyle(
                    color: StoryJobTheme.cyanAccent,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GlassCard(
                borderRadius: 22,
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: _milestones.map((milestone) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: StoryJobTheme.mintSuccess.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              milestone['icon'] as IconData,
                              color: StoryJobTheme.mintSuccess,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              milestone['title'] as String,
                              style: const TextStyle(
                                color: StoryJobTheme.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.check_circle_rounded,
                            color: StoryJobTheme.mintSuccess,
                            size: 18,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // ===============================================================
              // 6. SPEICHERN BUTTON
              // ===============================================================
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StoryJobTheme.primaryViolet,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveGrowthData,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Fähigkeiten & Profil speichern ✨',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HILFS-WIDGETS FÜR DIE SKILL-REIHEN
  // ===========================================================================

  Widget _buildSkillRow({
    required String title,
    required double value,
    required Color colorA,
    required Color colorB,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(colors: [colorA, colorB, colorA]),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.5),
            child: Container(
              decoration: const BoxDecoration(
                color: StoryJobTheme.cardSurface,
                shape: BoxShape.circle,
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
                title,
                style: const TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      final double totalWidth = constraints.maxWidth;
                      final double clamped = (details.localPosition.dx / totalWidth).clamp(0.0, 1.0);
                      HapticFeedback.selectionClick();
                      onChanged(clamped);
                    },
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          height: 5,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: value.clamp(0.05, 1.0),
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [colorA, colorB]),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment(value * 2 - 1, 0),
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: colorB.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }

  Widget _buildMiniAudioWave(Color waveColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(14, (i) {
          final heights = [4, 8, 14, 10, 18, 12, 6, 16, 10, 14, 8, 12, 6, 10];
          return Container(
            width: 2.5,
            height: heights[i % heights.length].toDouble(),
            decoration: BoxDecoration(
              color: waveColor.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTagPill(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StoryJobTheme.cardBorder),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: StoryJobTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}