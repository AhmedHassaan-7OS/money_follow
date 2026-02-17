import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/bloc/statistics/statistics_bloc.dart';
import 'package:money_follow/providers/currency_provider.dart';
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
    // Refresh statistics when page loads
    context.read<StatisticsBloc>().add(LoadStatistics());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.financialStatistics,
                    style: AppTheme.getHeadingMedium(context),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      context.read<StatisticsBloc>().add(LoadStatistics());
                    },
                    icon: Icon(Icons.refresh, color: AppTheme.primaryBlue),
                  ),
                ],
              ),
            ),

            // Statistics Content
            Expanded(
              child: BlocBuilder<StatisticsBloc, StatisticsState>(
                builder: (context, state) {
                  if (state is StatisticsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryBlue,
                      ),
                    );
                  }

                  if (state is StatisticsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppTheme.errorColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.errorLoadingStatistics,
                            style: AppTheme.getHeadingSmall(context),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: AppTheme.getBodyMedium(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is StatisticsLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<StatisticsBloc>().add(LoadStatistics());
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Quick Stats Cards
                            _buildQuickStatsSection(state, currencyProvider),
                            const SizedBox(height: 24),

                            // Monthly Report
                            _buildMonthlyReportSection(state, currencyProvider),
                            const SizedBox(height: 24),

                            // Weekly Breakdown
                            _buildWeeklyBreakdownSection(
                              state,
                              currencyProvider,
                            ),
                            const SizedBox(height: 24),

                            // Daily Activity
                            _buildDailyActivitySection(state, currencyProvider),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
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

  Widget _buildQuickStatsSection(
    StatisticsLoaded state,
    CurrencyProvider currencyProvider,
  ) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.quickOverview, style: AppTheme.getHeadingSmall(context)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                l10n.todaySpent,
                currencyProvider.formatAmount(state.totalSpentToday),
                Icons.today,
                AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                l10n.thisWeekSpent,
                currencyProvider.formatAmount(state.totalSpentThisWeek),
                Icons.date_range,
                AppTheme.accentGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          l10n.thisMonthSpent,
          currencyProvider.formatAmount(state.totalSpentThisMonth),
          Icons.calendar_month,
          AppTheme.warningColor,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String amount,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
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
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyReportSection(
    StatisticsLoaded state,
    CurrencyProvider currencyProvider,
  ) {
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final monthName = DateFormat('MMMM yyyy', locale.languageCode).format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.monthlyReport.replaceAll('{month}', monthName),
          style: AppTheme.getHeadingSmall(context),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
                ),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.totalExpenses,
                    style: AppTheme.getBodyLarge(context),
                  ),
                  Text(
                    currencyProvider.formatAmount(state.totalSpentThisMonth),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: AppTheme.getTextSecondary(context).withOpacity(0.2),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppTheme.getTextSecondary(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.statisticsCalculatedFromStart,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getTextSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyBreakdownSection(
    StatisticsLoaded state,
    CurrencyProvider currencyProvider,
  ) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.currentWeekBreakdown,
          style: AppTheme.getHeadingSmall(context),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
                ),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.weekTotal, style: AppTheme.getBodyLarge(context)),
                  Text(
                    currencyProvider.formatAmount(state.totalSpentThisWeek),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.dailyAverage,
                    style: AppTheme.getBodyMedium(context),
                  ),
                  Text(
                    currencyProvider.formatAmount(state.totalSpentThisWeek / 7),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.getTextSecondary(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyActivitySection(
    StatisticsLoaded state,
    CurrencyProvider currencyProvider,
  ) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final sortedDates = state.dailySummaries.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Sort by date descending

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dailyActivity, style: AppTheme.getHeadingSmall(context)),
        const SizedBox(height: 12),
        if (sortedDates.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                l10n.noTransactionsRecorded,
                style: AppTheme.getBodyMedium(context),
              ),
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
                        width: 2,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isToday
                              ? l10n.today
                              : DateFormat(
                                  'EEEE, d MMMM',
                                  locale.languageCode,
                                ).format(date),
                          style: AppTheme.getBodyLarge(context).copyWith(
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (summary['expense']! > 0) ...[
                              Icon(
                                Icons.arrow_downward,
                                size: 12,
                                color: AppTheme.errorColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                currencyProvider.formatAmount(
                                  summary['expense']!,
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.errorColor,
                                ),
                              ),
                            ],
                            if (summary['expense']! > 0 &&
                                summary['income']! > 0)
                              const SizedBox(width: 12),
                            if (summary['income']! > 0) ...[
                              Icon(
                                Icons.arrow_upward,
                                size: 12,
                                color: AppTheme.accentGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                currencyProvider.formatAmount(
                                  summary['income']!,
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.accentGreen,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    l10n.netAmount.replaceAll(
                      '{amount}',
                      currencyProvider.formatAmount(
                        summary['income']! - summary['expense']!,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: (summary['income']! - summary['expense']!) >= 0
                          ? AppTheme.accentGreen
                          : AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }
}
