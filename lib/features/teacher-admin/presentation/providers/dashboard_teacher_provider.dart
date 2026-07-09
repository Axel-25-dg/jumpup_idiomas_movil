import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/features/teacher-admin/data/teacher_repository.dart';
import 'package:jumpup_app/features/teacher-admin/models/stats_teacher_model.dart';


final statsProvider = FutureProvider<TeacherStats>((ref) async {
  return await TeacherRepository().fetchTeacherStats();
});