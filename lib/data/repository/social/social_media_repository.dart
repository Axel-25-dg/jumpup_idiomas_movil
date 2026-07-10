import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/remote/dio_client.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';

class SocialMediaRepository {
  SocialMediaRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  List<dynamic> _listFrom(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map && raw['results'] is List) return raw['results'] as List;
    return const [];
  }

  // ── Social Feed ─────────────────────────────────────────────────────────────

  Future<List<SocialPost>> fetchSocialFeed() async {
    try {
      final response = await _dio.get<dynamic>('/social-posts/');
      final list = _listFrom(response.data);
      return list
          .map((json) => SocialPost.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo cargar el feed social');
    }
  }

  Future<SocialPost> createSocialPost({
    required String content,
    String? imageUrl,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/social-posts/',
        data: {'content': content, 'image_url': imageUrl},
      );
      return SocialPost.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo crear la publicación');
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _dio.post<void>('/social-posts/$postId/like/');
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo dar like');
    }
  }

  Future<void> unlikePost(String postId) async {
    try {
      await _dio.post<void>('/social-posts/$postId/unlike/');
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo quitar el like');
    }
  }

  Future<List<SocialComment>> fetchComments(String postId) async {
    try {
      final response = await _dio.get<dynamic>('/social-posts/$postId/comments/');
      final list = _listFrom(response.data);
      return list
          .map((json) => SocialComment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudieron cargar los comentarios');
    }
  }

  Future<SocialComment> createComment({
    required String postId,
    required String content,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/social-posts/$postId/comments/',
        data: {'content': content},
      );
      return SocialComment.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo crear el comentario');
    }
  }

  // ── Mensajería ───────────────────────────────────────────────────────────────

  Future<List<MessageThread>> fetchMessages() async {
    try {
      final response = await _dio.get<dynamic>('/threads/');
      final list = _listFrom(response.data);
      return list
          .map((json) => MessageThread.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo cargar los mensajes');
    }
  }

  Future<List<ChatMessage>> fetchChatMessages(String threadId) async {
    try {
      final response =
          await _dio.get<dynamic>('/threads/$threadId/messages/');
      final list = _listFrom(response.data);
      return list
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo cargar el historial del chat');
    }
  }

  Future<ChatMessage> sendMessage({
    required String threadId,
    required String content,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/threads/$threadId/messages/',
        data: {'content': content},
      );
      return ChatMessage.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo enviar el mensaje');
    }
  }

  // ── Foro / Comunidad ─────────────────────────────────────────────────────────

  Future<List<ForumThread>> fetchForumThreads() async {
    try {
      final response = await _dio.get<dynamic>('/forum-threads/');
      final list = _listFrom(response.data);
      return list
          .map((json) => ForumThread.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo cargar el foro');
    }
  }

  Future<ForumThread> createForumThread({
    required String title,
    required String body,
    required String language,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/forum-threads/',
        data: {'title': title, 'body': body, 'language': language},
      );
      return ForumThread.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo crear el hilo');
    }
  }

  // ── Sesiones en Vivo ─────────────────────────────────────────────────────────

  Future<List<LiveSession>> fetchLiveSessions() async {
    try {
      final response = await _dio.get<dynamic>('/live-sessions/');
      final list = _listFrom(response.data);
      return list
          .map((json) => LiveSession.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo cargar las sesiones en vivo');
    }
  }

  Future<LiveSession> createLiveSession({
    required String title,
    required String courseId,
    required DateTime startsAt,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/live-sessions/',
        data: {
          'title': title,
          'course': courseId,
          'starts_at': startsAt.toIso8601String(),
        },
      );
      return LiveSession.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo crear la sesión en vivo');
    }
  }

  Future<void> startLiveSession(String id) async {
    try {
      await _dio.post<void>('/live-sessions/$id/start/');
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo iniciar la sesión');
    }
  }

  Future<void> endLiveSession(String id) async {
    try {
      await _dio.post<void>('/live-sessions/$id/end/');
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo finalizar la sesión');
    }
  }

  // ── Notificaciones ───────────────────────────────────────────────────────────

  Future<List<NotificationItem>> fetchNotifications() async {
    try {
      final response = await _dio.get<dynamic>('/notifications/');
      final list = _listFrom(response.data);
      return list
          .map(
              (json) => NotificationItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo cargar las notificaciones');
    }
  }

  Future<void> markNotificationRead(String notificationId) async {
    try {
      await _dio.post<void>('/notifications/$notificationId/read/');
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo marcar la notificación como leída');
    }
  }

  // ── Búsqueda ─────────────────────────────────────────────────────────────────

  Future<List<SearchResult>> search(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _dio.get<dynamic>(
        '/search/',
        queryParameters: {
          'q': query.trim(),
          'type': 'all',
          'limit': 20,
        },
      );
      final list = _listFrom(response.data);
      return list
          .map((json) => SearchResult.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'Error en la búsqueda');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  ApiException _handleDio(DioException e, String fallback) {
    final inner = e.error;
    if (inner is ApiException) return inner;
    return ApiException(
      e.response?.statusMessage ?? fallback,
      e.response?.statusCode,
      e,
    );
  }
}
