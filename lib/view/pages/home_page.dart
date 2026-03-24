import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/cubit/home/home_cubit.dart';
import 'package:money_follow/core/cubit/home/home_state.dart';
import 'package:money_follow/core/cubit/currency/currency_cubit.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

import 'package:money_follow/view/widgets/home/home_header.dart';
import 'package:money_follow/view/widgets/home/home_balance_card.dart';
import 'package:money_follow/view/widgets/home/home_monthly_expense_card.dart';
import 'package:money_follow/view/widgets/home/home_expense_chart.dart';
import 'package:money_follow/view/widgets/home/home_commitment_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = context.read<CurrencyCubit>();

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<HomeCubit>().loadData(),
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  HomeHeader(l10n: l10n),
                  const SizedBox(height: 20),
                  HomeBalanceCard(label: l10n.totalBalance, amount: currency.formatAmount(state.totalBalance)),
                  const SizedBox(height: 24),
                  HomeMonthlyExpenseCard(label: '${l10n.expenses} ${l10n.thisMonth}', amount: currency.formatAmount(state.monthlyExpenses)),
                  const SizedBox(height: 24),
                  if (state.expenses.isNotEmpty) ...[
                    Text('${l10n.expenses} by ${l10n.category}', style: AppTheme.getHeadingSmall(context)),
                    const SizedBox(height: 16),
                    HomeExpenseChart(data: context.read<HomeCubit>().getExpensesByCategory(), currencySymbol: currency.state.currencySymbol),
                    const SizedBox(height: 24),
                  ],
                  Text('${l10n.upcoming} ${l10n.commitments}', style: AppTheme.getHeadingSmall(context)),
                  const SizedBox(height: 16),
                  if (state.commitments.isEmpty)
                    HomeEmptyCommitmentsCard(label: l10n.noCommitmentsYet)
                  else
                    ...state.commitments.take(3).map((c) => HomeCommitmentCard(commitment: c, formatAmount: currency.formatAmount)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
