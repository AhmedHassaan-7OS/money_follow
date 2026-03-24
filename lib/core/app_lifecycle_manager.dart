import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/core/cubit/statistics/statistics_cubit.dart';
import 'package:money_follow/services/permission_service.dart';
import 'package:money_follow/services/bank_sms_service.dart';
import 'package:money_follow/services/commitment_reminder_service.dart';

class AppLifecycleManager extends StatefulWidget {
  const AppLifecycleManager({super.key, required this.child, required this.navigatorKey});
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager> with WidgetsBindingObserver {
  bool _permissionsRequested = false;
  bool _isShowingPendingDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
      _checkBankSms();
      CommitmentReminderService.checkAndNotifyDueCommitments().catchError((_) {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBankSms();
      CommitmentReminderService.checkAndNotifyDueCommitments().catchError((_) {});
    }
  }

  Future<void> _requestPermissions() async {
    if (_permissionsRequested) return;
    _permissionsRequested = true;
    await Future.delayed(const Duration(milliseconds: 500));
    final ctx = widget.navigatorKey.currentContext;
    if (mounted && ctx != null && ctx.mounted) await PermissionService.requestPermissionsOnStartup(ctx);
  }

  Future<void> _checkBankSms() async {
    if (!mounted || _isShowingPendingDialog) return;
    try {
      final pending = await BankSmsService.getPendingTransactions();
      if (pending.isEmpty) return;
      _isShowingPendingDialog = true;
      for (final tx in pending) {
        if (!mounted) break;
        final ctx = widget.navigatorKey.currentContext;
        if (ctx == null) break;
        final action = await _showSmsDialog(ctx, tx);
        if (action == 'save') {
          await BankSmsService.confirmAndSave(tx);
          if (mounted && ctx.mounted) {
            ctx.read<StatisticsCubit>().loadStatistics();
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Transaction saved')));
          }
        } else {
          await BankSmsService.removePendingById(tx.id);
        }
      }
    } finally {
      _isShowingPendingDialog = false;
    }
  }

  Future<String?> _showSmsDialog(BuildContext context, dynamic tx) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dc) => AlertDialog(
        title: Text(tx.isIncome ? 'Bank SMS Income' : 'Bank SMS Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ${tx.amount}'),
            Text('Sender: ${tx.sender}'),
            Text(tx.body, maxLines: 5, overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dc, 'skip'), child: const Text('Skip')),
          ElevatedButton(onPressed: () => Navigator.pop(dc, 'save'), child: const Text('Save')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
