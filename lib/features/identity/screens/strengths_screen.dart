// lib/features/identity/screens/strengths_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/identity/models/story_identity.dart';
import 'package:storyjob/features/identity/services/story_identity_service.dart';

class StrengthsScreen extends StatefulWidget {
  final String userId;
  final StoryIdentity currentIdentity;

  const StrengthsScreen({
    super.key,
    required this.userId,
    required this.currentIdentity,
  });

  @override
  State<StrengthsScreen> createState() => _StrengthsScreenState();
}

class _StrengthsScreenState extends State<StrengthsScreen> {
  final StoryIdentityService _identityService = StoryIdentityService();
  final TextEditingController _customStrengthController = TextEditingController();

  late List<String> _selectedStrengths;

  final List<String> _availableStrengths = [
    'Hands-on-Mentalität & Anpacken',
    'Ruhe & Verlässlichkeit in Krisen',
    'Analytisches & strukturiertes Denken',
    'Organisation, Weitblick & Planung',
    'Empathie, Zuhören & Teamgeist',
    'Kreatives Problemlösen & Ideenreichtum',
    'Verständliche Kommunikation & Erklärung',
    'Eigeninitiative & Durchhaltevermögen',
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedStrengths = List.from(widget.currentIdentity.strengths);
  }

  @override
  void dispose() {
    _customStrengthController.dispose();
    super.dispose();
  }

  void _toggleStrength(String strength) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedStrengths.contains(strength)) {
        _selectedStrengths.remove(strength);
      } else {
        _selectedStrengths.add(strength);
      }
    });
  }

  void _addCustomStrength() {
    final text = _customStrengthController.text.trim();
    if (text.isNotEmpty && !_selectedStrengths.contains(text)) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedStrengths.add(text);
        _customStrengthController.clear();
      });
    }
  }

  Future<void> _saveAndReturn() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      final updatedIdentity = widget.currentIdentity.copyWith(
        strengths: _selectedStrengths,
      );

      await _identityService.saveIdentity(widget.userId, updatedIdentity);

      if (!mounted) return;
      Navigator.of(context).pop(updatedIdentity);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Stärken erfolgreich gespeichert ✨',
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
    const Color strengthsAccent = StoryJobTheme.primaryViolet;

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
          'Deine Stärken',
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
                    child: CircularProgressIndicator(strokeWidth: 2, color: strengthsAccent),
                  )
                : const Text(
                    'Fertig',
                    style: TextStyle(
                      color: strengthsAccent,
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
                'Worauf kann man sich bei dir verlassen?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: StoryJobTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Wähle Stärken und Fähigkeiten aus, die dich im täglichen Machen und Zusammenarbeiten auszeichnen.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: StoryJobTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // EIGENE STÄRKE HINZUFÜGEN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: strengthsAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _customStrengthController,
                        style: const TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 13.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Eigene Stärke eintragen...',
                          hintStyle: TextStyle(
                            color: StoryJobTheme.textMuted,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _addCustomStrength(),
                      ),
                    ),
                    TextButton(
                      onPressed: _addCustomStrength,
                      child: const Text(
                        'Hinzufügen',
                        style: TextStyle(
                          color: strengthsAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // LISTE DER STÄRKEN
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
                      if (_selectedStrengths.any((s) => !_availableStrengths.contains(s))) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
                          child: Text(
                            'Deine eigenen Stärken:',
                            style: TextStyle(
                              fontSize: 12,
                              color: StoryJobTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ..._selectedStrengths.where((s) => !_availableStrengths.contains(s)).map((custom) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: strengthsAccent, size: 18),
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
                                  onTap: () => _toggleStrength(custom),
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

                      ..._availableStrengths.map((strength) {
                        final isSelected = _selectedStrengths.contains(strength);
                        return InkWell(
                          onTap: () => _toggleStrength(strength),
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
                                        ? strengthsAccent.withValues(alpha: 0.20)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? strengthsAccent
                                          : StoryJobTheme.cardBorder,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Center(
                                          child: Icon(
                                            Icons.check_rounded,
                                            size: 14,
                                            color: strengthsAccent,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    strength,
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
                    backgroundColor: strengthsAccent.withValues(alpha: 0.18),
                    foregroundColor: strengthsAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: strengthsAccent.withValues(alpha: 0.4)),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: strengthsAccent, strokeWidth: 2),
                        )
                      : const Text(
                          'Stärken sichern ✨',
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