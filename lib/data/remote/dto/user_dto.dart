class UserDto {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? role;
  final Map<String, dynamic>? profile;
  final bool isStaff;
  final bool isSuperuser;
  final bool isActive;
  final String? createdAt;

  UserDto({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.role,
    this.profile,
    this.isStaff = false,
    this.isSuperuser = false,
    this.isActive = true,
    this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      role: json['role']?.toString(),
      profile: json['profile'] as Map<String, dynamic>?,
      isStaff: json['is_staff'] as bool? ?? false,
      isSuperuser: json['is_superuser'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'profile': profile,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }
}
