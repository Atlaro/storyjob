// lib/features/identity/screens/values_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/identity/models/story_identity.dart';
import 'package:storyjob/features/identity/services/story_identity_service.dart';

class ValuesScreen extends StatefulWidget {
  final String userId;
  final StoryIdentity currentIdentity;

  const ValuesScreen({
    super.key,
    required this.userId,
    required this.currentIdentity,
  });

  @override
  State<ValuesScreen> createState() => _ValuesScreenState();
}

class _ValuesScreenState extends State<ValuesScreen> {
  final StoryIdentityService _identityService = StoryIdentityService();
  final TextEditingController _customValueController = TextEditingController();

  late List<String> _selectedValues;

  final List<String> _availableValues = [
    'Verantwortung & Verlässlichkeit',
    'Bodenständigkeit & Ehrlichkeit',
    'Hands-on & Machen',
    'Gemeinschaft & Zusammenhalt',
    'Mut, Neugier & Innovation',
    'Wertschätzung & Augenhöhe',
    'Nachhaltigkeit & Respekt',
    'Freiheit & Eigenverantwortung',
    'Treue & Loyalität',
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedValues = List.from(widget.currentIdentity.values);
  }

  @override
  void dispose() {
    _customValueController.dispose();
    super.dispose();
  }

  void _toggleValue(String value) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedValues.contains(value)) {
        _selectedValues.remove(value);
      } else {
        _selectedValues.add(value);
      }
    });
  }

  void _addCustomValue() {
    final text = _customValueController.text.trim();
    if (text.isNotEmpty && !_selectedValues.contains(text)) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedValues.add(text);
        _customValueController.clear();
      });
    }
  }

  Future<void> _saveAndReturn() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      final updatedIdentity = widget.currentIdentity.copyWith(
        values: _selectedValues,
      );

      await _identityService.saveIdentity(widget.userId, updatedIdentity);

      if (!mounted) return;
      Navigator.of(context).pop(updatedIdentity);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Werte erfolgreich gespeichert ✨',
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
    const Color valuesAccent = StoryJobTheme.champagneGold;

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
          'Deine Werte',
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
                    child: CircularProgressIndicator(strokeWidth: 2, color: valuesAccent),
                  )
                : const Text(
                    'Fertig',
                    style: TextStyle(
                      color: valuesAccent,
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
                'Welche Prinzipien leiten dich?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: StoryJobTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Wähle Werte aus, die dein tägliches Handeln, deine Haltung und die Resonanz zu anderen Menschen prägen.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: StoryJobTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // EIGENEN WERT ERGÄNZEN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_rounded, color: valuesAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _customValueController,
                        style: const TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 13.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Eigenen Kernwert eintragen...',
                          hintStyle: TextStyle(
                            color: StoryJobTheme.textMuted,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _addCustomValue(),
                      ),
                    ),
                    TextButton(
                      onPressed: _addCustomValue,
                      child: const Text(
                        'Hinzufügen',
                        style: TextStyle(
                          color: valuesAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // LISTE DER WERTE
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
                      if (_selectedValues.any((v) => !_availableValues.contains(v))) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
                          child: Text(
                            'Deine eigenen Werte:',
                            style: TextStyle(
                              fontSize: 12,
                              color: StoryJobTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ..._selectedValues.where((v) => !_availableValues.contains(v)).map((custom) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: valuesAccent, size: 18),
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
                                  onTap: () => _toggleValue(custom),
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

                      ..._availableValues.map((value) {
                        final isSelected = _selectedValues.contains(value);
                        return InkWell(
                          onTap: () => _toggleValue(value),
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
                                        ? valuesAccent.withValues(alpha: 0.20)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? valuesAccent
                                          : StoryJobTheme.cardBorder,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Center(
                                          child: Icon(
                                            Icons.check_rounded,
                                            size: 14,
                                            color: valuesAccent,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    value,
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
                    backgroundColor: valuesAccent.withValues(alpha: 0.18),
                    foregroundColor: valuesAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: valuesAccent.withValues(alpha: 0.4)),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: valuesAccent, strokeWidth: 2),
                        )
                      : const Text(
                          'Werte sichern ✨',
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