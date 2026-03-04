import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings()) {
    _loadSettings();
  }

  static const String _notificationsKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _proVersionKey = 'pro_version_enabled';
  static const String _usernameKey = 'username';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      notificationsEnabled: prefs.getBool(_notificationsKey) ?? true,
      darkModeEnabled: prefs.getBool(_darkModeKey) ?? false,
      proVersionEnabled: prefs.getBool(_proVersionKey) ?? false,
      username: prefs.getString(_usernameKey) ?? 'Diana',
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, state.notificationsEnabled);
    await prefs.setBool(_darkModeKey, state.darkModeEnabled);
    await prefs.setBool(_proVersionKey, state.proVersionEnabled);
    await prefs.setString(_usernameKey, state.username);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    await _saveSettings();
  }

  Future<void> setDarkModeEnabled(bool value) async {
    state = state.copyWith(darkModeEnabled: value);
    await _saveSettings();
  }

  Future<void> setProVersionEnabled(bool value) async {
    state = state.copyWith(proVersionEnabled: value);
    await _saveSettings();
  }

  Future<void> setUsername(String value) async {
    state = state.copyWith(username: value);
    await _saveSettings();
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = AppSettings();
  }
}

class AppSettings {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool proVersionEnabled;
  final String username;

  AppSettings({
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.proVersionEnabled = false,
    this.username = 'Diana',
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? proVersionEnabled,
    String? username,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      proVersionEnabled: proVersionEnabled ?? this.proVersionEnabled,
      username: username ?? this.username,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

final proVersionProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).proVersionEnabled;
});
