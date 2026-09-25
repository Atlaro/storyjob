import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/storyjob_theme.dart';
import '../../../../core/services/app_services.dart';
import '../widgets/ripple_painter.dart';

class RecordStoryScreen extends StatefulWidget {
  final VoidCallback? onPublished;

  const RecordStoryScreen({super.key, this.onPublished});

  @override
  State<RecordStoryScreen> createState() => _RecordStoryScreenState();
}

enum RecordState { idle, recording, analyzing, vibeResult }

class _RecordStoryScreenState extends State<RecordStoryScreen> with TickerProviderStateMixin {
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
        path: _lastRecordedFilePath!,
        durationSeconds: _recordDurationSeconds,
      );

      if (mounted) {
        widget.onPublished?.call();
        _showSuccessDialog();
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: StoryJobTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: StoryJobTheme.emeraldGreen,
              ),
              child: const Icon(Icons.check_rounded, color: StoryJobTheme.backgroundBase, size: 36),
            ),
            const SizedBox(height: 18),
            const Text(
              'Deine Story ist live! 🔥',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: StoryJobTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Deine Story wurde freigeschaltet. Unternehmen können deine Story ab sofort hören.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: StoryJobTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: StoryJobTheme.primaryViolet,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _currentState = RecordState.idle;
                    _lastRecordedFilePath = null;
                  });
                },
                child: const Text('Fertig', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
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
        title: const Text('Voice Story aufnehmen', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              if (_currentState == RecordState.idle || _currentState == RecordState.recording) ...[
                const SizedBox(height: 12),
                Text(
                  _currentState == RecordState.recording ? _formatDuration(_recordDurationSeconds) : '00:00',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: _currentState == RecordState.recording ? StoryJobTheme.neonPink : StoryJobTheme.textMuted,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: GestureDetector(
                    onTap: _toggleRecording,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_currentState == RecordState.recording) ...[
                          RepaintBoundary(
                            child: RippleCircle(animation: _radarController, radius: 140, color: StoryJobTheme.neonPink),
                          ),
                          RepaintBoundary(
                            child: RippleCircle(animation: _radarController, radius: 100, color: StoryJobTheme.primaryViolet, delay: 0.5),
                          ),
                        ],
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentState == RecordState.recording ? 110.0 : 130.0,
                          height: _currentState == RecordState.recording ? 110.0 : 130.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _currentState == RecordState.recording
                                  ? [StoryJobTheme.neonPink, StoryJobTheme.primaryViolet]
                                  : [StoryJobTheme.primaryViolet, StoryJobTheme.primaryViolet],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: StoryJobTheme.primaryViolet.withValues(alpha: 0.5),
                                blurRadius: 30,
                                spreadRadius: 4,
                              )
                            ],
                          ),
                          child: Icon(
                            _currentState == RecordState.recording ? Icons.stop_rounded : Icons.mic_rounded,
                            size: _currentState == RecordState.recording ? 44.0 : 56.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _currentState == RecordState.recording ? 'Aufnahme läuft... (Tippen zum Beenden)' : 'Erzähl, was du wirklich kannst.',
                  style: const TextStyle(color: StoryJobTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kein Lebenslauf. Keine Noten. Nur deine Story.\n🌱 Weniger Papier. Mehr Chancen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 13.5, height: 1.4),
                ),
              ] else if (_currentState == RecordState.analyzing) ...[
                const SizedBox(height: 80),
                const CircularProgressIndicator(color: StoryJobTheme.primaryViolet),
                const SizedBox(height: 24),
                const Text(
                  'KI analysiert deine Story...',
                  style: TextStyle(color: StoryJobTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ] else if (_currentState == RecordState.vibeResult) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: StoryJobTheme.cardSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: StoryJobTheme.cardBorder),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: StoryJobTheme.cyanAccent, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'KI Story Analyse',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StoryJobTheme.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildVibeMetric('Leidenschaft & Energie', 0.94, '94%', StoryJobTheme.emeraldGreen),
                      const SizedBox(height: 14),
                      _buildVibeMetric('Klarheit der Aussage', 0.88, '88%', StoryJobTheme.cyanAccent),
                      const SizedBox(height: 14),
                      _buildVibeMetric('Team-Fit', 0.96, '96%', StoryJobTheme.neonPink),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _isPublishing
                    ? const CircularProgressIndicator(color: StoryJobTheme.cyanAccent)
                    : SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StoryJobTheme.primaryViolet,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _publishStory,
                          child: const Text(
                            'Story jetzt veröffentlichen',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVibeMetric(String label, double progress, String valueText, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: StoryJobTheme.textSecondary)),
            Text(valueText, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: StoryJobTheme.cardBorder,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}