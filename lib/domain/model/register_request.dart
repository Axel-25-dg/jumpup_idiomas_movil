class RegisterRequest {
  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.role = 'student',
    this.acceptTerms = true,
  });

  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final String role;
  final bool acceptTerms;

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'password': password,
      'password2': confirmPassword,
      'role': role,
    };
  }
}
