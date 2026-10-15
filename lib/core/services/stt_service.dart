// lib/core/services/stt_service.dart
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FreeSttService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  Function(bool)? _externalListeningStateChanged;

  bool get isAvailable => _isAvailable;
  bool get isListening => _speech.isListening;

  Future<bool> init() async {
    try {
      _isAvailable = await _speech.initialize(
        onError: (val) {
          debugPrint('FreeSttService Fehler: $val');
          _externalListeningStateChanged?.call(false);
        },
        onStatus: (status) {
          debugPrint('FreeSttService Status: $status');
          if (status == 'done' || status == 'notListening') {
            _externalListeningStateChanged?.call(false);
          } else if (status == 'listening') {
            _externalListeningStateChanged?.call(true);
          }
        },
      );
      return _isAvailable;
    } catch (e) {
      debugPrint('FreeSttService Initialisierungs-Ausnahme: $e');
      _isAvailable = false;
      return false;
    }
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function(bool) onListeningStateChanged,
  }) async {
    _externalListeningStateChanged = onListeningStateChanged;

    if (!_isAvailable) {
      final initialized = await init();
      if (!initialized) {
        onListeningStateChanged(false);
        return;
      }
    }

    try {
      await _speech.listen(
        onResult: (val) {
          onResult(val.recognizedWords);
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          cancelOnError: true,
          localeId: 'de_DE',
        ),
      );
      onListeningStateChanged(true);
    } catch (e) {
      debugPrint('FreeSttService Listen-Fehler: $e');
      onListeningStateChanged(false);
    }
  }

  Future<void> stopListening() async {
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('FreeSttService Stop-Fehler: $e');
    } finally {
      _externalListeningStateChanged?.call(false);
    }
  }
}