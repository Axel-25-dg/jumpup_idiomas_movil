import 'package:dio/dio.dart';
import 'package:jumpup_app/data/remote/dio_client.dart';

/// Servicio exclusivo del rol Admin — estadísticas, órdenes y suscripciones.
class AdminService {
  AdminService() : _dio = DioClient.instance.dio;

  final Dio _dio;

  // ── Dashboard ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboard() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/dashboard/admin/');
    return res.data ?? {};
  }

  // ── Estadísticas de ventas ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> getSalesStats() async {
    final res = await _dio.get<Map<String, dynamic>>('/api/orders/stats/');
    return res.data ?? {};
  }

  // ── Resumen de suscripciones ───────────────────────────────────────────────

  Future<Map<String, dynamic>> getSubSummary() async {
    final res =
        await _dio.get<Map<String, dynamic>>('/api/my-subscriptions/summary/');
    return res.data ?? {};
  }

  // ── Órdenes ────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllOrders({String? status}) async {
    final res = await _dio.get<dynamic>('/api/orders/', queryParameters: {
      if (status != null) 'status': status,
      'ordering': '-created_at',
      'page_size': 50,
    });
    return _toList(res.data);
  }

  Future<void> approveOrder(int orderId) async {
    await _dio.post<void>('/api/orders/$orderId/approve/');
  }

  // ── Suscripciones activas ──────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllSubs() async {
    final res =
        await _dio.get<dynamic>('/api/my-subscriptions/', queryParameters: {
      'ordering': '-start_date',
      'page_size': 50,
    });
    return _toList(res.data);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _toList(dynamic data) {
    if (data is List) return List<Map<String, dynamic>>.from(data);
    if (data is Map && data['results'] is List) {
      return List<Map<String, dynamic>>.from(data['results'] as List);
    }
    return [];
  }
}
