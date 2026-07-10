import 'package:jumpup_app/data/repository/base_repository.dart';

class FeedbackService extends BaseRepository {
  const FeedbackService();

  Future<void> sendSuggestion({
    required String message,
    String? category,
  }) async {
    await handleRequest<void>(() async {
      await dio.post<dynamic>(
        'feedback/',
        data: {
          'message': message,
          if (category != null) 'category': category,
        },
      );
    }, message: 'No se pudo enviar el feedback');
  }
}
