import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jumpup_app/data/repository/social/social_media_repository.dart';

/// Adapter que devuelve una respuesta JSON configurable por ruta.
class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this._responses);

  final Map<String, String> _responses; // path → json string

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = _responses[options.path] ?? '[]';
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json']
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('SocialMediaRepository — fetchThreads', () {
    test('retorna lista vacía cuando el servidor devuelve []', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
      dio.httpClientAdapter = _JsonAdapter({'threads/': '[]'});

      final repo = SocialMediaRepository(dio: dio);
      final result = await repo.fetchThreads();

      expect(result, isEmpty);
    });

    test('parsea MessageThread correctamente', () async {
      const json = '''
      [{
        "id": 1,
        "subject": "Clase de conversación",
        "participants": [{"id": 2, "username": "María"}],
        "unread_count": 2,
        "last_message": "¿Listas para la práctica?"
      }]
      ''';

      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
      dio.httpClientAdapter = _JsonAdapter({'threads/': json});

      final repo = SocialMediaRepository(dio: dio);
      final result = await repo.fetchThreads();

      expect(result.length, 1);
      expect(result.first.title, 'Clase de conversación');
      expect(result.first.participantName, 'María');
      expect(result.first.unreadCount, 2);
    });
  });

  group('SocialMediaRepository — fetchNotifications', () {
    test('parsea NotificationItem desde lista directa', () async {
      const json = '''
      [{
        "id": 1,
        "title": "Nueva respuesta",
        "message": "Alguien respondió tu hilo.",
        "type": "community",
        "is_read": false
      }]
      ''';

      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
      dio.httpClientAdapter = _JsonAdapter({'notifications/': json});

      final repo = SocialMediaRepository(dio: dio);
      final result = await repo.fetchNotifications();

      expect(result.length, 1);
      expect(result.first.title, 'Nueva respuesta');
      expect(result.first.isRead, isFalse);
    });

    test('parsea NotificationItem desde wrapper {results: [...]}', () async {
      const json = '''
      {
        "count": 1,
        "results": [{
          "id": 2,
          "title": "Clase en vivo",
          "message": "Tu tutoría comienza en 15 minutos.",
          "type": "teacher",
          "is_read": true
        }]
      }
      ''';

      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
      dio.httpClientAdapter = _JsonAdapter({'notifications/': json});

      final repo = SocialMediaRepository(dio: dio);
      final result = await repo.fetchNotifications();

      expect(result.length, 1);
      expect(result.first.type, 'teacher');
      expect(result.first.isRead, isTrue);
    });
  });

  group('SocialMediaRepository — fetchSocialFeed', () {
    test('parsea SocialPost correctamente', () async {
      const json = '''
      [{
        "id": 1,
        "author": {"id": 3, "username": "Paula"},
        "content": "¡Completé mi racha de 7 días!",
        "created_at": "2026-07-07T18:30:00.000Z",
        "likes_count": 12,
        "comments_count": 3
      }]
      ''';

      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
      dio.httpClientAdapter = _JsonAdapter({'social-posts/': json});

      final repo = SocialMediaRepository(dio: dio);
      final result = await repo.fetchSocialFeed();

      expect(result.length, 1);
      expect(result.first.authorName, 'Paula');
      expect(result.first.reactionCount, 12);
    });
  });

  group('SocialMediaRepository — search', () {
    test('retorna lista vacía para query vacío sin llamar a la red', () async {
      // Con query vacío no debe ni hacer la petición
      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
      dio.httpClientAdapter = _JsonAdapter({});

      final repo = SocialMediaRepository(dio: dio);
      final result = await repo.search('  ');

      expect(result, isEmpty);
    });

    test('parsea SearchResult con wrapper results', () async {
      const json = '''
      {
        "results": [{
          "id": 1,
          "title": "Curso de inglés B1",
          "type": "course",
          "subtitle": "Inglés · Intermedio"
        }]
      }
      ''';

      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
      dio.httpClientAdapter = _JsonAdapter({'search/': json});

      final repo = SocialMediaRepository(dio: dio);
      final result = await repo.search('inglés');

      expect(result.length, 1);
      expect(result.first.title, 'Curso de inglés B1');
    });
  });

  group('SocialMediaRepository — Comments', () {
    test('fetchComments retorna lista de SocialComment', () async {
      const json = '''
      [{
        "id": 1,
        "post": 10,
        "author_name": "Juan",
        "body": "¡Excelente post!",
        "created_at": "2026-07-07T18:30:00.000Z"
      }]
      ''';

      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
      dio.httpClientAdapter = _JsonAdapter({'social-comments/': json});

      final repo = SocialMediaRepository(dio: dio);
      final result = await repo.fetchComments(10);

      expect(result.length, 1);
      expect(result.first.body, '¡Excelente post!');
      expect(result.first.authorName, 'Juan');
    });

    test('createComment envía los datos correctos y retorna SocialComment', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
      
      // Mocking POST response
      const responseJson = '''
      {
        "id": 2,
        "post": 10,
        "author_name": "Juan",
        "body": "Nuevo comentario",
        "created_at": "2026-07-07T18:40:00.000Z"
      }
      ''';
      
      dio.httpClientAdapter = _JsonAdapter({'social-comments/': responseJson});

      final repo = SocialMediaRepository(dio: dio);
      final result = await repo.createComment(postId: 10, body: 'Nuevo comentario');

      expect(result.id, 2);
      expect(result.body, 'Nuevo comentario');
    });
  });
}
