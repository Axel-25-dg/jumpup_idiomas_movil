import 'package:jumpup_app/domain/model/dashboard_models.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';

/// Servicio para los endpoints de Dashboard y Perfil de Usuario.
///
/// Endpoints:
/// - GET  /api/profile/        — Obtener el perfil del usuario actual
/// - PUT  /api/profile/        — Actualizar el perfil
/// - GET  /api/dashboard/      — Resumen para el home/dashboard
/// - GET  /api/activity-logs/  — Historial de actividad
class DashboardService extends BaseRepository {
  const DashboardService();

  // ─── Profile ────────────────────────────────────────────────────────────────

  Future<UserProfileModel> getProfile() async {
    return handleRequest(() async {
      // TODO: final response = await dio.get('/api/profile/');
      return _mockProfile();
    }, message: 'No se pudo cargar el perfil del usuario');
  }

  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) async {
    return handleRequest(() async {
      // TODO: final response = await dio.put('/api/profile/', data: data);
      final current = _mockProfile();
      return UserProfileModel(
        id: current.id,
        userId: current.userId,
        username: data['username'] ?? current.username,
        email: data['email'] ?? current.email,
        avatarUrl: data['avatar_url'] ?? current.avatarUrl,
        nativeLanguage: data['native_language'] ?? current.nativeLanguage,
        learningLanguages: data['learning_languages']?.cast<String>() ?? current.learningLanguages,
        bio: data['bio'] ?? current.bio,
        joinedAt: current.joinedAt,
      );
    }, message: 'No se pudo actualizar el perfil');
  }

  // ─── Dashboard ──────────────────────────────────────────────────────────────

  Future<DashboardSummaryModel> getDashboardSummary() async {
    return handleRequest(() async {
      // TODO: final response = await dio.get('/api/dashboard/');
      return _mockDashboardSummary();
    }, message: 'No se pudo cargar el resumen del dashboard');
  }

  // ─── Mock Data ──────────────────────────────────────────────────────────────

  UserProfileModel _mockProfile() => UserProfileModel(
        id: 1,
        userId: 1,
        username: 'juan_perez',
        email: 'juan@ute.edu.ec',
        avatarUrl: 'https://i.pravatar.cc/150?u=juan_perez',
        nativeLanguage: 'Español',
        learningLanguages: ['Inglés', 'Francés'],
        bio: 'Estudiante de la UTE apasionado por los idiomas y la tecnología.',
        joinedAt: DateTime.now().subtract(const Duration(days: 120)),
      );

  DashboardSummaryModel _mockDashboardSummary() => DashboardSummaryModel(
        activeCourses: 2,
        totalXp: 450,
        currentStreak: 12,
        todayGoalProgress: 0.75, // 75% completado de la meta diaria
        upcomingClasses: 1,
        recentActivities: [
          ActivityLogModel(
            id: 1,
            activityType: 'lesson_completed',
            description: 'Completaste la lección "Saludos básicos"',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ActivityLogModel(
            id: 2,
            activityType: 'achievement_unlocked',
            description: '¡Desbloqueaste el logro "En racha"!',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ActivityLogModel(
            id: 3,
            activityType: 'course_started',
            description: 'Iniciaste el curso "Francés para viajeros"',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
      );
}
