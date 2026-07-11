import 'package:jumpup_app/data/repository/base_repository.dart';

class AITutorService extends BaseRepository {
  const AITutorService();

  Future<Map<String, dynamic>> sendChatMessage(String message) async {
    return handleRequest<Map<String, dynamic>>(() async {
      final response = await dio.post<Map<String, dynamic>>(
        'ai-tutor/chat/',
        data: {'message': message},
      );
      return response.data!;
    }, message: 'No se pudo enviar el mensaje al tutor de IA');
  }

  Future<List<Map<String, dynamic>>> getChatHistory() async {
    return handleRequest<List<Map<String, dynamic>>>(() async {
      final response = await dio.get<dynamic>('ai-tutor/history/');
      final data = response.data;
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      if (data is Map && data['results'] is List) {
        return (data['results'] as List).cast<Map<String, dynamic>>();
      }
      return const [];
    }, message: 'No se pudo obtener el historial');
  }

  Future<void> clearChatHistory() async {
    await handleRequest<void>(() async {
      await dio.delete<dynamic>('ai-tutor/history/');
    }, message: 'No se pudo limpiar el historial');
  }
}
