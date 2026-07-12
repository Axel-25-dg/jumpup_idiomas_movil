import 'package:jumpup_app/domain/model/media_progress_model.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';

class MediaProgressService extends BaseRepository {
  const MediaProgressService();

  Future<MediaProgressModel> resumeProgress(int lessonId) async {
    return handleRequest<MediaProgressModel>(() async {
      final response = await dio.get<dynamic>(
        'media-progress/resume/$lessonId/',
      );
      final data = response.data;
      if (data is Map) {
        // If the response has detail (no progress found), return default
        if (data.containsKey('detail') && data['position_sec'] == null) {
          return MediaProgressModel(
            id: 0,
            lesson: lessonId,
            positionSeconds: 0,
            durationSeconds: 0,
            completed: false,
          );
        }
        return MediaProgressModel.fromJson(data as Map<String, dynamic>);
      }
      return MediaProgressModel(
        id: 0,
        lesson: lessonId,
        positionSeconds: 0,
        durationSeconds: 0,
        completed: false,
      );
    }, message: 'No se pudo obtener el progreso del video');
  }

  Future<MediaProgressModel> saveProgress({
    required int lessonId,
    required int positionSeconds,
    required int durationSeconds,
    bool completed = false,
  }) async {
    return handleRequest<MediaProgressModel>(() async {
      final response = await dio.post<Map<String, dynamic>>(
        'media-progress/',
        data: {
          'lesson': lessonId,
          'position_sec': positionSeconds,
          'duration_sec': durationSeconds,
          'completed': completed,
        },
      );
      return MediaProgressModel.fromJson(response.data!);
    }, message: 'No se pudo guardar el progreso del video');
  }
}
