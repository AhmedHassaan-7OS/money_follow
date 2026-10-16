import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:money_follow/view/widgets/animated_press_scale.dart';
import 'package:money_follow/core/cubit/history/history_cubit.dart';
import 'package:money_follow/core/cubit/history/history_state.dart';
import 'package:money_follow/core/cubit/statistics/statistics_cubit.dart';
import 'package:money_follow/view/pages/edit_income_page.dart';
import 'package:money_follow/view/pages/edit_expense_page.dart';
import 'package:money_follow/view/pages/edit_commitment_page.dart';
import 'package:money_follow/view/widgets/history/history_date_header.dart';
import 'package:money_follow/view/widgets/history/history_list_item.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/utils/localization_extensions.dart';

class HistoryListView extends StatelessWidget {
  const HistoryListView({super.key, required this.state});
  final HistoryState state;

  Future<void> _navigateToEdit(BuildContext context, HistoryItem item) async {
    final cubit = context.read<HistoryCubit>();
    Widget? editPage;

    switch (item.type) {
      case 'Income':
        final income = await cubit.getIncomeById(item.id);
        if (income != null)
          editPage = EditIncomePage(
            income: income,
            onUpdated: cubit.loadHistory,
          );
        break;
      case 'Expense':
        final expense = await cubit.getExpenseById(item.id);
        if (expense != null)
          editPage = EditExpensePage(
            expense: expense,
            onUpdated: cubit.loadHistory,
          );
        break;
      case 'Commitment':
        final commitment = await cubit.getCommitmentById(item.id);
        if (commitment != null)
          editPage = EditCommitmentPage(
            commitment: commitment,
            onUpdated: cubit.loadHistory,
          );
        break;
    }

    if (editPage != null && context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => editPage!),
      );
      if (context.mounted) context.read<StatisticsCubit>().loadStatistics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBlue),
      );
    }
    if (state.filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/empty.json',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTransactionsYetLabel,
              style: AppTheme.getHeadingSmall(
                context,
              ).copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.startAddingTransactionsLabel,
              style: AppTheme.getBodyMedium(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    // Hoist date formatters and "today"/"yesterday" keys out of the builder so
    // they are computed once instead of on every item (and on every recycle).
    final dFormat = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();
    final todayStr = dFormat.format(now);
    final yesterdayStr = dFormat.format(now.subtract(const Duration(days: 1)));
    final localeCode = l10n.locale.languageCode;

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<HistoryCubit>().loadHistory();
        if (context.mounted)
          await context.read<StatisticsCubit>().loadStatistics();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 120,
        ),
        itemCount: state.filtered.length,
        itemBuilder: (context, index) {
          final item = state.filtered[index];
          final itemDateStr = dFormat.format(item.date);
          final dateText = itemDateStr == todayStr
              ? l10n.today
              : (itemDateStr == yesterdayStr
                    ? l10n.yesterdayLabel
                    : DateFormat.yMMMd(localeCode).format(item.date));
          final showHeader =
              index == 0 ||
              itemDateStr != dFormat.format(state.filtered[index - 1].date);

          return Column(
                key: ValueKey('${item.type}_${item.id}'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader) ...[
                    if (index > 0) const SizedBox(height: 16),
                    HistoryDateHeader(dateText: dateText, date: item.date),
                  ],
                  AnimatedPressScale(
                    onTap: () => _navigateToEdit(context, item),
                    child: HistoryListItem(item: item),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }
}
