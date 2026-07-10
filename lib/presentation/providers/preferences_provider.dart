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
}

class PreferencesState {
  final bool darkMode;
  final bool notifications;
  final bool haptics;

  PreferencesState({
    required this.darkMode,
    required this.notifications,
    required this.haptics,
  });

  PreferencesState copyWith({
    bool? darkMode,
    bool? notifications,
    bool? haptics,
  }) {
    return PreferencesState(
      darkMode: darkMode ?? this.darkMode,
      notifications: notifications ?? this.notifications,
      haptics: haptics ?? this.haptics,
    );
  }
}

final preferencesProvider = StateNotifierProvider<PreferencesNotifier, PreferencesState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferencesNotifier(prefs);
});
