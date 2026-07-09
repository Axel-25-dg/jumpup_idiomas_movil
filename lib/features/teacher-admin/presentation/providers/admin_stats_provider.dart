import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/features/teacher-admin/models/admin_stats_model.dart';
import '../../data/teacher_repository.dart';

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  return TeacherRepository().getAdminStats();
});