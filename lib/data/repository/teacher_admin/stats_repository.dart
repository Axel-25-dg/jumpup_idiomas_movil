// lib/data/repository/teacher_admin/stats_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/admin_stats_model.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/domain/model/admin/stats_teacher_model.dart';
import 'package:jumpup_app/domain/model/admin/user_stats.dart';

class StatsRepository extends BaseRepository {
  Future<AdminStats> getAdminStats() async {
    try {
      final response = await dio.get<Map<String, dynamic>>('dashboard/admin/');
      return AdminStats.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException('Error al cargar estadísticas', e.response?.statusCode, e);
    }
  }

  Future<TeacherStats> fetchTeacherStats() async {
    try {
      final response = await dio.get<Map<String, dynamic>>('dashboard/teacher/');
      return TeacherStats.fromJson(response.data!);
    } on DioException catch (e) {
      // Fallback: calcular desde classrooms
      try {
        final classroomsRes = await dio.get<dynamic>('classrooms/');
        final classrooms = (classroomsRes.data as List)
            .map((i) => ClassroomModel.fromJson(i as Map<String, dynamic>))
            .toList();
        return TeacherStats(
          totalAulas: classrooms.length,
          totalAlumnos: classrooms.fold(0, (sum, item) => sum + item.studentsCount),
        );
      } catch (_) {
        throw ApiException('Error al cargar estadísticas del profesor', e.response?.statusCode, e);
      }
    }
  }

  Future<UserStats> fetchUserStats(String studentId) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('user-stats/$studentId/');
      return UserStats.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException('Error al obtener estadísticas', e.response?.statusCode, e);
    }
  }
}