import 'dart:ui';

class LocalizationState {
  final Locale locale;

  const LocalizationState({this.locale = const Locale('en')});

  LocalizationState copyWith({Locale? locale}) {
    return LocalizationState(locale: locale ?? this.locale);
  }
}
