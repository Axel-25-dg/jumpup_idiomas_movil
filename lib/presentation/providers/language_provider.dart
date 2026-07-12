// lib/presentation/providers/language_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/language_repository.dart';
import 'package:jumpup_app/domain/model/admin/admin_language_model.dart';
import 'package:jumpup_app/presentation/providers/teacher_repository_provider.dart';

final languageNotifierProvider = StateNotifierProvider<LanguageNotifier, AsyncValue<List<Language>>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).languages;
  return LanguageNotifier(repository);
});

class LanguageNotifier extends StateNotifier<AsyncValue<List<Language>>> {
  final LanguageRepository _repository;

  LanguageNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchLanguages();
  }

  Future<void> fetchLanguages() async {
    state = const AsyncValue.loading();
    try {
      final languages = await _repository.fetchLanguages();
      state = AsyncValue.data(languages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addLanguage(String name, String code, {String? flagIconUrl}) async {
    try {
      final newLanguage = await _repository.createLanguage(
        name: name,
        code: code,
        flagIconUrl: flagIconUrl,
      );
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newLanguage]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> editLanguage(int id, String name, String code, {String? flagIconUrl}) async {
    try {
      await _repository.updateLanguage(
        id: id,
        name: name,
        code: code,
        flagIconUrl: flagIconUrl,
      );
      await fetchLanguages();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteLanguage(int id) async {
    try {
      await _repository.deleteLanguage(id);
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((l) => l.id != id).toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await fetchLanguages();
  }
}

// Provider de solo lectura
final languageProvider = FutureProvider<List<Language>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider).languages;
  return repository.fetchLanguages();
});

final adminLanguagesProvider = languageProvider;
