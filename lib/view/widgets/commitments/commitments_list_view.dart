import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:money_follow/view/widgets/animated_press_scale.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/models/commitment_model.dart';
import 'package:money_follow/core/cubit/commitment/commitment_cubit.dart';
import 'package:money_follow/core/cubit/commitment/commitment_state.dart';
import 'package:money_follow/core/cubit/currency/currency_cubit.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/view/widgets/app_card.dart';
import 'package:money_follow/view/widgets/app_snack_bar.dart';

import 'package:money_follow/view/pages/edit_commitment_page.dart';
import 'package:money_follow/view/widgets/commitments/commitments_stats_card.dart';
import 'package:money_follow/view/widgets/commitments/commitments_filter_chips.dart';
import 'package:money_follow/view/widgets/commitments/commitments_list_tile.dart';

class CommitmentsListView extends StatelessWidget {
  const CommitmentsListView({super.key, required this.state});
  final CommitmentState state;

  Future<bool?> _confirmDelete(BuildContext context, CommitmentModel item) {
    return showDialog<bool>(
      context: context,
      builder: (dc) => AlertDialog(
        title: const Text('Delete commitment?'),
        content: Text('Delete "${item.title}" permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dc, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dc, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = context.read<CurrencyCubit>();
    final visible = state.filtered;

    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
      children: [
        Text('TODO ${l10n.commitments}', style: AppTheme.getHeadingMedium(context)),
        const SizedBox(height: 12),
        CommitmentStatsCard(pendingCount: state.pendingCount, completedCount: state.completedCount),
        const SizedBox(height: 16),
        CommitmentFilterChips(
          currentFilter: state.filter,
          onFilterChanged: (f) => context.read<CommitmentCubit>().setFilter(f),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: state.isLoading
              ? const Padding(key: ValueKey('loading'), padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
              : visible.isEmpty
                  ? AppCard(
                      key: const ValueKey('empty'),
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset('assets/lottie/empty.json', width: 120, height: 120, fit: BoxFit.contain),
                            const SizedBox(height: 16),
                            Text(
                              state.filter == CommitmentFilter.completed ? 'No completed commitments yet' : 'No commitments yet',
                              style: AppTheme.getBodyMedium(context),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      key: ValueKey('list_${visible.length}_${state.filter.name}'),
                      children: List.generate(visible.length, (index) {
                        final item = visible[index];
                        return AnimatedPressScale(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditCommitmentPage(
                                commitment: item,
                                onUpdated: () => context.read<CommitmentCubit>().load(),
                              ),
                            ),
                          ),
                          child: Dismissible(
                            key: ValueKey('c_${item.id}_${item.dueDate}'),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => _confirmDelete(context, item),
                            onDismissed: (_) {
                              context.read<CommitmentCubit>().delete(item);
                              AppSnackBar.success(context, 'Commitment deleted');
                            },
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(color: AppTheme.errorColor, borderRadius: BorderRadius.circular(16)),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete_outline, color: Colors.white),
                            ),
                            child: CommitmentTodoTile(
                              item: item,
                              currency: currency,
                              onToggle: (v) => context.read<CommitmentCubit>().toggleStatus(item, v),
                              onTap: () {},
                            ),
                          ),
                        ).animate(delay: (index * 35).ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
                      }),
                    ),
        ),
        const SizedBox(height: 90),
      ],
    );
  }
}
