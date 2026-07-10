import 'package:jumpup_app/data/repository/teacher_admin/teacher_repository.dart';
import 'package:jumpup_app/domain/model/classroom_model.dart';

class TeacherService {
  final TeacherRepository _repository = TeacherRepository();

  Future<ClassroomModel> createClassroom({
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
