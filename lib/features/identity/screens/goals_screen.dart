// lib/features/identity/screens/goals_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/identity/models/story_identity.dart';
import 'package:storyjob/features/identity/services/story_identity_service.dart';

class GoalsScreen extends StatefulWidget {
  final String userId;
  final StoryIdentity currentIdentity;

  const GoalsScreen({
    super.key,
    required this.userId,
    required this.currentIdentity,
  });

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final StoryIdentityService _identityService = StoryIdentityService();
  final TextEditingController _customGoalController = TextEditingController();

  late List<String> _selectedGoals;

  final List<String> _availableGoals = [
    'Etwas Sinnvolles bewegen',
    'Praxis & Handwerk vertiefen',
    'Eigenes Team aufbauen & leiten',
    'Verantwortung & Haltung leben',
    'Gemeinschaft voranbringen',
    'Nachhaltigen Wandel gestalten',
    'Neues wagen & gründen',
    'Freiraum & Flexibilität verbinden',
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedGoals = List.from(widget.currentIdentity.goals);
  }

  @override
  void dispose() {
    _customGoalController.dispose();
    super.dispose();
  }

  void _toggleGoal(String goal) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.add(goal);
      }
    });
  }

  void _addCustomGoal() {
    final text = _customGoalController.text.trim();
    if (text.isNotEmpty && !_selectedGoals.contains(text)) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedGoals.add(text);
        _customGoalController.clear();
      });
    }
  }

  Future<void> _saveAndReturn() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      final updatedIdentity = widget.currentIdentity.copyWith(
        goals: _selectedGoals,
      );

      await _identityService.saveIdentity(widget.userId, updatedIdentity);

      if (!mounted) return;
      Navigator.of(context).pop(updatedIdentity);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Ziele & Meilensteine gespeichert ✨',
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
    const goalsAccent = StoryJobTheme.champagneGold;

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
          'Deine Ziele & Vision',
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
                    child: CircularProgressIndicator(strokeWidth: 2, color: goalsAccent),
                  )
                : const Text(
                    'Fertig',
                    style: TextStyle(
                      color: goalsAccent,
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
                'Wohin möchtest du steuern?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: StoryJobTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Wähle Ziele aus, die deine persönliche Richtung und Ambition beschreiben.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: StoryJobTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // FREITEXT: EIGENES ZIEL ERGÄNZEN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag_rounded, color: goalsAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _customGoalController,
                        style: const TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 13.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Eigenes Ziel formulieren...',
                          hintStyle: TextStyle(
                            color: StoryJobTheme.textMuted,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _addCustomGoal(),
                      ),
                    ),
                    TextButton(
                      onPressed: _addCustomGoal,
                      child: const Text(
                        'Hinzufügen',
                        style: TextStyle(
                          color: goalsAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // LISTE DER ZIELE
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
                      // Individuelle Ziele
                      if (_selectedGoals.any((g) => !_availableGoals.contains(g))) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                          child: Text(
                            'Deine eigenen Ziele:',
                            style: TextStyle(
                              fontSize: 12,
                              color: StoryJobTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ..._selectedGoals.where((g) => !_availableGoals.contains(g)).map((custom) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: goalsAccent, size: 18),
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
                                  onTap: () => _toggleGoal(custom),
                                  child: const Icon(Icons.close_rounded, size: 16, color: StoryJobTheme.textMuted),
                                ),
                              ],
                            ),
                          );
                        }),
                        Divider(
                          height: 16,
                          thickness: 1,
                          indent: 16,
                          endIndent: 16,
                          color: StoryJobTheme.cardBorder,
                        ),
                      ],

                      // Standard-Auswahl
                      ..._availableGoals.map((goal) {
                        final isSelected = _selectedGoals.contains(goal);
                        return InkWell(
                          onTap: () => _toggleGoal(goal),
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
                                        ? goalsAccent.withValues(alpha: 0.20)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? goalsAccent
                                          : StoryJobTheme.cardBorder,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Center(
                                          child: Icon(
                                            Icons.check_rounded,
                                            size: 14,
                                            color: goalsAccent,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    goal,
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
                    backgroundColor: goalsAccent.withValues(alpha: 0.18),
                    foregroundColor: goalsAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: goalsAccent.withValues(alpha: 0.4)),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: goalsAccent, strokeWidth: 2),
                        )
                      : const Text(
                          'Ziele sichern ✨',
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