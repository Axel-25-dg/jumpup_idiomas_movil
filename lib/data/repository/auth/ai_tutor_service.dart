import 'package:jumpup_app/data/repository/base_repository.dart';

/// Servicio para interactuar con el Tutor IA Conversacional.
///
/// Endpoints:
/// - POST /api/ai-tutor/chat/ — Enviar mensaje al chat con IA y recibir respuesta
class AITutorService extends BaseRepository {
  const AITutorService();

  Future<Map<String, dynamic>> sendChatMessage(String message) async {
    return handleRequest(() async {
      // TODO: final response = await dio.post('/api/ai-tutor/chat/', data: {'message': message});
      return {
        'reply': '¡Excelente frase! Podrías mejorarla diciendo: "I would like to practice speaking". ¿Quieres intentarlo de nuevo usando el micrófono?',
        'corrections': 'Podrías mejorarla diciendo: "I would like to practice speaking".',
        'hasAudio': true,
      };
    }, message: 'No se pudo enviar el mensaje al tutor de IA');
  }
}
