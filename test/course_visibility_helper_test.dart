import 'package:flutter_test/flutter_test.dart';
import 'package:jumpup_app/domain/model/admin/classroom_model.dart';
import 'package:jumpup_app/domain/model/admin/course_models.dart';
import 'package:jumpup_app/presentation/screens/student/course_visibility_helper.dart';

void main() {
  group('course visibility helper', () {
    final course = CourseModel(
      id: 7,
      language: 1,
      languageName: 'English',
      title: 'English Advanced',
      description: 'Advanced course',
      difficultyLevel: 'B2',
    );

    test('marks a course as enrolled when the classroom references the same course id', () {
      final classrooms = [
        ClassroomModel(
          id: 1,
          name: 'Aula 1',
          description: '',
          accessCode: '',
          teacherName: 'Teacher',
          isActive: true,
          createdAt: DateTime.now(),
          courseId: 7,
        ),
      ];

      expect(isCourseEnrolled(course: course, classrooms: classrooms), isTrue);
    });

    test('marks a course as enrolled when the classroom uses the course name', () {
      final classrooms = [
        ClassroomModel(
          id: 2,
          name: 'Aula 2',
          description: '',
          accessCode: '',
          teacherName: 'Teacher',
          isActive: true,
          createdAt: DateTime.now(),
          courseName: 'English Advanced',
        ),
      ];

      expect(isCourseEnrolled(course: course, classrooms: classrooms), isTrue);
    });

    test('filters out already enrolled courses from the available list', () {
      final classrooms = [
        ClassroomModel(
          id: 3,
          name: 'Aula 3',
          description: '',
          accessCode: '',
          teacherName: 'Teacher',
          isActive: true,
          createdAt: DateTime.now(),
          courseId: 7,
        ),
      ];

      final courses = [course, CourseModel(
        id: 8,
        language: 1,
        languageName: 'English',
        title: 'Spanish Basics',
        description: 'Basics course',
        difficultyLevel: 'A1',
      )];

      expect(filterAvailableCourses(courses: courses, classrooms: classrooms).map((c) => c.id), [8]);
    });
  });
}
