import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter/foundation.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._();
  static SpeechService get instance => _instance;
  SpeechService._();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  /// Notificador para que la UI sepa si el servicio está escuchando activamente.
  /// Esto es útil porque el servicio puede detenerse automáticamente por silencio.
  final ValueNotifier<bool> isListeningNotifier = ValueNotifier(false);

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');
          isListeningNotifier.value = _speech.isListening;
        },
        onError: (error) {
          debugPrint('Speech error: $error');
          isListeningNotifier.value = false;
        },
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('Error initializing speech: $e');
      return false;
    }
  }

  Future<void> startListening({
    required Function(String) onResult,
    Function(double)? onSoundLevelChange,
    String languageTag = 'en-US',
  }) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return;
    }

    // Asegurarnos de que el estado inicial sea correcto
    isListeningNotifier.value = true;

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords);
      },
      onSoundLevelChange: (level) {
        if (onSoundLevelChange != null) onSoundLevelChange(level);
      },
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
        localeId: languageTag,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    isListeningNotifier.value = false;
  }

  bool get isListening => _speech.isListening;
}
