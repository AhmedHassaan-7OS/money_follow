import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/cubit/home/home_cubit.dart';
import 'package:money_follow/core/cubit/home/home_state.dart';
import 'package:money_follow/core/cubit/currency/currency_cubit.dart';
import 'package:money_follow/core/cubit/currency/currency_state.dart';
import 'package:money_follow/models/commitment_model.dart';
import 'package:money_follow/view/pages/settings_page.dart';
import 'package:money_follow/view/pages/statistics_page.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

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

    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, currState) {
        final currency = context.read<CurrencyCubit>();
        return BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: AppTheme.getBackgroundColor(context),
              body: SafeArea(
                child: RefreshIndicator(
                  onRefresh: () => context.read<HomeCubit>().loadData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(l10n: l10n),
                        const SizedBox(height: 20),
                        _BalanceCard(
                          label: l10n.totalBalance,
                          amount: currency.formatAmount(state.totalBalance),
                        ),
                        const SizedBox(height: 24),
                        _MonthlyExpenseCard(
                          label: '${l10n.expenses} ${l10n.thisMonth}',
                          amount: currency.formatAmount(state.monthlyExpenses),
                        ),
                        const SizedBox(height: 24),
                        if (state.expenses.isNotEmpty) ...[
                          Text('${l10n.expenses} by ${l10n.category}',
                              style: AppTheme.getHeadingSmall(context)),
                          const SizedBox(height: 16),
                          _ExpenseChart(
                            data: context.read<HomeCubit>().getExpensesByCategory(),
                            currencySymbol: currency.state.currencySymbol,
                          ),
                          const SizedBox(height: 24),
                        ],
                        Text('${l10n.upcoming} ${l10n.commitments}',
                            style: AppTheme.getHeadingSmall(context)),
                        const SizedBox(height: 16),
                        if (state.commitments.isEmpty)
                          _EmptyCommitmentsCard(label: l10n.noCommitmentsYet)
                        else
                          ...state.commitments.take(3).map(
                            (c) => _CommitmentCard(
                              commitment: c,
                              formatAmount: currency.formatAmount,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l10n.overview, style: AppTheme.getHeadingMedium(context)),
        Row(children: [
          IconButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StatisticsPage())),
            icon: const Icon(Icons.analytics_outlined),
            color: AppTheme.primaryBlue,
          ),
          IconButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsPage())),
            icon: const Icon(Icons.settings_outlined),
            color: AppTheme.getTextSecondary(context),
          ),
        ]),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.label, required this.amount});
  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(
              color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(amount, style: AppTheme.balanceText),
        ],
      ),
    );
  }
}

class _MonthlyExpenseCard extends StatelessWidget {
  const _MonthlyExpenseCard({required this.label, required this.amount});
  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.getBodyMedium(context)),
          const SizedBox(height: 8),
          Text(amount, style: AppTheme.getHeadingMedium(context)),
        ],
      ),
    );
  }
}

class _ExpenseChart extends StatelessWidget {
  const _ExpenseChart({required this.data, required this.currencySymbol});
  final Map<String, double> data;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();
    final colors = [
      AppTheme.primaryBlue, AppTheme.accentGreen,
      AppTheme.warningColor, AppTheme.errorColor, AppTheme.lightBlue,
    ];
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PieChart(PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.entries.map((e) {
          final idx = data.keys.toList().indexOf(e.key);
          return PieChartSectionData(
            color: colors[idx % colors.length],
            value: e.value,
            title: '${e.key}\n$currencySymbol${e.value.toStringAsFixed(0)}',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
          );
        }).toList(),
      )),
    );
  }
}

class _EmptyCommitmentsCard extends StatelessWidget {
  const _EmptyCommitmentsCard({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label,
          style: AppTheme.getBodyMedium(context),
          textAlign: TextAlign.center),
    );
  }
}

class _CommitmentCard extends StatelessWidget {
  const _CommitmentCard({required this.commitment, required this.formatAmount});
  final CommitmentModel commitment;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime.tryParse(commitment.dueDate);
    final isOverdue = dueDate != null && dueDate.isBefore(DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: isOverdue ? Border.all(color: AppTheme.errorColor) : null,
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: (isOverdue ? AppTheme.errorColor : AppTheme.primaryBlue)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.schedule,
              color: isOverdue ? AppTheme.errorColor : AppTheme.primaryBlue,
              size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(commitment.title, style: AppTheme.getBodyLarge(context)),
              const SizedBox(height: 4),
              Text(
                dueDate != null
                    ? 'Due on ${DateFormat('MMM dd').format(dueDate)}'
                    : 'Due: ${commitment.dueDate}',
                style: TextStyle(fontSize: 12,
                    color: isOverdue ? AppTheme.errorColor
                        : AppTheme.getTextSecondary(context)),
              ),
            ],
          ),
        ),
        Text(formatAmount(commitment.amount),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                color: isOverdue ? AppTheme.errorColor
                    : AppTheme.getTextPrimary(context))),
      ]),
    );
  }
}
