import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/core/cubit/commitment/commitment_cubit.dart';
import 'package:money_follow/core/cubit/commitment/commitment_state.dart';
import 'package:money_follow/view/widgets/app_snack_bar.dart';

import 'package:money_follow/view/widgets/commitments/add_commitment_sheet.dart';
import 'package:money_follow/view/widgets/commitments/commitments_list_view.dart';

class CommitmentsPage extends StatelessWidget {
  const CommitmentsPage({super.key});

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCommitmentSheet(
        onSave: (c) => context.read<CommitmentCubit>().insertSafe(c),
      ),
    ).then((saved) {
      if (saved == true && context.mounted) {
        AppSnackBar.success(context, 'Commitment added');
        context.read<CommitmentCubit>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddSheet(context),
          icon: const Icon(Icons.add_task),
          label: const Text('Add'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: BlocConsumer<CommitmentCubit, CommitmentState>(
          listener: (context, state) {},
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<CommitmentCubit>().load(),
              child: CommitmentsListView(state: state),
            );
          },
        ),
      ),
    );
  }
}
