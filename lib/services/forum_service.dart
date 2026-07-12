import 'package:dio/dio.dart';
import 'package:jumpup_app/data/remote/dio_client.dart';

/// Servicio del foro comunitario — categorías, hilos, posts y reacciones.
class ForumService {
  ForumService() : _dio = DioClient.instance.dio;

  final Dio _dio;

  // ── Categorías ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCategories() =>
      _getList('/api/forum-categories/');

  // ── Hilos ──────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getThreads({
    int? categoryId,
    String? search,
  }) =>
      _getList('/api/forum-threads/', params: {
        if (categoryId != null) 'category': categoryId,
        if (search != null && search.isNotEmpty) 'search': search,
        'ordering': '-is_pinned,-created_at',
      });

  // ── Posts ──────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getPosts(int threadId) =>
      _getList('/api/forum-posts/', params: {
        'thread': threadId,
        'ordering': 'created_at',
      });

  // ── Crear hilo ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createThread({
    required int categoryId,
    required String title,
    required String body,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/forum-threads/',
      data: {'category': categoryId, 'title': title, 'body': body},
    );
    return res.data!;
  }

  // ── Crear post ─────────────────────────────────────────────────────────────

  Future<void> createPost({
    required int threadId,
    required String body,
    int? parentId,
  }) async {
    await _dio.post<void>('/api/forum-posts/', data: {
      'thread': threadId,
      'body': body,
      if (parentId != null) 'parent': parentId,
    });
  }

  // ── Reacciones ─────────────────────────────────────────────────────────────

  /// reaction: 'like' | 'love' | 'helpful' | 'confused'
  Future<void> react(int postId, String reaction) async {
    await _dio.post<void>('/api/forum-reactions/', data: {
      'post': postId,
      'reaction': reaction,
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
