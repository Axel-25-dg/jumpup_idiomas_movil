import 'package:jumpup_app/domain/model/user_profile_model.dart';

/// Roles que el backend puede devolver en el JWT o en /auth/me/
enum UserRole { admin, teacher, student, unknown }

class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.role = UserRole.unknown,
    this.profile,
    this.isStaff = false,
    this.isSuperuser = false,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final UserProfile? profile;
  final bool isStaff;
  final bool isSuperuser;
  final bool isActive;
  final DateTime? createdAt;

  /// Derived property for full name
  String get fullName => '$firstName $lastName'.trim();

  /// Get avatar URL - prioritize profile.avatarUrl, then other sources
  String? get avatarUrl {
    return profile?.avatarUrl ?? profile?.avatar;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final role = parseRole(json['role'] is Map<String, dynamic>
        ? json['role']['name']?.toString() ?? ''
        : json['role']?.toString() ?? '');

    // Parse profile
    UserProfile? profile;
    if (json['profile'] is Map<String, dynamic>) {
      profile = UserProfile.fromJson(json['profile']);
    }

    // Parse createdAt
    DateTime? createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.tryParse(json['created_at'].toString());
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      role: role,
      profile: profile,
      isStaff: json['is_staff'] as bool? ?? false,
      isSuperuser: json['is_superuser'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: createdAt,
    );
  }

  factory UserModel.fromJwtPayload(Map<String, dynamic> payload) {
    return UserModel(
      id: payload['user_id']?.toString() ?? payload['id']?.toString() ?? '',
      username: payload['username']?.toString() ?? payload['email']?.toString() ?? '',
      email: payload['email']?.toString() ?? '',
      firstName: payload['first_name']?.toString() ?? '',
      lastName: payload['last_name']?.toString() ?? '',
      role: parseRole(payload['role']?.toString() ?? payload['roles']?.toString() ?? ''),
      isStaff: payload['is_staff'] is bool
          ? payload['is_staff'] as bool
          : payload['is_staff']?.toString().toLowerCase() == 'true',
      isSuperuser: payload['is_superuser'] is bool
          ? payload['is_superuser'] as bool
          : payload['is_superuser']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role.name,
      'profile': profile,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static UserRole parseRole(Object? raw) {
    final str = raw?.toString().toLowerCase().trim() ?? '';
    if (str.isEmpty) return UserRole.student;

    if (str.contains('admin') || str.contains('administrador') || str.contains('superuser')) {
      return UserRole.admin;
    }
    if (str.contains('teacher') || str.contains('profesor') || str.contains('instructor') ||
        str.contains('assistant') || str.contains('staff')) {
      return UserRole.teacher;
    }
    if (str.contains('student') || str.contains('estudiante') || str.contains('learner') ||
        str.contains('user')) {
      return UserRole.student;
    }
    return UserRole.student;
  }
}
