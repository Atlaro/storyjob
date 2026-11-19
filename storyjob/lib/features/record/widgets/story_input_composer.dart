// lib/features/record/widgets/story_input_composer.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/services/stt_service.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/identity/services/story_ai_processor.dart';

class StoryInputComposer extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isTeamMode;
  final int maxLines;
  final ValueChanged<StoryExtractionResult>? onExtractionComplete;
  final ValueChanged<bool>? onListeningChanged;

  const StoryInputComposer({
    super.key,
    required this.controller,
    this.hintText = 'Schreibe deine Gedanken oder sprich sie einfach ein...',
    this.isTeamMode = false,
    this.maxLines = 4,
    this.onExtractionComplete,
    this.onListeningChanged,
  });

  @override
  State<StoryInputComposer> createState() => _StoryInputComposerState();
}

class _StoryInputComposerState extends State<StoryInputComposer> {
  final FreeSttService _sttService = FreeSttService();
  bool _isListening = false;
  bool _isProcessingAi = false;
  String _textBeforeDictation = '';

  @override
  void dispose() {
    if (_isListening) {
      _sttService.stopListening();
    }
    super.dispose();
  }

  Future<void> _toggleListening() async {
    HapticFeedback.mediumImpact();

    if (_isListening) {
      await _sttService.stopListening();
      if (mounted) {
        setState(() => _isListening = false);
      }
      widget.onListeningChanged?.call(false);
      return;
    }

    _textBeforeDictation = widget.controller.text.trim();

    await _sttService.startListening(
      onResult: (recognizedWords) {
        if (!mounted) return;
        final combined = _textBeforeDictation.isEmpty
            ? recognizedWords
            : '$_textBeforeDictation $recognizedWords';
        widget.controller.value = TextEditingValue(
          text: combined,
          selection: TextSelection.collapsed(offset: combined.length),
        );
      },
      onListeningStateChanged: (listening) {
        if (!mounted) return;
        setState(() => _isListening = listening);
        widget.onListeningChanged?.call(listening);
      },
    );

    if (mounted && !_sttService.isAvailable) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Mikrofon oder Spracherkennung konnte nicht gestartet werden.',
            style: TextStyle(color: StoryJobTheme.textPrimary, fontSize: 12.5),
          ),
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: StoryJobTheme.cardBorder),
          ),
        ),
      );
    }
  }

  Future<void> _enhanceStoryText() async {
    final rawText = widget.controller.text.trim();
    if (rawText.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Bitte zuerst einen kurzen Gedanken eintippen oder einsprechen.',
            style: TextStyle(color: StoryJobTheme.textPrimary, fontSize: 12.5),
          ),
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: StoryJobTheme.cardBorder),
          ),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isProcessingAi = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';
      final result = await StoryAiProcessor.processAndTagProfile(
        userId: uid,
        transcriptText: rawText,
      );

      final polished = _polishSentence(rawText);
      widget.controller.value = TextEditingValue(
        text: polished,
        selection: TextSelection.collapsed(offset: polished.length),
      );

      widget.onExtractionComplete?.call(result);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Story aufbereitet und in deinem Profil ergänzt ✨',
            style: TextStyle(
              color: StoryJobTheme.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: StoryJobTheme.cardBorder),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessingAi = false);
    }
  }

  String _polishSentence(String input) {
    final cleaned = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return cleaned;
    final capitalized = cleaned[0].toUpperCase() + cleaned.substring(1);
    final endsWithPunctuation =
        capitalized.endsWith('.') ||
        capitalized.endsWith('!') ||
        capitalized.endsWith('?');
    return endsWithPunctuation ? capitalized : '$capitalized.';
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.isTeamMode
        ? StoryJobTheme.primaryViolet
        : StoryJobTheme.cyanAccent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isListening ? accentColor : StoryJobTheme.cardBorder,
          width: _isListening ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (_isListening)
            BoxShadow(
              color: accentColor.withValues(alpha: 0.22),
              blurRadius: 16,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.controller,
            maxLines: widget.maxLines,
            style: const TextStyle(
              color: StoryJobTheme.textPrimary,
              fontSize: 14,
              height: 1.45,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                color: StoryJobTheme.textMuted,
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: StoryJobTheme.cardBorder),
          const SizedBox(height: 10),
          Row(
            children: [
              InkWell(
                onTap: _toggleListening,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _isListening
                        ? accentColor.withValues(alpha: 0.18)
                        : StoryJobTheme.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isListening
                          ? accentColor
                          : StoryJobTheme.cardBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isListening
                            ? Icons.mic_rounded
                            : Icons.mic_none_rounded,
                        color: _isListening
                            ? accentColor
                            : StoryJobTheme.textSecondary,
                        size: 17,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isListening ? 'Höre zu...' : 'Einsprechen',
                        style: TextStyle(
                          color: _isListening
                              ? accentColor
                              : StoryJobTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _isProcessingAi ? null : _enhanceStoryText,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: StoryJobTheme.primaryViolet.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: StoryJobTheme.primaryViolet.withValues(alpha: 0.42),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isProcessingAi)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: StoryJobTheme.champagneGold,
                          ),
                        )
                      else
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: StoryJobTheme.champagneGold,
                          size: 15,
                        ),
                      const SizedBox(width: 6),
                      Text(
                        _isProcessingAi
                            ? 'Wird geformt...'
                            : 'KI formen lassen ✨',
                        style: const TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}