import 'package:dio/dio.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/social_media_models.dart';

class SocialMediaRepository extends BaseRepository {
  const SocialMediaRepository({Dio? dio}) : super(dio);

  // ── Social Feed ─────────────────────────────────────────────────────────────

  Future<List<SocialPost>> fetchSocialFeed({String? postType}) async {
    return getList('social-posts/', SocialPost.fromJson,
        queryParameters: postType != null ? {'post_type': postType} : null,
        message: 'No se pudo cargar el feed social');
  }

  Future<SocialPost> createSocialPost({
    required String content,
    String? imageUrl,
    String postType = 'general',
    bool isPublic = true,
  }) async {
    return createOne('social-posts/', SocialPost.fromJson,
        data: {
          'content': content,
          'post_type': postType,
          if (imageUrl != null) 'image_url': imageUrl,
          'is_public': isPublic,
        },
        message: 'No se pudo crear la publicación');
  }

  Future<void> reactToPost(int postId, {String reaction = 'like'}) async {
    await handleRequest<void>(() async {
      await dio.post<dynamic>('social-reactions/', data: {
        'post': postId,
        'reaction': reaction,
      });
    }, message: 'No se pudo reaccionar');
  }

  Future<void> removeReaction(int postId) async {
    await handleRequest<void>(() async {
      final resp = await dio.get<dynamic>('social-reactions/',
          queryParameters: {'post': postId});
      final list = resp.data is List
          ? resp.data as List
          : (resp.data is Map && resp.data['results'] is List)
              ? resp.data['results'] as List
              : [];
      if (list.isNotEmpty) {
        final reactionId = list.first['id'];
        await dio.delete<dynamic>('social-reactions/$reactionId/');
      }
    }, message: 'No se pudo quitar la reacción');
  }

  Future<List<SocialComment>> fetchComments(int postId) async {
    return getList('social-comments/', SocialComment.fromJson,
        queryParameters: {'post': postId},
        message: 'No se pudieron cargar los comentarios');
  }

  Future<SocialComment> createComment({
    required int postId,
    required String body,
  }) async {
    return createOne('social-comments/', SocialComment.fromJson,
        data: {'post': postId, 'body': body},
        message: 'No se pudo crear el comentario');
  }

  // ── Mensajería ───────────────────────────────────────────────────────────────

  Future<List<MessageThread>> fetchThreads() async {
    return getList('threads/', MessageThread.fromJson,
        message: 'No se pudieron cargar los hilos');
  }

  Future<MessageThread> createThread({
    required String subject,
    required List<int> participants,
  }) async {
    return createOne('threads/', MessageThread.fromJson,
        data: {'subject': subject, 'participants': participants},
        message: 'No se pudo crear el hilo');
  }

  Future<List<ChatMessage>> fetchChatMessages(int threadId) async {
    return getList('threads/$threadId/messages/', ChatMessage.fromJson,
        message: 'No se pudo cargar el historial del chat');
  }

  Future<ChatMessage> sendMessage({
    required int threadId,
    required String body,
  }) async {
    return createOne('threads/$threadId/messages/', ChatMessage.fromJson,
        data: {'body': body},
        message: 'No se pudo enviar el mensaje');
  }

  // ── Foro / Comunidad ─────────────────────────────────────────────────────────

  Future<List<ForumCategory>> fetchForumCategories() async {
    return getList('forum-categories/', ForumCategory.fromJson,
        message: 'No se pudieron cargar las categorías');
  }

  Future<List<ForumThread>> fetchForumThreads({int? categoryId}) async {
    return getList('forum-threads/', ForumThread.fromJson,
        queryParameters: categoryId != null ? {'category': categoryId} : null,
        message: 'No se pudo cargar el foro');
  }

  Future<ForumThread> createForumThread({
    required int categoryId,
    required String title,
    required String body,
  }) async {
    return createOne('forum-threads/', ForumThread.fromJson,
        data: {'category': categoryId, 'title': title, 'body': body},
        message: 'No se pudo crear el hilo');
  }

  Future<List<ForumPost>> fetchForumPosts(int threadId) async {
    return getList('forum-posts/', ForumPost.fromJson,
        queryParameters: {'thread': threadId},
        message: 'No se pudieron cargar las respuestas');
  }

