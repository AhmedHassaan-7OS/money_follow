import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/providers/theme_provider.dart';
import 'package:money_follow/providers/localization_provider.dart';
import 'package:money_follow/providers/currency_provider.dart';
import 'package:money_follow/view/pages/main_navigation.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/utils/system_detection_helper.dart';
import 'package:money_follow/services/permission_service.dart';
import 'package:money_follow/services/bank_sms_service.dart';
import 'package:money_follow/bloc/statistics/statistics_bloc.dart';

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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _permissionsRequested = false;
  bool _isShowingPendingDialog = false;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Request permissions after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissionsOnStartup();
      _checkPendingBankSmsAndPrompt();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPendingBankSmsAndPrompt();
    }
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

  Future<void> _checkPendingBankSmsAndPrompt() async {
    if (!mounted || _isShowingPendingDialog) return;

    try {
      final pending = await BankSmsService.getPendingTransactions();
      if (pending.isEmpty) return;

      _isShowingPendingDialog = true;
      for (final tx in pending) {
        if (!mounted) break;
        final context = _navigatorKey.currentContext;
        if (context == null) break;

        final action = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(tx.isIncome ? 'Bank SMS Income' : 'Bank SMS Expense'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amount: ${tx.amount}'),
                const SizedBox(height: 8),
                Text('Sender: ${tx.sender}'),
                const SizedBox(height: 8),
                Text(
                  tx.body,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, 'skip'),
                child: const Text('Skip'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, 'save'),
                child: const Text('Save'),
              ),
            ],
          ),
        );

        if (action == 'save') {
          await BankSmsService.confirmAndSave(tx);
          if (mounted && context.mounted) {
            context.read<StatisticsBloc>().add(LoadStatistics());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction saved from bank SMS')),
            );
          }
        } else {
          await BankSmsService.removePendingById(tx.id);
        }
      }
    } catch (e) {
      print('Error while processing pending bank SMS: $e');
    } finally {
      _isShowingPendingDialog = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<StatisticsBloc>(
          create: (context) => StatisticsBloc()..add(LoadStatistics()),
        ),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => LocalizationProvider()),
          ChangeNotifierProvider(create: (context) => CurrencyProvider()),
        ],
        child: Consumer2<ThemeProvider, LocalizationProvider>(
        builder: (context, themeProvider, localizationProvider, child) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
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
      ),
    );
  }
}
