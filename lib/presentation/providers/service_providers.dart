import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/core/services/ocr_service.dart';
import 'package:jumpup_app/core/services/speech_service.dart';

final ocrServiceProvider = Provider<OcrService>((ref) {
  return OcrService.instance;
});

final speechServiceProvider = Provider<SpeechService>((ref) {
  return SpeechService.instance;
});

final isListeningProvider = StateProvider<bool>((ref) {
  return false;
});
