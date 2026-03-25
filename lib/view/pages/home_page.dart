import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/cubit/home/home_cubit.dart';
import 'package:money_follow/core/cubit/home/home_state.dart';
import 'package:money_follow/core/cubit/currency/currency_cubit.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

import 'package:money_follow/view/widgets/home/home_header.dart';
import 'package:money_follow/view/widgets/home/home_balance_card.dart';
import 'package:money_follow/view/widgets/home/home_monthly_expense_card.dart';
import 'package:money_follow/view/widgets/home/home_expense_chart.dart';
import 'package:money_follow/view/widgets/home/home_chart_filter_chips.dart';
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

  Widget _anm(Widget w, int i) => w.animate(delay: (i * 35).ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = context.read<CurrencyCubit>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<HomeCubit>().loadData(),
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final hc = context.read<HomeCubit>();
              return ListView(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
                children: [
                  _anm(HomeHeader(l10n: l10n), 0),
                  const SizedBox(height: 20),
                  _anm(HomeBalanceCard(label: l10n.totalBalance, amount: currency.formatAmount(state.totalBalance)), 1),
                  const SizedBox(height: 24),
                  _anm(HomeMonthlyExpenseCard(label: '${l10n.expenses} ${l10n.thisMonth}', amount: currency.formatAmount(state.monthlyExpenses)), 2),
                  const SizedBox(height: 24),
                  if (state.expenses.isNotEmpty) ...[
                    _anm(HomeChartFilterChips(cubit: hc, state: state), 3),
                    const SizedBox(height: 16),
                    _anm(HomeExpenseChart(data: hc.getExpensesByCategory(), currencySymbol: currency.state.currencySymbol, chartType: state.chartType, onTypeChanged: hc.setChartType), 4),
                    const SizedBox(height: 24),
                  ],
                  _anm(Text('${l10n.upcoming} ${l10n.commitments}', style: AppTheme.getHeadingSmall(context)), 5),
                  const SizedBox(height: 16),
                  if (state.commitments.isEmpty)
                    _anm(HomeEmptyCommitmentsCard(label: l10n.noCommitmentsYet), 6)
                  else
                    ...state.commitments.take(3).map((c) => _anm(HomeCommitmentCard(commitment: c, formatAmount: currency.formatAmount), 7)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
