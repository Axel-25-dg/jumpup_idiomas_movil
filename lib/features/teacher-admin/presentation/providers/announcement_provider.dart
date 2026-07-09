import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/features/teacher-admin/models/announcement_model.dart';
import '../../data/teacher_repository.dart';

// Este provider permite refrescar los anuncios fácilmente si es necesario
final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final repo = TeacherRepository();
  return repo.fetchAnnouncements();
});