import 'package:flutter_test/flutter_test.dart';
import 'package:jumpup_app/domain/model/forum_thread.dart';
import 'package:jumpup_app/domain/model/live_session.dart';
import 'package:jumpup_app/domain/model/message_thread.dart';
// import 'package:jumpup_app/domain/model/notification_item.dart';
// import 'package:jumpup_app/domain/model/search_result.dart';
// import 'package:jumpup_app/domain/model/social_post.dart';


void main() {
  group('social media models', () {
    test('MessageThread crea un resumen útil', () {
      const thread = MessageThread(
        id: 1,
        title: 'Clase de conversación',
        participantName: 'María',
        unreadCount: 2, subject: '',
      );

      expect(thread.title, contains('Clase de conversación'));
      expect(thread.unreadCount, 2);
    });

    test('ForumThread serializa y deserialize correctamente', () {
      const thread = ForumThread(
        id: 1,
        title: 'Dudas de pronunciación',
        authorName: 'Luis',
        body: '¿Cómo pronuncio esta palabra?',
        postCount: 4,
      );

      final json = thread.toJson();
      final decoded = ForumThread.fromJson(json);

      expect(decoded.title, 'Dudas de pronunciación');
      expect(decoded.postCount, 4);
    });

    test('LiveSession expone estado y horario', () {
      final session = LiveSession(
        id: 1,
        title: 'Tutoría de speaking',
        hostName: 'Ana',
        startsAt: DateTime(2026, 7, 7, 20, 0),
        status: 'scheduled',
      );

      expect(session.status, 'scheduled');
      expect(session.title, contains('speaking'));
    });
  });


}
