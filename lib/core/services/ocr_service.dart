import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';

class OcrService {
  static final OcrService _instance = OcrService._();
  static OcrService get instance => _instance;
  OcrService._();

  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Extrae texto de una imagen y devuelve el contenido detectado.
  Future<String> recognizeText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      String text = recognizedText.text;
      
      // Limpieza básica
      text = text.replaceAll('\n', ' ');
      
      return text;
    } catch (e) {
      debugPrint('Error en OCR: $e');
      return '';
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
