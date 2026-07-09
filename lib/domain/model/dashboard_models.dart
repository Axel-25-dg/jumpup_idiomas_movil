// Modelos del módulo de Dashboard y Usuarios
// Cubre: UserProfile, DashboardSummary, ActivityLog

// ─── UserProfile ──────────────────────────────────────────────────────────────

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.nativeLanguage,
    this.learningLanguages = const [],
    this.bio,
    required this.joinedAt,
    this.timezone,
  });

  final int id;
  final int userId;
  final String username;
  final String email;
  final String? avatarUrl;
  final String nativeLanguage;
  final List<String> learningLanguages;
  final String? bio;
  final DateTime joinedAt;
  final String? timezone;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      nativeLanguage: json['native_language']?.toString() ?? 'ES',
      learningLanguages: (json['learning_languages'] as List?)?.map((e) => e.toString()).toList() ?? [],
      bio: json['bio']?.toString(),
      joinedAt: DateTime.tryParse(json['joined_at']?.toString() ?? '') ?? DateTime.now(),
      timezone: json['timezone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'username': username,
        'email': email,
        'avatar_url': avatarUrl,
        'native_language': nativeLanguage,
        'learning_languages': learningLanguages,
        'bio': bio,
        'joined_at': joinedAt.toIso8601String(),
        'timezone': timezone,
      };
}

// ─── DashboardSummary ─────────────────────────────────────────────────────────

class DashboardSummaryModel {
  const DashboardSummaryModel({
    required this.activeCourses,
    required this.totalXp,
    required this.currentStreak,
    required this.todayGoalProgress,
    required this.upcomingClasses,
    required this.recentActivities,
  });

  final int activeCourses;
  final int totalXp;
  final int currentStreak;
  final double todayGoalProgress; // 0.0 to 1.0
  final int upcomingClasses;
  final List<ActivityLogModel> recentActivities;

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      activeCourses: json['active_courses'] as int? ?? 0,
      totalXp: json['total_xp'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      todayGoalProgress: (json['today_goal_progress'] as num?)?.toDouble() ?? 0.0,
      upcomingClasses: json['upcoming_classes'] as int? ?? 0,
      recentActivities: (json['recent_activities'] as List?)
              ?.map((e) => ActivityLogModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// ─── ActivityLog ──────────────────────────────────────────────────────────────

class ActivityLogModel {
  const ActivityLogModel({
    required this.id,
    required this.activityType,
    required this.description,
    required this.createdAt,
    this.relatedId,
  });

  final int id;
  final String activityType; // 'lesson_completed', 'achievement_unlocked', 'course_started'
  final String description;
  final DateTime createdAt;
  final int? relatedId;

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] as int,
      activityType: json['activity_type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      relatedId: json['related_id'] as int?,
    );
  }
}
