import 'package:jumpup_app/domain/model/user_model.dart';

class AuthTokenModel {
  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.user,
    this.requires2FA = false,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;

  /// Usuario incluido en la respuesta de login (evita una segunda llamada a /me/)
  final UserModel? user;

  /// true cuando el backend requiere verificación 2FA antes de entregar tokens
  final bool requires2FA;

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    // El backend puede indicar 2FA con { requires_2fa: true } sin tokens
    final needs2FA = json['requires_2fa'] == true;

    // El usuario puede venir dentro de la respuesta del login directamente
    UserModel? user;
    final userJson = json['user'];
    if (userJson is Map<String, dynamic>) {
      user = UserModel.fromJson(userJson);
    }

    return AuthTokenModel(
      accessToken: json['access']?.toString() ??
          json['accessToken']?.toString() ??
          json['token']?.toString() ??
          '',
      refreshToken: json['refresh']?.toString() ??
          json['refreshToken']?.toString() ??
          '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      user: user,
      requires2FA: needs2FA,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}
