import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/storyjob_theme.dart';
import '../../../../core/services/app_services.dart';
import '../widgets/ripple_painter.dart';

class RecordScreen extends StatefulWidget {
  final VoidCallback? onPublished;

  const RecordScreen({super.key, this.onPublished});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

enum RecordState { idle, recording, analyzing, vibeResult }

class _RecordScreenState extends State<RecordScreen> with TickerProviderStateMixin {
  RecordState _currentState = RecordState.idle;
  late AnimationController _radarController;
  Timer? _timer;
  int _recordDurationSeconds = 0;
  String? _lastRecordedFilePath;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _radarController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    HapticFeedback.heavyImpact();

    if (_currentState == RecordState.idle) {
      try {
        final path = await AppServices.startRecording();
        setState(() {
          _lastRecordedFilePath = path;
          _currentState = RecordState.recording;
          _recordDurationSeconds = 0;
          _radarController.repeat();
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (t) {
          setState(() {
            _recordDurationSeconds++;
          });
        });
      } catch (e) {
        _showError(e.toString());
      }
    } else if (_currentState == RecordState.recording) {
      _radarController.stop();
      _timer?.cancel();

      try {
        final path = await AppServices.stopRecording();
        if (path != null) {
          _lastRecordedFilePath = path;
        }

        setState(() {
          _currentState = RecordState.analyzing;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _currentState = RecordState.vibeResult;
            });
          }
        });
      } catch (e) {
        _showError('Fehler beim Stoppen: $e');
        setState(() => _currentState = RecordState.idle);
      }
    }
  }

  Future<void> _publishStory() async {
    if (_lastRecordedFilePath == null) return;

    HapticFeedback.mediumImpact();
    setState(() => _isPublishing = true);

    try {
      await AppServices.publishStory(
        filePath: _lastRecordedFilePath!,
        durationSeconds: _recordDurationSeconds,
      );

      if (mounted) {
        widget.onPublished?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deine Story ist jetzt live! 🔥')),
        );
        setState(() {
          _currentState = RecordState.idle;
          _lastRecordedFilePath = null;
        });
      }
    } catch (e) {
      _showError('Fehler beim Veröffentlichen: $e');
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Story aufnehmen'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              if (_currentState == RecordState.idle || _currentState == RecordState.recording) ...[
                const SizedBox(height: 20),
                Text(
                  _currentState == RecordState.recording ? _formatDuration(_recordDurationSeconds) : '00:00',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: _currentState == RecordState.recording ? StoryJobTheme.neonPink : StoryJobTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: GestureDetector(
                    onTap: _toggleRecording,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_currentState == RecordState.recording) ...[
                          RippleCircle(animation: _radarController, radius: 140, color: StoryJobTheme.neonPink),
                          RippleCircle(animation: _radarController, radius: 100, color: StoryJobTheme.primaryViolet, delay: 0.5),
                        ],
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [StoryJobTheme.primaryViolet, StoryJobTheme.neonPink],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: StoryJobTheme.primaryViolet.withValues(alpha: 0.5),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                          child: Icon(
                            _currentState == RecordState.recording ? Icons.stop_rounded : Icons.mic_rounded,
                            size: 56,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  _currentState == RecordState.recording ? 'Aufnahme läuft...' : 'Erzähl, was du wirklich kannst.',
                  style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ] else if (_currentState == RecordState.analyzing) ...[
                const SizedBox(height: 100),
                const CircularProgressIndicator(color: StoryJobTheme.cyanAccent),
                const SizedBox(height: 24),
                const Text(
                  'KI analysiert deine Story...',
                  style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 16),
                ),
              ] else if (_currentState == RecordState.vibeResult) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: StoryJobTheme.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: StoryJobTheme.cardBorder),
                  ),
                  child: Column(
                    children: const [
                      Text('Analyse erfolgreich!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StoryJobTheme.textPrimary)),
                      SizedBox(height: 10),
                      Text('Dein Pitch wirkt klar, motiviert und authentisch.', style: TextStyle(color: StoryJobTheme.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _isPublishing
                    ? const CircularProgressIndicator(color: StoryJobTheme.cyanAccent)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: StoryJobTheme.primaryViolet),
                        onPressed: _publishStory,
                        child: const Text('Story jetzt veröffentlichen', style: TextStyle(color: Colors.white)),
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}