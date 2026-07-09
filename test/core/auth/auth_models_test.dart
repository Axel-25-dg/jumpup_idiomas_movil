import 'package:flutter_test/flutter_test.dart';
import 'package:jumpup_app/domain/model/login_request.dart';
import 'package:jumpup_app/domain/model/register_request.dart';
import 'package:jumpup_app/domain/model/forgot_password_request.dart';
import 'package:jumpup_app/domain/model/two_factor_request.dart';
import 'package:jumpup_app/domain/model/auth_token_model.dart';

void main() {
  group('auth models', () {
    test('LoginRequest serializa correctamente', () {
      final request =
          LoginRequest(email: 'ana@example.com', password: '123456');
      final json = request.toJson();

      expect(json['email'], 'ana@example.com');
      expect(json['password'], '123456');
    });

    test('RegisterRequest serializa correctamente', () {
      final request = RegisterRequest(
        firstName: 'Ana',
        lastName: 'García',
        username: 'ana_garcia',
        email: 'ana@example.com',
        password: 'secret123',
        confirmPassword: 'secret123',
      );
      final json = request.toJson();

      expect(json['first_name'], 'Ana');
      expect(json['last_name'], 'García');
      expect(json['email'], 'ana@example.com');
    });

    test('ForgotPasswordRequest serializa correctamente', () {
      final request = ForgotPasswordRequest(email: 'ana@example.com');
      final json = request.toJson();

      expect(json['email'], 'ana@example.com');
    });

    test('TwoFactorRequest serializa correctamente', () {
      final request = TwoFactorRequest(code: '123456');
      final json = request.toJson();

      expect(json['code'], '123456');
    });

    test('AuthTokenModel deserializa correctamente', () {
      final token = AuthTokenModel.fromJson({
        'accessToken': 'abc',
        'refreshToken': 'def',
        'expiresAt': '2026-01-01T00:00:00.000Z',
      });

      expect(token.accessToken, 'abc');
      expect(token.refreshToken, 'def');
      expect(token.expiresAt, isNotNull);
    });
  });
}
