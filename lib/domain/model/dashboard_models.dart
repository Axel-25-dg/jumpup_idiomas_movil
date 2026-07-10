// Modelos del módulo de Dashboard y Usuarios
// Cubre: UserProfile, DashboardSummary, ActivityLog

// ─── UserProfile ──────────────────────────────────────────────────────────────

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.username,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.avatarUrl,
    this.nativeLanguageId,
    this.languagesLearning = const [],
    this.languagesTeaching = const [],
  });

  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final int? nativeLanguageId;
  final List<int> languagesLearning;
  final List<int> languagesTeaching;

  String get fullName {
    final parts = [firstName, lastName].where((s) => s.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(' ') : username;
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : <String, dynamic>{};

    return UserProfileModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      username: (json['username'] ?? 'Usuario').toString(),
      email: (json['email'] ?? '').toString(),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      avatarUrl: (profile['avatar_url'] ?? profile['avatar'])?.toString(),
      nativeLanguageId: profile['native_language'] is int
          ? profile['native_language'] as int
          : int.tryParse(profile['native_language']?.toString() ?? ''),
      languagesLearning: (profile['languages_learning'] as List?)
              ?.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
              .where((e) => e > 0)
              .toList() ??
          const [],
      languagesTeaching: (profile['languages_teaching'] as List?)
              ?.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
              .where((e) => e > 0)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'profile': {
          if (nativeLanguageId != null) 'native_language': nativeLanguageId,
          'languages_learning': languagesLearning,
          'languages_teaching': languagesTeaching,
        },
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
  final double todayGoalProgress;
  final int upcomingClasses;
  final List<ActivityLogModel> recentActivities;

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      activeCourses: int.tryParse(json['active_courses']?.toString() ??
              json['courses_enrolled']?.toString() ??
              json['enrollments']?.toString() ??
              '0') ??
          0,
      totalXp: int.tryParse(
              json['total_xp']?.toString() ?? json['xp']?.toString() ?? '0') ??
          0,
      currentStreak: int.tryParse(json['current_streak']?.toString() ??
              json['streak']?.toString() ??
              '0') ??
          0,
      todayGoalProgress: (json['today_goal_progress'] as num?)?.toDouble() ??
          (json['progress_today'] as num?)?.toDouble() ??
          0.0,
      upcomingClasses: int.tryParse(json['upcoming_classes']?.toString() ??
              json['upcoming_sessions']?.toString() ??
              json['next_classes']?.toString() ??
              '0') ??
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
  final String activityType;
  final String description;
  final DateTime createdAt;
  final int? relatedId;

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      activityType: json['activity_type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      relatedId: int.tryParse(json['related_id']?.toString() ?? ''),
    );
  }
}
