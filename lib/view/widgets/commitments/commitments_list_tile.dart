import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/constants/app_constants.dart';
import 'package:money_follow/models/commitment_model.dart';
import 'package:money_follow/core/cubit/currency/currency_cubit.dart';

class AnimatedCommitmentTile extends StatefulWidget {
  const AnimatedCommitmentTile({super.key, required this.child, required this.delayMs});

  final Widget child;
  final int delayMs;

  @override
  State<AnimatedCommitmentTile> createState() => _AnimatedCommitmentTileState();
}

class _AnimatedCommitmentTileState extends State<AnimatedCommitmentTile> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 220),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        offset: _visible ? Offset.zero : const Offset(0.06, 0),
        child: widget.child,
      ),
    );
  }
}

class CommitmentTodoTile extends StatelessWidget {
  const CommitmentTodoTile({
    super.key,
    required this.item,
    required this.currency,
    required this.onToggle,
    required this.onTap,
  });

  final CommitmentModel item;
  final CurrencyCubit currency;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime.tryParse(item.dueDate);
    final isOverdue =
        dueDate != null &&
        dueDate.isBefore(DateTime.now()) &&
        !item.isCompleted;

    final accent = item.isCompleted
        ? AppTheme.accentGreen
        : isOverdue ? AppTheme.errorColor : AppTheme.warningColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: item.isCompleted,
          onChanged: (value) => onToggle(value ?? false),
        ),
        title: Text(
          item.title,
          style: AppTheme.getBodyLarge(context).copyWith(
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          dueDate == null ? item.dueDate : 'Due ${DateFormat(AppConstants.displayDateFormat).format(dueDate)}${isOverdue ? ' (Overdue)' : ''}',
          style: TextStyle(color: accent),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currency.formatAmount(item.amount),
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Icon(
              AppConstants.getCommitmentIcon(item.title),
              size: 16,
              color: accent,
            ),
          ],
        ),
      ),
    );
  }
}
