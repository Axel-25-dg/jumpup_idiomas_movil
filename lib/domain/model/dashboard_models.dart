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
    // /auth/me/ puede devolver el perfil directamente o anidado en 'profile'
    final profile = json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : json;

    return UserProfileModel(
      id: (profile['id'] ?? json['id'] ?? 0) as int,
      userId: (json['id'] ?? profile['user_id'] ?? profile['user'] ?? 0) as int,
      username:
          json['username']?.toString() ?? profile['username']?.toString() ?? '',
      email: json['email']?.toString() ?? profile['email']?.toString() ?? '',
      avatarUrl: profile['avatar_url']?.toString() ??
          profile['avatar']?.toString() ??
          json['avatar_url']?.toString(),
      nativeLanguage: profile['native_language']?.toString() ??
          json['native_language']?.toString() ??
          'ES',
      learningLanguages: (profile['languages_learning'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['languages_learning'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      bio: profile['bio']?.toString() ?? json['bio']?.toString(),
      joinedAt: DateTime.tryParse(profile['date_joined']?.toString() ??
              json['date_joined']?.toString() ??
              profile['joined_at']?.toString() ??
              json['joined_at']?.toString() ??
              '') ??
          DateTime.now(),
      timezone: profile['timezone']?.toString() ?? json['timezone']?.toString(),
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
      activeCourses: json['active_courses'] as int? ??
          json['courses_enrolled'] as int? ??
          json['enrollments'] as int? ??
          0,
      totalXp: json['total_xp'] as int? ?? json['xp'] as int? ?? 0,
      currentStreak:
          json['current_streak'] as int? ?? json['streak'] as int? ?? 0,
      todayGoalProgress: (json['today_goal_progress'] as num?)?.toDouble() ??
          (json['progress_today'] as num?)?.toDouble() ??
          0.0,
      upcomingClasses: json['upcoming_classes'] as int? ??
          json['upcoming_sessions'] as int? ??
          json['next_classes'] as int? ??
          0,
      recentActivities: (json['recent_activities'] as List?)
              ?.map((e) => ActivityLogModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['activities'] as List?)
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
  final String
      activityType; // 'lesson_completed', 'achievement_unlocked', 'course_started'
  final String description;
  final DateTime createdAt;
  final int? relatedId;

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] as int,
      activityType: json['activity_type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      relatedId: json['related_id'] as int?,
    );
  }
}
