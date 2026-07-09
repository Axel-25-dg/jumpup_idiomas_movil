import 'package:jumpup_app/core/error/api_exception.dart';

abstract class BaseRepository {
  const BaseRepository();

  Future<T> handleRequest<T>(Future<T> Function() request,
      {String? message}) async {
    try {
      return await request();
    } catch (error) {
      throw ApiException(message ?? 'Ocurrió un error inesperado', null, error);
    }
  }
}
