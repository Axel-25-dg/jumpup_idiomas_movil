import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';

bool isCourseEnrolled({
  required CourseModel course,
  required List<ClassroomModel> classrooms,
}) {
  final normalizedTitle = course.title.trim().toLowerCase();
  final enrolledCourseIds = classrooms
      .map((classroom) => classroom.courseId)
      .whereType<int>()
      .toSet();

  if (enrolledCourseIds.contains(course.id)) {
    return true;
  }

  final enrolledCourseNames = classrooms
      .map((classroom) => classroom.courseName?.trim().toLowerCase())
      .whereType<String>()
      .toSet();

  return enrolledCourseNames.contains(normalizedTitle);
}

List<CourseModel> filterAvailableCourses({
  required List<CourseModel> courses,
  required List<ClassroomModel> classrooms,
}) {
  return courses
      .where((course) => !isCourseEnrolled(course: course, classrooms: classrooms))
      .toList();
}
