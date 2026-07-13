// lib/data/repository/teacher_admin/user_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/admin_user_model.dart';


class UserRepository extends BaseRepository {
  UserRepository({Dio? dio}) : super(dio);
  // ─── STAFF (Admin/Teacher) ──────────────────────────────────────

  // Listar Staff
  Future<List<User>> fetchUsers() {
    return getList<User>(
      'users/',
      (json) => User.fromJson(json),
      message: 'Error al cargar usuarios',
    );
  }

  // Obtener Staff por ID
  Future<User?> getUserById(int id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('users/$id/');
      return User.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException('Error al obtener usuario', e.response?.statusCode, e);
    }
  }

  // Crear Staff
  Future<void> createUser(Map<String, dynamic> data) {
    return executeRequest(
      () async => await dio.post('users/', data: data),
      message: 'Error al crear usuario',
    );
  }

  // Editar Staff
  Future<void> updateUser(int id, Map<String, dynamic> data) {
    return executeRequest(
      () async => await dio.patch('users/$id/', data: data),
      message: 'Error al actualizar usuario',
    );
  }

  // Eliminar Staff
  Future<void> deleteUser(int id) {
    return executeRequest(
      () async => await dio.delete('users/$id/'),
      message: 'Error al eliminar usuario',
    );
  }

  // ─── ESTUDIANTES ──────────────────────────────────────────────────

  // Listar Estudiantes
  Future<List<User>> fetchStudents() {
    return getList<User>(
      'admin-students/',
      (json) => User.fromJson(json),
      message: 'Error al cargar estudiantes',
    );
  }

  // Editar Estudiante
  Future<void> updateStudent(int id, Map<String, dynamic> data) {
    return executeRequest(
      () async => await dio.patch('admin-students/$id/', data: data),
      message: 'Error al actualizar estudiante',
    );
  }

  // Eliminar Estudiante
  Future<void> deleteStudent(int id) {
    return executeRequest(
      () async => await dio.delete('admin-students/$id/'),
      message: 'Error al eliminar estudiante',
    );
  }

  // ─── COMUNES ──────────────────────────────────────────────────────

  // Activar/Desactivar (funciona para ambos)
  Future<void> toggleUserStatus(int id, bool isActive) {
    return executeRequest(
      () async => await dio.patch('users/$id/', data: {'is_active': isActive}),
      message: 'Error al cambiar estado del usuario',
    );
  }

  // Cambiar rol (solo para Staff)
  Future<void> changeUserRole(int id, int roleId) {
    return executeRequest(
      () async => await dio.patch('users/$id/', data: {'role_id': roleId}),
      message: 'Error al cambiar rol del usuario',
    );
  }

  // Editar nombre y correo (Staff y Student)
  Future<void> updateUserInfo(int id, Map<String, dynamic> data) {
    return executeRequest(
      () async => await dio.patch('users/$id/', data: data),
      message: 'Error al actualizar información del usuario',
    );
  }

  // Editar estudiante (nombre y correo)
  Future<void> updateStudentInfo(int id, Map<String, dynamic> data) {
    return executeRequest(
      () async => await dio.patch('admin-students/$id/', data: data),
      message: 'Error al actualizar información del estudiante',
    );
  }
}