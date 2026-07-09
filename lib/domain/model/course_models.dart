// Modelos del módulo de Contenido Educativo
// Cubre: Language, Course, Module, Lesson, Exercise

// ─── Language ─────────────────────────────────────────────────────────────────

class LanguageModel {
  const LanguageModel({
    required this.id,
    required this.name,
    required this.code,
    this.flagIconUrl,
    this.coursesCount = 0,
  });

  final int id;
  final String name;
  final String code;
  final String? flagIconUrl;
  final int coursesCount;

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      flagIconUrl: json['flag_icon_url']?.toString(),
      coursesCount: json['courses_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'flag_icon_url': flagIconUrl,
        'courses_count': coursesCount,
      };
}

// ─── Course ───────────────────────────────────────────────────────────────────

class CourseModel {
  const CourseModel({
    required this.id,
    required this.language,
    required this.languageName,
    required this.title,
    required this.description,
    required this.difficultyLevel,
    this.imageUrl,
    this.modulesCount = 0,
    this.lessonsCount = 0,
    this.totalXpReward = 0,
  });

  final int id;
  final int language;
  final String languageName;
  final String title;
  final String description;
  final String difficultyLevel;
  final String? imageUrl;
  final int modulesCount;
  final int lessonsCount;
  final int totalXpReward;

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as int,
      language: json['language'] as int,
      languageName: json['language_name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      difficultyLevel: json['difficulty_level']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      modulesCount: json['modules_count'] as int? ?? 0,
      lessonsCount: json['lessons_count'] as int? ?? 0,
      totalXpReward: json['total_xp_reward'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'language': language,
        'language_name': languageName,
        'title': title,
        'description': description,
        'difficulty_level': difficultyLevel,
        'image_url': imageUrl,
        'modules_count': modulesCount,
        'lessons_count': lessonsCount,
        'total_xp_reward': totalXpReward,
      };
}

// ─── Module ───────────────────────────────────────────────────────────────────

class ModuleModel {
  const ModuleModel({
    required this.id,
    required this.course,
    required this.courseTitle,
    required this.title,
    required this.order,
    this.lessonsCount = 0,
  });

  final int id;
  final int course;
  final String courseTitle;
  final String title;
  final int order;
  final int lessonsCount;

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] as int,
      course: json['course'] as int,
      courseTitle: json['course_title']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      order: json['order'] as int? ?? 0,
      lessonsCount: json['lessons_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'course': course,
        'course_title': courseTitle,
        'title': title,
        'order': order,
        'lessons_count': lessonsCount,
      };
}

// ─── Lesson ───────────────────────────────────────────────────────────────────

class LessonModel {
  const LessonModel({
    required this.id,
    required this.module,
    required this.moduleTitle,
    required this.title,
    required this.contentType,
    required this.order,
    required this.xpReward,
    this.exercisesCount = 0,
  });

  final int id;
  final int module;
  final String moduleTitle;
  final String title;
  final String contentType;
  final int order;
  final int xpReward;
  final int exercisesCount;

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as int,
      module: json['module'] as int,
      moduleTitle: json['module_title']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      contentType: json['content_type']?.toString() ?? '',
      order: json['order'] as int? ?? 0,
      xpReward: json['xp_reward'] as int? ?? 0,
      exercisesCount: json['exercises_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'module': module,
        'module_title': moduleTitle,
        'title': title,
        'content_type': contentType,
        'order': order,
        'xp_reward': xpReward,
        'exercises_count': exercisesCount,
      };
}

// ─── Exercise ─────────────────────────────────────────────────────────────────

class ExerciseModel {
  const ExerciseModel({
    required this.id,
    required this.lesson,
    required this.lessonTitle,
    required this.questionText,
    required this.exerciseType,
    required this.correctAnswer,
  });

  final int id;
  final int lesson;
  final String lessonTitle;
  final String questionText;
  final String exerciseType;
  final String correctAnswer;

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as int,
      lesson: json['lesson'] as int,
      lessonTitle: json['lesson_title']?.toString() ?? '',
      questionText: json['question_text']?.toString() ?? '',
      exerciseType: json['exercise_type']?.toString() ?? '',
      correctAnswer: json['correct_answer']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lesson': lesson,
        'lesson_title': lessonTitle,
        'question_text': questionText,
        'exercise_type': exerciseType,
        'correct_answer': correctAnswer,
      };
}
