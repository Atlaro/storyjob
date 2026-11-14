// lib/core/services/audio_service.dart
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioRecorder _audioRecorder = AudioRecorder();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static String? _lastRecordedPath;
  static String? _currentPlayingUrl;
  static bool _isListenerInitialized = false;

  static void _ensureInitialized() {
    if (_isListenerInitialized) return;
    _isListenerInitialized = true;
    _audioPlayer.onPlayerComplete.listen((_) {
      _currentPlayingUrl = null;
    });
  }

  /// Stream für den Wiedergabestatus (playing, paused, completed, stopped)
  static Stream<PlayerState> get onPlayerStateChanged {
    _ensureInitialized();
    return _audioPlayer.onPlayerStateChanged;
  }

  /// Prüft, ob aktuell eine Wiedergabe läuft
  static bool get isPlaying => _audioPlayer.state == PlayerState.playing;

  /// Liefert die URL oder den Pfad der aktuell abgespielten Datei
  static String? get currentPlayingUrl => _currentPlayingUrl;

  /// Startet die echte Audio-Aufnahme auf dem Smartphone / Web
  static Future<void> startRecording() async {
    await stopAudio();

    if (await _audioRecorder.hasPermission()) {
      String filePath = '';
      if (kIsWeb) {
        filePath = 'pitch_${DateTime.now().millisecondsSinceEpoch}.m4a';
      } else {
        final dir = await getApplicationDocumentsDirectory();
        filePath = '${dir.path}/pitch_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );
      _lastRecordedPath = filePath;
    } else {
      throw Exception('Mikrofon-Berechtigung wurde verweigert.');
    }
  }

  /// Stoppt die Aufnahme und gibt den Dateipfad zurück
  static Future<String?> stopRecording() async {
    final path = await _audioRecorder.stop();
    return path ?? _lastRecordedPath;
  }

  /// Bricht die Aufnahme geordnet ab
  static Future<void> cancelRecording() async {
    try {
      await _audioRecorder.cancel();
      _lastRecordedPath = null;
    } catch (e) {
      debugPrint('AudioService.cancelRecording Fehler: $e');
    }
  }

  /// Spielt ein lokales Audio oder eine Remote-URL ab
  static Future<void> playAudio(String path) async {
    _ensureInitialized();
    try {
      await _audioPlayer.stop();
      _currentPlayingUrl = path;

      if (path.startsWith('http://') || path.startsWith('https://')) {
        await _audioPlayer.play(UrlSource(path));
      } else {
        await _audioPlayer.play(DeviceFileSource(path));
      }
    } catch (e) {
      debugPrint('AudioService.playAudio Fehler: $e');
      _currentPlayingUrl = null;
    }
  }

  /// Stoppt die aktuelle Wiedergabe sauber
  static Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _currentPlayingUrl = null;
    } catch (e) {
      debugPrint('AudioService.stopAudio Fehler: $e');
    }
  }

  static void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
  }
}