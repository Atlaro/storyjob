// lib/features/voice/screens/voice_story_recorder_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';

enum VoiceRecordState { idle, countdown, recording, review }

class VoiceStoryRecorderScreen extends StatefulWidget {
  const VoiceStoryRecorderScreen({super.key});

  @override
  State<VoiceStoryRecorderScreen> createState() => _VoiceStoryRecorderScreenState();
}

class _VoiceStoryRecorderScreenState extends State<VoiceStoryRecorderScreen>
    with TickerProviderStateMixin {
  VoiceRecordState _currentState = VoiceRecordState.idle;

  int _impulseIndex = 0;
  final List<String> _impulses = [
    '„Erzähl von deinem prägendsten beruflichen Moment und was dich antreibt.“',
    '„Welchen Wert vermisst du in der heutigen Arbeitswelt am meisten?“',
    '„Was war dein größtes Learning aus einem gescheiterten Projekt?“',
    '„Beschreibe dein ideales Team in drei Worten – und warum?“',
  ];

  int _countdownNumber = 3;
  Timer? _countdownTimer;

  late AnimationController _recordDurationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isPlayingReview = false;
  late AnimationController _playbackController;

  @override
  void initState() {
    super.initState();

    _recordDurationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..addListener(() {
        setState(() {});
        if (_recordDurationController.isCompleted) {
          _stopRecording();
        }
      });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _playbackController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..addListener(() {
        setState(() {});
        if (_playbackController.isCompleted) {
          setState(() => _isPlayingReview = false);
          _playbackController.reset();
        }
      });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _recordDurationController.dispose();
    _pulseController.dispose();
    _playbackController.dispose();
    super.dispose();
  }

  void _shuffleImpulse() {
    HapticFeedback.lightImpact();
    setState(() {
      _impulseIndex = (_impulseIndex + 1) % _impulses.length;
    });
  }

  void _startCountdown() {
    HapticFeedback.selectionClick();
    setState(() {
      _currentState = VoiceRecordState.countdown;
      _countdownNumber = 3;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownNumber == 1) {
        timer.cancel();
        _startRecording();
      } else {
        HapticFeedback.selectionClick();
        setState(() {
          _countdownNumber--;
        });
      }
    });
  }

  void _startRecording() {
    HapticFeedback.heavyImpact();
    setState(() {
      _currentState = VoiceRecordState.recording;
    });
    _pulseController.repeat(reverse: true);
    _recordDurationController.forward(from: 0.0);
  }

  void _stopRecording() {
    HapticFeedback.mediumImpact();
    _pulseController.stop();
    _pulseController.animateTo(0.0, duration: const Duration(milliseconds: 300));

    _playbackController.duration =
        _recordDurationController.duration! * _recordDurationController.value;
    _recordDurationController.stop();

    setState(() {
      _currentState = VoiceRecordState.review;
    });
  }

  void _retake() {
    HapticFeedback.lightImpact();
    _playbackController.stop();
    _playbackController.reset();
    _recordDurationController.reset();
    setState(() {
      _isPlayingReview = false;
      _currentState = VoiceRecordState.idle;
    });
  }

  void _togglePlayback() {
    HapticFeedback.selectionClick();
    setState(() {
      _isPlayingReview = !_isPlayingReview;
      if (_isPlayingReview) {
        if (_playbackController.isCompleted) _playbackController.reset();
        _playbackController.forward();
      } else {
        _playbackController.stop();
      }
    });
  }

  String _formatDuration(Duration duration) {
    final m = duration.inMinutes.toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final bool isRecording = _currentState == VoiceRecordState.recording;
    final bool isReview = _currentState == VoiceRecordState.review;
    final bool isCountdown = _currentState == VoiceRecordState.countdown;

    Duration currentDuration = Duration.zero;
    if (isRecording) {
      currentDuration = _recordDurationController.duration! * _recordDurationController.value;
    } else if (isReview) {
      currentDuration = _playbackController.duration! * _playbackController.value;
    }

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'StoryJob',
          style: TextStyle(color: StoryJobTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: StoryJobTheme.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // 1. Die Impuls-Karte mit Shuffle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedOpacity(
                opacity: (isRecording || isCountdown) ? 0.35 : 1.0,
                duration: const Duration(milliseconds: 400),
                child: GlassCard(
                  padding: const EdgeInsets.all(18),
                  borderRadius: 22,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.cyanAccent, size: 14),
                              SizedBox(width: 8),
                              Text(
                                'DEIN IMPULS',
                                style: TextStyle(
                                  color: StoryJobTheme.cyanAccent,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: (isRecording || isCountdown) ? null : _shuffleImpulse,
                            child: Icon(
                              Icons.sync_rounded,
                              color: (isRecording || isCountdown)
                                  ? Colors.transparent
                                  : StoryJobTheme.textSecondary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _impulses[_impulseIndex],
                          key: ValueKey<int>(_impulseIndex),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // ===============================================================
            // 2. SCHWEBENDE AUDIO-BUBBLE MIT WERTEN
            // ===============================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -24,
                    right: 28,
                    child: _buildGlowTag('Offene Kultur', StoryJobTheme.cyanAccent),
                  ),
                  Positioned(
                    bottom: -24,
                    left: 20,
                    child: _buildGlowTag('Teamgeist', StoryJobTheme.pinkMagenta),
                  ),
                  Positioned(
                    bottom: -24,
                    right: 14,
                    child: _buildGlowTag('Offenes Engagement', StoryJobTheme.amberEnergy),
                  ),

                  GlassCard(
                    borderRadius: 28,
                    borderGradient: StoryJobTheme.dnaCardBorder,
                    hasNeonGlow: true,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        // Avatar-Ersatz statt fehlendem Asset
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: StoryJobTheme.primaryViolet.withValues(alpha: 0.25),
                            border: Border.all(color: StoryJobTheme.pinkMagenta, width: 1.5),
                          ),
                          child: const Center(
                            child: Text(
                              'S',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        GestureDetector(
                          onTap: isReview ? _togglePlayback : null,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                            child: Icon(
                              _isPlayingReview ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        Expanded(
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFB923C), Color(0xFFC084FC), Color(0xFF38BDF8)],
                            ).createShader(bounds),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(24, (i) {
                                final heights = [8, 14, 22, 16, 28, 20, 12, 24, 30, 18, 12, 22, 16, 24, 18, 12, 20, 14, 8, 16, 12, 18, 10, 6];
                                return Container(
                                  width: 2.5,
                                  height: heights[i % heights.length].toDouble(),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        Text(
                          isRecording || isReview ? _formatDuration(currentDuration) : '0:24',
                          style: const TextStyle(
                            color: StoryJobTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ===============================================================
            // 3. AUFNAHME-PANEL UNTEN MIT PULSIERENDEM BUTTON
            // ===============================================================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: BoxDecoration(
                color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: StoryJobTheme.cardBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isRecording
                        ? 'Aufnahme läuft (max. 30s)...'
                        : (isReview ? 'Story prüfen oder neu aufnehmen' : 'Sprachnachricht senden'),
                    style: const TextStyle(
                      color: StoryJobTheme.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (isReview)
                        GestureDetector(
                          onTap: _retake,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: StoryJobTheme.cardSurface,
                              border: Border.all(color: StoryJobTheme.cardBorder),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: StoryJobTheme.textSecondary, size: 20),
                          ),
                        )
                      else
                        const Text(
                          'Sprachnachricht',
                          style: TextStyle(color: StoryJobTheme.textMuted, fontSize: 11),
                        ),

                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isRecording ? _pulseAnimation.value : 1.0,
                            child: GestureDetector(
                              onTap: () {
                                if (_currentState == VoiceRecordState.idle) {
                                  _startCountdown();
                                } else if (isRecording) {
                                  _stopRecording();
                                } else if (isReview) {
                                  _togglePlayback();
                                }
                              },
                              child: Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: isRecording
                                      ? const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)])
                                      : StoryJobTheme.brandGradient,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isRecording ? const Color(0xFFEF4444) : StoryJobTheme.cyanAccent)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 18,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: _buildCenterIcon(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      if (isReview)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.heavyImpact();
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: StoryJobTheme.mintSuccess.withValues(alpha: 0.2),
                              border: Border.all(color: StoryJobTheme.mintSuccess),
                            ),
                            child: const Icon(Icons.check_rounded, color: StoryJobTheme.mintSuccess, size: 22),
                          ),
                        )
                      else
                        const Text(
                          'Natural Voice',
                          style: TextStyle(color: StoryJobTheme.textMuted, fontSize: 11),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCenterIcon() {
    switch (_currentState) {
      case VoiceRecordState.countdown:
        return Text(
          '$_countdownNumber',
          key: ValueKey<int>(_countdownNumber),
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
        );
      case VoiceRecordState.recording:
        return const Icon(Icons.stop_rounded, color: Colors.white, size: 28, key: ValueKey('stop'));
      case VoiceRecordState.review:
        return Icon(_isPlayingReview ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.white, size: 30, key: ValueKey(_isPlayingReview));
      case VoiceRecordState.idle:
        return const Icon(Icons.mic_rounded, color: Colors.white, size: 28, key: ValueKey('mic'));
    }
  }
}