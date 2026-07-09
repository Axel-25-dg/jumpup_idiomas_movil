import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/remote/dio_client.dart';

abstract class BaseRepository {
  const BaseRepository();
  Dio get dio => DioClient.instance.dio;

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
    String? message,
  }) async {
    return handleRequest<T>(() async {
      final response = await dio.get<Map<String, dynamic>>(endpoint);
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

  Future<T> handleRequest<T>(Future<T> Function() request,
      {String? message}) async {
    try {
      return await request();
    } catch (error) {
      if (error is ApiException) rethrow;
      throw ApiException(message ?? 'Ocurrió un error inesperado', null, error);
    }
  }
}
