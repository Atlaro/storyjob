// lib/features/messages/screens/story_dialog_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:storyjob/core/services/app_services.dart';
import 'package:storyjob/core/services/audio_service.dart';
import 'package:storyjob/core/services/resonance_analytics_service.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/features/messages/models/message_model.dart';
import 'package:storyjob/features/messages/widgets/appointment_request_widget.dart';
import 'package:storyjob/features/match/services/resonance_intelligence_service.dart';

class StoryDialogScreen extends StatefulWidget {
  final String chatId;
  final String? targetName;
  final String? partnerName;
  final String? companyName;
  final String roleContext;
  final String? roleTitle;
  final String matchScore;
  final String? initialResonanceTopic;
  final bool startWithVoice;
  final bool isProfileUnlocked; // Zwei-Stufen-Sichtbarkeitsstatus

  const StoryDialogScreen({
    super.key,
    required this.chatId,
    this.targetName,
    this.partnerName,
    this.companyName,
    this.roleContext = '',
    this.roleTitle,
    this.matchScore = '94% Team-Fit ✨',
    this.initialResonanceTopic,
    this.startWithVoice = false,
    this.isProfileUnlocked = true,
  });

  String get effectiveName => targetName ?? partnerName ?? companyName ?? 'Partner';
  String get effectiveRole => roleTitle ?? (roleContext.isNotEmpty ? roleContext : 'Chance auf Augenhöhe');

  @override
  State<StoryDialogScreen> createState() => _StoryDialogScreenState();
}

