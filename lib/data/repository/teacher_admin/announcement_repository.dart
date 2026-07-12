// lib/data/repository/teacher_admin/announcement_repository.dart
import 'package:jumpup_app/data/repository/base_repository.dart';
import 'package:jumpup_app/domain/model/admin/announcement_model.dart';

class AnnouncementRepository extends BaseRepository {
  // 📥 Obtener todos los anuncios
  Future<List<Announcement>> fetchAnnouncements() {
    return getList<Announcement>(
      'announcements/',
      (json) => Announcement.fromJson(json),
      message: 'Error al cargar anuncios',
    );
  }

  // ➕ Crear anuncio
  Future<Announcement> createAnnouncement(Map<String, dynamic> data) {
    return handleRequest<Announcement>(
      () async {
        final response = await dio.post<Map<String, dynamic>>('announcements/', data: data);
        return Announcement.fromJson(response.data!);
      },
      message: 'Error al crear anuncio',
    );
  }

  // ✏️ Editar anuncio
  Future<Announcement> updateAnnouncement(int id, Map<String, dynamic> data) {
    return handleRequest<Announcement>(
      () async {
        final response = await dio.patch<Map<String, dynamic>>('announcements/$id/', data: data);
        return Announcement.fromJson(response.data!);
      },
      message: 'Error al actualizar anuncio',
    );
  }

  // 🗑️ Eliminar anuncio
  Future<void> deleteAnnouncement(int id) {
    return executeRequest(
      () async => await dio.delete('announcements/$id/'),
      message: 'Error al eliminar anuncio',
    );
  }
}