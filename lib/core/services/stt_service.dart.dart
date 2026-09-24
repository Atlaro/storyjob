import 'package:speech_to_text/speech_to_text.dart' as stt;

class FreeSttService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;

  Future<void> init() async {
    _isAvailable = await _speech.initialize(
      onError: (val) => print('Error: $val'),
      onStatus: (val) => print('Status: $val'),
    );
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function(bool) onListeningStateChanged,
  }) async {
    if (_isAvailable) {
      await _speech.listen(
        onResult: (val) => onResult(val.recognizedWords),
        localeId: 'de_DE',
      );
      onListeningStateChanged(true);
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}