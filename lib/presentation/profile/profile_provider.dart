import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

part 'profile_provider.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPrefs(SharedPrefsRef ref) async {
  return SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPrefsProvider).valueOrNull;
    final saved = prefs?.getString(AppConstants.keyThemeMode) ?? 'system';
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setTheme(ThemeMode mode) async {
    final prefs = ref.read(sharedPrefsProvider).requireValue;
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(AppConstants.keyThemeMode, value);
    state = mode;
  }
}

@Riverpod(keepAlive: true)
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  bool build() {
    final prefs = ref.watch(sharedPrefsProvider).valueOrNull;
    return prefs?.getBool(AppConstants.keyNotificationsEnabled) ?? true;
  }

  Future<void> toggle() async {
    final prefs = ref.read(sharedPrefsProvider).requireValue;
    state = !state;
    await prefs.setBool(AppConstants.keyNotificationsEnabled, state);
  }
}

@Riverpod(keepAlive: true)
class SelectedDepartamentoNotifier extends _$SelectedDepartamentoNotifier {
  @override
  String? build() {
    final prefs = ref.watch(sharedPrefsProvider).valueOrNull;
    return prefs?.getString(AppConstants.keySelectedDepartamento);
  }

  Future<void> select(String? codigo) async {
    final prefs = ref.read(sharedPrefsProvider).requireValue;
    state = codigo;
    if (codigo != null) {
      await prefs.setString(AppConstants.keySelectedDepartamento, codigo);
    } else {
      await prefs.remove(AppConstants.keySelectedDepartamento);
    }
  }
}
