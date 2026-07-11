import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class PreferencesNotifier extends StateNotifier<PreferencesState> {
  final SharedPreferences _prefs;

  PreferencesNotifier(this._prefs) : super(PreferencesState(
    darkMode: _prefs.getBool('darkMode') ?? true,
    notifications: _prefs.getBool('notifications') ?? true,
    haptics: _prefs.getBool('haptics') ?? true,
    language: _prefs.getString('language') ?? 'es',
  ));

  void toggleDarkMode() {
    state = state.copyWith(darkMode: !state.darkMode);
    _prefs.setBool('darkMode', state.darkMode);
  }

  void toggleNotifications() {
    state = state.copyWith(notifications: !state.notifications);
    _prefs.setBool('notifications', state.notifications);
  }

  void toggleHaptics() {
    state = state.copyWith(haptics: !state.haptics);
    _prefs.setBool('haptics', state.haptics);
  }

  void setLanguage(String languageCode) {
    state = state.copyWith(language: languageCode);
    _prefs.setString('language', languageCode);
  }
}

class PreferencesState {
  final bool darkMode;
  final bool notifications;
  final bool haptics;
  final String language;

  PreferencesState({
    required this.darkMode,
    required this.notifications,
    required this.haptics,
    required this.language,
  });

  PreferencesState copyWith({
    bool? darkMode,
    bool? notifications,
    bool? haptics,
    String? language,
  }) {
    return PreferencesState(
      darkMode: darkMode ?? this.darkMode,
      notifications: notifications ?? this.notifications,
      haptics: haptics ?? this.haptics,
      language: language ?? this.language,
    );
  }
}

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, PreferencesState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferencesNotifier(prefs);
});

/// Exposes only the darkMode flag for quick access
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(preferencesProvider).darkMode;
});
