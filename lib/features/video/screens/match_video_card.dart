// lib/features/record/screens/video_recording_screen.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:storyjob/core/theme/storyjob_theme.dart';

enum VideoRecordState { idle, countdown, recording, review }

class VideoRecordingScreen extends StatefulWidget {
  const VideoRecordingScreen({super.key});

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen>
    with TickerProviderStateMixin {
  
  VideoRecordState _currentState = VideoRecordState.idle;

  // Timer & Controller
  int _countdownNumber = 3;
  Timer? _countdownTimer;
  
  // Timer für 60 Sekunden Video
  late AnimationController _recordDurationController;
  
  // Pulsierende Aura für Aufnahme
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // 60 Sekunden Aufnahme-Timer
    _recordDurationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addListener(() {
        setState(() {}); // UI Update für den Progress-Ring
        if (_recordDurationController.isCompleted) {
          _stopRecording();
        }
      });

    // Pulsieren des Record-Buttons
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
    
    // TODO später: Kamera initialisieren (camera Controller)
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _recordDurationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // --- ACTIONS ---

  void _startCountdown() {
    HapticFeedback.selectionClick();
    setState(() {
      _currentState = VideoRecordState.countdown;
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
      _currentState = VideoRecordState.recording;
    });
    _pulseController.repeat(reverse: true);
    _recordDurationController.forward(from: 0.0);
    
    // TODO später: cameraController.startVideoRecording()
  }

  void _stopRecording() {
    HapticFeedback.mediumImpact();
    _pulseController.stop();
    _pulseController.animateTo(0.0, duration: const Duration(milliseconds: 300));
    _recordDurationController.stop();

    setState(() {
      _currentState = VideoRecordState.review;
    });
    
    // TODO später: cameraController.stopVideoRecording()
  }

  void _retake() {
    HapticFeedback.lightImpact();
    _recordDurationController.reset();
    setState(() {
      _currentState = VideoRecordState.idle;
    });
    
    // TODO später: Aufgenommenes File verwerfen, VideoPlayer ausblenden
  }

  void _toggleCameraFrontBack() {
    HapticFeedback.lightImpact();
    // TODO später: Zwischen Front- und Backkamera switchen
  }

  // --- HELPER ---

  String _formatDuration(Duration duration) {
    final m = duration.inMinutes.toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final bool isRecording = _currentState == VideoRecordState.recording;
    final bool isReview = _currentState == VideoRecordState.review;
    final bool isCountdown = _currentState == VideoRecordState.countdown;

    // Aktuelle Zeit
    final currentDuration = _recordDurationController.duration! * _recordDurationController.value;

    return Scaffold(
      backgroundColor: Colors.black, // Tiefer Kamerahintergrund
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Kamera Preview / Video Player Layer
          Container(
            color: const Color(0xFF111116), // Dummy Hintergrund bis Camera aktiv ist
            child: const Center(
              child: Icon(Icons.videocam_off_rounded, color: StoryJobTheme.cardBorder, size: 48),
            ),
          ),

          // 2. Cinematic Gradient Overlay (von unten und oben)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.2, 0.6, 1.0],
              ),
            ),
          ),

