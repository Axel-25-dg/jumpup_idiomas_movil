import '../data/teacher_repository.dart';
import '../models/classroom_model.dart';

class TeacherService {
  final TeacherRepository _repository = TeacherRepository();

  Future<Classroom> createClassroom({
    required String name,
    required String description,
    required int courseId,
  }) async {
    return await _repository.createClassroom(
      name: name,
      description: description,
      courseId: courseId,
    );
  }
}