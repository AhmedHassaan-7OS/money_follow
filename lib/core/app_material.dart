import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/cubit/theme/theme_cubit.dart';
import 'package:money_follow/core/cubit/theme/theme_state.dart';
import 'package:money_follow/core/cubit/localization/localization_cubit.dart';
import 'package:money_follow/core/cubit/localization/localization_state.dart';
import 'package:money_follow/view/pages/main_navigation.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

class AppMaterial extends StatelessWidget {
  const AppMaterial({super.key, required this.navigatorKey});
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<LocalizationCubit, LocalizationState>(
          builder: (context, locState) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'Money Follow',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.themeMode,
              locale: locState.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: LocalizationCubit.supportedLocales,
              builder: (context, child) => Directionality(
                textDirection: locState.locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
                child: child!,
              ),
              home: const MainNavigation(),
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}
