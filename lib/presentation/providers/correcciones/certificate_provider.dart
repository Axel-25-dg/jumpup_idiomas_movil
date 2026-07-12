// lib/presentation/providers/certificate_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/certificate_repository.dart';
import 'package:jumpup_app/domain/model/admin/certificate_model.dart';
import 'package:jumpup_app/presentation/providers/correcciones/teacher_repository_provider.dart';
  

final certificateNotifierProvider = StateNotifierProvider<CertificateNotifier, AsyncValue<List<Certificate>>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).certificates;
  return CertificateNotifier(repository);
});

class CertificateNotifier extends StateNotifier<AsyncValue<List<Certificate>>> {
  final CertificateRepository _repository;

  CertificateNotifier(this._repository) : super(const AsyncValue.data([])) {
    fetchCertificates();
  }

  Future<void> fetchCertificates() async {
    state = const AsyncValue.loading();
    try {
      final certificates = await _repository.fetchCertificates();
      state = AsyncValue.data(certificates);
    } catch (e) {
      state = AsyncValue.data([]);
    }
  }

  Future<void> createCertificate(Map<String, dynamic> data) async {
    try {
      await _repository.createCertificate(data);
      await fetchCertificates();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateCertificate(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateCertificate(id, data);
      await fetchCertificates();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteCertificate(int id) async {
    try {
      await _repository.deleteCertificate(id);
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((c) => c.id != id).toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> issueCertificate(int id) async {
    try {
      await _repository.issueCertificate(id);
      await fetchCertificates();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> revokeCertificate(int id) async {
    try {
      await _repository.revokeCertificate(id);
      await fetchCertificates();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await fetchCertificates();
  }
}