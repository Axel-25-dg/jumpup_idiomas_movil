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
    int toInt(dynamic val, [int def = 0]) {
      if (val == null) return def;
      if (val is num) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? def;
      return def;
    }

    return UserProgressModel(
      id: toInt(json['id']),
      user: toInt(json['user'] ?? json['usuario']),
      userEmail: json['user_email']?.toString() ?? json['email']?.toString() ?? '',
      lesson: toInt(json['lesson'] ?? json['leccion'] ?? json['lesson_id']),
      lessonTitle: json['lesson_title']?.toString() ?? json['leccion_titulo']?.toString() ?? '',
      lessonXp: toInt(json['lesson_xp'] ?? json['xp'] ?? json['puntos']),
      courseTitle: json['course_title']?.toString() ?? '',
      languageCode: json['language_code']?.toString() ?? '',
      status: json['status']?.toString() ?? 'in_progress',
      score: (json['score'] as num?)?.toDouble() ?? (json['puntaje'] as num?)?.toDouble() ?? 0.0,
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
    int toInt(dynamic val, [int def = 0]) {
      if (val == null) return def;
      if (val is num) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? def;
      return def;
    }

    final totalXp = toInt(json['total_xp'] ?? json['xp'] ?? json['points'] ?? json['total_points'] ?? json['puntos_totales'] ?? json['puntos']);
    final level = toInt(json['level'] ?? json['current_level'] ?? json['nivel'], (totalXp ~/ 100) + 1);
    
    // Resilient XP progress calculation
    int xpForNext = toInt(json['xp_for_next_level'] ?? json['next_level_xp'] ?? json['xp_siguiente_nivel'], 100);
    if (xpForNext <= 0) xpForNext = 100;

    int xpProg = toInt(json['xp_progress'] ?? json['current_xp'] ?? json['xp_actual'], -1);
    if (xpProg == -1) {
      xpProg = totalXp % xpForNext;
    }

    return ProgressSummaryModel(
      totalLessons: toInt(json['total_lessons'] ?? json['lessons_count'] ?? json['lecciones_totales']),
      lessonsCompleted: toInt(json['lessons_completed'] ?? json['completed_lessons'] ?? json['lecciones_completadas']),
      lessonsInProgress: toInt(json['lessons_in_progress'] ?? json['lecciones_en_progreso']),
      coursesStarted: toInt(json['courses_started'] ?? json['cursos_empezados']),
      coursesCompleted: toInt(json['courses_completed'] ?? json['cursos_completados']),
      percentage: (json['percentage'] as num?)?.toDouble() ?? (json['progreso'] as num?)?.toDouble() ?? 0.0,
      totalXp: totalXp,
      level: level > 0 ? level : 1,
      xpForNextLevel: xpForNext,
      xpProgress: xpProg,
      xpProgressInLevel: toInt(json['xp_progress_in_level'] ?? json['level_progress'] ?? json['progreso_nivel'], xpProg),
      currentStreak: toInt(json['current_streak'] ?? json['streak'] ?? json['streak_count'] ?? json['racha_actual']),
      longestStreak: toInt(json['longest_streak'] ?? json['max_streak'] ?? json['racha_maxima']),
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.tryParse(json['last_activity_date'].toString())
          : null,
      achievementsCount: toInt(json['achievements_count'] ?? json['badges_count'] ?? json['logros_count']),
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

  /// Retorna un modelo de estadísticas vacío (valores en cero).
  factory UserStatsModel.empty() {
    return const UserStatsModel(
      totalXp: 0,
      level: 1,
      xpForNextLevel: 100,
      xpProgress: 0,
      xpProgressInLevel: 0,
      currentStreak: 0,
      longestStreak: 0,
      lastActivityDate: null,
    );
  }

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val, [int def = 0]) {
      if (val == null) return def;
      if (val is num) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? def;
      return def;
    }

    final totalXp = toInt(json['total_xp'] ?? json['xp'] ?? json['points'] ?? json['total_points'] ?? json['puntos_totales'] ?? json['puntos']);
    final level = toInt(json['level'] ?? json['current_level'] ?? json['nivel'], (totalXp ~/ 100) + 1);
    
    // Resilient XP progress calculation
    int xpForNext = toInt(json['xp_for_next_level'] ?? json['next_level_xp'] ?? json['xp_siguiente_nivel'], 100);
    if (xpForNext <= 0) xpForNext = 100;

    int xpProg = toInt(json['xp_progress'] ?? json['current_xp'] ?? json['xp_actual'], -1);
    if (xpProg == -1) {
      xpProg = totalXp % xpForNext;
    }

    return UserStatsModel(
      totalXp: totalXp,
      level: level > 0 ? level : 1,
      xpForNextLevel: xpForNext,
      xpProgress: xpProg,
      xpProgressInLevel: toInt(json['xp_progress_in_level'] ?? json['level_progress'] ?? json['progreso_nivel'], xpProg),
      currentStreak: toInt(json['current_streak'] ?? json['streak'] ?? json['streak_count'] ?? json['racha_actual']),
      longestStreak: toInt(json['longest_streak'] ?? json['max_streak'] ?? json['racha_maxima']),
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.tryParse(json['last_activity_date'].toString())
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
    int toInt(dynamic val, [int def = 0]) {
      if (val == null) return def;
      if (val is num) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? def;
      return def;
    }
    return AchievementModel(
      id: toInt(json['id']),
      name: json['name']?.toString() ?? json['nombre']?.toString() ?? '',
      description: json['description']?.toString() ?? json['descripcion']?.toString() ?? '',
      requiredXp: toInt(json['required_xp'] ?? json['xp_requerido']),
      iconUrl: json['icon_url']?.toString() ?? json['imagen']?.toString() ?? json['icon']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['activo'] == true,
      triggerType: json['trigger_type']?.toString() ?? json['tipo']?.toString(),
      requiredValue: toInt(json['required_value'] ?? json['valor_requerido']),
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
      id: json['id'] as int? ?? 0,
      achievement: AchievementModel.fromJson(
          json['achievement'] as Map<String, dynamic>? ?? json['logro'] as Map<String, dynamic>? ?? {}),
      unlockedAt: DateTime.tryParse(json['unlocked_at']?.toString() ?? json['fecha_desbloqueo']?.toString() ?? '') ??
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
    int toInt(dynamic val, [int def = 0]) {
      if (val == null) return def;
      if (val is num) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? def;
      return def;
    }

    // Manejo robusto del usuario (puede venir anidado o plano)
    Object? userObj = json['user'] ?? json['usuario'];
    String username = 'Estudiante';
    String email = '';
    int uId = 0;
    
    if (userObj is Map) {
      username = userObj['full_name']?.toString() ?? 
                 userObj['username']?.toString() ?? 
                 userObj['nombre']?.toString() ?? 
                 userObj['email']?.toString() ?? 
                 'Estudiante';
      email = userObj['email']?.toString() ?? '';
      uId = toInt(userObj['id'] ?? userObj['pk']);
    } else {
      username = json['username']?.toString() ?? 
                 json['full_name']?.toString() ?? 
                 json['nombre']?.toString() ?? 
                 'Estudiante';
      email = json['email']?.toString() ?? '';
      uId = toInt(json['user_id'] ?? json['id'] ?? json['usuario_id']);
    }

    return RankingEntryModel(
      position: toInt(json['position'] ?? json['rank'] ?? json['puesto']),
      userId: uId,
      username: username,
      email: email,
      totalXp: toInt(json['total_xp'] ?? json['xp'] ?? json['points'] ?? json['total_points'] ?? json['puntos_totales'] ?? json['puntos']),
      level: toInt(json['level'] ?? json['current_level'] ?? json['nivel'], 1),
      currentStreak: toInt(json['current_streak'] ?? json['streak'] ?? json['streak_count'] ?? json['racha']),
      longestStreak: toInt(json['longest_streak'] ?? json['max_streak'] ?? json['racha_maxima']),
      isMe: json['is_me'] == true || json['is_me'] == 1 || json['is_me'] == 'true' || json['es_yo'] == true,
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
    int toInt(dynamic val, [int def = 0]) {
      if (val == null) return def;
      if (val is num) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? def;
      return def;
    }

    final rawRanking = json['ranking'] ?? json['results'] ?? json['data'] ?? json['usuarios'];
    final List<dynamic> rankingList = rawRanking is List ? rawRanking : [];

    final rankingItems = rankingList
              .map((e) {
                if (e is Map) return RankingEntryModel.fromJson(Map<String, dynamic>.from(e));
                return null;
              })
              .whereType<RankingEntryModel>()
              .toList();

    int myPos = toInt(json['my_position'] ?? json['position'] ?? json['rank'] ?? json['mi_puesto']);
    int myXpVal = toInt(json['my_xp'] ?? json['xp'] ?? json['points'] ?? json['total_xp'] ?? json['mis_puntos'] ?? json['puntos']);
    int myLvl = toInt(json['my_level'] ?? json['level'] ?? json['mi_nivel'], 0);

    // Si faltan datos propios, buscarlos en la lista
    if (myPos == 0 || myXpVal == 0) {
      RankingEntryModel? me;
      try {
        me = rankingItems.firstWhere((e) => e.isMe);
      } catch (_) {
        // No se encontró 'isMe', nada que hacer
      }
      
      if (me != null) {
        if (myPos == 0) myPos = me.position > 0 ? me.position : rankingItems.indexOf(me) + 1;
        if (myXpVal == 0) myXpVal = me.totalXp;
        if (myLvl == 0) myLvl = me.level;
      }
    }

    return RankingModel(
      myPosition: myPos,
      myXp: myXpVal,
      myLevel: myLvl > 0 ? myLvl : 1,
      ranking: rankingItems,
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
    int toInt(dynamic val, [int def = 0]) {
      if (val == null) return def;
      if (val is num) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? def;
      return def;
    }
    return ProgressByLanguage(
      languageId: toInt(json['language_id'] ?? json['id']),
      languageName: json['language_name']?.toString() ?? json['nombre']?.toString() ?? '',
      languageCode: json['language_code']?.toString() ?? json['codigo']?.toString() ?? '',
      flagUrl: json['flag_url']?.toString() ?? json['bandera']?.toString(),
      totalLessons: toInt(json['total_lessons'] ?? json['lecciones_totales']),
      completed: toInt(json['completed'] ?? json['completadas']),
      percentage: (json['percentage'] as num?)?.toDouble() ?? (json['progreso'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
