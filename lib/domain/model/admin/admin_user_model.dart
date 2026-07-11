class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final int roleId;
  final String roleName;
  final bool isActive;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roleId,
    required this.roleName,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final role = json['role'];
    return User(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      roleId: role is Map ? int.tryParse(role['id']?.toString() ?? '') ?? 0 : 0,
      roleName: role is Map
          ? role['name']?.toString() ?? 'N/A'
          : role?.toString() ?? 'N/A',
      isActive: json['is_active'] ?? true,
    );
  }
}
