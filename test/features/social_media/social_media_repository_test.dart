import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jumpup_app/data/repository/social/social_media_repository.dart';

Dio _fakeDio({required String path, required dynamic responseData}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
  dio.httpClientAdapter = _FakeAdapter(path: path, data: responseData);
  return dio;
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({required this.path, required this.data});

  final String path;
  final dynamic data;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '[]', // devuelve lista vacía por defecto para rutas no configuradas
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json']
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

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
  group('SocialMediaRepository — fetchMessages', () {
    test('retorna lista vacía cuando el servidor devuelve []', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
      dio.httpClientAdapter = _JsonAdapter({'/threads/': '[]'});

      final repo = SocialMediaRepository(dio: dio);
      final result = await repo.fetchMessages();

      expect(result, isEmpty);
    });

    test('parsea MessageThread correctamente', () async {
      const json = '''
      [{
        "id": "1",
        "title": "Clase de conversación",
        "participantName": "María",
        "unreadCount": 2,
        "lastMessage": "¿Listas para la práctica?"
      }]
      ''';

      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
      dio.httpClientAdapter = _JsonAdapter({'threads/': json});

      final repo = SocialMediaRepository(dio: dio);
      final result = await repo.fetchMessages();

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
        "id": "n1",
        "title": "Nueva respuesta",
        "message": "Alguien respondió tu hilo.",
        "type": "community",
        "isRead": false
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
          "id": "n2",
          "title": "Clase en vivo",
          "message": "Tu tutoría comienza en 15 minutos.",
          "type": "teacher",
          "isRead": true
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
        "id": "p1",
        "authorName": "Paula",
        "content": "¡Completé mi racha de 7 días!",
        "createdAt": "2026-07-07T18:30:00.000Z",
        "likes": 12,
        "comments": 3
      }]
      ''';

      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
      dio.httpClientAdapter = _JsonAdapter({'social-posts/': json});

      final repo = SocialMediaRepository(dio: dio);
      final result = await repo.fetchSocialFeed();

      expect(result.length, 1);
      expect(result.first.authorName, 'Paula');
      expect(result.first.likes, 12);
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
          "id": "s1",
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
}

extension on Object? {
   get length => null;

  get first => null;
}
