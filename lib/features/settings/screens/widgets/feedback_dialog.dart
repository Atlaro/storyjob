// lib/features/settings/screens/widgets/feedback_dialog.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.mediumImpact();
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => const FeedbackDialog(),
    );
  }

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _feedbackController = TextEditingController();
  int _selectedTypeIndex = 0;
  bool _isSending = false;

  final List<String> _types = const [
    '💡 Feature-Wunsch',
    '✨ Werte-Resonanz',
    '🛠️ Fehler melden',
    '💬 Lob & Eindruck',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    HapticFeedback.lightImpact();

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('app_feedback').add({
        'userId': user?.uid ?? 'anonymous',
        'email': user?.email ?? 'unbekannt',
        'type': _types[_selectedTypeIndex],
        'message': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.cyanAccent, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Danke für deinen Impuls auf Augenhöhe ✨',
                  style: TextStyle(
                    color: StoryJobTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: StoryJobTheme.cardBorder),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Senden: $e'),
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dialog-Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: StoryJobTheme.cyanAccent.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.forum_rounded,
                          color: StoryJobTheme.cyanAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gestalte StoryJob mit',
                              style: TextStyle(
                                color: StoryJobTheme.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Dein ehrlicher Impuls auf Augenhöhe.',
                              style: TextStyle(
                                color: StoryJobTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close_rounded, color: StoryJobTheme.textMuted, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Pill-Kategorieauswahl
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _types.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedTypeIndex == index;
                        return ChoiceChip(
                          label: Text(_types[index]),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedTypeIndex = index);
                            }
                          },
                          selectedColor: StoryJobTheme.primaryViolet,
                          backgroundColor: StoryJobTheme.cardSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected
                                  ? StoryJobTheme.primaryViolet
                                  : StoryJobTheme.cardBorder,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : StoryJobTheme.textSecondary,
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          showCheckmark: false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Eingabefeld Slate-Surface
                  Container(
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cardSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: StoryJobTheme.cardBorder),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: TextField(
                      controller: _feedbackController,
                      maxLines: 4,
                      style: const TextStyle(
                        color: StoryJobTheme.textPrimary,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Was begeistert dich? Was können wir noch verbessern?',
                        hintStyle: TextStyle(
                          color: StoryJobTheme.textMuted,
                          fontSize: 12.5,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Aktionen (Pill-Buttons)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: StoryJobTheme.textSecondary,
                            side: const BorderSide(color: StoryJobTheme.cardBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          child: const Text(
                            'Abbrechen',
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSending ? null : _submitFeedback,
                          icon: _isSending
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send_rounded, size: 15),
                          label: Text(
                            _isSending ? 'Senden...' : 'Absenden ✨',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StoryJobTheme.primaryViolet,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}