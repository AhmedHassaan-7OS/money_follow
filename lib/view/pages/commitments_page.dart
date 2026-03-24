import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/cubit/commitment/commitment_cubit.dart';
import 'package:money_follow/core/cubit/commitment/commitment_state.dart';
import 'package:money_follow/view/widgets/app_snack_bar.dart';

import 'package:money_follow/view/widgets/commitments/add_commitment_sheet.dart';
import 'package:money_follow/view/widgets/commitments/commitments_list_view.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: FloatingActionButton.extended(
          onPressed: _showAddSheet,
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
