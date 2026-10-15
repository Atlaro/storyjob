// lib/features/record/screens/story_recording_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:storyjob/core/services/app_services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/core/widgets/glass_card.dart';
import 'package:storyjob/features/record/screens/story_success_screen.dart';

class StoryRecordingScreen extends StatefulWidget {
  const StoryRecordingScreen({super.key});

  @override
  State<StoryRecordingScreen> createState() => _StoryRecordingScreenState();
}

class _StoryRecordingScreenState extends State<StoryRecordingScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _isRecording = false;
  int _secondsElapsed = 0;
  static const int _recommendedMaxSeconds = 60;
  Timer? _timer;
  String? _recordedFilePath;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _waveAnimController;

  int _activePromptIndex = 0;
  final List<String> _recordingPrompts = const [
    '„Wer bist du und was begeistert dich im Alltag, Ehrenamt oder Beruf?“',
    '„Auf welches Erlebnis oder Projekt mit echten Menschen bist du stolz?“',
    '„Welche gelebten Werte und welches Miteinander sind dir für die Zukunft wichtig?“',
    '„Worin liegt deine größte Stärke, wenn du gemeinsam im Team anpackst?“',
    '„Was möchtest du in deiner nächsten Chance wirklich sinnstiftend bewegen?“',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      if (_isRecording) {
        _pauseRecordingOnAppBackground();
      }
    }
  }

  Future<void> _pauseRecordingOnAppBackground() async {
    _timer?.cancel();
    _pulseController.stop();
    _waveAnimController.stop();

    try {
      final path = await AppServices.stopRecording();
      if (mounted) {
        setState(() {
          _isRecording = false;
          if (path != null) _recordedFilePath = path;
        });
      }
    } catch (e) {
      debugPrint('Fehler beim Pausieren im Hintergrund: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRecording) {
        setState(() {
          _secondsElapsed++;
          if (_secondsElapsed % 7 == 0) {
            _activePromptIndex = (_activePromptIndex + 1) % _recordingPrompts.length;
          }
        });

        if (_secondsElapsed >= _recommendedMaxSeconds) {
          _finishStory();
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pulseController.dispose();
    _waveAnimController.dispose();
    super.dispose();
  }

  Future<void> _togglePauseRecording() async {
    HapticFeedback.mediumImpact();

    if (_isRecording) {
      _timer?.cancel();
      _pulseController.stop();
      _waveAnimController.stop();

      try {
        final path = await AppServices.stopRecording();
        setState(() {
          _isRecording = false;
          if (path != null) _recordedFilePath = path;
        });
      } catch (e) {
        debugPrint('Fehler beim Stoppen des Mikrofons: $e');
      }
    } else {
      try {
        await AppServices.startRecording();
        setState(() {
          _isRecording = true;
        });
        _pulseController.repeat(reverse: true);
        _waveAnimController.repeat();
        _startTimer();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mikrofonfehler: $e', style: const TextStyle(fontSize: 13)),
            backgroundColor: StoryJobTheme.cardSurfaceElevated,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _finishStory() async {
    if (_secondsElapsed < 3) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Sprich bitte mindestens 3 Sekunden ein, um deine Wellenlänge spürbar zu machen.',
            style: TextStyle(fontSize: 13, color: StoryJobTheme.textPrimary),
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

    HapticFeedback.heavyImpact();
    _timer?.cancel();

    if (_isRecording) {
      try {
        final path = await AppServices.stopRecording();
        if (path != null) _recordedFilePath = path;
      } catch (e) {
        debugPrint('Fehler beim finalen Audio-Stopp: $e');
      }
    }

    if (!mounted) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => StorySuccessScreen(
          userId: currentUserId,
          audioFilePath: _recordedFilePath ?? '',
          durationSeconds: _secondsElapsed,
          isVideo: false,
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final List<double> waveHeights = [14, 22, 34, 20, 48, 64, 82, 58, 42, 28, 44, 20, 12];
    final double progressRatio = (_secondsElapsed / _recommendedMaxSeconds).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: StoryJobTheme.textPrimary,
            size: 18,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Deine Audio-Story',
          style: TextStyle(
            color: StoryJobTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Prompt-Impulskarte mit GlassCard & Neon-Border
              GlassCard(
                borderRadius: 22,
                borderGradient: StoryJobTheme.dnaCardBorder,
                hasNeonGlow: true,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.cyanAccent, size: 14),
                        SizedBox(width: 8),
                        Text(
                          'STORYJOB DNA • WERTE-IMPULS',
                          style: TextStyle(
                            color: StoryJobTheme.cyanAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _recordingPrompts[_activePromptIndex],
                        key: ValueKey<int>(_activePromptIndex),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: StoryJobTheme.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Timer & Fortschrittsanzeige
              Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, StoryJobTheme.cyanAccent],
                    ).createShader(bounds),
                    child: Text(
                      _formatTime(_secondsElapsed),
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? const Color(0xFFEF4444)
                              : StoryJobTheme.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isRecording
                            ? 'Aufnahme läuft...'
                            : (_secondsElapsed > 0 ? 'Pausiert' : 'Bereit für deine Audio-Story (max. 60 Sek.)'),
                        style: const TextStyle(
                          color: StoryJobTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 150,
                      height: 5,
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressRatio >= 1.0 ? const Color(0xFFEF4444) : StoryJobTheme.cyanAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Audio Wave Visualisierung mit Neon-Gradient
              AnimatedBuilder(
                animation: _waveAnimController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ShaderMask(
                      shaderCallback: (bounds) => StoryJobTheme.soundWaveGradient.createShader(bounds),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(waveHeights.length, (index) {
                          final double baseHeight = waveHeights[index];
                          double currentHeight = baseHeight;

                          if (_isRecording) {
                            final waveFactor = math.sin((_waveAnimController.value * 2 * math.pi) + (index * 0.5));
                            currentHeight = math.max(6.0, baseHeight + (waveFactor * 14.0));
                          }

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 80),
                            width: 4,
                            height: currentHeight,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: _isRecording ? Colors.white : Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),

              // Buttons (Record & Abschluss)
              Column(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isRecording ? _pulseAnimation.value : 1.0,
                        child: GestureDetector(
                          onTap: _togglePauseRecording,
                          child: Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: StoryJobTheme.cardSurfaceElevated,
                              border: Border.all(
                                color: _isRecording
                                    ? const Color(0xFFEF4444).withValues(alpha: 0.8)
                                    : StoryJobTheme.cyanAccent.withValues(alpha: 0.6),
                                width: 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isRecording ? const Color(0xFFEF4444) : StoryJobTheme.cyanAccent)
                                      .withValues(alpha: 0.30),
                                  blurRadius: 22,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isRecording
                                  ? Icons.pause_rounded
                                  : (_secondsElapsed > 0 ? Icons.play_arrow_rounded : Icons.mic_rounded),
                              color: _isRecording ? const Color(0xFFEF4444) : StoryJobTheme.cyanAccent,
                              size: 36,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StoryJobTheme.primaryViolet,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _finishStory,
                      child: const Text(
                        'Audio-Story abschließen ✨',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}