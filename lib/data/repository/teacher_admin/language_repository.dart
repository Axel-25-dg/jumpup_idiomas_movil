// lib/data/repository/teacher_admin/language_repository.dart
import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/admin_language_model.dart';

class LanguageRepository extends BaseRepository {
  LanguageRepository({Dio? dio}) : super(dio);
  Future<List<Language>> fetchLanguages() {
    return getList<Language>(
      'languages/',
      (json) => Language.fromJson(json),
      message: 'Error al cargar idiomas',
    );
  }

  Future<Language> createLanguage({
    required String name,
    required String code,
    String? flagIconUrl,
  }) {
    return createOne<Language>(
      'languages/',
      (json) => Language.fromJson(json),
      data: {
        'name': name,
        'code': code.toLowerCase(),
        'flag_icon_url': flagIconUrl ?? '',
      },
      message: 'Error al crear idioma',
    );
  }

  Future<void> updateLanguage({
    required int id,
    required String name,
    required String code,
    String? flagIconUrl,
  }) async {
    try {
      await dio.patch(
        'languages/$id/',
        data: {
          'name': name,
          'code': code.toLowerCase(),
          'flag_icon_url': flagIconUrl ?? '',
        },
      );
    } on DioException catch (e) {
      throw ApiException('Error al actualizar idioma', e.response?.statusCode, e);
    }
  }

  Future<void> deleteLanguage(int id) async {
    try {
      await dio.delete('languages/$id/');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ApiException('Idioma tiene cursos asociados', 409, e);
      }
      throw ApiException('Error al eliminar idioma', e.response?.statusCode, e);
    }
  }

  Future<Language?> getLanguageById(int id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('languages/$id/');
      return Language.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException('Error al obtener idioma', e.response?.statusCode, e);
    }
  }
}