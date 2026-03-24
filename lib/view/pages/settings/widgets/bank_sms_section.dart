import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/cubit/bank_sms/bank_sms_cubit.dart';
import 'package:money_follow/core/cubit/bank_sms/bank_sms_state.dart';
import 'package:money_follow/view/widgets/settings_toggle_tile.dart';
import 'package:money_follow/view/pages/settings/widgets/settings_layout_helpers.dart';

class BankSmsSection extends StatelessWidget {
  const BankSmsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Bank SMS'),
        BlocBuilder<BankSmsCubit, BankSmsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return SettingsCard(
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final cubit = context.read<BankSmsCubit>();
            return SettingsCard(
              child: Column(
                children: [
                  SettingsToggleTile(
                    icon: Icons.sms_outlined,
                    title: 'Read bank SMS',
                    subtitle: 'Detect income/expense from incoming bank messages',
                    value: state.captureEnabled,
                    onChanged: (v) => cubit.toggleCapture(v),
                  ),
                  const SettingsDivider(),
                  SettingsToggleTile(
                    icon: Icons.flash_on_outlined,
                    title: 'Auto record',
                    subtitle: 'Save detected messages directly without confirmation',
                    value: state.autoRecordEnabled,
                    onChanged: state.captureEnabled ? (v) => cubit.toggleAutoRecord(v) : null,
                  ),
                  const SettingsDivider(),
                  ListTile(
                    leading: const Icon(Icons.pending_actions_outlined, color: AppTheme.primaryBlue),
                    title: Text('Pending transactions (${state.pendingCount})'),
                    subtitle: const Text('Review and confirm detected bank messages'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _reviewPendingNow(context, cubit, state),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _reviewPendingNow(BuildContext context, BankSmsCubit cubit, BankSmsState state) async {
    if (state.pendingTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending bank transactions')),
      );
      return;
    }

    for (final tx in state.pendingTransactions) {
      if (!context.mounted) break;
      final action = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(tx.isIncome ? 'Income from SMS' : 'Expense from SMS'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount: ${tx.amount}'),
              const SizedBox(height: 8),
              Text('Sender: ${tx.sender}'),
              const SizedBox(height: 8),
              Text(tx.body, maxLines: 4, overflow: TextOverflow.ellipsis),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'skip'),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, 'save'),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (action == 'save') {
        await cubit.confirmAndSave(tx);
      } else {
        await cubit.removePending(tx);
      }
    }
  }
}
