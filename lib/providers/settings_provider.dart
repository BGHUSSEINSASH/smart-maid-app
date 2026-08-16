import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool darkMode;
  final String language; // 'ar' | 'en'
  final bool notificationsEnabled;

  const SettingsState({
    this.darkMode = false,
    this.language = 'ar',
    this.notificationsEnabled = true,
  });

  SettingsState copyWith({
    bool? darkMode,
    String? language,
    bool? notificationsEnabled,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void toggleDarkMode() => state = state.copyWith(darkMode: !state.darkMode);
  void setLanguage(String lang) => state = state.copyWith(language: lang);
  void toggleNotifications() =>
      state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
