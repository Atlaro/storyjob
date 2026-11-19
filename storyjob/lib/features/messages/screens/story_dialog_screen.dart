// lib/features/messages/screens/story_dialog_screen.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/services/app_services.dart';
import 'package:storyjob/core/services/audio_service.dart';
import 'package:storyjob/core/services/match_analytics_service.dart';
import 'package:storyjob/core/services/story_symbiosis_service.dart';
import 'package:storyjob/core/services/story_symbiosis_telemetry.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/features/match/services/match_intelligence_service.dart';
import 'package:storyjob/features/messages/models/message_model.dart';
import 'package:storyjob/features/messages/widgets/appointment_request_widget.dart';

class StoryDialogScreen extends StatefulWidget {
  final String chatId;
  final String? recipientId;
  final String? targetName;
  final String? partnerName;
  final String? teamName;
  final String roleContext;
  final String? roleTitle;
  final String matchScore;
  final String? initialResonanceTopic;
  final List<String> sharedValues;
  final bool startWithVoice;
  final bool isProfileUnlocked;

  const StoryDialogScreen({
    super.key,
    required this.chatId,
    this.recipientId,
    this.targetName,
    this.partnerName,
    this.teamName,
    this.roleContext = '',
    this.roleTitle,
    this.matchScore = 'Dialog auf Augenhöhe ✨',
    this.initialResonanceTopic,
    this.sharedValues = const [],
    this.startWithVoice = false,
    this.isProfileUnlocked = true,
  });

  String get effectiveName =>
      targetName ?? partnerName ?? teamName ?? 'Partner';

  String get effectiveRole => roleTitle ??
      (roleContext.isNotEmpty ? roleContext : 'Begegnung auf Augenhöhe');

  @override
  State<StoryDialogScreen> createState() => _StoryDialogScreenState();
}

