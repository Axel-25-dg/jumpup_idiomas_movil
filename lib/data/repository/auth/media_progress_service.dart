import 'package:jumpup_app/domain/model/media_progress_model.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';

class MediaProgressService extends BaseRepository {
  const MediaProgressService();

  Future<MediaProgressModel?> getProgress(int lessonId) async {
    return handleRequest<MediaProgressModel?>(() async {
      final response = await dio.get<dynamic>(
        'media-progress/',
        queryParameters: {'lesson': lessonId},
      );
      final data = response.data;
      if (data is List && data.isNotEmpty) {
        return MediaProgressModel.fromJson(data.first as Map<String, dynamic>);
      }
      if (data is Map && data['results'] is List) {
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          return MediaProgressModel.fromJson(results.first as Map<String, dynamic>);
        }
      }
      return null;
    }, message: 'No se pudo obtener el progreso del video');
  }

  Future<MediaProgressModel> saveProgress({
    required int lessonId,
    required int positionSeconds,
    required int durationSeconds,
    bool completed = false,
  }) async {
    return handleRequest<MediaProgressModel>(() async {
      final existing = await getProgress(lessonId);
      if (existing != null) {
        final response = await dio.patch<Map<String, dynamic>>(
          'media-progress/${existing.id}/',
          data: {
            'position_seconds': positionSeconds,
            'duration_seconds': durationSeconds,
            'completed': completed,
          },
        );
        return MediaProgressModel.fromJson(response.data!);
      } else {
        final response = await dio.post<Map<String, dynamic>>(
          'media-progress/',
          data: {
            'lesson': lessonId,
            'position_seconds': positionSeconds,
            'duration_seconds': durationSeconds,
            'completed': completed,
          },
        );
        return MediaProgressModel.fromJson(response.data!);
      }
    }, message: 'No se pudo guardar el progreso del video');
  }
}
