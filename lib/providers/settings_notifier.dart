import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;

  SettingsState({
    required this.themeMode,
    required this.locale,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final storage = FlutterSecureStorage();

  SettingsNotifier()
      : super(SettingsState(themeMode: ThemeMode.light, locale: Locale('en'))) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final darkMode = await storage.read(key: 'darkMode');
    final language = await storage.read(key: 'language');

    state = state.copyWith(
      themeMode: darkMode == 'true' ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(language ?? 'en'),
    );
  }

  Future<void> toggleDarkMode(bool isDarkMode) async {
    final themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    await storage.write(key: 'darkMode', value: isDarkMode.toString());
    state = state.copyWith(themeMode: themeMode);
  }

  Future<void> changeLanguage(String languageCode) async {
    final locale = Locale(languageCode);
    await storage.write(key: 'language', value: languageCode);
    state = state.copyWith(locale: locale);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
