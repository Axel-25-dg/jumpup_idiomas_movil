/// Roles que el backend puede devolver en el JWT o en /auth/me/
enum UserRole { admin, teacher, student, unknown }

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.role = UserRole.unknown,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final UserRole role;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ??
          json['full_name']?.toString() ??
          json['username']?.toString() ??
          '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ??
          json['avatar']?.toString() ??
          json['profile_picture']?.toString(),
      role: _parseRole(json['role'] ?? json['user_type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'role': role.name,
    };
  }

  static UserRole _parseRole(Object? raw) {
    final value = raw is Map
        ? (raw['name'] ?? raw['code'] ?? raw['slug'] ?? raw['role'])
        : raw;

    switch (value?.toString().toLowerCase()) {
      case 'admin':
      case 'administrator':
      case 'administrador':
        return UserRole.admin;
      case 'teacher':
      case 'profesor':
      case 'instructor':
      case 'assistant_teacher':
        return UserRole.teacher;
      case 'student':
      case 'estudiante':
      case 'learner':
      case 'premium_student':
        return UserRole.student;
      default:
        return UserRole.unknown;
    }
  }
}
