import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/features/teacher-admin/models/user_stats.dart';
import 'package:jumpup_app/features/teacher-admin/presentation/providers/resource_provider.dart';

final studentStatsProvider = FutureProvider.family<UserStats, String>((ref, studentId) {
  return ref.read(teacherRepositoryProvider).fetchUserStats(studentId);
});
