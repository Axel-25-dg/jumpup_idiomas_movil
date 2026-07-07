enum UserRole { student, teacher, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final List<String> targetLanguages; // Idiomas que el estudiante aprende
  final List<String> teachingLanguages; // Idiomas que el docente enseña
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.targetLanguages = const [],
    this.teachingLanguages = const [],
    this.avatarUrl,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    List<String>? targetLanguages,
    List<String>? teachingLanguages,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      targetLanguages: targetLanguages ?? this.targetLanguages,
      teachingLanguages: teachingLanguages ?? this.teachingLanguages,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
