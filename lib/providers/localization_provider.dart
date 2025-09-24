import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class LocalizationProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;

  LocalizationProvider() {
    _loadLocale();
  }

  void _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    
    if (languageCode != null) {
      // User has previously set a language
      _locale = Locale(languageCode);
    } else {
      // First time launch - detect system language
      _locale = _detectSystemLanguage();
      // Save the detected language
      await prefs.setString('language_code', _locale.languageCode);
    }
    notifyListeners();
  }

  Locale _detectSystemLanguage() {
    // Get system locale
    Locale systemLocale = ui.PlatformDispatcher.instance.locale;
    String systemLanguage = systemLocale.languageCode.toLowerCase();
    
    // Check if system language is supported
    for (Locale supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == systemLanguage) {
        return supportedLocale;
      }
    }
    
    // Fallback to English if system language not supported
    return const Locale('en');
  }

  void setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    
    try {
      _locale = locale;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
      notifyListeners();
    } catch (e) {
      // Fallback to English if there's an error
      _locale = const Locale('en');
      notifyListeners();
    }
  }

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ar'), // Arabic
    Locale('fr'), // French
    Locale('de'), // German
    Locale('ja'), // Japanese
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'ar': 'العربية',
    'fr': 'Français',
    'de': 'Deutsch',
    'ja': '日本語',
  };

  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? 'English';
  }
}
