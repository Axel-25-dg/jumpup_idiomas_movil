// lib/presentation/providers/announcement_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/announcement_repository.dart';
import 'package:jumpup_app/domain/model/admin/announcement_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/teacher_repository_provider.dart';

final announcementNotifierProvider = StateNotifierProvider<AnnouncementNotifier, AsyncValue<List<Announcement>>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).announcements;
  return AnnouncementNotifier(repository);
});

class AnnouncementNotifier extends StateNotifier<AsyncValue<List<Announcement>>> {
  final AnnouncementRepository _repository;

  AnnouncementNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchAnnouncements();
  }

  // 📥 Obtener todos los anuncios
  Future<void> fetchAnnouncements() async {
    state = const AsyncValue.loading();
    try {
      final announcements = await _repository.fetchAnnouncements();
      state = AsyncValue.data(announcements);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // ➕ Crear anuncio
  Future<void> createAnnouncement({
    required String title,
    required String content,
    required DateTime startDate,
    required DateTime endDate,
    bool isActive = true,
  }) async {
    try {
      await _repository.createAnnouncement({
        'title': title,
        'content': content,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_active': isActive,
      });
      await fetchAnnouncements();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // ✏️ Editar anuncio
  Future<void> updateAnnouncement({
    required int id,
    required String title,
    required String content,
    required DateTime startDate,
    required DateTime endDate,
    bool? isActive,
  }) async {
    try {
      final data = {
        'title': title,
        'content': content,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        if (isActive != null) 'is_active': isActive,
      };
      await _repository.updateAnnouncement(id, data);
      await fetchAnnouncements();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 🗑️ Eliminar anuncio
  Future<void> deleteAnnouncement(int id) async {
    try {
      await _repository.deleteAnnouncement(id);
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((a) => a.id != id).toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 🔄 Refrescar
  Future<void> refresh() async {
    await fetchAnnouncements();
  }
}

// Provider de solo lectura
final announcementsProvider = FutureProvider<List<Announcement>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).announcements;
  return repository.fetchAnnouncements();
});