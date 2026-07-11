// lib/data/repository/teacher_admin/user_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/admin_user_model.dart';

class UserRepository extends BaseRepository {
  Future<List<User>> fetchUsers() {
    return getList<User>(
      'users/',
      (json) => User.fromJson(json),
      message: 'Error al cargar usuarios',
    );
  }

  Future<User?> getUserById(int id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('users/$id/');
      return User.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException('Error al obtener usuario', e.response?.statusCode, e);
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) {
    return executeRequest(
      () async => await dio.patch('users/$id/', data: data),
      message: 'Error al actualizar usuario',
    );
  }

  Future<void> createUser(Map<String, dynamic> data) {
    return executeRequest(
      () async => await dio.post('users/', data: data),
      message: 'Error al crear usuario',
    );
  }

  Future<void> deleteUser(int id) {
    return executeRequest(
      () async => await dio.delete('users/$id/'),
      message: 'Error al eliminar usuario',
    );
  }

  Future<void> toggleUserStatus(int id, bool isActive) {
    return executeRequest(
      () async => await dio.patch('users/$id/', data: {'is_active': isActive}),
      message: 'Error al cambiar estado del usuario',
    );
  }

  Future<void> changeUserRole(int id, int roleId) {
    return executeRequest(
      () async => await dio.patch('users/$id/', data: {'role_id': roleId}),
      message: 'Error al cambiar rol del usuario',
    );
  }
}