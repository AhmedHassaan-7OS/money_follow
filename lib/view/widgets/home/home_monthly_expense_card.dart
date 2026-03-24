import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/view/widgets/animated_press_scale.dart';

class HomeMonthlyExpenseCard extends StatelessWidget {
  const HomeMonthlyExpenseCard({super.key, required this.label, required this.amount});
  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return AnimatedPressScale(
      child: Container(
        width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.getBodyMedium(context)),
          const SizedBox(height: 8),
          Text(amount, style: AppTheme.getHeadingMedium(context)),
        ],
      ),
    ));
  }
}
