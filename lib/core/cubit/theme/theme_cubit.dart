import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

/// Manages app theme (light/dark mode).
class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeCubit() : super(const ThemeState()) {
    _loadTheme();
  }

  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    emit(state.copyWith(themeMode: newMode));
    _saveTheme();
  }

  void setTheme(ThemeMode themeMode) {
    emit(state.copyWith(themeMode: themeMode));
    _saveTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      final mode = isDark ? ThemeMode.dark : ThemeMode.light;
      emit(state.copyWith(themeMode: mode));
    } catch (_) {
      // Default to light on error.
    }
  }

  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, state.isDarkMode);
    } catch (_) {
      // Silently ignore save errors.
    }
  }
}
