// lib/features/identity/screens/workstyle_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/identity/models/story_identity.dart';
import 'package:storyjob/features/identity/services/story_identity_service.dart';

class WorkstyleScreen extends StatefulWidget {
  final String userId;
  final StoryIdentity currentIdentity;

  const WorkstyleScreen({
    super.key,
    required this.userId,
    required this.currentIdentity,
  });

  @override
  State<WorkstyleScreen> createState() => _WorkstyleScreenState();
}

class _WorkstyleScreenState extends State<WorkstyleScreen> {
  final StoryIdentityService _identityService = StoryIdentityService();
  final TextEditingController _customWorkstyleController = TextEditingController();

  late List<String> _selectedWorkstyle;

  final List<String> _availableWorkstyles = [
    'Eigenverantwortliche Gestaltung & Vertrauen',
    'Vor Ort & Hands-on im Geschehen',
    'Flexible Einteilung & Freiraum',
    'Enge Teamabsprachen auf Augenhöhe',
    'Strukturierte & planbare Abläufe',
    'Fokuszeit für ungestörte Vertiefung',
    'Offener Ideenaustausch & Feedbackkultur',
    'Praxisnah, direkt & unbürokratisch',
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedWorkstyle = List.from(widget.currentIdentity.workstyle);
  }

  @override
  void dispose() {
    _customWorkstyleController.dispose();
    super.dispose();
  }

  void _toggleWorkstyle(String style) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedWorkstyle.contains(style)) {
        _selectedWorkstyle.remove(style);
      } else {
        _selectedWorkstyle.add(style);
      }
    });
  }

  void _addCustomWorkstyle() {
    final text = _customWorkstyleController.text.trim();
    if (text.isNotEmpty && !_selectedWorkstyle.contains(text)) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedWorkstyle.add(text);
        _customWorkstyleController.clear();
      });
    }
  }

  Future<void> _saveAndReturn() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      final updatedIdentity = widget.currentIdentity.copyWith(
        workstyle: _selectedWorkstyle,
      );

      await _identityService.saveIdentity(widget.userId, updatedIdentity);

      if (!mounted) return;
      Navigator.of(context).pop(updatedIdentity);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Arbeitsweise erfolgreich gespeichert ✨',
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
    const Color workstyleAccent = StoryJobTheme.primaryViolet;

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
          'Deine Arbeitsweise',
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
                    child: CircularProgressIndicator(strokeWidth: 2, color: workstyleAccent),
                  )
                : const Text(
                    'Fertig',
                    style: TextStyle(
                      color: workstyleAccent,
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
                'Wie arbeitest du am besten?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: StoryJobTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Wähle Arbeitsweisen aus, die dir Energie geben und die Zusammenarbeit im Alltag stimmig machen.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: StoryJobTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // EIGENE ARBEITSWEISE ERGÄNZEN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.work_outline_rounded, color: workstyleAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _customWorkstyleController,
                        style: const TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 13.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Eigene Arbeitsweise eintragen...',
                          hintStyle: TextStyle(
                            color: StoryJobTheme.textMuted,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _addCustomWorkstyle(),
                      ),
                    ),
                    TextButton(
                      onPressed: _addCustomWorkstyle,
                      child: const Text(
                        'Hinzufügen',
                        style: TextStyle(
                          color: workstyleAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // LISTE DER ARBEITSWEISEN
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
                      if (_selectedWorkstyle.any((s) => !_availableWorkstyles.contains(s))) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
                          child: Text(
                            'Deine individuellen Arbeitsweisen:',
                            style: TextStyle(
                              fontSize: 12,
                              color: StoryJobTheme.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ..._selectedWorkstyle.where((s) => !_availableWorkstyles.contains(s)).map((custom) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: workstyleAccent, size: 18),
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
                                  onTap: () => _toggleWorkstyle(custom),
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

                      ..._availableWorkstyles.map((style) {
                        final isSelected = _selectedWorkstyle.contains(style);
                        return InkWell(
                          onTap: () => _toggleWorkstyle(style),
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
                                        ? workstyleAccent.withValues(alpha: 0.20)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? workstyleAccent
                                          : StoryJobTheme.cardBorder,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Center(
                                          child: Icon(
                                            Icons.check_rounded,
                                            size: 14,
                                            color: workstyleAccent,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    style,
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
                    backgroundColor: workstyleAccent.withValues(alpha: 0.18),
                    foregroundColor: workstyleAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: workstyleAccent.withValues(alpha: 0.4)),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: workstyleAccent, strokeWidth: 2),
                        )
                      : const Text(
                          'Arbeitsweise sichern ✨',
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