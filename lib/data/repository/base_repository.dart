import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Añadir foundation
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/remote/dio_client.dart';

abstract class BaseRepository {
  final Dio? _dio;
  const BaseRepository([this._dio]);
  
  Dio get dio => _dio ?? DioClient.instance.dio;

  List<dynamic> _listFrom(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map && raw['results'] is List) return raw['results'] as List;
    return const [];
  }

  Map<String, dynamic> _mapFrom(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return const {};
  }

  Future<List<T>> getList<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? queryParameters,
    String? message,
  }) async {
    return handleRequest<List<T>>(() async {
      final response =
          await dio.get<dynamic>(endpoint, queryParameters: queryParameters);
      final data = _listFrom(response.data);
      return data.map((e) => fromJson(_mapFrom(e))).toList();
    }, message: message ?? 'No se pudieron cargar los datos');
  }

  Future<T> getOne<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? queryParameters,
    String? message,
  }) async {
    return handleRequest<T>(() async {
      final response = await dio.get<Map<String, dynamic>>(endpoint,
          queryParameters: queryParameters);
      return fromJson(response.data!);
    }, message: message ?? 'No se pudo obtener el dato');
  }

  Future<T> createOne<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? data,
    String? message,
  }) async {
    return handleRequest<T>(() async {
      final response =
          await dio.post<Map<String, dynamic>>(endpoint, data: data);
      return fromJson(response.data!);
    }, message: message ?? 'No se pudo crear');
  }

  // Correccion - Metodo para operaciones que no retornan datos (POST, PUT, PATCH, DELETE)
  
  Future<void> executeRequest(
    Future<Response> Function() request, {
    String? message,
  }) async {
    try {
      final response = await request();
      // Debug log for checking status codes
      debugPrint('API Request Success: ${response.statusCode} | Data: ${response.data}');
    } catch (error) {
      if (error is ApiException) rethrow;
      
      if (error is DioException) {
        final statusCode = error.response?.statusCode;
        debugPrint('API Request Failed: $statusCode | Error: ${error.message}');
        throw ApiException(message ?? 'Ocurrió un error inesperado', statusCode, error);
      }

      throw ApiException(message ?? 'Ocurrió un error inesperado', null, error);
    }
  }

  Future<T> handleRequest<T>(Future<T> Function() request,
      {String? message}) async {
    try {
      return await request();
    } catch (error) {
      if (error is ApiException) rethrow;
      // Extraer ApiException anidada dentro de DioException
      if (error is DioException && error.error is ApiException) {
        throw error.error as ApiException;
      }
      if (error is DioException) {
        final statusCode = error.response?.statusCode;
        final body = error.response?.data;
        String msg = message ?? 'Ocurrió un error inesperado';
        if (body is Map) {
          msg = body['detail']?.toString() ??
              body['non_field_errors']?.toString() ??
              body['message']?.toString() ??
              _extractFieldErrors(body) ??
              msg;
        }
        throw ApiException(msg, statusCode, error);
      }
      throw ApiException(message ?? 'Ocurrió un error inesperado', null, error);
    }
  }

  String? _extractFieldErrors(Map body) {
    final errors = <String>[];
    body.forEach((key, value) {
      if (key != 'detail' && key != 'non_field_errors' && key != 'message') {
        if (value is List) {
          errors.addAll(value.map((e) => e.toString()));
        } else if (value is String) {
          errors.add(value);
        }
      }
    });
    return errors.isEmpty ? null : errors.join('\n');
  }
}
