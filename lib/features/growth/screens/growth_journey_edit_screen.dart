// lib/features/growth/screens/growth_journey_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/core/widgets/glass_button.dart';
import 'package:storyjob/features/identity/models/story_identity.dart';
import 'package:storyjob/features/identity/services/story_identity_service.dart';

class GrowthJourneyEditScreen extends StatefulWidget {
  final String userId;
  final StoryIdentity initialIdentity;

  const GrowthJourneyEditScreen({
    super.key,
    required this.userId,
    required this.initialIdentity,
  });

  @override
  State<GrowthJourneyEditScreen> createState() => _GrowthJourneyEditScreenState();
}

class _GrowthJourneyEditScreenState extends State<GrowthJourneyEditScreen> {
  final StoryIdentityService _identityService = StoryIdentityService();

  late final TextEditingController _learningController;
  late final TextEditingController _impactController;

  bool _isSaving = false;

  final List<String> _inspirationTags = const [
    'Projektleitung',
    'Erneuerbare Energien',
    'Handwerk & Meister',
    'Teamkultur & Mentoring',
    'Ehrenamt & Einsatz',
    'Digitale Workflows',
    'Nachhaltigkeit',
    'Kreatives Schaffen',
  ];

  @override
  void initState() {
    super.initState();
    _learningController = TextEditingController(
      text: widget.initialIdentity.learningInterests.join(', '),
    );
    _impactController = TextEditingController(
      text: widget.initialIdentity.impactVision,
    );
  }

  @override
  void dispose() {
    _learningController.dispose();
    _impactController.dispose();
    super.dispose();
  }

  void _addInspirationTag(String tag) {
    HapticFeedback.selectionClick();
    final currentText = _learningController.text.trim();
    final existingList = currentText
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();

    if (!existingList.contains(tag.toLowerCase())) {
      setState(() {
        if (currentText.isEmpty) {
          _learningController.text = tag;
        } else {
          _learningController.text = '$currentText, $tag';
        }
      });
    }
  }

  Future<void> _saveJourney() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      final updatedInterests = _learningController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final updatedIdentity = StoryIdentity(
        interests: widget.initialIdentity.interests,
        values: widget.initialIdentity.values,
        goals: widget.initialIdentity.goals,
        workstyle: widget.initialIdentity.workstyle,
        motivators: widget.initialIdentity.motivators,
        strengths: widget.initialIdentity.strengths,
        communities: widget.initialIdentity.communities,
        learningInterests: updatedInterests,
        impactVision: _impactController.text.trim(),
      );

      await _identityService.saveIdentity(widget.userId, updatedIdentity);

      if (!mounted) return;
      Navigator.of(context).pop(updatedIdentity);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Entwicklungsreise erfolgreich aktualisiert ✨',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFF1E222B),
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
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        iconTheme: const IconThemeData(color: StoryJobTheme.textPrimary),
        title: const Text(
          'Entwicklungsreise gestalten',
          style: TextStyle(
            color: StoryJobTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Zukunft & Wirkung gestalten',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: StoryJobTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Definiere, worin du wachsen möchtest und welchen Beitrag du in Teams, Betrieben oder Initiativen leisten willst.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: StoryJobTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              GlassCard(
                padding: const EdgeInsets.all(18),
                borderRadius: 22,
                borderColor: StoryJobTheme.champagneGold.withValues(alpha: 0.22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _learningController,
                      style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Wachstumsfelder & Interessen (kommagetrennt)',
                        labelStyle: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13),
                        hintText: 'z.B. Teamleitung, Erneuerbare Energien, Praxis-Know-how',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.28),
                          fontSize: 12.5,
                        ),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: StoryJobTheme.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: StoryJobTheme.champagneGold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Schnellauswahl / Impulse
                    const Text(
                      'Impulse zum Antippen:',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: StoryJobTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _inspirationTags.map((tag) {
                        return GestureDetector(
                          onTap: () => _addInspirationTag(tag),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: StoryJobTheme.champagneGold.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: StoryJobTheme.champagneGold.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_rounded, size: 12, color: StoryJobTheme.champagneGold),
                                const SizedBox(width: 3),
                                Text(
                                  tag,
                                  style: const TextStyle(
                                    color: StoryJobTheme.champagneGold,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _impactController,
                      style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 14),
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Wirkung & Vision',
                        labelStyle: const TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13),
                        hintText: 'Welche Werte und Veränderungen möchtest du in deiner täglichen Arbeit bewegen?',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.28),
                          fontSize: 12.5,
                        ),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.25),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: StoryJobTheme.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: StoryJobTheme.cyanAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _isSaving
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent),
                      ),
                    )
                  : GlassButton(
                      label: 'Entwicklungsreise speichern',
                      isPrimaryGlow: true,
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: _saveJourney,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}