// lib/features/identity/screens/motivators_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/identity/models/story_identity.dart';
import 'package:storyjob/features/identity/services/story_identity_service.dart';

class MotivatorsScreen extends StatefulWidget {
  final String userId;
  final StoryIdentity currentIdentity;

  const MotivatorsScreen({
    super.key,
    required this.userId,
    required this.currentIdentity,
  });

  @override
  State<MotivatorsScreen> createState() => _MotivatorsScreenState();
}

class _MotivatorsScreenState extends State<MotivatorsScreen> {
  final StoryIdentityService _identityService = StoryIdentityService();
  final TextEditingController _customMotivatorController = TextEditingController();

  late List<String> _selectedMotivators;

  final List<String> _availableMotivators = [
    'Sinnstiftende Aufgaben & echter Nutzen',
    'Freiheit & eigenverantwortliches Arbeiten',
    'Sichtbare Ergebnisse & echtes Handwerk',
    'Zusammenhalt & verlässliche Gemeinschaft',
    'Persönliches Wachstum & Neues lernen',
    'Sicherheit, Beständigkeit & Verlässlichkeit',
    'Echtes Feedback & aufrichtige Wertschätzung',
    'Verantwortung für Mensch & Region tragen',
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedMotivators = List.from(widget.currentIdentity.motivators);
  }

  @override
  void dispose() {
    _customMotivatorController.dispose();
    super.dispose();
  }

  void _toggleMotivator(String motivator) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedMotivators.contains(motivator)) {
        _selectedMotivators.remove(motivator);
      } else {
        _selectedMotivators.add(motivator);
      }
    });
  }

  void _addCustomMotivator() {
    final text = _customMotivatorController.text.trim();
    if (text.isNotEmpty && !_selectedMotivators.contains(text)) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedMotivators.add(text);
        _customMotivatorController.clear();
      });
    }
  }

  Future<void> _saveAndReturn() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      final updatedIdentity = widget.currentIdentity.copyWith(
        motivators: _selectedMotivators,
      );

      await _identityService.saveIdentity(widget.userId, updatedIdentity);

      if (!mounted) return;
      Navigator.of(context).pop(updatedIdentity);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Motivatoren erfolgreich gespeichert ✨',
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
          content: Text('Fehler beim Speichern: $e', style: const TextStyle(fontSize: 13)),
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color motivatorsAccent = StoryJobTheme.champagneGold;

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: StoryJobTheme.textPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Deine Motivatoren',
          style: TextStyle(
            color: StoryJobTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveAndReturn,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: motivatorsAccent),
                  )
                : const Text(
                    'Fertig',
                    style: TextStyle(
                      color: motivatorsAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18.0, 10.0, 18.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Was treibt dich im Kern an?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: StoryJobTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Wähle Faktoren aus, die deine innere Motivation und Freude im Alltag tragen.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: StoryJobTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // FREITEXT: EIGENEN ANTREIBER HINZUFÜGEN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: motivatorsAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _customMotivatorController,
                        style: const TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 13.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Eigenen Antreiber eintragen...',
                          hintStyle: TextStyle(
                            color: StoryJobTheme.textMuted,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _addCustomMotivator(),
                      ),
                    ),
                    TextButton(
                      onPressed: _addCustomMotivator,
                      child: const Text(
                        'Hinzufügen',
                        style: TextStyle(
                          color: motivatorsAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // LISTE DER MOTIVATOREN
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: StoryJobTheme.cardSurfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: StoryJobTheme.cardBorder),
                  ),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    children: [
                      if (_selectedMotivators.any((m) => !_availableMotivators.contains(m))) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
                          child: Text(
                            'Deine eigenen Antreiber:',
                            style: TextStyle(
                              fontSize: 12,
                              color: StoryJobTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ..._selectedMotivators.where((m) => !_availableMotivators.contains(m)).map((custom) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: motivatorsAccent, size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    custom,
                                    style: const TextStyle(
                                      color: StoryJobTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _toggleMotivator(custom),
                                  child: const Icon(Icons.close_rounded, size: 16, color: StoryJobTheme.textMuted),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(
                          height: 16,
                          thickness: 1,
                          indent: 16,
                          endIndent: 16,
                          color: StoryJobTheme.cardBorder,
                        ),
                      ],

                      ..._availableMotivators.map((motivator) {
                        final isSelected = _selectedMotivators.contains(motivator);
                        return InkWell(
                          onTap: () => _toggleMotivator(motivator),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? motivatorsAccent.withValues(alpha: 0.20)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? motivatorsAccent
                                          : StoryJobTheme.cardBorder,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Center(
                                          child: Icon(
                                            Icons.check_rounded,
                                            size: 14,
                                            color: motivatorsAccent,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    motivator,
                                    style: TextStyle(
                                      color: isSelected
                                          ? StoryJobTheme.textPrimary
                                          : StoryJobTheme.textSecondary,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAndReturn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: motivatorsAccent.withValues(alpha: 0.16),
                    foregroundColor: motivatorsAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: motivatorsAccent.withValues(alpha: 0.38)),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: motivatorsAccent, strokeWidth: 2),
                        )
                      : const Text(
                          'Motivatoren sichern ✨',
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}