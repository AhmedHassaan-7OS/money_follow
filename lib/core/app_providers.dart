import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/core/cubit/theme/theme_cubit.dart';
import 'package:money_follow/core/cubit/localization/localization_cubit.dart';
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

class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LocalizationCubit()),
        BlocProvider(create: (_) => CurrencyCubit()),
        BlocProvider(create: (_) => StatisticsCubit()..loadStatistics()),
        BlocProvider(create: (_) => HomeCubit()..loadData()),
        BlocProvider(create: (_) => HistoryCubit()..loadHistory()),
        BlocProvider(create: (_) => ExpenseCubit()..loadExpenses()),
        BlocProvider(create: (_) => IncomeCubit()..loadIncomes()),
        BlocProvider(create: (_) => CommitmentCubit()..load()),
        BlocProvider(create: (_) => BackupCubit()..loadBackupSize()),
        BlocProvider(create: (_) => BankSmsCubit()..loadState()),
        BlocProvider(create: (_) => CommitmentReminderCubit()..loadSettings()),
      ],
      child: child,
    );
  }
}
