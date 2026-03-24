import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/cubit/statistics/statistics_cubit.dart';
import 'package:money_follow/core/cubit/statistics/statistics_state.dart';
import 'package:money_follow/core/cubit/currency/currency_cubit.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    context.read<StatisticsCubit>().loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = context.read<CurrencyCubit>();

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            _StatsHeader(l10n: l10n),
            Expanded(
              child: BlocBuilder<StatisticsCubit, StatisticsState>(
                builder: (context, state) {
                  if (state is StatisticsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryBlue),
                    );
                  }
                  if (state is StatisticsError) {
                    return _ErrorView(message: state.message, l10n: l10n);
                  }
                  if (state is StatisticsLoaded) {
                    return _StatsContent(state: state, currency: currency);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back,
              color: AppTheme.getTextPrimary(context)),
        ),
        const SizedBox(width: 8),
        Text(l10n.financialStatistics,
            style: AppTheme.getHeadingMedium(context)),
        const Spacer(),
        IconButton(
          onPressed: () =>
              context.read<StatisticsCubit>().loadStatistics(),
          icon: Icon(Icons.refresh, color: AppTheme.primaryBlue),
        ),
      ]),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.l10n});
  final String message;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
          const SizedBox(height: 16),
          Text(l10n.errorLoadingStatistics,
              style: AppTheme.getHeadingSmall(context)),
          const SizedBox(height: 8),
          Text(message, style: AppTheme.getBodyMedium(context),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({required this.state, required this.currency});
  final StatisticsLoaded state;
  final CurrencyCubit currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final now = DateTime.now();
    final monthName =
        DateFormat('MMMM yyyy', locale.languageCode).format(now);

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<StatisticsCubit>().loadStatistics(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _QuickStats(state: state, currency: currency, l10n: l10n),
            const SizedBox(height: 24),
            _MonthlyReport(
                state: state, currency: currency,
                monthName: monthName, l10n: l10n),
            const SizedBox(height: 24),
            _WeeklyBreakdown(
                state: state, currency: currency, l10n: l10n),
            const SizedBox(height: 24),
            _DailyActivity(
                state: state, currency: currency, l10n: l10n),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({
    required this.state,
    required this.currency,
    required this.l10n,
  });
  final StatisticsLoaded state;
  final CurrencyCubit currency;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.quickOverview,
            style: AppTheme.getHeadingSmall(context)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _StatCard(
            title: l10n.todaySpent,
            amount: currency.formatAmount(state.totalSpentToday),
            icon: Icons.today, color: AppTheme.primaryBlue,
          )),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(
            title: l10n.thisWeekSpent,
            amount: currency.formatAmount(state.totalSpentThisWeek),
            icon: Icons.date_range, color: AppTheme.accentGreen,
          )),
        ]),
        const SizedBox(height: 12),
        _StatCard(
          title: l10n.thisMonthSpent,
          amount: currency.formatAmount(state.totalSpentThisMonth),
          icon: Icons.calendar_month, color: AppTheme.warningColor,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark
                    ? 0.3 : 0.05),
            blurRadius: 10, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.getBodyMedium(context)),
              const SizedBox(height: 4),
              Text(amount, style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ]),
    );
  }
}

class _MonthlyReport extends StatelessWidget {
  const _MonthlyReport({
    required this.state,
    required this.currency,
    required this.monthName,
    required this.l10n,
  });
  final StatisticsLoaded state;
  final CurrencyCubit currency;
  final String monthName;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.monthlyReport.replaceAll('{month}', monthName),
            style: AppTheme.getHeadingSmall(context)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.totalExpenses,
                    style: AppTheme.getBodyLarge(context)),
                Text(currency.formatAmount(state.totalSpentThisMonth),
                    style: TextStyle(fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.errorColor)),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1,
                color: AppTheme.getTextSecondary(context).withOpacity(0.2)),
            const SizedBox(height: 16),
            Row(children: [
              Icon(Icons.info_outline, size: 16,
                  color: AppTheme.getTextSecondary(context)),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.statisticsCalculatedFromStart,
                  style: TextStyle(fontSize: 12,
                      color: AppTheme.getTextSecondary(context)))),
            ]),
          ]),
        ),
      ],
    );
  }
}

class _WeeklyBreakdown extends StatelessWidget {
  const _WeeklyBreakdown({
    required this.state,
    required this.currency,
    required this.l10n,
  });
  final StatisticsLoaded state;
  final CurrencyCubit currency;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.currentWeekBreakdown,
            style: AppTheme.getHeadingSmall(context)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.weekTotal,
                    style: AppTheme.getBodyLarge(context)),
                Text(currency.formatAmount(state.totalSpentThisWeek),
                    style: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGreen)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.dailyAverage,
                    style: AppTheme.getBodyMedium(context)),
                Text(currency.formatAmount(state.totalSpentThisWeek / 7),
                    style: TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextSecondary(context))),
              ],
            ),
          ]),
        ),
      ],
    );
  }
}

class _DailyActivity extends StatelessWidget {
  const _DailyActivity({
    required this.state,
    required this.currency,
    required this.l10n,
  });
  final StatisticsLoaded state;
  final CurrencyCubit currency;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final sortedDates = state.dailySummaries.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dailyActivity,
            style: AppTheme.getHeadingSmall(context)),
        const SizedBox(height: 12),
        if (sortedDates.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(l10n.noTransactionsRecorded,
                  style: AppTheme.getBodyMedium(context)),
            ),
          )
        else
          ...sortedDates.take(7).map((dateKey) {
            final summary = state.dailySummaries[dateKey]!;
            final date = DateTime.parse(dateKey);
            final isToday =
                DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateKey;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: isToday
                    ? Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        width: 2)
                    : null,
              ),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          isToday
                              ? l10n.today
                              : DateFormat('EEEE, d MMMM',
                                      locale.languageCode)
                                  .format(date),
                          style: AppTheme.getBodyLarge(context).copyWith(
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                      const SizedBox(height: 4),
                      Row(children: [
                        if (summary['expense']! > 0) ...[
                          Icon(Icons.arrow_downward, size: 12,
                              color: AppTheme.errorColor),
                          const SizedBox(width: 4),
                          Text(currency.formatAmount(summary['expense']!),
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.errorColor)),
                        ],
                        if (summary['expense']! > 0 &&
                            summary['income']! > 0)
                          const SizedBox(width: 12),
                        if (summary['income']! > 0) ...[
                          Icon(Icons.arrow_upward, size: 12,
                              color: AppTheme.accentGreen),
                          const SizedBox(width: 4),
                          Text(currency.formatAmount(summary['income']!),
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.accentGreen)),
                        ],
                      ]),
                    ],
                  ),
                ),
                Text(
                    l10n.netAmount.replaceAll('{amount}',
                        currency.formatAmount(
                            summary['income']! - summary['expense']!)),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: (summary['income']! - summary['expense']!) >= 0
                            ? AppTheme.accentGreen
                            : AppTheme.errorColor)),
              ]),
            );
          }),
      ],
    );
  }
}
