import 'package:flutter_test/flutter_test.dart';
import 'package:jumpup_app/domain/model/forum_thread.dart';
import 'package:jumpup_app/domain/model/live_session.dart';
import 'package:jumpup_app/domain/model/message_thread.dart';
import 'package:jumpup_app/domain/model/notification_item.dart';
import 'package:jumpup_app/domain/model/search_result.dart';
import 'package:jumpup_app/domain/model/social_post.dart';
import 'package:jumpup_app/data/repository/social/social_media_service.dart';

void main() {
  group('social media models', () {
    test('MessageThread crea un resumen útil', () {
      final thread = MessageThread(
        id: 'msg-1',
        title: 'Clase de conversación',
        participantName: 'María',
        unreadCount: 2,
      );

      expect(thread.summary, contains('Clase de conversación'));
      expect(thread.unreadCount, 2);
    });

    test('ForumThread serializa y deserializa correctamente', () {
      final thread = ForumThread(
        id: 'f-1',
        title: 'Dudas de pronunciación',
        authorName: 'Luis',
        language: 'Inglés',
        replies: 4,
      );

      final json = thread.toJson();
      final decoded = ForumThread.fromJson(json);

      expect(decoded.title, 'Dudas de pronunciación');
      expect(decoded.replies, 4);
    });

    test('LiveSession expone estado y horario', () {
      final session = LiveSession(
        id: 'live-1',
        title: 'Tutoría de speaking',
        hostName: 'Ana',
        startsAt: DateTime(2026, 7, 7, 20, 0),
        status: 'scheduled',
      );

      expect(session.statusLabel, 'Programada');
      expect(session.title, contains('speaking'));
    });
  });

  test('SocialMediaService devuelve datos de ejemplo por categoría', () async {
    final service = SocialMediaService();

    final messages = await service.fetchMessages();
    final notifications = await service.fetchNotifications();
    final posts = await service.fetchSocialFeed();

    expect(messages, isNotEmpty);
    expect(notifications, isNotEmpty);
    expect(posts, isNotEmpty);
  });
}
