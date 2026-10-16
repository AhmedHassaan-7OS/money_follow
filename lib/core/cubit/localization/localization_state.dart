import 'dart:ui';
import 'package:equatable/equatable.dart';

class LocalizationState extends Equatable {
  final Locale locale;

  const LocalizationState({this.locale = const Locale('en')});

  LocalizationState copyWith({Locale? locale}) {
    return LocalizationState(locale: locale ?? this.locale);
  }

  @override
  List<Object?> get props => [locale];
}
