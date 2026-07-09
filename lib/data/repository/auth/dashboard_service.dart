import 'package:jumpup_app/domain/model/dashboard_models.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';

class DashboardService extends BaseRepository {
  const DashboardService();

  Future<UserProfileModel> getProfile() async {
    return getOne('auth/me/', UserProfileModel.fromJson,
        message: 'No se pudo cargar el perfil del usuario');
  }

  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) async {
    return handleRequest<UserProfileModel>(() async {
      final response = await dio.put<Map<String, dynamic>>(
        'profile/',
        data: data,
      );
      return UserProfileModel.fromJson(response.data!);
    }, message: 'No se pudo actualizar el perfil');
  }

  Future<DashboardSummaryModel> getDashboardSummary() async {
    return getOne('dashboard/student/', DashboardSummaryModel.fromJson,
        message: 'No se pudo cargar el resumen del dashboard');
  }
}
