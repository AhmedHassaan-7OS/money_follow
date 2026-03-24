import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/cubit/history/history_cubit.dart';
import 'package:money_follow/core/cubit/history/history_state.dart';
import 'package:money_follow/core/cubit/statistics/statistics_cubit.dart';
import 'package:money_follow/view/pages/edit_income_page.dart';
import 'package:money_follow/view/pages/edit_expense_page.dart';
import 'package:money_follow/view/pages/edit_commitment_page.dart';
import 'package:money_follow/view/widgets/history/history_date_header.dart';
import 'package:money_follow/view/widgets/history/history_list_item.dart';

class HistoryListView extends StatelessWidget {
  const HistoryListView({super.key, required this.state});
  final HistoryState state;

  Future<void> _navigateToEdit(BuildContext context, HistoryItem item) async {
    final cubit = context.read<HistoryCubit>();
    Widget? editPage;

    switch (item.type) {
      case 'Income':
        final income = await cubit.getIncomeById(item.id);
        if (income != null) editPage = EditIncomePage(income: income, onUpdated: cubit.loadHistory);
        break;
      case 'Expense':
        final expense = await cubit.getExpenseById(item.id);
        if (expense != null) editPage = EditExpensePage(expense: expense, onUpdated: cubit.loadHistory);
        break;
      case 'Commitment':
        final commitment = await cubit.getCommitmentById(item.id);
        if (commitment != null) editPage = EditCommitmentPage(commitment: commitment, onUpdated: cubit.loadHistory);
        break;
    }

    if (editPage != null && context.mounted) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => editPage!));
      if (context.mounted) context.read<StatisticsCubit>().loadStatistics();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
    }
    if (state.filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No transactions yet', style: AppTheme.getHeadingSmall(context).copyWith(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Start adding transactions', style: AppTheme.getBodyMedium(context), textAlign: TextAlign.center),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<HistoryCubit>().loadHistory();
        if (context.mounted) await context.read<StatisticsCubit>().loadStatistics();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.filtered.length,
        itemBuilder: (context, index) {
          final item = state.filtered[index];
          final dFormat = DateFormat('yyyy-MM-dd');
          final isToday = dFormat.format(item.date) == dFormat.format(DateTime.now());
          final isYesterday = dFormat.format(item.date) == dFormat.format(DateTime.now().subtract(const Duration(days: 1)));
          final dateText = isToday ? 'Today' : (isYesterday ? 'Yesterday' : DateFormat('MMM dd, yyyy').format(item.date));
          final showHeader = index == 0 || dFormat.format(item.date) != dFormat.format(state.filtered[index - 1].date);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader) ...[
                if (index > 0) const SizedBox(height: 16),
                HistoryDateHeader(dateText: dateText, date: item.date),
              ],
              HistoryListItem(item: item, onTap: () => _navigateToEdit(context, item)),
            ],
          );
        },
      ),
    );
  }
}
