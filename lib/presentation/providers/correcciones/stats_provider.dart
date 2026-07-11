// lib/presentation/providers/stats_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:jumpup_app/data/repository/teacher_admin/stats_repository.dart';
import 'package:jumpup_app/domain/model/admin/admin_stats_model.dart';
import 'package:jumpup_app/domain/model/admin/stats_teacher_model.dart';
import 'package:jumpup_app/domain/model/admin/user_stats.dart';
import 'package:jumpup_app/presentation/providers/correcciones/teacher_repository_provider.dart';

final adminStatsProvider = FutureProvider<AdminStats>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).stats;
  return repository.getAdminStats();
});

final teacherStatsProvider = FutureProvider<TeacherStats>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).stats;
  return repository.fetchTeacherStats();
});

final userStatsProvider = FutureProvider.family<UserStats, String>((ref, studentId) {
  final repository = ref.watch(teacherRepositoryProvider).stats;
  return repository.fetchUserStats(studentId);
});