import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/core/cubit/theme/theme_cubit.dart';
import 'package:money_follow/core/cubit/theme/theme_state.dart';
import 'package:money_follow/core/cubit/localization/localization_cubit.dart';
import 'package:money_follow/core/cubit/localization/localization_state.dart';
import 'package:money_follow/core/cubit/currency/currency_cubit.dart';
import 'package:money_follow/core/cubit/statistics/statistics_cubit.dart';
import 'package:money_follow/core/cubit/home/home_cubit.dart';
import 'package:money_follow/core/cubit/history/history_cubit.dart';
import 'package:money_follow/core/cubit/expense/expense_cubit.dart';
import 'package:money_follow/core/cubit/income/income_cubit.dart';
import 'package:money_follow/core/cubit/commitment/commitment_cubit.dart';
import 'package:money_follow/core/cubit/backup/backup_cubit.dart';
import 'package:money_follow/core/cubit/bank_sms/bank_sms_cubit.dart';
import 'package:money_follow/core/cubit/commitment_reminder/commitment_reminder_cubit.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/view/pages/main_navigation.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/utils/system_detection_helper.dart';
import 'package:money_follow/services/permission_service.dart';
import 'package:money_follow/services/bank_sms_service.dart';
import 'package:money_follow/services/commitment_reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await CommitmentReminderService.initialize();
  } catch (e) {
    debugPrint('Commitment reminders plugin unavailable: $e');
  }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissionsOnStartup();
      _checkPendingBankSmsAndPrompt();
      CommitmentReminderService.checkAndNotifyDueCommitments().catchError((e) {
        debugPrint('Reminder check failed: $e');
      });
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
      CommitmentReminderService.checkAndNotifyDueCommitments().catchError((e) {
        debugPrint('Reminder check failed on resume: $e');
      });
    }
  }

  Future<void> _requestPermissionsOnStartup() async {
    if (_permissionsRequested) return;
    _permissionsRequested = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final navContext = _navigatorKey.currentContext;
      if (mounted && navContext != null && navContext.mounted) {
        await PermissionService.requestPermissionsOnStartup(navContext);
      }
    } catch (e) {
      debugPrint('Error requesting permissions on startup: $e');
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
          builder: (dc) => AlertDialog(
            title: Text(tx.isIncome ? 'Bank SMS Income' : 'Bank SMS Expense'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amount: ${tx.amount}'),
                const SizedBox(height: 8),
                Text('Sender: ${tx.sender}'),
                const SizedBox(height: 8),
                Text(tx.body, maxLines: 5, overflow: TextOverflow.ellipsis),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dc, 'skip'),
                child: const Text('Skip'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dc, 'save'),
                child: const Text('Save'),
              ),
            ],
          ),
        );
        if (action == 'save') {
          await BankSmsService.confirmAndSave(tx);
          if (mounted && context.mounted) {
            context.read<StatisticsCubit>().loadStatistics();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction saved from bank SMS')),
            );
          }
        } else {
          await BankSmsService.removePendingById(tx.id);
        }
      }
    } catch (e) {
      debugPrint('Error while processing pending bank SMS: $e');
    } finally {
      _isShowingPendingDialog = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LocalizationCubit()),
        BlocProvider(create: (_) => CurrencyCubit()),
        BlocProvider(create: (_) => StatisticsCubit()..loadStatistics()),
        BlocProvider(create: (_) => HomeCubit()),
        BlocProvider(create: (_) => HistoryCubit()),
        BlocProvider(create: (_) => ExpenseCubit()),
        BlocProvider(create: (_) => IncomeCubit()),
        BlocProvider(create: (_) => CommitmentCubit()),
        BlocProvider(create: (_) => BackupCubit()),
        BlocProvider(create: (_) => BankSmsCubit()),
        BlocProvider(create: (_) => CommitmentReminderCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocalizationCubit, LocalizationState>(
            builder: (context, locState) {
              return MaterialApp(
                navigatorKey: _navigatorKey,
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
                builder: (context, child) {
                  return Directionality(
                    textDirection:
                        locState.locale.languageCode == 'ar'
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                    child: child!,
                  );
                },
                home: const MainNavigation(),
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}
