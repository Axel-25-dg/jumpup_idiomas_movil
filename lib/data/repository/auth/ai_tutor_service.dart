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
}
