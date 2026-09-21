import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class FreeSttService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  /// Initialisiert die Spracherkennungs-Engine des Smartphones
  Future<bool> init() async {
    if (_isInitialized) return true;

    _isInitialized = await _speech.initialize(
      onError: (SpeechRecognitionError error) => print('STT Fehler: $error'),
      onStatus: (String status) => print('STT Status: $status'),
    );
    return _isInitialized;
  }

  /// Startet das Zuhören und liefert den erkannten Text in Echtzeit zurück
  Future<void> startListening({
    required Function(String recognizedText) onResult,
    required Function(bool isListening) onListeningStateChanged,
  }) async {
    bool available = await init();

    if (available) {
      onListeningStateChanged(true);
      await _speech.listen(
        localeId: 'de_DE', // Deutsche Spracherkennung
        onResult: (SpeechRecognitionResult result) {
          onResult(result.recognizedWords);
          if (result.finalResult) {
            onListeningStateChanged(false);
          }
        },
        listenFor: const Duration(seconds: 60), // Max. Dauer der Aufnahme
        pauseFor: const Duration(seconds: 3),   // Stoppt nach 3 Sek. Stille
      );
    } else {
      print("Spracherkennung auf diesem Gerät nicht verfügbar.");
    }
  }

  /// Stoppt die Spracherkennung manuell
  Future<void> stopListening() async {
    await _speech.stop();
  }

  bool get isListening => _speech.isListening;
}