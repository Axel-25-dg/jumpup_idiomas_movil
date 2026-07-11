/// Modelo de dominio que representa las estadísticas académicas de un estudiante.
/// Es una clase inmutable que ayuda a separar la API del resto de la lógica.
class UserStats {
  final int id;
  final int userId;
  final String userEmail;
  final int totalXp;
  final int currentStreak;
  final int longestStreak;

  UserStats({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
  });

  /// Factory para convertir el JSON de la API a nuestro modelo de dominio.
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      id: json['id'] as int,
      userId: json['user'] as int,
      userEmail: json['user_email'] as String,
      totalXp: json['total_xp'] as int,
      currentStreak: json['current_streak'] as int,
      longestStreak: json['longest_streak'] as int,
    );
  }
}
