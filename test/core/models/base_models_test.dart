import 'package:flutter_test/flutter_test.dart';
import 'package:jumpup_app/core/error/api_exception.dart';
import 'package:jumpup_app/domain/model/models.dart';
import 'package:jumpup_app/data/repository/base_repository.dart';

class _TestRepository extends BaseRepository {
  const _TestRepository();
}

void main() {
  group('UserModel', () {
    test('serializa y deserializa correctamente', () {
      const user = UserModel(
        id: '1',
        name: 'Ana',
        email: 'ana@example.com',
      );

      final json = user.toJson();
      final decoded = UserModel.fromJson(json);

      expect(decoded.id, '1');
      expect(decoded.name, 'Ana');
      expect(decoded.email, 'ana@example.com');
    });
  });

  group('ApiResponse', () {
    test('envuelve el payload y conserva los errores', () {
      final response = ApiResponse<String>.fromJson(
        {
          'success': true,
          'message': 'ok',
          'data': 'ok',
          'statusCode': 200,
          'errors': <dynamic>[],
        },
        fromJsonT: (value) => value.toString(),
      );

      expect(response.success, isTrue);
      expect(response.data, 'ok');
      expect(response.errors, isEmpty);
    });
  });

  test('BaseRepository convierte los errores en ApiException', () async {
    const repository = _TestRepository();

    await expectLater(
      repository.handleRequest<String>(() async => throw Exception('boom')),
      throwsA(isA<ApiException>()),
    );
  });
}