class _StoryDialogScreenState extends State<StoryDialogScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MatchAnalyticsService _analytics = MatchAnalyticsService();
  final MatchIntelligenceService _resonanceService = MatchIntelligenceService();

  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;

  String? _currentlyPlayingAudioUrl;
  double _playbackProgress = 0.0;
  String? _activePromptAnchor;
  DateTime? _screenEnterTime;

  static const LinearGradient _audioAuraGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF8A4C),
      Color(0xFFEC4899),
      Color(0xFF8B5CF6),
      Color(0xFF22D3EE),
    ],
  );

  static const LinearGradient _outgoingBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6366F1),
      Color(0xFF22D3EE),
    ],
  );

  static const List<String> _conversationStarters = [
    'Wie sieht euer Alltag im Team wirklich aus?',
    'Kurz per Stimme: Was treibt dich gerade an?',
    'Worauf legen wir im Miteinander den größten Wert?',
    'Lust auf ein lockeres Kennenlernen per Stimme?',
  ];

  @override
  void initState() {
    super.initState();
    _screenEnterTime = DateTime.now();
    _activePromptAnchor = widget.initialResonanceTopic;

    _analytics.track(
      eventType: 'dialog_viewed',
      targetId: widget.chatId,
      targetRole: 'dialog_partner',
      screen: 'story_dialog',
      details: {
        'partnerName': widget.effectiveName,
        'roleContext': widget.effectiveRole,
        'initialTopic': widget.initialResonanceTopic,
        'isUnlocked': widget.isProfileUnlocked,
      },
    );

    StorySymbiosisTelemetry.recordEcosystemEvent(
      eventName: 'story_dialog_opened',
      roleContext: 'dialog',
      targetId: widget.recipientId ?? widget.chatId,
      category: widget.effectiveRole,
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

  List<String> get _resolvedValues {
    if (widget.sharedValues.isNotEmpty) {
      return widget.sharedValues.take(3).toList();
    }
    if (widget.initialResonanceTopic != null &&
        widget.initialResonanceTopic!.trim().isNotEmpty) {
      return [widget.initialResonanceTopic!.trim()];
    }
    return const ['Augenhöhe', 'Eigenverantwortung', 'Praxis'];
  }

  void _selectConversationStarter(String starter) {
    HapticFeedback.selectionClick();
    setState(() {
      _activePromptAnchor = starter;
      if (_textController.text.trim().isEmpty) {
        _textController.text = '$starter ';
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
      }
    });
  }

  // ==========================================================================
  // SEND & AUDIO LOGIC
  // ==========================================================================

  Future<void> _sendTextMessage([String? presetText]) async {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    if (presetText == null) {
      _textController.clear();
    }
    HapticFeedback.lightImpact();

    final isAppointmentResponse =
        text.startsWith('✅') || text.startsWith('Passt mir leider nicht');
    final latencySec = _screenEnterTime != null
        ? DateTime.now().difference(_screenEnterTime!).inSeconds
        : 0;

    _analytics.track(
      eventType: isAppointmentResponse
          ? 'appointment_action_logged'
          : 'dialog_message_sent',
      targetId: widget.chatId,
      targetRole: 'dialog_partner',
      screen: 'story_dialog',
      details: {
        'type': 'text',
        'characterLength': text.length,
        'latencySec': latencySec,
        'isAppointmentAction': isAppointmentResponse,
        'actionText': text,
        'anchorTopic': _activePromptAnchor,
      },
    );

    try {
      await AppServices.sendMessage(
        widget.chatId,
        text,
        type: 'text',
      );

      await StorySymbiosisTelemetry.recordEcosystemEvent(
        eventName: isAppointmentResponse
            ? 'dialog_appointment_response'
            : 'dialog_text_message_sent',
        roleContext: 'dialog',
        targetId: widget.recipientId ?? widget.chatId,
        category: widget.effectiveRole,
      );

      if (mounted && presetText == null) {
        setState(() => _activePromptAnchor = null);
      }
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
      final anchorSnapshot = _activePromptAnchor;
      setState(() {
        _isRecording = false;
        _recordSeconds = 0;
      });

      try {
        final path = await AppServices.stopRecording();
        if (path != null) {
          final durationLabel =
              '${recordedSec ~/ 60}:${(recordedSec % 60).toString().padLeft(2, '0')}';
          final anchorSuffix =
              (anchorSnapshot != null && anchorSnapshot.trim().isNotEmpty)
                  ? ' • ${anchorSnapshot.trim()}'
                  : '';

          _analytics.track(
            eventType: 'dialog_voice_exchanged',
            targetId: widget.chatId,
            targetRole: 'dialog_partner',
            screen: 'story_dialog',
            details: {
              'audioDurationSec': recordedSec,
              'anchorTopic': anchorSnapshot,
            },
          );

          await _resonanceService.recordVoiceInteraction(
            targetId: widget.chatId,
            listenedSeconds: recordedSec,
          );

          await AppServices.sendMessage(
            widget.chatId,
            '🎤 Sprachnachricht ($durationLabel Min.$anchorSuffix)',
            type: 'audio',
            audioUrl: path,
          );

          await StorySymbiosisTelemetry.recordEcosystemEvent(
            eventName: 'dialog_voice_message_sent',
            roleContext: 'dialog',
            targetId: widget.recipientId ?? widget.chatId,
            category: widget.effectiveRole,
          );

          if (mounted) {
            setState(() => _activePromptAnchor = null);
          }
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

  Future<void> _playAudio(String? audioUrl, {double? seekRatio}) async {
    if (audioUrl == null || audioUrl.isEmpty) return;

    HapticFeedback.selectionClick();

    if (seekRatio != null) {
      setState(() {
        _currentlyPlayingAudioUrl = audioUrl;
        _playbackProgress = seekRatio.clamp(0.0, 1.0);
      });
      await AudioService.playAudio(audioUrl);
      return;
    }

    if (_currentlyPlayingAudioUrl == audioUrl) {
      await AudioService.stopAudio();
      setState(() {
        _currentlyPlayingAudioUrl = null;
        _playbackProgress = 0.0;
      });
    } else {
      await AudioService.playAudio(audioUrl);
      setState(() {
        _currentlyPlayingAudioUrl = audioUrl;
        _playbackProgress = _playbackProgress > 0.0 ? _playbackProgress : 0.25;
      });

      _analytics.track(
        eventType: 'dialog_voice_played',
        targetId: widget.chatId,
        targetRole: 'dialog_partner',
        screen: 'story_dialog',
        details: {'audioUrl': audioUrl},
      );
    }
  }

  Future<void> _sendQuickImpulseToPartner() async {
    final recipient = widget.recipientId?.trim() ?? '';
    if (recipient.isEmpty) return;

    HapticFeedback.lightImpact();
    await StorySymbiosisService.sendStoryImpulse(
      recipientId: recipient,
      targetName: widget.effectiveName,
      storyTitle: widget.effectiveRole,
      matchScore: 'Dialog-Impuls ✨',
      type: 'dialog_spark',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Impuls an ${widget.effectiveName} gesendet ✨',
          style: const TextStyle(fontSize: 12.5),
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
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
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: Stack(
        children: [
          Positioned(
            top: -90,
            left: -70,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: StoryJobTheme.primaryViolet.withValues(alpha: 0.14),
              ),
            ),
          ),
          Positioned(
            bottom: 70,
            right: -80,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: StoryJobTheme.cyanAccent.withValues(alpha: 0.10),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildCustomHeader(context),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: AppServices.getChatMessages(widget.chatId),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ?? [];
                      final messages = docs
                          .map((d) => MessageModel.fromFirestore(d))
                          .toList();

                      return ListView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                        children: [
                          _buildSystemSparkCard(),
                          const SizedBox(height: 16),
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
                if (!_isRecording) _buildConversationStarterStrip(),
                _buildBottomInputBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    final values = _resolvedValues;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: StoryJobTheme.cyanAccent.withValues(alpha: 0.32),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Semantics(
                label: 'Zurück',
                button: true,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: StoryJobTheme.textSecondary,
                    size: 18,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 10),
              _buildPartnerAvatar(size: 44),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isProfileUnlocked
                                ? StoryJobTheme.mintSuccess
                                    .withValues(alpha: 0.15)
                                : StoryJobTheme.cyanAccent
                                    .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: widget.isProfileUnlocked
                                  ? StoryJobTheme.mintSuccess
                                      .withValues(alpha: 0.4)
                                  : StoryJobTheme.cyanAccent
                                      .withValues(alpha: 0.4),
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
              Semantics(
                label: 'Impuls senden',
                button: true,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.bolt_rounded,
                    color: StoryJobTheme.cyanAccent,
                    size: 21,
                  ),
                  onPressed: _sendQuickImpulseToPartner,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<dynamic>(
            stream: _resonanceService.streamPairData(widget.chatId),
            builder: (context, snapshot) {
              final pair = snapshot.data;
              final stageLabel =
                  pair?.stageLabel ?? 'Im Dialog auf Augenhöhe';
              final badgeText = widget.matchScore.contains('%')
                  ? 'StoryJob™ Symbiose'
                  : widget.matchScore;

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: StoryJobTheme.cyanAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      badgeText,
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
          if (values.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: values.map((val) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: StoryJobTheme.primaryViolet.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: StoryJobTheme.primaryViolet.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    val,
                    style: const TextStyle(
                      color: StoryJobTheme.textPrimary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPartnerAvatar({double size = 34, bool showOnlineDot = true}) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF8A4C),
                Color(0xFFEC4899),
                Color(0xFF8B5CF6),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Center(
            child: widget.isProfileUnlocked
                ? Text(
                    widget.effectiveName.isNotEmpty
                        ? widget.effectiveName[0].toUpperCase()
                        : 'S',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: size * 0.40,
                    ),
                  )
                : Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: size * 0.48,
                  ),
          ),
        ),
        if (showOnlineDot)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: StoryJobTheme.mintSuccess,
                shape: BoxShape.circle,
                border: Border.all(
                  color: StoryJobTheme.cardSurfaceElevated,
                  width: 1.8,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSystemSparkCard() {
    final topic =
        widget.initialResonanceTopic ?? 'Gemeinsame Werte & Miteinander';

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(15),
      borderGradient: StoryJobTheme.dnaCardBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.graphic_eq_rounded,
                color: StoryJobTheme.cyanAccent,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'StoryJob™ Begegnungs-Impuls',
                style: TextStyle(
                  color: StoryJobTheme.cyanAccent,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Verbindender Anker: „$topic“. Sprecht gerne kurz per Stimme ein, was euch wirklich bewegt – echt, offen und ohne Lebenslauf-Floskeln.',
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

  Widget _buildConversationStarterStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_activePromptAnchor != null &&
            _activePromptAnchor!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: [
                const Icon(
                  Icons.mic_external_on_rounded,
                  size: 13,
                  color: StoryJobTheme.cyanAccent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Aktiver Gesprächs-Anker: ${_activePromptAnchor!}',
                    style: const TextStyle(
                      color: StoryJobTheme.cyanAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _activePromptAnchor = null),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: StoryJobTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _conversationStarters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final starter = _conversationStarters[index];
              final isSelected = _activePromptAnchor == starter;
              return GestureDetector(
                onTap: () => _selectConversationStarter(starter),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? StoryJobTheme.primaryViolet.withValues(alpha: 0.24)
                        : StoryJobTheme.cardSurfaceElevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? StoryJobTheme.cyanAccent.withValues(alpha: 0.65)
                          : StoryJobTheme.cardBorder,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      starter,
                      style: TextStyle(
                        color: isSelected
                            ? StoryJobTheme.textPrimary
                            : StoryJobTheme.textSecondary,
                        fontSize: 11.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    // 1. Terminvorschlag-Karte
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
                color: Colors.black.withValues(alpha: 0.22),
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
                  Icon(
                    Icons.event_available_rounded,
                    color: StoryJobTheme.cyanAccent,
                    size: 16,
                  ),
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
                          backgroundColor:
                              StoryJobTheme.cyanAccent.withValues(alpha: 0.18),
                          foregroundColor: StoryJobTheme.cyanAccent,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: StoryJobTheme.cyanAccent
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => _sendTextMessage(
                          '✅ Passt perfekt! Ich freue mich auf das Kennenlernen.',
                        ),
                        child: const Text(
                          'Annehmen',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: StoryJobTheme.textSecondary,
                          side:
                              const BorderSide(color: StoryJobTheme.cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _sendTextMessage(
                          'Passt mir leider nicht ganz. Können wir einen Alternativtermin finden?',
                        ),
                        child: const Text(
                          'Verschieben',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

    // 2. Interaktive Audio-Hero-Card
    if (message.isAudio) {
      final isPlaying = _currentlyPlayingAudioUrl == message.audioUrl;
      final parts = message.text.split('•');
      final durationMeta = parts.first
          .replaceAll('🎤 Sprachnachricht', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .trim();
      final topicTag = parts.length > 1 ? parts.sublist(1).join('•').trim() : '';

      const waveHeights = [
        8, 14, 22, 12, 26, 16, 10, 18, 24, 14, 28,
        18, 12, 20, 26, 14, 22, 16, 10, 18, 12, 8,
      ];

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              _buildPartnerAvatar(size: 32, showOnlineDot: false),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.80,
                ),
                padding: const EdgeInsets.all(1.35),
                decoration: BoxDecoration(
                  gradient: _audioAuraGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141829),
                    borderRadius: BorderRadius.circular(20.65),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (topicTag.isNotEmpty) ...[
                        Text(
                          '🎙️ $topicTag',
                          style: const TextStyle(
                            color: StoryJobTheme.cyanAccent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                      ],
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Semantics(
                            label: isPlaying
                                ? 'Sprachnachricht pausieren'
                                : 'Sprachnachricht abspielen',
                            button: true,
                            child: GestureDetector(
                              onTap: () => _playAudio(message.audioUrl),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFF8A4C),
                                      Color(0xFFEC4899),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFEC4899)
                                          .withValues(alpha: 0.40),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTapDown: (details) {
                                final box =
                                    context.findRenderObject() as RenderBox?;
                                final width = box?.size.width ?? 160;
                                final ratio =
                                    (details.localPosition.dx / width)
                                        .clamp(0.0, 1.0);
                                _playAudio(message.audioUrl, seekRatio: ratio);
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(waveHeights.length,
                                    (index) {
                                  final barRatio =
                                      index / waveHeights.length;
                                  final isReached =
                                      isPlaying && barRatio <= _playbackProgress;
                                  return Container(
                                    width: 2.5,
                                    height: waveHeights[index].toDouble(),
                                    decoration: BoxDecoration(
                                      color: isReached
                                          ? StoryJobTheme.cyanAccent
                                          : StoryJobTheme.primaryViolet
                                              .withValues(alpha: 0.65),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            durationMeta.isNotEmpty ? durationMeta : 'Voice',
                            style: const TextStyle(
                              color: StoryJobTheme.textSecondary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 3. Text-Nachrichten: Rechts (Eigene im Gradient) vs. Links (Partner mit Avatar)
    if (isMe) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.76,
          ),
          decoration: BoxDecoration(
            gradient: _outgoingBubbleGradient,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(6),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              height: 1.38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPartnerAvatar(size: 32, showOnlineDot: false),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(
                  color: StoryJobTheme.cardBorder,
                  width: 1,
                ),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 13.5,
                  height: 1.38,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: StoryJobTheme.backgroundBase.withValues(alpha: 0.96),
        border: const Border(
          top: BorderSide(color: StoryJobTheme.cardBorder),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isRecording
                      ? const Color(0xFFEF4444).withValues(alpha: 0.50)
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
                          'Sprachnachricht läuft...',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_recordSeconds ~/ 60}:${(_recordSeconds % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontWeight: FontWeight.w600,
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
                              hintText: 'Antwort schreiben oder einsprechen...',
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
                        Semantics(
                          label: 'Nachricht senden',
                          button: true,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.arrow_upward_rounded,
                              color: StoryJobTheme.cyanAccent,
                              size: 20,
                            ),
                            onPressed: () => _sendTextMessage(),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            label: _isRecording
                ? 'Sprachaufnahme stoppen'
                : 'Sprachaufnahme starten',
            button: true,
            child: GestureDetector(
              onTap: _toggleVoiceRecording,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _isRecording
                      ? const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        )
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF22D3EE),
                            Color(0xFF8B5CF6),
                            Color(0xFFEC4899),
                          ],
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF8B5CF6))
                          .withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}// lib/features/messages/screens/story_dialog_screen.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storyjob/core/services/app_services.dart';
import 'package:storyjob/core/services/audio_service.dart';
import 'package:storyjob/core/services/match_analytics_service.dart';
import 'package:storyjob/core/services/story_symbiosis_service.dart';
import 'package:storyjob/core/services/story_symbiosis_telemetry.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/core/widgets/story_waveform_widget.dart';
import 'package:storyjob/features/match/services/match_intelligence_service.dart';
import 'package:storyjob/features/messages/models/message_model.dart';
import 'package:storyjob/features/messages/widgets/appointment_request_widget.dart';

class StoryDialogScreen extends StatefulWidget {
  final String chatId;
  final String? recipientId;
  final String? targetName;
  final String? partnerName;
  final String? teamName;
  final String roleContext;
  final String? roleTitle;
  final String matchScore;
  final String? initialResonanceTopic;
  final List<String> sharedValues;
  final bool startWithVoice;
  final bool isProfileUnlocked;

  const StoryDialogScreen({
    super.key,
    required this.chatId,
    this.recipientId,
    this.targetName,
    this.partnerName,
    this.teamName,
    this.roleContext = '',
    this.roleTitle,
    this.matchScore = 'Dialog auf Augenhöhe ✨',
    this.initialResonanceTopic,
    this.sharedValues = const [],
    this.startWithVoice = false,
    this.isProfileUnlocked = true,
  });

  String get effectiveName =>
      targetName ?? partnerName ?? teamName ?? 'Partner';

  String get effectiveRole => roleTitle ??
      (roleContext.isNotEmpty ? roleContext : 'Begegnung auf Augenhöhe');

  @override
  State<StoryDialogScreen> createState() => _StoryDialogScreenState();
}

class _StoryDialogScreenState extends State<StoryDialogScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MatchAnalyticsService _analytics = MatchAnalyticsService();
  final MatchIntelligenceService _resonanceService = MatchIntelligenceService();

  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;

  String? _currentlyPlayingAudioUrl;
  double _playbackProgress = 0.0;
  String? _activePromptAnchor;
  DateTime? _screenEnterTime;

  static const LinearGradient _audioAuraGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF8A4C),
      Color(0xFFEC4899),
      Color(0xFF8B5CF6),
      Color(0xFF22D3EE),
    ],
  );

  static const LinearGradient _outgoingBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6366F1),
      Color(0xFF22D3EE),
    ],
  );

  static const List<String> _conversationStarters = [
    'Wie sieht euer Alltag im Team wirklich aus?',
    'Kurz per Stimme: Was treibt dich gerade an?',
    'Worauf legen wir im Miteinander den größten Wert?',
    'Lust auf ein lockeres Kennenlernen per Stimme?',
  ];

  @override
  void initState() {
    super.initState();
    _screenEnterTime = DateTime.now();
    _activePromptAnchor = widget.initialResonanceTopic;

    _analytics.track(
      eventType: 'dialog_viewed',
      targetId: widget.chatId,
      targetRole: 'dialog_partner',
      screen: 'story_dialog',
      details: {
        'partnerName': widget.effectiveName,
        'roleContext': widget.effectiveRole,
        'initialTopic': widget.initialResonanceTopic,
        'isUnlocked': widget.isProfileUnlocked,
      },
    );

    StorySymbiosisTelemetry.recordEcosystemEvent(
      eventName: 'story_dialog_opened',
      roleContext: 'dialog',
      targetId: widget.recipientId ?? widget.chatId,
      category: widget.effectiveRole,
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

  List<String> get _resolvedValues {
    if (widget.sharedValues.isNotEmpty) {
      return widget.sharedValues.take(3).toList();
    }
    if (widget.initialResonanceTopic != null &&
        widget.initialResonanceTopic!.trim().isNotEmpty) {
      return [widget.initialResonanceTopic!.trim()];
    }
    return const ['Augenhöhe', 'Eigenverantwortung', 'Praxis'];
  }

  void _selectConversationStarter(String starter) {
    HapticFeedback.selectionClick();
    setState(() {
      _activePromptAnchor = starter;
      if (_textController.text.trim().isEmpty) {
        _textController.text = '$starter ';
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
      }
    });
  }

  // ==========================================================================
  // SEND & AUDIO LOGIC
  // ==========================================================================

  Future<void> _sendTextMessage([String? presetText]) async {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    if (presetText == null) {
      _textController.clear();
    }
    HapticFeedback.lightImpact();

    final isAppointmentResponse =
        text.startsWith('✅') || text.startsWith('Passt mir leider nicht');
    final latencySec = _screenEnterTime != null
        ? DateTime.now().difference(_screenEnterTime!).inSeconds
        : 0;

    _analytics.track(
      eventType: isAppointmentResponse
          ? 'appointment_action_logged'
          : 'dialog_message_sent',
      targetId: widget.chatId,
      targetRole: 'dialog_partner',
      screen: 'story_dialog',
      details: {
        'type': 'text',
        'characterLength': text.length,
        'latencySec': latencySec,
        'isAppointmentAction': isAppointmentResponse,
        'actionText': text,
        'anchorTopic': _activePromptAnchor,
      },
    );

    try {
      await AppServices.sendMessage(
        widget.chatId,
        text,
        type: 'text',
      );

      await StorySymbiosisTelemetry.recordEcosystemEvent(
        eventName: isAppointmentResponse
            ? 'dialog_appointment_response'
            : 'dialog_text_message_sent',
        roleContext: 'dialog',
        targetId: widget.recipientId ?? widget.chatId,
        category: widget.effectiveRole,
      );

      if (mounted && presetText == null) {
        setState(() => _activePromptAnchor = null);
      }
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
      final anchorSnapshot = _activePromptAnchor;
      setState(() {
        _isRecording = false;
        _recordSeconds = 0;
      });

      try {
        final path = await AppServices.stopRecording();
        if (path != null) {
          final durationLabel =
              '${recordedSec ~/ 60}:${(recordedSec % 60).toString().padLeft(2, '0')}';
          final anchorSuffix =
              (anchorSnapshot != null && anchorSnapshot.trim().isNotEmpty)
                  ? ' • ${anchorSnapshot.trim()}'
                  : '';

          _analytics.track(
            eventType: 'dialog_voice_exchanged',
            targetId: widget.chatId,
            targetRole: 'dialog_partner',
            screen: 'story_dialog',
            details: {
              'audioDurationSec': recordedSec,
              'anchorTopic': anchorSnapshot,
            },
          );

          await _resonanceService.recordVoiceInteraction(
            targetId: widget.chatId,
            listenedSeconds: recordedSec,
          );

          await AppServices.sendMessage(
            widget.chatId,
            '🎤 Sprachnachricht ($durationLabel Min.$anchorSuffix)',
            type: 'audio',
            audioUrl: path,
          );

          await StorySymbiosisTelemetry.recordEcosystemEvent(
            eventName: 'dialog_voice_message_sent',
            roleContext: 'dialog',
            targetId: widget.recipientId ?? widget.chatId,
            category: widget.effectiveRole,
          );

          if (mounted) {
            setState(() => _activePromptAnchor = null);
          }
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

  Future<void> _playAudio(String? audioUrl, {double? seekRatio}) async {
    if (audioUrl == null || audioUrl.isEmpty) return;

    HapticFeedback.selectionClick();

    if (seekRatio != null) {
      setState(() {
        _currentlyPlayingAudioUrl = audioUrl;
        _playbackProgress = seekRatio.clamp(0.0, 1.0);
      });
      await AudioService.playAudio(audioUrl);
      return;
    }

    if (_currentlyPlayingAudioUrl == audioUrl) {
      await AudioService.stopAudio();
      setState(() {
        _currentlyPlayingAudioUrl = null;
        _playbackProgress = 0.0;
      });
    } else {
      await AudioService.playAudio(audioUrl);
      setState(() {
        _currentlyPlayingAudioUrl = audioUrl;
        _playbackProgress = _playbackProgress > 0.0 ? _playbackProgress : 0.25;
      });

      _analytics.track(
        eventType: 'dialog_voice_played',
        targetId: widget.chatId,
        targetRole: 'dialog_partner',
        screen: 'story_dialog',
        details: {'audioUrl': audioUrl},
      );
    }
  }

  Future<void> _sendQuickImpulseToPartner() async {
    final recipient = widget.recipientId?.trim() ?? '';
    if (recipient.isEmpty) return;

    HapticFeedback.lightImpact();
    await StorySymbiosisService.sendStoryImpulse(
      recipientId: recipient,
      targetName: widget.effectiveName,
      storyTitle: widget.effectiveRole,
      matchScore: 'Dialog-Impuls ✨',
      type: 'dialog_spark',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Impuls an ${widget.effectiveName} gesendet ✨',
          style: const TextStyle(fontSize: 12.5),
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
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
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: Stack(
        children: [
          Positioned(
            top: -90,
            left: -70,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: StoryJobTheme.primaryViolet.withValues(alpha: 0.14),
              ),
            ),
          ),
          Positioned(
            bottom: 70,
            right: -80,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: StoryJobTheme.cyanAccent.withValues(alpha: 0.10),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildCustomHeader(context),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: AppServices.getChatMessages(widget.chatId),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ?? [];
                      final messages = docs
                          .map((d) => MessageModel.fromFirestore(d))
                          .toList();

                      return ListView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                        children: [
                          _buildSystemSparkCard(),
                          const SizedBox(height: 16),
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
                if (!_isRecording) _buildConversationStarterStrip(),
                _buildBottomInputBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    final values = _resolvedValues;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: StoryJobTheme.cyanAccent.withValues(alpha: 0.32),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Semantics(
                label: 'Zurück',
                button: true,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: StoryJobTheme.textSecondary,
                    size: 18,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 10),
              _buildPartnerAvatar(size: 44),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isProfileUnlocked
                                ? StoryJobTheme.mintSuccess
                                    .withValues(alpha: 0.15)
                                : StoryJobTheme.cyanAccent
                                    .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: widget.isProfileUnlocked
                                  ? StoryJobTheme.mintSuccess
                                      .withValues(alpha: 0.4)
                                  : StoryJobTheme.cyanAccent
                                      .withValues(alpha: 0.4),
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
              Semantics(
                label: 'Impuls senden',
                button: true,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.bolt_rounded,
                    color: StoryJobTheme.cyanAccent,
                    size: 21,
                  ),
                  onPressed: _sendQuickImpulseToPartner,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<dynamic>(
            stream: _resonanceService.streamPairData(widget.chatId),
            builder: (context, snapshot) {
              final pair = snapshot.data;
              final stageLabel =
                  pair?.stageLabel ?? 'Im Dialog auf Augenhöhe';
              final badgeText = widget.matchScore.contains('%')
                  ? 'StoryJob™ Symbiose'
                  : widget.matchScore;

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: StoryJobTheme.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: StoryJobTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: StoryJobTheme.cyanAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      badgeText,
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
          if (values.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: values.map((val) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: StoryJobTheme.primaryViolet.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: StoryJobTheme.primaryViolet.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    val,
                    style: const TextStyle(
                      color: StoryJobTheme.textPrimary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPartnerAvatar({double size = 34, bool showOnlineDot = true}) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF8A4C),
                Color(0xFFEC4899),
                Color(0xFF8B5CF6),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Center(
            child: widget.isProfileUnlocked
                ? Text(
                    widget.effectiveName.isNotEmpty
                        ? widget.effectiveName[0].toUpperCase()
                        : 'S',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: size * 0.40,
                    ),
                  )
                : Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: size * 0.48,
                  ),
          ),
        ),
        if (showOnlineDot)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: StoryJobTheme.mintSuccess,
                shape: BoxShape.circle,
                border: Border.all(
                  color: StoryJobTheme.cardSurfaceElevated,
                  width: 1.8,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSystemSparkCard() {
    final topic =
        widget.initialResonanceTopic ?? 'Gemeinsame Werte & Miteinander';

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(15),
      borderGradient: StoryJobTheme.dnaCardBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.graphic_eq_rounded,
                color: StoryJobTheme.cyanAccent,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'StoryJob™ Begegnungs-Impuls',
                style: TextStyle(
                  color: StoryJobTheme.cyanAccent,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Verbindender Anker: „$topic“. Sprecht gerne kurz per Stimme ein, was euch wirklich bewegt – echt, offen und ohne Lebenslauf-Floskeln.',
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

  Widget _buildConversationStarterStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_activePromptAnchor != null &&
            _activePromptAnchor!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: [
                const Icon(
                  Icons.mic_external_on_rounded,
                  size: 13,
                  color: StoryJobTheme.cyanAccent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Aktiver Gesprächs-Anker: ${_activePromptAnchor!}',
                    style: const TextStyle(
                      color: StoryJobTheme.cyanAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _activePromptAnchor = null),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: StoryJobTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _conversationStarters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final starter = _conversationStarters[index];
              final isSelected = _activePromptAnchor == starter;
              return GestureDetector(
                onTap: () => _selectConversationStarter(starter),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? StoryJobTheme.primaryViolet.withValues(alpha: 0.24)
                        : StoryJobTheme.cardSurfaceElevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? StoryJobTheme.cyanAccent.withValues(alpha: 0.65)
                          : StoryJobTheme.cardBorder,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      starter,
                      style: TextStyle(
                        color: isSelected
                            ? StoryJobTheme.textPrimary
                            : StoryJobTheme.textSecondary,
                        fontSize: 11.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    // 1. Terminvorschlag-Karte
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
                color: Colors.black.withValues(alpha: 0.22),
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
                  Icon(
                    Icons.event_available_rounded,
                    color: StoryJobTheme.cyanAccent,
                    size: 16,
                  ),
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
                          backgroundColor:
                              StoryJobTheme.cyanAccent.withValues(alpha: 0.18),
                          foregroundColor: StoryJobTheme.cyanAccent,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: StoryJobTheme.cyanAccent
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => _sendTextMessage(
                          '✅ Passt perfekt! Ich freue mich auf das Kennenlernen.',
                        ),
                        child: const Text(
                          'Annehmen',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: StoryJobTheme.textSecondary,
                          side:
                              const BorderSide(color: StoryJobTheme.cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _sendTextMessage(
                          'Passt mir leider nicht ganz. Können wir einen Alternativtermin finden?',
                        ),
                        child: const Text(
                          'Verschieben',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

    // 2. Interaktive Audio-Hero-Card
    if (message.isAudio) {
      final isPlaying = _currentlyPlayingAudioUrl == message.audioUrl;
      final parts = message.text.split('•');
      final durationMeta = parts.first
          .replaceAll('🎤 Sprachnachricht', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .trim();
      final topicTag = parts.length > 1 ? parts.sublist(1).join('•').trim() : '';

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              _buildPartnerAvatar(size: 32, showOnlineDot: false),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.80,
                ),
                padding: const EdgeInsets.all(1.35),
                decoration: BoxDecoration(
                  gradient: _audioAuraGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141829),
                    borderRadius: BorderRadius.circular(20.65),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (topicTag.isNotEmpty) ...[
                        Text(
                          '🎙️ $topicTag',
                          style: const TextStyle(
                            color: StoryJobTheme.cyanAccent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                      ],
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Semantics(
                            label: isPlaying
                                ? 'Sprachnachricht pausieren'
                                : 'Sprachnachricht abspielen',
                            button: true,
                            child: GestureDetector(
                              onTap: () => _playAudio(message.audioUrl),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFF8A4C),
                                      Color(0xFFEC4899),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFEC4899)
                                          .withValues(alpha: 0.40),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StoryWaveformWidget(
                              isPlaying: isPlaying,
                              progress: isPlaying ? _playbackProgress : 0.0,
                              interactiveSeek: true,
                              onSeek: (ratio) =>
                                  _playAudio(message.audioUrl, seekRatio: ratio),
                              barCount: 22,
                              maxHeight: 28,
                              activeColor: StoryJobTheme.cyanAccent,
                              inactiveColor: StoryJobTheme.primaryViolet
                                  .withValues(alpha: 0.65),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            durationMeta.isNotEmpty ? durationMeta : 'Voice',
                            style: const TextStyle(
                              color: StoryJobTheme.textSecondary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 3. Text-Nachrichten: Rechts (Eigene im Gradient) vs. Links (Partner mit Avatar)
    if (isMe) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.76,
          ),
          decoration: BoxDecoration(
            gradient: _outgoingBubbleGradient,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(6),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              height: 1.38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPartnerAvatar(size: 32, showOnlineDot: false),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(
                  color: StoryJobTheme.cardBorder,
                  width: 1,
                ),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: StoryJobTheme.textPrimary,
                  fontSize: 13.5,
                  height: 1.38,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: StoryJobTheme.backgroundBase.withValues(alpha: 0.96),
        border: const Border(
          top: BorderSide(color: StoryJobTheme.cardBorder),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isRecording
                      ? StoryJobTheme.cyanAccent.withValues(alpha: 0.55)
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
                        Expanded(
                          child: StoryWaveformWidget(
                            isRecording: true,
                            barCount: 18,
                            maxHeight: 24,
                            gradient: _audioAuraGradient,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${_recordSeconds ~/ 60}:${(_recordSeconds % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontWeight: FontWeight.w700,
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
                              hintText: 'Antwort schreiben oder einsprechen...',
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
                        Semantics(
                          label: 'Nachricht senden',
                          button: true,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.arrow_upward_rounded,
                              color: StoryJobTheme.cyanAccent,
                              size: 20,
                            ),
                            onPressed: () => _sendTextMessage(),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            label: _isRecording
                ? 'Sprachaufnahme stoppen'
                : 'Sprachaufnahme starten',
            button: true,
            child: GestureDetector(
              onTap: _toggleVoiceRecording,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _isRecording
                      ? const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        )
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF22D3EE),
                            Color(0xFF8B5CF6),
                            Color(0xFFEC4899),
                          ],
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF8B5CF6))
                          .withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}