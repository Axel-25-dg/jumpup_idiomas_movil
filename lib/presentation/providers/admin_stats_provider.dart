import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/domain/model/admin_stats_model.dart';
import 'package:jumpup_app/data/repository/teacher_admin/teacher_repository.dart';

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  return TeacherRepository().getAdminStats();
});