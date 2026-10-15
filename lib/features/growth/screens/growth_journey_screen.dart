// lib/features/growth/screens/growth_journey_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/core/widgets/glow_orb.dart';
import 'package:storyjob/core/widgets/story_level_tracker_widget.dart';
import 'package:storyjob/features/growth/screens/growth_journey_edit_screen.dart';
import 'package:storyjob/features/identity/models/story_identity.dart';
import 'package:storyjob/features/identity/services/story_identity_service.dart';

class GrowthJourneyScreen extends StatefulWidget {
  final String userId;

  const GrowthJourneyScreen({
    super.key,
    required this.userId,
  });

  @override
  State<GrowthJourneyScreen> createState() => _GrowthJourneyScreenState();
}

class _GrowthJourneyScreenState extends State<GrowthJourneyScreen> {
  final StoryIdentityService _identityService = StoryIdentityService();
  bool _isLoading = true;
  StoryIdentity? _identity;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final identity = await _identityService.loadIdentity(widget.userId);
    if (mounted) {
      setState(() {
        _identity = identity;
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEdit() async {
    HapticFeedback.lightImpact();
    final updated = await Navigator.of(context).push<StoryIdentity>(
      MaterialPageRoute(
        builder: (_) => GrowthJourneyEditScreen(
          userId: widget.userId,
          initialIdentity: _identity ?? const StoryIdentity(),
        ),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _identity = updated;
      });
    }
  }

  int _calculateCompleteness(StoryIdentity? id) {
    if (id == null) return 25;
    int points = 25; // Basis-Klang
    if (id.values.isNotEmpty) points += 25;
    if (id.learningInterests.isNotEmpty) points += 25;
    if ((id.impactVision).isNotEmpty) points += 25;
    return points.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final completeness = _calculateCompleteness(_identity);

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        title: const Text(
          'Entwicklungsreise',
          style: TextStyle(
            color: StoryJobTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: StoryJobTheme.cyanAccent, size: 24),
            onPressed: _isLoading ? null : _navigateToEdit,
            tooltip: 'Reise bearbeiten',
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: GlowOrb(
              color: StoryJobTheme.primaryViolet.withValues(alpha: 0.25),
              size: 260,
            ),
          ),
          Positioned(
            bottom: -50,
            left: -40,
            child: GlowOrb(
              color: StoryJobTheme.cyanAccent.withValues(alpha: 0.18),
              size: 260,
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Dein Entwicklungspfad',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: StoryJobTheme.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sichtbares Potenzial statt statischer Lebenslauf. Halte fest, wohin deine Reise geht.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: StoryJobTheme.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 1. STORYJOB DNA™ ENTFALTUNGSTRACKER
                        StoryLevelTrackerWidget(
                          dnaCompleteness: completeness,
                          storiesRecorded: _identity?.interests.length ?? 1,
                          activeValuesCount: _identity?.values.length ?? 0,
                          onDeepenStory: _navigateToEdit,
                        ),
                        const SizedBox(height: 16),

                        // 2. WIRKUNGSVISION
                        GlassCard(
                          padding: const EdgeInsets.all(18),
                          borderRadius: 22,
                          borderColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: StoryJobTheme.cyanAccent.withValues(alpha: 0.15),
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome_rounded,
                                      color: StoryJobTheme.cyanAccent,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Wirkung & Vision',
                                    style: TextStyle(
                                      color: StoryJobTheme.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                (_identity?.impactVision != null && _identity!.impactVision.isNotEmpty)
                                    ? _identity!.impactVision
                                    : 'Noch keine Vision hinterlegt. Formuliere kurz, was du in Projekten und Teams bewegen möchtest.',
                                style: TextStyle(
                                  color: StoryJobTheme.textPrimary.withValues(alpha: 0.9),
                                  fontSize: 13.5,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 3. WACHSTUMSFELDER & FOKUS
                        GlassCard(
                          padding: const EdgeInsets.all(18),
                          borderRadius: 22,
                          borderColor: StoryJobTheme.champagneGold.withValues(alpha: 0.25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: StoryJobTheme.champagneGold.withValues(alpha: 0.15),
                                    ),
                                    child: const Icon(
                                      Icons.psychology_rounded,
                                      color: StoryJobTheme.champagneGold,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Wachstumsfelder & Fokus',
                                    style: TextStyle(
                                      color: StoryJobTheme.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              if (_identity != null && _identity!.learningInterests.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _identity!.learningInterests.map((item) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: StoryJobTheme.champagneGold.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: StoryJobTheme.champagneGold.withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          color: StoryJobTheme.textPrimary,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              else
                                const Text(
                                  'Noch keine Schwerpunkte gewählt.',
                                  style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 4. WERTE-BASIS
                        if (_identity != null && _identity!.values.isNotEmpty) ...[
                          GlassCard(
                            padding: const EdgeInsets.all(18),
                            borderRadius: 22,
                            borderColor: StoryJobTheme.primaryViolet.withValues(alpha: 0.25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: StoryJobTheme.primaryViolet.withValues(alpha: 0.15),
                                      ),
                                      child: const Icon(
                                        Icons.favorite_rounded,
                                        color: StoryJobTheme.primaryViolet,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Gelebte Werte',
                                      style: TextStyle(
                                        color: StoryJobTheme.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _identity!.values.map((v) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: StoryJobTheme.primaryViolet.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: StoryJobTheme.primaryViolet.withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: Text(
                                        v,
                                        style: const TextStyle(
                                          color: StoryJobTheme.textPrimary,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],

                        // CTA PILL BUTTON
                        SizedBox(
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: StoryJobTheme.cardSurfaceElevated,
                              foregroundColor: StoryJobTheme.cyanAccent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(
                                  color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                            onPressed: _navigateToEdit,
                            icon: const Icon(Icons.tune_rounded, size: 16),
                            label: const Text(
                              'Entwicklungspfad anpassen',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}