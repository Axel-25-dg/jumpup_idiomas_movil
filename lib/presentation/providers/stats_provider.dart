// lib/presentation/providers/stats_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/stats_repository.dart';
import 'package:jumpup_app/domain/model/admin/admin_stats_model.dart';
import 'package:jumpup_app/domain/model/admin/stats_teacher_model.dart';
import 'package:jumpup_app/domain/model/admin/user_stats.dart';
import 'package:jumpup_app/presentation/providers/teacher_repository_provider.dart';


// ─── ADMIN STATS NOTIFIER ──────────────────────────────────

final adminStatsNotifierProvider = StateNotifierProvider<AdminStatsNotifier, AsyncValue<AdminStats>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).stats;
  return AdminStatsNotifier(repository);
});

class AdminStatsNotifier extends StateNotifier<AsyncValue<AdminStats>> {
  final StatsRepository _repository;

  AdminStatsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    state = const AsyncValue.loading();
    try {
      final stats = await _repository.getAdminStats();
      state = AsyncValue.data(stats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  //  Método para refrescar manualmente
  Future<void> refresh() async {
    await _loadStats();
  }
}

// ─── ADMIN STATS PROVIDER (mantiene compatibilidad) ──────────────────

final adminStatsProvider = Provider<AsyncValue<AdminStats>>((ref) {
  return ref.watch(adminStatsNotifierProvider);
});

// ─── TEACHER STATS (sin cambios) ──────────────────────────────────────

final teacherStatsProvider = FutureProvider<TeacherStats>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).stats;
  return repository.fetchTeacherStats();
});

// ─── STUDENT STATS (sin cambios) ──────────────────────────────────────

final studentStatsByIdProvider = FutureProvider.family<UserStats, String>((ref, studentId) {
  final repository = ref.watch(teacherRepositoryProvider).stats;
  return repository.fetchUserStats(studentId);
});