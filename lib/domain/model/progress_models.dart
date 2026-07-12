// Modelos del módulo de Progreso y Gamificación
// Cubre: UserProgress, UserStats, Achievement, UserAchievement, Ranking

// ─── UserProgress ─────────────────────────────────────────────────────────────

class UserProgressModel {
  const UserProgressModel({
    required this.id,
    required this.user,
    required this.userEmail,
    required this.lesson,
    required this.lessonTitle,
    required this.lessonXp,
    required this.courseTitle,
    required this.languageCode,
    required this.status,
    this.score = 0.0,
    this.completedAt,
  });

  final int id;
  final int user;
  final String userEmail;
  final int lesson;
  final String lessonTitle;
  final int lessonXp;
  final String courseTitle;
  final String languageCode;
  final String status; // 'in_progress' | 'completed'
  final double score;
  final DateTime? completedAt;

  bool get isCompleted => status == 'completed';

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      id: json['id'] as int,
      user: json['user'] as int,
      userEmail: json['user_email'] as String,
      lesson: json['lesson'] as int,
      lessonTitle: json['lesson_title'] as String? ?? '',
      lessonXp: json['lesson_xp'] as int? ?? 0,
      courseTitle: json['course_title'] as String? ?? '',
      languageCode: json['language_code'] as String? ?? '',
      status: json['status']?.toString() ?? 'in_progress',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user,
        'user_email': userEmail,
        'lesson': lesson,
        'lesson_title': lessonTitle,
        'lesson_xp': lessonXp,
        'course_title': courseTitle,
        'language_code': languageCode,
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
    required this.xpProgressInLevel,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
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
  final int xpProgressInLevel;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
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
      xpProgressInLevel: int.tryParse(json['xp_progress_in_level']?.toString() ?? '0') ?? 0,
      currentStreak: int.tryParse(json['current_streak']?.toString() ?? json['streak']?.toString() ?? '0') ?? 0,
      longestStreak: int.tryParse(json['longest_streak']?.toString() ?? '0') ?? 0,
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.tryParse(json['last_activity_date'] as String)
          : null,
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
    required this.xpProgressInLevel,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
  });

  final int totalXp;
  final int level;
  final int xpForNextLevel;
  final int xpProgress;
  final int xpProgressInLevel;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;

  /// Porcentaje de progreso hacia el siguiente nivel (0.0 a 1.0).
  double get levelProgress =>
      xpForNextLevel > 0 ? xpProgress / xpForNextLevel : 0.0;

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalXp: int.tryParse(json['total_xp']?.toString() ?? json['xp']?.toString() ?? '0') ?? 0,
      level: int.tryParse(json['level']?.toString() ?? '1') ?? 1,
      xpForNextLevel: int.tryParse(json['xp_for_next_level']?.toString() ?? '100') ?? 100,
      xpProgress: int.tryParse(json['xp_progress']?.toString() ?? '0') ?? 0,
      xpProgressInLevel: int.tryParse(json['xp_progress_in_level']?.toString() ?? '0') ?? 0,
      currentStreak: int.tryParse(json['current_streak']?.toString() ?? json['streak']?.toString() ?? '0') ?? 0,
      longestStreak: int.tryParse(json['longest_streak']?.toString() ?? '0') ?? 0,
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.tryParse(json['last_activity_date'] as String)
          : null,
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
    this.triggerType,
    this.requiredValue,
    this.createdAt,
  });

  final int id;
  final String name;
  final String description;
  final int requiredXp;
  final String? iconUrl;
  final bool isActive;
  final String? triggerType; // Por XP acumulado, etc.
  final int? requiredValue;
  final DateTime? createdAt;

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      requiredXp: int.tryParse(json['required_xp']?.toString() ?? '0') ?? 0,
      iconUrl: json['icon_url']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      triggerType: json['trigger_type']?.toString(),
      requiredValue: int.tryParse(json['required_value']?.toString() ?? '0'),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'required_xp': requiredXp,
        'icon_url': iconUrl,
        'is_active': isActive,
        'trigger_type': triggerType,
        'required_value': requiredValue,
        'created_at': createdAt?.toIso8601String(),
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
    required this.longestStreak,
    required this.isMe,
  });

  final int position;
  final int userId;
  final String username;
  final String email;
  final int totalXp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final bool isMe;

  factory RankingEntryModel.fromJson(Map<String, dynamic> json) {
    return RankingEntryModel(
      position: json['position'] as int,
      userId: json['user_id'] as int,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      totalXp: json['total_xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      isMe: json['is_me'] as bool? ?? false,
    );
  }
}

// ─── Ranking ─────────────────────────────────────────────────────────────────

class RankingModel {
  const RankingModel({
    required this.myPosition,
    required this.myXp,
    required this.myLevel,
    required this.ranking,
  });

  final int myPosition;
  final int myXp;
  final int myLevel;
  final List<RankingEntryModel> ranking;

  factory RankingModel.fromJson(Map<String, dynamic> json) {
    return RankingModel(
      myPosition: json['my_position'] as int? ?? 0,
      myXp: json['my_xp'] as int? ?? 0,
      myLevel: json['my_level'] as int? ?? 1,
      ranking: (json['ranking'] as List<dynamic>?)
              ?.map((e) => RankingEntryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// ─── ProgressByLanguage ──────────────────────────────────────────────────────

class ProgressByLanguage {
  const ProgressByLanguage({
    required this.languageId,
    required this.languageName,
    required this.languageCode,
    this.flagUrl,
    required this.totalLessons,
    required this.completed,
    required this.percentage,
  });

  final int languageId;
  final String languageName;
  final String languageCode;
  final String? flagUrl;
  final int totalLessons;
  final int completed;
  final double percentage;

  factory ProgressByLanguage.fromJson(Map<String, dynamic> json) {
    return ProgressByLanguage(
      languageId: json['language_id'] as int? ?? 0,
      languageName: json['language_name']?.toString() ?? '',
      languageCode: json['language_code']?.toString() ?? '',
      flagUrl: json['flag_url']?.toString(),
      totalLessons: json['total_lessons'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