          // 3. UI Layer
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                      
                      // Timer Indicator
                      AnimatedOpacity(
                        opacity: (isRecording || isReview) ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isRecording 
                                ? const Color(0xFFEF4444).withValues(alpha: 0.25) 
                                : Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isRecording 
                                  ? const Color(0xFFEF4444).withValues(alpha: 0.5) 
                                  : Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              if (isRecording) ...[
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFCA5A5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                _formatDuration(currentDuration),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Camera Switch Button (versteckt im Review-Modus)
                      AnimatedOpacity(
                        opacity: isReview ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: GestureDetector(
                          onTap: isReview ? null : _toggleCameraFrontBack,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            child: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Schwebende Impuls-Karte (Glas-Effekt)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedSlide(
                    offset: isReview ? const Offset(0, -0.5) : Offset.zero, // Fährt sanft hoch
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    child: AnimatedOpacity(
                      opacity: isReview ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 400),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: StoryJobTheme.champagneGold.withValues(alpha: 0.3),
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.champagneGold, size: 14),
                                    SizedBox(width: 8),
                                    Text(
                                      'ZEIGE DEINE HALTUNG',
                                      style: TextStyle(
                                        color: StoryJobTheme.champagneGold,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  '„Beschreibe dein ideales Team in drei Worten – und warum?“',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Record Action Center
                SizedBox(
                  width: double.infinity,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Retake Button (Mülleimer) - Fährt nach links aus
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                        left: isReview ? 40 : MediaQuery.of(context).size.width / 2 - 25,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isReview ? 1.0 : 0.0,
                          child: GestureDetector(
                            onTap: isReview ? _retake : null,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.6),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: const Icon(Icons.delete_outline_rounded, color: Colors.white70, size: 22),
                            ),
                          ),
                        ),
                      ),

                      // Zentraler Button & Progress-Ring
                      GestureDetector(
                        onTap: () {
                          if (_currentState == VideoRecordState.idle) _startCountdown();
                          else if (isRecording) _stopRecording();
                        },
                        child: SizedBox(
                          width: 88,
                          height: 88,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Pulsierende Aura hinten (nur bei Aufnahme)
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: isRecording ? _pulseAnimation.value : 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: StoryJobTheme.primaryViolet.withValues(alpha: isRecording ? 0.35 : 0.0),
                                            blurRadius: 30,
                                            spreadRadius: isRecording ? 10 : 0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Progress Ring (60s)
                              if (isRecording || isReview)
                                AnimatedBuilder(
                                  animation: _recordDurationController,
                                  builder: (context, child) {
                                    final progress = _recordDurationController.value;
                                    final ringColor = Color.lerp(
                                      StoryJobTheme.primaryViolet, 
                                      const Color(0xFFFCA5A5), 
                                      progress > 0.8 ? (progress - 0.8) * 5 : 0.0
                                    )!;
                                    
                                    return CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 4,
                                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                                      valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                                    );
                                  },
                                ),
                                // Dünner Platzhalter-Ring, wenn noch nicht aufgenommen wird
                                if (!isRecording && !isReview)
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: StoryJobTheme.primaryViolet.withValues(alpha: 0.6), width: 3),
                                    ),
                                  ),
                              
                              // Der Button Core
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    color: isRecording 
                                        ? const Color(0xFFEF4444) 
                                        : (isReview ? StoryJobTheme.primaryViolet : StoryJobTheme.primaryViolet.withValues(alpha: 0.9)),
                                    borderRadius: BorderRadius.circular(isRecording ? 16 : 40), // Wird quadratischer bei Aufnahme
                                    boxShadow: [
                                      if (!isRecording)
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.4),
                                          blurRadius: 10,
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
                            ],
                          ),
                        ),
                      ),
                      
                      // "Sichern" Button (Play-Icon im Review-Modus, rutscht nach rechts)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                        right: isReview ? 40 : MediaQuery.of(context).size.width / 2 - 25,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isReview ? 1.0 : 0.0,
                          child: GestureDetector(
                            onTap: isReview ? () {
                              HapticFeedback.mediumImpact();
                              // TODO später: Video speichern und Playback starten oder Screen schließen
                              Navigator.pop(context);
                            } : null,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: StoryJobTheme.primaryViolet,
                                border: Border.all(color: StoryJobTheme.champagneGold.withValues(alpha: 0.5)),
                                boxShadow: [
                                  BoxShadow(
                                    color: StoryJobTheme.primaryViolet.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                  )
                                ],
                              ),
                              child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Instruktionstext unten
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _getInstructionText(),
                    key: ValueKey<VideoRecordState>(_currentState),
                    style: TextStyle(
                      color: isRecording ? const Color(0xFFFCA5A5) : Colors.white70,
                      fontSize: 13,
                      fontWeight: (isRecording || isCountdown) ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterIcon() {
    switch (_currentState) {
      case VideoRecordState.countdown:
        return Text(
          '$_countdownNumber',
          key: ValueKey<int>(_countdownNumber),
          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
        );
      case VideoRecordState.recording:
        return const SizedBox(key: ValueKey('recording')); // Icon verschwindet, Button wird zum roten Quadrat
      case VideoRecordState.review:
        return const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36, key: ValueKey('play'));
      case VideoRecordState.idle:
      default:
        return const SizedBox(key: ValueKey('idle')); // Nur der lila Button ohne Icon
    }
  }

  String _getInstructionText() {
    switch (_currentState) {
      case VideoRecordState.countdown:
        return 'Mach dich bereit...';
      case VideoRecordState.recording:
        return 'Authentische Story aufnehmen (max. 60 Sek.)';
      case VideoRecordState.review:
        return 'Video prüfen oder verwerfen';
      case VideoRecordState.idle:
      default:
        return 'Tippe zum Starten';
    }
  }
}