import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_readInitialThemeMode(_prefs));

  static const String _themeModeKey = 'app_theme_mode';

  final SharedPreferences _prefs;

  bool get isDarkMode => state == ThemeMode.dark;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    emit(mode);
    await _prefs.setString(_themeModeKey, mode.name);
  }

  Future<void> toggleTheme() async {
    final nextMode = state == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(nextMode);
  }

  Future<void> useSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  static ThemeMode _readInitialThemeMode(SharedPreferences prefs) {
    final savedMode = prefs.getString(_themeModeKey);

    switch (savedMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }
}