  Future<ForumPost> createForumPost({
    required int threadId,
    required String body,
    int? parentId,
  }) async {
    return createOne('forum-posts/', ForumPost.fromJson,
        data: {
          'thread': threadId,
          'body': body,
          if (parentId != null) 'parent': parentId,
        },
        message: 'No se pudo publicar la respuesta');
  }

  // ── Sesiones en Vivo ─────────────────────────────────────────────────────────

  Future<List<LiveSession>> fetchLiveSessions({String? status}) async {
    return getList('live-sessions/', LiveSession.fromJson,
        queryParameters: status != null ? {'status': status} : null,
        message: 'No se pudieron cargar las sesiones en vivo');
  }

  Future<LiveSession> createLiveSession({
    required String title,
    required int courseId,
    required DateTime startsAt,
  }) async {
    return createOne('live-sessions/', LiveSession.fromJson,
        data: {
          'title': title,
          'course': courseId,
          'starts_at': startsAt.toIso8601String(),
        },
        message: 'No se pudo crear la sesión en vivo');
  }

  Future<void> joinLiveSession(int sessionId) async {
    await handleRequest<void>(() async {
      await dio.post<dynamic>('live-sessions/$sessionId/join/');
    }, message: 'No se pudo unir a la sesión');
  }

  Future<void> startLiveSession(int id) async {
    await handleRequest<void>(() async {
      await dio.post<dynamic>('live-sessions/$id/start/');
    }, message: 'No se pudo iniciar la sesión');
  }

  Future<void> endLiveSession(int id) async {
    await handleRequest<void>(() async {
      await dio.post<dynamic>('live-sessions/$id/end/');
    }, message: 'No se pudo finalizar la sesión');
  }

  // ── Notificaciones ───────────────────────────────────────────────────────────

  Future<List<NotificationItem>> fetchNotifications({bool? unreadOnly}) async {
    return getList('notifications/', NotificationItem.fromJson,
        queryParameters: unreadOnly == true ? {'is_read': 'false'} : null,
        message: 'No se pudieron cargar las notificaciones');
  }

  Future<int> fetchUnreadCount() async {
    return handleRequest<int>(() async {
      final response = await dio.get<dynamic>('notifications/unread-count/');
      final data = response.data;
      if (data is Map) return data['unread_count'] as int? ?? 0;
      return 0;
    }, message: 'No se pudo obtener el conteo');
  }

  Future<void> markNotificationRead(int notificationId) async {
    await handleRequest<void>(() async {
      await dio.post<dynamic>('notifications/$notificationId/read/');
    }, message: 'No se pudo marcar como leída');
  }

  Future<void> markAllNotificationsRead() async {
    await handleRequest<void>(() async {
      await dio.post<dynamic>('notifications/read-all/');
    }, message: 'No se pudieron marcar todas como leídas');
  }

  // ── Favoritos ────────────────────────────────────────────────────────────────

  Future<List<dynamic>> fetchFavorites() async {
    return getList('favorites/', (json) => json,
        message: 'No se pudieron cargar los favoritos');
  }

  Future<dynamic> addFavorite({int? courseId, int? lessonId}) async {
    return createOne('favorites/', (json) => json,
        data: {
          if (courseId != null) 'course': courseId,
          if (lessonId != null) 'lesson': lessonId,
        },
        message: 'No se pudo agregar a favoritos');
  }

  Future<void> removeFavorite(int favoriteId) async {
    await handleRequest<void>(() async {
      await dio.delete<dynamic>('favorites/$favoriteId/');
    }, message: 'No se pudo eliminar el favorito');
  }

  // ── Búsqueda ─────────────────────────────────────────────────────────────────

  Future<List<SearchResult>> search(String query, {String type = 'all'}) async {
    if (query.trim().isEmpty) return [];
    return getList('search/', SearchResult.fromJson,
        queryParameters: {'q': query.trim(), 'type': type},
        message: 'Error en la búsqueda');
  }

  Future<List<ChatMessage>> fetchMessages() async {
    return getList('messages/', ChatMessage.fromJson,
        message: 'No se pudieron cargar los mensajes');
  }
}
