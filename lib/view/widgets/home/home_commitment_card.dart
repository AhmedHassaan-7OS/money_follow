import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/models/commitment_model.dart';

class HomeCommitmentCard extends StatelessWidget {
  const HomeCommitmentCard({super.key, required this.commitment, required this.formatAmount});
  final CommitmentModel commitment;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime.tryParse(commitment.dueDate);
    final isOverdue = dueDate != null && dueDate.isBefore(DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: isOverdue ? Border.all(color: AppTheme.errorColor) : null,
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: (isOverdue ? AppTheme.errorColor : AppTheme.primaryBlue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.schedule, color: isOverdue ? AppTheme.errorColor : AppTheme.primaryBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(commitment.title, style: AppTheme.getBodyLarge(context)),
              const SizedBox(height: 4),
              Text(
                dueDate != null ? 'Due on ${DateFormat('MMM dd').format(dueDate)}' : 'Due: ${commitment.dueDate}',
                style: TextStyle(fontSize: 12, color: isOverdue ? AppTheme.errorColor : AppTheme.getTextSecondary(context)),
              ),
            ],
          ),
        ),
        Text(formatAmount(commitment.amount),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isOverdue ? AppTheme.errorColor : AppTheme.getTextPrimary(context))),
      ]),
    );
  }
}

class HomeEmptyCommitmentsCard extends StatelessWidget {
  const HomeEmptyCommitmentsCard({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.getCardColor(context), borderRadius: BorderRadius.circular(16)),
      child: Text(label, style: AppTheme.getBodyMedium(context), textAlign: TextAlign.center),
    );
  }
}
