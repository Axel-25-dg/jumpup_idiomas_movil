// Modelos del módulo de Progreso y Gamificación
// Cubre: UserProgress, UserStats, Achievement, UserAchievement, Ranking

// ─── UserProgress ─────────────────────────────────────────────────────────────

class UserProgressModel {
  const UserProgressModel({
    required this.id,
    required this.lesson,
    required this.status,
    this.score = 0.0,
    this.completedAt,
  });

  final int id;
  final int lesson;
  final String status; // 'in_progress' | 'completed'
  final double score;
  final DateTime? completedAt;

  bool get isCompleted => status == 'completed';

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      id: json['id'] as int,
      lesson: json['lesson'] as int,
      status: json['status']?.toString() ?? 'in_progress',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lesson': lesson,
        'status': status,
        'score': score,
        'completed_at': completedAt?.toIso8601String(),
      };
}

// ─── ProgressSummary ──────────────────────────────────────────────────────────

class ProgressSummaryModel {
  const ProgressSummaryModel({
    required this.totalLessons,
    required this.lessonsCompleted,
    required this.lessonsInProgress,
    required this.coursesStarted,
    required this.coursesCompleted,
    required this.percentage,
    required this.totalXp,
    required this.level,
    required this.xpForNextLevel,
    required this.xpProgress,
    required this.currentStreak,
    required this.longestStreak,
    required this.achievementsCount,
  });

  final int totalLessons;
  final int lessonsCompleted;
  final int lessonsInProgress;
  final int coursesStarted;
  final int coursesCompleted;
  final double percentage;
  final int totalXp;
  final int level;
  final int xpForNextLevel;
  final int xpProgress;
  final int currentStreak;
  final int longestStreak;
  final int achievementsCount;

  factory ProgressSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProgressSummaryModel(
      totalLessons: int.tryParse(json['total_lessons']?.toString() ?? '0') ?? 0,
      lessonsCompleted: int.tryParse(json['lessons_completed']?.toString() ?? '0') ?? 0,
      lessonsInProgress: int.tryParse(json['lessons_in_progress']?.toString() ?? '0') ?? 0,
      coursesStarted: int.tryParse(json['courses_started']?.toString() ?? '0') ?? 0,
      coursesCompleted: int.tryParse(json['courses_completed']?.toString() ?? '0') ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      totalXp: int.tryParse(json['total_xp']?.toString() ?? json['xp']?.toString() ?? '0') ?? 0,
      level: int.tryParse(json['level']?.toString() ?? '1') ?? 1,
      xpForNextLevel: int.tryParse(json['xp_for_next_level']?.toString() ?? '100') ?? 100,
      xpProgress: int.tryParse(json['xp_progress']?.toString() ?? '0') ?? 0,
      currentStreak: int.tryParse(json['current_streak']?.toString() ?? json['streak']?.toString() ?? '0') ?? 0,
      longestStreak: int.tryParse(json['longest_streak']?.toString() ?? '0') ?? 0,
      achievementsCount: int.tryParse(json['achievements_count']?.toString() ?? '0') ?? 0,
    );
  }

}

// ─── UserStats ────────────────────────────────────────────────────────────────

class UserStatsModel {
  const UserStatsModel({
    required this.totalXp,
    required this.level,
    required this.xpForNextLevel,
    required this.xpProgress,
    required this.currentStreak,
    required this.longestStreak,
  });

  final int totalXp;
  final int level;
  final int xpForNextLevel;
  final int xpProgress;
  final int currentStreak;
  final int longestStreak;

  /// Porcentaje de progreso hacia el siguiente nivel (0.0 a 1.0).
  double get levelProgress =>
      xpForNextLevel > 0 ? xpProgress / xpForNextLevel : 0.0;

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalXp: int.tryParse(json['total_xp']?.toString() ?? json['xp']?.toString() ?? '0') ?? 0,
      level: int.tryParse(json['level']?.toString() ?? '1') ?? 1,
      xpForNextLevel: int.tryParse(json['xp_for_next_level']?.toString() ?? '100') ?? 100,
      xpProgress: int.tryParse(json['xp_progress']?.toString() ?? '0') ?? 0,
      currentStreak: int.tryParse(json['current_streak']?.toString() ?? json['streak']?.toString() ?? '0') ?? 0,
      longestStreak: int.tryParse(json['longest_streak']?.toString() ?? '0') ?? 0,
    );
  }

}

// ─── Achievement ──────────────────────────────────────────────────────────────

class AchievementModel {
  const AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredXp,
    this.iconUrl,
    this.isActive = true,
  });

  final int id;
  final String name;
  final String description;
  final int requiredXp;
  final String? iconUrl;
  final bool isActive;

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      requiredXp: json['required_xp'] as int? ?? 0,
      iconUrl: json['icon_url']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'required_xp': requiredXp,
        'icon_url': iconUrl,
        'is_active': isActive,
      };
}

// ─── UserAchievement ──────────────────────────────────────────────────────────

class UserAchievementModel {
  const UserAchievementModel({
    required this.id,
    required this.achievement,
    required this.unlockedAt,
  });

  final int id;
  final AchievementModel achievement;
  final DateTime unlockedAt;

  factory UserAchievementModel.fromJson(Map<String, dynamic> json) {
    return UserAchievementModel(
      id: json['id'] as int,
      achievement: AchievementModel.fromJson(
          json['achievement'] as Map<String, dynamic>),
      unlockedAt: DateTime.tryParse(json['unlocked_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

// ─── RankingEntry ─────────────────────────────────────────────────────────────

class RankingEntryModel {
  const RankingEntryModel({
    required this.position,
    required this.userId,
    required this.username,
    required this.email,
    required this.totalXp,
    required this.level,
    required this.currentStreak,
  });

  final int position;
  final int userId;
  final String username;
  final String email;
  final int totalXp;
  final int level;
  final int currentStreak;

  factory RankingEntryModel.fromJson(Map<String, dynamic> json) {
    return RankingEntryModel(
      position: json['position'] as int,
      userId: json['user_id'] as int,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      totalXp: json['total_xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      currentStreak: json['current_streak'] as int? ?? 0,
    );
  }
}
