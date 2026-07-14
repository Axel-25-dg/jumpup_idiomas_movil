// lib/presentation/providers/email_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/email_repository.dart';
import 'package:jumpup_app/domain/model/admin/broadcast_email_model.dart';
import 'package:jumpup_app/domain/model/admin/email_log_model.dart';
import 'package:jumpup_app/presentation/providers/teacher_repository_provider.dart';
import 'package:jumpup_app/presentation/providers/stats_provider.dart';

// ─── BROADCAST NOTIFIER ────────────────────────────────────────────────

final broadcastEmailNotifierProvider = StateNotifierProvider<BroadcastEmailNotifier, AsyncValue<List<BroadcastEmail>>>((ref) {
  // ✅ CAMBIADO: usar emailRepository en lugar de emails
  final repository = ref.watch(teacherRepositoryProvider).emailRepository;
  return BroadcastEmailNotifier(ref, repository);
});

class BroadcastEmailNotifier extends StateNotifier<AsyncValue<List<BroadcastEmail>>> {
  final Ref _ref;
  final EmailRepository _repository;

  BroadcastEmailNotifier(this._ref, this._repository) : super(const AsyncValue.data([])) {
    fetchAll();
  }

  Future<void> fetchAll() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.fetchBroadcastEmails();
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _refreshStats() async {
    final statsNotifier = _ref.read(adminStatsNotifierProvider.notifier);
    await statsNotifier.refresh();
  }

  Future<void> create(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createBroadcastEmail(data);
      await fetchAll();
      await _refreshStats();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateBroadcastEmail(id, data);
      await fetchAll();
      await _refreshStats();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> delete(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteBroadcastEmail(id);
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((c) => c.id != id).toList());
      await _refreshStats();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> send(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.sendBroadcastEmail(id);
      await fetchAll();
      await _refreshStats();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await fetchAll();
    await _refreshStats();
  }
}

// ─── EMAIL LOG NOTIFIER ────────────────────────────────────────────────

final emailLogNotifierProvider = StateNotifierProvider.family<EmailLogNotifier, AsyncValue<List<EmailLog>>, int?>((ref, broadcastId) {
  // ✅ CAMBIADO: usar emailRepository en lugar de emails
  final repository = ref.watch(teacherRepositoryProvider).emailRepository;
  return EmailLogNotifier(repository, broadcastId);
});

class EmailLogNotifier extends StateNotifier<AsyncValue<List<EmailLog>>> {
  final EmailRepository _repository;
  final int? _broadcastId;

  EmailLogNotifier(this._repository, this._broadcastId) : super(const AsyncValue.data([])) {
    fetchAll();
  }

  Future<void> fetchAll() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.fetchEmailLogs(broadcastId: _broadcastId);
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await fetchAll();
  }
}