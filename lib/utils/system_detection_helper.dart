import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class SystemDetectionHelper {
  static void printSystemInfo() {
    Locale systemLocale = ui.PlatformDispatcher.instance.locale;
    
    print('🌍 System Detection Info:');
    print('📱 Language Code: ${systemLocale.languageCode}');
    print('🏳️ Country Code: ${systemLocale.countryCode ?? 'Not available'}');
    print('🌐 Full Locale: ${systemLocale.toString()}');
    print('');
    
    // Show what would be detected
    String detectedLanguage = _getDetectedLanguage(systemLocale);
    String detectedCurrency = _getDetectedCurrency(systemLocale);
    
    print('✅ Detected Settings:');
    print('🗣️ Language: $detectedLanguage');
    print('💰 Currency: $detectedCurrency');
    print('');
  }
  
  static String _getDetectedLanguage(Locale systemLocale) {
    List<String> supportedLanguages = ['en', 'ar', 'fr', 'de', 'ja'];
    String systemLanguage = systemLocale.languageCode.toLowerCase();
    
    if (supportedLanguages.contains(systemLanguage)) {
      return systemLanguage.toUpperCase();
    }
    return 'EN (fallback)';
  }
  
  static String _getDetectedCurrency(Locale systemLocale) {
    String? countryCode = systemLocale.countryCode?.toUpperCase();
    
    Map<String, String> countryToCurrency = {
      'SA': 'SAR',
      'EG': 'EGP', 
      'AE': 'AED',
      'JP': 'JPY',
      'DE': 'EUR',
      'FR': 'EUR',
      'US': 'USD',
    };
    
    if (countryCode != null && countryToCurrency.containsKey(countryCode)) {
      return countryToCurrency[countryCode]!;
    }
    
    // Check for Arabic language
    if (systemLocale.languageCode.toLowerCase() == 'ar') {
      return 'SAR (Arabic default)';
    }
    
    return 'USD (fallback)';
  }
}
