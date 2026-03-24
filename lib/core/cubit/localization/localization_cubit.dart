import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization_state.dart';

/// Manages app locale with system detection fallback.
class LocalizationCubit extends Cubit<LocalizationState> {
  LocalizationCubit() : super(const LocalizationState()) {
    _loadLocale();
  }

  static const List<ui.Locale> supportedLocales = [
    ui.Locale('en'),
    ui.Locale('ar'),
    ui.Locale('fr'),
    ui.Locale('de'),
    ui.Locale('ja'),
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'ar': 'العربية',
    'fr': 'Français',
    'de': 'Deutsch',
    'ja': '日本語',
  };

  String getLanguageName(String code) {
    return languageNames[code] ?? 'English';
  }

  void setLocale(ui.Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    try {
      emit(state.copyWith(locale: locale));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
    } catch (_) {
      emit(state.copyWith(locale: const ui.Locale('en')));
    }
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code');
    if (code != null) {
      emit(state.copyWith(locale: ui.Locale(code)));
    } else {
      final detected = _detectSystemLanguage();
      emit(state.copyWith(locale: detected));
      await prefs.setString('language_code', detected.languageCode);
    }
  }

  ui.Locale _detectSystemLanguage() {
    final systemLang =
        ui.PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    for (final supported in supportedLocales) {
      if (supported.languageCode == systemLang) return supported;
    }
    return const ui.Locale('en');
  }
}
