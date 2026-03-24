import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/models/commitment_model.dart';
import 'package:money_follow/core/cubit/commitment/commitment_cubit.dart';
import 'package:money_follow/core/cubit/commitment/commitment_state.dart';
import 'package:money_follow/core/cubit/currency/currency_cubit.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/view/widgets/app_card.dart';
import 'package:money_follow/view/widgets/app_snack_bar.dart';

import 'package:money_follow/view/pages/edit_commitment_page.dart';
import 'package:money_follow/view/pages/commitments/widgets/commitments_stats_card.dart';
import 'package:money_follow/view/pages/commitments/widgets/commitments_filter_chips.dart';
import 'package:money_follow/view/pages/commitments/widgets/commitments_list_tile.dart';
import 'package:money_follow/view/pages/commitments/widgets/add_commitment_sheet.dart';

class CommitmentsPage extends StatefulWidget {
  const CommitmentsPage({super.key});

  @override
  State<CommitmentsPage> createState() => _CommitmentsPageState();
}

class _CommitmentsPageState extends State<CommitmentsPage> {
  @override
  void initState() {
    super.initState();
    context.read<CommitmentCubit>().load();
  }

  void _showAddSheet() {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCommitmentSheet(
        onSave: (c) => context.read<CommitmentCubit>().insertSafe(c),
      ),
    ).then((saved) {
      if (saved == true && mounted) {
        AppSnackBar.success(context, 'Commitment added');
        context.read<CommitmentCubit>().load();
      }
    });
  }

  Future<bool?> _confirmDelete(CommitmentModel item) {
    return showDialog<bool>(
      context: context,
      builder: (dc) => AlertDialog(
        title: const Text('Delete commitment?'),
        content: Text('Delete "${item.title}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dc, false),
            child: const Text('Cancel'),
          ),
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

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add_task),
        label: const Text('Add'),
      ),
      body: SafeArea(
        child: BlocConsumer<CommitmentCubit, CommitmentState>(
          listener: (context, state) {}, // Handled by sheets/dialogs mostly
          builder: (context, state) {
            final visible = state.filtered;
            return RefreshIndicator(
              onRefresh: () => context.read<CommitmentCubit>().load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('TODO ${l10n.commitments}', style: AppTheme.getHeadingMedium(context)),
                  const SizedBox(height: 12),
                  CommitmentStatsCard(
                    pendingCount: state.pendingCount,
                    completedCount: state.completedCount,
                  ),
                  const SizedBox(height: 16),
                  CommitmentFilterChips(
                    currentFilter: state.filter,
                    onFilterChanged: (f) => context.read<CommitmentCubit>().setFilter(f),
                  ),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: state.isLoading
                        ? const Padding(
                            key: ValueKey('loading'),
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : visible.isEmpty
                            ? AppCard(
                                key: const ValueKey('empty'),
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    state.filter == CommitmentFilter.completed
                                        ? 'No completed commitments yet'
                                        : 'No commitments yet',
                                    style: AppTheme.getBodyMedium(context),
                                  ),
                                ),
                              )
                            : Column(
                                key: ValueKey('list_${visible.length}_${state.filter.name}'),
                                children: List.generate(visible.length, (index) {
                                  final item = visible[index];
                                  return AnimatedCommitmentTile(
                                    delayMs: 35 * index,
                                    child: Dismissible(
                                      key: ValueKey('c_${item.id}_${item.dueDate}'),
                                      direction: DismissDirection.endToStart,
                                      confirmDismiss: (_) => _confirmDelete(item),
                                      onDismissed: (_) {
                                        context.read<CommitmentCubit>().delete(item);
                                        AppSnackBar.success(context, 'Commitment deleted');
                                      },
                                      background: Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          color: AppTheme.errorColor,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: const Icon(Icons.delete_outline, color: Colors.white),
                                      ),
                                      child: CommitmentTodoTile(
                                        item: item,
                                        currency: currency,
                                        onToggle: (v) => context.read<CommitmentCubit>().toggleStatus(item, v),
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditCommitmentPage(
                                              commitment: item,
                                              onUpdated: () => context.read<CommitmentCubit>().load(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
