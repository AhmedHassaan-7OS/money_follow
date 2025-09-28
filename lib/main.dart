import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/providers/theme_provider.dart';
import 'package:money_follow/providers/localization_provider.dart';
import 'package:money_follow/providers/currency_provider.dart';
import 'package:money_follow/view/pages/main_navigation.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/utils/system_detection_helper.dart';
import 'package:money_follow/services/permission_service.dart';

void main() {
  // Print system detection info for debugging
  SystemDetectionHelper.printSystemInfo();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _permissionsRequested = false;

  @override
  void initState() {
    super.initState();
    // Request permissions after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissionsOnStartup();
    });
  }

  Future<void> _requestPermissionsOnStartup() async {
    if (_permissionsRequested) return;
    _permissionsRequested = true;

    try {
      // Wait a bit for the UI to settle
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        await PermissionService.requestPermissionsOnStartup(context);
      }
    } catch (e) {
      print('Error requesting permissions on startup: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LocalizationProvider()),
        ChangeNotifierProvider(create: (context) => CurrencyProvider()),
      ],
      child: Consumer2<ThemeProvider, LocalizationProvider>(
        builder: (context, themeProvider, localizationProvider, child) {
          return MaterialApp(
            title: AppLocalizations.of(context).appTitle,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localizationProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LocalizationProvider.supportedLocales,
            builder: (context, child) {
              // Handle RTL for Arabic
              return Directionality(
                textDirection: localizationProvider.locale.languageCode == 'ar' 
                    ? TextDirection.rtl 
                    : TextDirection.ltr,
                child: child!,
              );
            },
            home: const MainNavigation(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
