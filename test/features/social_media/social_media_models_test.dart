import 'package:flutter_test/flutter_test.dart';
import 'package:jumpup_app/domain/model/forum_thread.dart';
import 'package:jumpup_app/domain/model/live_session.dart';
import 'package:jumpup_app/domain/model/message_thread.dart';

void main() {
  group('social media models', () {
    test('MessageThread expone title y unreadCount correctamente', () {
      const thread = MessageThread(
        id: 1,
        subject: 'Clase de conversación',
        unreadCount: 2,
      );

      expect(thread.title, contains('Clase de conversación'));
      expect(thread.unreadCount, 2);
    });

    test('ForumThread serializa y deserializa correctamente', () {
      const thread = ForumThread(
        id: 1,
        title: 'Dudas de pronunciación',
        body: '¿Cómo pronuncio esta palabra?',
        authorName: 'Luis',
        postCount: 4,
      );

      final json = thread.toJson();
      final decoded = ForumThread.fromJson(json);

      expect(decoded.title, 'Dudas de pronunciación');
      expect(decoded.postCount, 4);
    });

    test('LiveSession expone estado y horario correctamente', () {
      final session = LiveSession(
        id: 1,
        title: 'Tutoría de speaking',
        hostName: 'Ana',
        startsAt: DateTime(2026, 7, 7, 20, 0),
        status: 'scheduled',
      );

      expect(session.status, 'scheduled');
      expect(session.title, contains('speaking'));
      expect(session.isScheduled, isTrue);
      expect(session.isLive, isFalse);
      expect(session.isEnded, isFalse);
    });

    test('LiveSession detecta estado en vivo', () {
      const session = LiveSession(
        id: 2,
        title: 'Sesión activa',
        status: 'live',
      );

      expect(session.isLive, isTrue);
      expect(session.statusLabel, 'En vivo');
    });

    test('MessageThread.fromJson parsea correctamente desde JSON', () {
      final json = {
        'id': 10,
        'subject': 'Práctica de inglés',
        'unread_count': 3,
        'participants': [
          {'username': 'carlos'}
        ],
      };

      final thread = MessageThread.fromJson(json);

      expect(thread.id, 10);
      expect(thread.subject, 'Práctica de inglés');
      expect(thread.unreadCount, 3);
      expect(thread.participantName, 'carlos');
    });
  });
}
