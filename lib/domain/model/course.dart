class CourseModel {
  final String id;
  final String title;
  final String description;
  final String languageCode;
  final String teacherId;
  final int totalModules;
  final String? imageUrl;

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.languageCode,
    required this.teacherId,
    this.totalModules = 0,
    this.imageUrl,
  });
}

class ModuleModel {
  final String id;
  final String courseId;
  final String title;
  final int order;
  final int totalLessons;

  const ModuleModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.order,
    this.totalLessons = 0,
  });
}

class LessonModel {
  final String id;
  final String moduleId;
  final String title;
  final String content;
  final int order;
  final bool isCompleted;

  const LessonModel({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.content,
    required this.order,
    this.isCompleted = false,
  });
}
