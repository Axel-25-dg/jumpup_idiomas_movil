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
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      roleId: json['role']?['id'] ?? 0,
      roleName: json['role']?['name'] ?? 'N/A',
      isActive: json['is_active'] ?? true,
    );
  }
}