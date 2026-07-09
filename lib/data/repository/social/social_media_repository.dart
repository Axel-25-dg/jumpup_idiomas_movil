import 'package:dio/dio.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/data/remote/dio_client.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';

/// Repositorio real que consume la API del VPS Hetzner.
///
/// BaseURL (leída del .env): https://guaman-idiomas-ute.online/api/
///
/// Endpoints implementados:
///   GET  /social/feed/          → fetchSocialFeed()
///   GET  /messaging/threads/    → fetchMessages()
///   GET  /community/threads/    → fetchForumThreads()
///   POST /community/threads/    → createForumThread()
///   GET  /live-sessions/        → fetchLiveSessions()
///   GET  /notifications/        → fetchNotifications()
///   POST /notifications/{id}/read/ → markNotificationRead()
///   GET  /search/?q=            → search()
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
      final response = await _dio.get<dynamic>('/social/feed/');
      final list = _listFrom(response.data);
      return list
          .map((json) => SocialPost.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDio(e, 'No se pudo cargar el feed social');
    }
  }

  // ── Mensajería ───────────────────────────────────────────────────────────────

  Future<List<MessageThread>> fetchMessages() async {
    try {
      final response = await _dio.get<dynamic>('/messaging/threads/');
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
          await _dio.get<dynamic>('/messaging/threads/$threadId/messages/');
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
        '/messaging/threads/$threadId/messages/',
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
      final response = await _dio.get<dynamic>('/community/threads/');
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
        '/community/threads/',
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
        queryParameters: {'q': query.trim()},
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
