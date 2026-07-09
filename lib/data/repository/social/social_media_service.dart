import 'package:jumpup_app/domain/model/social_media_models.dart';

class SocialMediaService {
  Future<List<MessageThread>> fetchMessages() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return [
      const MessageThread(
        id: 'msg-1',
        title: 'Clase de conversación',
        participantName: 'María',
        unreadCount: 2,
        lastMessage: '¿Listas para la práctica?',
      ),
      const MessageThread(
        id: 'msg-2',
        title: 'Soporte técnico',
        participantName: 'Carlos',
        unreadCount: 0,
        lastMessage: 'Tu video ya está disponible.',
      ),
    ];
  }

  Future<List<ForumThread>> fetchForumThreads() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return [
      const ForumThread(
        id: 'forum-1',
        title: 'Dudas de pronunciación',
        authorName: 'Luis',
        language: 'Inglés',
        replies: 4,
        isPinned: true,
      ),
    ];
  }

  Future<List<LiveSession>> fetchLiveSessions() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return [
      LiveSession(
        id: 'live-1',
        title: 'Tutoría de speaking',
        hostName: 'Ana',
        startsAt: DateTime(2026, 7, 7, 20, 0),
        status: 'scheduled',
      ),
    ];
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return [
      const NotificationItem(
        id: 'notif-1',
        title: 'Nueva respuesta',
        message: 'Alguien respondió tu hilo en la comunidad.',
        type: 'community',
      ),
      const NotificationItem(
        id: 'notif-2',
        title: 'Clase en vivo',
        message: 'Tu tutoría comienza en 15 minutos.',
        type: 'teacher',
        isRead: true,
      ),
    ];
  }

  Future<List<SearchResult>> search(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (query.isEmpty) {
      return [];
    }

    return [
      const SearchResult(
        id: 'search-1',
        title: 'Curso de inglés B1',
        type: 'course',
        subtitle: 'Inglés · Intermedio',
      ),
      const SearchResult(
        id: 'search-2',
        title: 'Lección de pronunciación',
        type: 'lesson',
        subtitle: 'Pronunciación · 12 min',
      ),
    ];
  }

  Future<List<SocialPost>> fetchSocialFeed() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return [
      SocialPost(
        id: 'post-1',
        authorName: 'Paula',
        content: '¡Completé mi racha de 7 días!',
        createdAt: DateTime(2026, 7, 7, 18, 30),
        likes: 12,
        comments: 3,
      ),
    ];
  }
}