class _StoryDialogScreenState extends State<StoryDialogScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ResonanceAnalyticsService _analytics = ResonanceAnalyticsService();
  final ResonanceIntelligenceService _resonanceService = ResonanceIntelligenceService();

  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  String? _currentlyPlayingAudioUrl;

  DateTime? _screenEnterTime;

  @override
  void initState() {
    super.initState();
    _screenEnterTime = DateTime.now();

    _analytics.track(
      eventType: 'dialog_viewed',
      targetId: widget.chatId,
      targetRole: 'dialog_partner',
      screen: 'story_dialog',
      details: {
        'partnerName': widget.effectiveName,
        'roleContext': widget.effectiveRole,
        'matchScore': widget.matchScore,
        'initialTopic': widget.initialResonanceTopic,
        'isUnlocked': widget.isProfileUnlocked,
      },
    );

    if (widget.startWithVoice) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _toggleVoiceRecording();
      });
    }
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    AudioService.stopAudio();
    super.dispose();
  }

  // ==========================================================================
  // SEND & AUDIO LOGIC MIT SIGNAL-TRACKING
  // ==========================================================================

  Future<void> _sendTextMessage([String? presetText]) async {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    if (presetText == null) {
      _textController.clear();
    }
    HapticFeedback.lightImpact();

    final isAppointmentResponse = text.startsWith('✅') || text.startsWith('Passt mir leider nicht');
    final latencySec = _screenEnterTime != null
        ? DateTime.now().difference(_screenEnterTime!).inSeconds
        : 0;

    _analytics.track(
      eventType: isAppointmentResponse ? 'appointment_action_logged' : 'dialog_message_sent',
      targetId: widget.chatId,
      targetRole: 'dialog_partner',
      screen: 'story_dialog',
      details: {
        'type': 'text',
        'characterLength': text.length,
        'latencySec': latencySec,
        'isAppointmentAction': isAppointmentResponse,
        'actionText': text,
        'matchScore': widget.matchScore,
      },
    );

    try {
      await AppServices.sendMessage(
        widget.chatId,
        text,
        type: 'text',
      );
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Senden: $e'),
          backgroundColor: StoryJobTheme.cardSurfaceElevated,
        ),
      );
    }
  }

  Future<void> _toggleVoiceRecording() async {
    HapticFeedback.mediumImpact();

    if (_isRecording) {
      _recordTimer?.cancel();
      final recordedSec = _recordSeconds;
      setState(() {
        _isRecording = false;
        _recordSeconds = 0;
      });

      try {
        final path = await AppServices.stopRecording();
        if (path != null) {
          final durationLabel = '${recordedSec ~/ 60}:${(recordedSec % 60).toString().padLeft(2, '0')}';

          _analytics.track(
            eventType: 'dialog_voice_exchanged',
            targetId: widget.chatId,
            targetRole: 'dialog_partner',
            screen: 'story_dialog',
            details: {
              'audioDurationSec': recordedSec,
              'matchScore': widget.matchScore,
            },
          );

          await _resonanceService.recordVoiceInteraction(
            targetId: widget.chatId,
            listenedSeconds: recordedSec,
          );

          await AppServices.sendMessage(
            widget.chatId,
            '🎤 Sprachnachricht ($durationLabel Min.)',
            type: 'audio',
            audioUrl: path,
          );
          _scrollToBottom();
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aufnahme abgeschlossen: $e'),
            backgroundColor: StoryJobTheme.cardSurfaceElevated,
          ),
        );
      }
    } else {
      try {
        await AppServices.startRecording();
        setState(() {
          _isRecording = true;
          _recordSeconds = 0;
        });

        _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) return;
          setState(() {
            _recordSeconds++;
          });
          if (_recordSeconds >= 60) {
            _toggleVoiceRecording();
          }
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mikrofonfehler: $e'),
            backgroundColor: StoryJobTheme.cardSurfaceElevated,
          ),
        );
      }
    }
  }

  Future<void> _playAudio(String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) return;

    HapticFeedback.selectionClick();

    if (_currentlyPlayingAudioUrl == audioUrl) {
      await AudioService.stopAudio();
      setState(() => _currentlyPlayingAudioUrl = null);
    } else {
      await AudioService.playAudio(audioUrl);
      setState(() => _currentlyPlayingAudioUrl = audioUrl);

      _analytics.track(
        eventType: 'dialog_voice_played',
        targetId: widget.chatId,
        targetRole: 'dialog_partner',
        screen: 'story_dialog',
        details: {'audioUrl': audioUrl},
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ==========================================================================
  // UI BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(context),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: AppServices.getChatMessages(widget.chatId),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  final messages = docs.map((d) => MessageModel.fromFirestore(d)).toList();

                  return ListView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    children: [
                      _buildSystemSparkCard(),
                      const SizedBox(height: 14),
                      ...messages.map((message) {
                        final isMe = message.isMine(currentUserId);
                        return _buildMessageBubble(message, isMe);
                      }),
                    ],
                  );
                },
              ),
            ),

            AppointmentRequestWidget(
              chatId: widget.chatId,
              currentUserId: currentUserId,
              partnerName: widget.effectiveName,
            ),

            _buildBottomInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: StoryJobTheme.textSecondary,
                  size: 18,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 10),

              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: StoryJobTheme.dnaCardBorder,
                      border: Border.all(
                        color: StoryJobTheme.cyanAccent.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: widget.isProfileUnlocked
                          ? Text(
                              widget.effectiveName.isNotEmpty ? widget.effectiveName[0].toUpperCase() : 'S',
                              style: const TextStyle(
                                color: StoryJobTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            )
                          : const Icon(
                              Icons.shield_rounded,
                              color: StoryJobTheme.cyanAccent,
                              size: 20,
                            ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: StoryJobTheme.mintSuccess,
                        shape: BoxShape.circle,
                        border: Border.all(color: StoryJobTheme.cardSurfaceElevated, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.effectiveName,
                            style: const TextStyle(
                              color: StoryJobTheme.textPrimary,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.isProfileUnlocked
                                ? StoryJobTheme.mintSuccess.withValues(alpha: 0.15)
                                : StoryJobTheme.cyanAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: widget.isProfileUnlocked
                                  ? StoryJobTheme.mintSuccess.withValues(alpha: 0.4)
                                  : StoryJobTheme.cyanAccent.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            widget.isProfileUnlocked ? 'Freigegeben' : 'Anonym',
                            style: TextStyle(
                              color: widget.isProfileUnlocked
                                  ? StoryJobTheme.mintSuccess
                                  : StoryJobTheme.cyanAccent,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.effectiveRole,
                      style: const TextStyle(
                        color: StoryJobTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: StoryJobTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Live-Stream der Beziehungs- und Matching-Ebene
          StreamBuilder<ResonancePairData?>(
            stream: _resonanceService.streamPairData(widget.chatId),
            builder: (context, snapshot) {
              final pair = snapshot.data;
              final displayScore = pair != null ? '${pair.relationshipStrength}%' : widget.matchScore;
              final stageLabel = pair?.stageLabel ?? 'Im Dialog auf Augenhöhe';

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.cyanAccent, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      displayScore,
                      style: const TextStyle(
                        color: StoryJobTheme.cyanAccent,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: StoryJobTheme.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stageLabel,
                        style: const TextStyle(
                          color: StoryJobTheme.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSparkCard() {
    final topic = widget.initialResonanceTopic ?? 'Gemeinsame Werte & Miteinander';

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      borderGradient: StoryJobTheme.dnaCardBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.primaryViolet, size: 15),
              SizedBox(width: 6),
              Text(
                'StoryJob DNA Match-Impuls',
                style: TextStyle(
                  color: StoryJobTheme.primaryViolet,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Eure Profile zeigen hohe Schnittmengen bei „$topic“. Kein formelles Anschreiben nötig – startet euer Kennenlernen direkt auf Augenhöhe.',
            style: const TextStyle(
              color: StoryJobTheme.textPrimary,
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    if (message.text.startsWith('📅 Terminvorschlag:')) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82,
          ),
          decoration: BoxDecoration(
            color: StoryJobTheme.cardSurfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: StoryJobTheme.cyanAccent.withValues(alpha: 0.40),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.event_available_rounded, color: StoryJobTheme.cyanAccent, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Kennenlern-Termin',
                    style: TextStyle(
                      color: StoryJobTheme.cyanAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                message.text.replaceFirst('📅 Terminvorschlag:', '').trim(),
                style: const TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
              if (!isMe) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StoryJobTheme.cyanAccent.withValues(alpha: 0.18),
                          foregroundColor: StoryJobTheme.cyanAccent,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: StoryJobTheme.cyanAccent.withValues(alpha: 0.45)),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => _sendTextMessage('✅ Passt perfekt! Ich freue mich auf das Kennenlernen.'),
                        child: const Text('Annehmen', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: StoryJobTheme.textSecondary,
                          side: const BorderSide(color: StoryJobTheme.cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _sendTextMessage('Passt mir leider nicht ganz. Können wir einen Alternativtermin finden?'),
                        child: const Text('Verschieben', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? StoryJobTheme.primaryViolet.withValues(alpha: 0.28)
              : StoryJobTheme.cardSurfaceElevated,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          border: Border.all(
            color: isMe
                ? StoryJobTheme.primaryViolet.withValues(alpha: 0.50)
                : StoryJobTheme.cardBorder,
            width: 1,
          ),
        ),
        child: message.isAudio
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _playAudio(message.audioUrl),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: StoryJobTheme.cyanAccent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _currentlyPlayingAudioUrl == message.audioUrl
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: StoryJobTheme.cyanAccent,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Audio-Wellenform
                  ShaderMask(
                    shaderCallback: (bounds) => StoryJobTheme.soundWaveGradient.createShader(bounds),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(12, (index) {
                        final heights = [6, 12, 18, 10, 22, 14, 8, 16, 20, 12, 14, 8];
                        return Container(
                          width: 2.5,
                          height: heights[index % heights.length].toDouble(),
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    message.text.isNotEmpty ? message.text : 'Voice',
                    style: const TextStyle(
                      color: StoryJobTheme.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                message.text,
                style: const TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 13.5,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                ),
              ),
      ),
    );
  }

  Widget _buildBottomInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: StoryJobTheme.backgroundBase,
        border: Border(top: BorderSide(color: StoryJobTheme.cardBorder)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleVoiceRecording,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording
                    ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                    : StoryJobTheme.cardSurfaceElevated,
                border: Border.all(
                  color: _isRecording
                      ? const Color(0xFFEF4444)
                      : StoryJobTheme.cyanAccent.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(
                _isRecording ? Icons.stop_rounded : Icons.mic_none_rounded,
                color: _isRecording ? const Color(0xFFEF4444) : StoryJobTheme.cyanAccent,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isRecording
                      ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                      : StoryJobTheme.cardBorder,
                ),
              ),
              child: _isRecording
                  ? Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Sprachnachricht aufnehmen...',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_recordSeconds ~/ 60}:${(_recordSeconds % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(
                              color: StoryJobTheme.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Nachricht schreiben...',
                              hintStyle: TextStyle(
                                color: StoryJobTheme.textMuted,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onSubmitted: (_) => _sendTextMessage(),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.arrow_upward_rounded, color: StoryJobTheme.cyanAccent, size: 20),
                          onPressed: () => _sendTextMessage(),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}