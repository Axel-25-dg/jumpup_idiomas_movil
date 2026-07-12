// lib/data/repository/teacher_admin/certificate_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/certificate_model.dart';
 
class CertificateRepository extends BaseRepository {
  // Obtener todos los certificados (GET)
  Future<List<Certificate>> fetchCertificates() {
    return getList<Certificate>(
      'certificates/',
      (json) => Certificate.fromJson(json),
      message: 'Error al cargar certificados',
    );
  }

  // Obtener certificado por ID (GET)
  Future<Certificate> getCertificateById(int id) {
    return getOne<Certificate>(
      'certificates/$id/',
      (json) => Certificate.fromJson(json),
      message: 'Error al obtener certificado',
    );
  }

  // Crear certificado (POST) - Usa fromCreateJson porque no devuelve id
  Future<Certificate> createCertificate(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        'certificates/',
        data: data,
      );
      return Certificate.fromCreateJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException('Error al crear certificado', e.response?.statusCode, e);
    }
  }

  // Actualizar certificado (PATCH)
  Future<Certificate> updateCertificate(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch('certificates/$id/', data: data);
      return Certificate.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException('Error al actualizar certificado', e.response?.statusCode, e);
    }
  }

  // Eliminar certificado (DELETE)
  Future<void> deleteCertificate(int id) {
    return executeRequest(
      () async => await dio.delete('certificates/$id/'),
      message: 'Error al eliminar certificado',
    );
  }

  // Emitir certificado (PATCH issue)
  Future<Certificate> issueCertificate(int id) async {
    try {
      final response = await dio.patch('certificates/$id/issue/');
      return Certificate.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException('Error al emitir certificado', e.response?.statusCode, e);
    }
  }

  // Revocar certificado (PATCH revoke)
  Future<Certificate> revokeCertificate(int id) async {
    try {
      final response = await dio.patch('certificates/$id/revoke/');
      return Certificate.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException('Error al revocar certificado', e.response?.statusCode, e);
    }
  }
}