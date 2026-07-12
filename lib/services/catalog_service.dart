import 'package:dio/dio.dart';
import 'package:jumpup_app/data/remote/dio_client.dart';

/// Servicio de catálogo público — cursos, idiomas, módulos, lecciones,
/// planes de suscripción y progreso.
/// Usa DioClient centralizado (token + refresh automático).
class CatalogService {
  CatalogService() : _dio = DioClient.instance.dio;

  final Dio _dio;

  // ── Idiomas ────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getLanguages() =>
      _getList('/api/languages/');

  // ── Cursos ─────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCourses({
    int? languageId,
    String? difficulty,
    String? search,
  }) =>
      _getList('/api/courses/', params: {
        if (languageId != null) 'language': languageId,
        if (difficulty != null) 'difficulty_level': difficulty,
        if (search != null && search.isNotEmpty) 'search': search,
        'page_size': 50,
      });

  // ── Módulos ────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getModules(int courseId) =>
      _getList('/api/modules/',
          params: {'course': courseId, 'ordering': 'order'});

  // ── Lecciones ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getLessons(int moduleId) =>
      _getList('/api/lessons/',
          params: {'module': moduleId, 'ordering': 'order'});

  // ── Planes de suscripción ──────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getPlans() =>
      _getList('/api/subscriptions/active/');

  /// Suscripción activa del usuario. Retorna null si no tiene ninguna.
  Future<Map<String, dynamic>?> getCurrentSub() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
          '/api/my-subscriptions/current/');
      final data = res.data ?? {};
      if (data['subscription'] == null) return null;
      return data;
    } catch (_) {
      return null;
    }
  }

  // ── Órdenes / Checkout ─────────────────────────────────────────────────────

  /// Crea una orden de compra y devuelve su id.
  Future<int> createOrder(int planId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/orders/',
      data: {'subscription': planId, 'payment_method': 'credit_card'},
    );
    return res.data!['id'] as int;
  }

  /// Aprueba la orden (demo sin Stripe real).
  Future<void> approveOrder(int orderId) async {
    await _dio.post<void>('/api/orders/$orderId/approve/');
  }

  // ── Progreso ───────────────────────────────────────────────────────────────

  Future<void> completeLesson(int lessonId, int score) async {
    await _dio.post<void>('/api/progress/', data: {
      'lesson': lessonId,
      'status': 'completed',
      'score': score,
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _getList(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    final res = await _dio.get<dynamic>(path, queryParameters: params);
    final d = res.data;
    if (d is List) return List<Map<String, dynamic>>.from(d);
    if (d is Map && d['results'] is List) {
      return List<Map<String, dynamic>>.from(d['results'] as List);
    }
    return [];
  }
}
