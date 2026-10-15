// lib/features/record/screens/video_recording_screen.dart
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:storyjob/core/theme/storyjob_theme.dart';
import 'package:storyjob/features/record/screens/story_success_screen.dart';

class VideoRecordingScreen extends StatefulWidget {
  const VideoRecordingScreen({super.key});

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  int _secondsRecorded = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      int frontIndex = _cameras.indexWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
      );
      _selectedCameraIndex = frontIndex != -1 ? frontIndex : 0;

      await _setupCameraController(_cameras[_selectedCameraIndex]);
    } catch (e) {
      debugPrint('Kamera-Initialisierungsfehler: $e');
    }
  }

  Future<void> _setupCameraController(CameraDescription cameraDescription) async {
    final prevController = _cameraController;
    final CameraController controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: true,
    );

    await prevController?.dispose();

    if (!mounted) return;

    try {
      await controller.initialize();
      if (!mounted) return;

      setState(() {
        _cameraController = controller;
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Kamera-Setup-Fehler: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isRecording) return;
    HapticFeedback.selectionClick();

    setState(() {
      _isCameraInitialized = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    });

    await _setupCameraController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _toggleRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    HapticFeedback.heavyImpact();

    if (_isRecording) {
      await _stopAndFinish();
    } else {
      try {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
          _secondsRecorded = 0;
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) return;
          setState(() {
            _secondsRecorded++;
          });

          if (_secondsRecorded >= 60) {
            _stopAndFinish();
          }
        });
      } catch (e) {
        debugPrint('Fehler beim Starten der Videoaufnahme: $e');
      }
    }
  }

  Future<void> _stopAndFinish() async {
    _timer?.cancel();
    HapticFeedback.mediumImpact();

    String videoPath = '';

    if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
      try {
        final XFile videoFile = await _cameraController!.stopVideoRecording();
        videoPath = videoFile.path;
      } catch (e) {
        debugPrint('Fehler beim Stoppen der Videoaufnahme: $e');
      }
    }

    if (!mounted) return;

    setState(() {
      _isRecording = false;
    });

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StorySuccessScreen(
          userId: currentUserId,
          audioFilePath: videoPath,
          isVideo: true,
          durationSeconds: _secondsRecorded > 0 ? _secondsRecorded : 15,
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCameraController(controller.description);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoryJobTheme.backgroundBase,
      body: Stack(
        children: [
          if (_isCameraInitialized && _cameraController != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize?.height ?? 1,
                  height: _cameraController!.value.previewSize?.width ?? 1,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: StoryJobTheme.cyanAccent),
            ),

          // Vignette
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.65),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.80),
                ],
                stops: const [0.0, 0.35, 0.85],
              ),
            ),
          ),

          // Top Header Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(color: StoryJobTheme.cardBorder),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close_rounded, color: StoryJobTheme.textPrimary, size: 20),
                    ),
                  ),

                  // Timer-Pille
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isRecording
                            ? const Color(0xFFEF4444).withValues(alpha: 0.6)
                            : StoryJobTheme.cardBorder,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isRecording) ...[
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _formatDuration(_secondsRecorded),
                          style: const TextStyle(
                            color: StoryJobTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Kamera wechseln
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(color: StoryJobTheme.cardBorder),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: _isRecording ? null : _switchCamera,
                      icon: Icon(
                        Icons.flip_camera_ios_rounded,
                        color: _isRecording ? StoryJobTheme.textMuted : StoryJobTheme.textPrimary,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Shutter
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _toggleRecording,
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: StoryJobTheme.cardSurfaceElevated.withValues(alpha: 0.70),
                          border: Border.all(
                            color: _isRecording
                                ? const Color(0xFFEF4444).withValues(alpha: 0.70)
                                : StoryJobTheme.primaryViolet.withValues(alpha: 0.60),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording
                                      ? const Color(0xFFEF4444)
                                      : StoryJobTheme.primaryViolet)
                                  .withValues(alpha: 0.28),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: _isRecording ? 30 : 64,
                            height: _isRecording ? 30 : 64,
                            decoration: BoxDecoration(
                              color: _isRecording
                                  ? const Color(0xFFEF4444)
                                  : StoryJobTheme.primaryViolet,
                              borderRadius: BorderRadius.circular(_isRecording ? 8 : 32),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _isRecording
                          ? 'Tippen zum Abschließen'
                          : 'Authentische Story aufnehmen (max. 60 Sek.)',
                      style: const TextStyle(
                        color: StoryJobTheme.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
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
}