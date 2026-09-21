import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _lastRecordedPath;

  /// Startet die echte Audio-Aufnahme auf dem Smartphone
  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/pitch_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );
      _lastRecordedPath = filePath;
    }
  }

  /// Stoppt die Aufnahme und gibt den Dateipfad zurück
  Future<String?> stopRecording() async {
    final path = await _audioRecorder.stop();
    return path ?? _lastRecordedPath;
  }

  /// Spielt eine gespeicherte Audio-Datei ab
  Future<void> playAudio(String path) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(path));
  }

  /// Stoppt die aktuelle Wiedergabe
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
  }
}