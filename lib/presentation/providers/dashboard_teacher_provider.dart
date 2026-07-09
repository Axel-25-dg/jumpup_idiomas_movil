import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/teacher_repository.dart';
import 'package:jumpup_app/domain/model/stats_teacher_model.dart';

final statsProvider = FutureProvider<TeacherStats>((ref) async {
  return await TeacherRepository().fetchTeacherStats();
});
