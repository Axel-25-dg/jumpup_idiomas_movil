import 'package:flutter_test/flutter_test.dart';
import 'package:jumpup_app/data/repository/teacher_admin/classroom_repository.dart';
import 'package:jumpup_app/data/repository/teacher_admin/course_repository.dart';

void main() {
  group('payload builders', () {
    test('buildClassroomPayload includes course and is_active', () {
      final payload = buildClassroomPayload(
        name: 'Aula demo',
        description: 'Descripción de prueba',
        courseId: 3,
      );

      expect(payload['name'], 'Aula demo');
      expect(payload['description'], 'Descripción de prueba');
      expect(payload['course'], 3);
      expect(payload['is_active'], true);
    });

    test('buildCoursePayload maps language_id and course fields', () {
      final payload = buildCoursePayload({
        'title': 'Curso de prueba',
        'description': 'Descripción del curso',
        'language_id': 8,
        'difficulty_level': 'intermediate',
        'image_url': 'https://example.com/image.png',
      });

      expect(payload['language_id'], 8);
      expect(payload['title'], 'Curso de prueba');
      expect(payload['description'], 'Descripción del curso');
      expect(payload['difficulty_level'], 'intermediate');
      expect(payload['image_url'], 'https://example.com/image.png');
    });
  });
}
