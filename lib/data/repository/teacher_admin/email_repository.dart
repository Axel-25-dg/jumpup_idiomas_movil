// lib/data/repository/teacher_admin/email_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/broadcast_email_model.dart';
import 'package:jumpup_app/domain/model/admin/email_log_model.dart';

class EmailRepository extends BaseRepository {
  EmailRepository({Dio? dio}) : super(dio);

  // ─── BROADCAST EMAILS ──────────────────────────────────────────────

  Future<List<BroadcastEmail>> fetchBroadcastEmails() {
    return getList<BroadcastEmail>(
      'broadcast-emails/',
      (json) => BroadcastEmail.fromJson(json),
      message: 'Error al cargar envíos masivos',
    );
  }

  Future<BroadcastEmail> getBroadcastEmail(int id) {
    return getOne<BroadcastEmail>(
      'broadcast-emails/$id/',
      (json) => BroadcastEmail.fromJson(json),
      message: 'Error al obtener el envío',
    );
  }

  Future<BroadcastEmail> createBroadcastEmail(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        'broadcast-emails/',
        data: data,
      );
      return BroadcastEmail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException('Error al crear el envío', e.response?.statusCode, e);
    }
  }

  Future<BroadcastEmail> updateBroadcastEmail(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.patch(
        'broadcast-emails/$id/',
        data: data,
      );
      return BroadcastEmail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException('Error al actualizar el envío', e.response?.statusCode, e);
    }
  }

  Future<void> deleteBroadcastEmail(int id) {
    return executeRequest(
      () async => await dio.delete('broadcast-emails/$id/'),
      message: 'Error al eliminar el envío',
    );
  }

  Future<BroadcastEmail> sendBroadcastEmail(int id) async {
    try {
      final response = await dio.post('broadcast-emails/$id/send/');
      return BroadcastEmail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException('Error al enviar el correo', e.response?.statusCode, e);
    }
  }

  // ─── EMAIL LOGS ────────────────────────────────────────────────────

  Future<List<EmailLog>> fetchEmailLogs({int? broadcastId}) async {
    try {
      final query = broadcastId != null ? {'broadcast': broadcastId} : null;
      final response = await dio.get(
        'email-logs/',
        queryParameters: query,
      );
      final data = response.data;
      final list = data is List ? data : (data['results'] as List? ?? []);
      return list
          .map((json) => EmailLog.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException('Error al cargar historial de correos', e.response?.statusCode, e);
    }
  }

  Future<EmailLog> getEmailLog(int id) {
    return getOne<EmailLog>(
      'email-logs/$id/',
      (json) => EmailLog.fromJson(json),
      message: 'Error al obtener el registro',
    );
  }
}