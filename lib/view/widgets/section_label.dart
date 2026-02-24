import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';

/// ============================================================
/// SectionLabel — الـ label اللي فوق كل حقل في الفورم.
///
/// بدل ما تكتب في كل حقل:
///   Text(l10n.amount, style: AppTheme.getHeadingSmall(context)),
///   const SizedBox(height: 12),
///
/// دلوقتي:
///   SectionLabel(l10n.amount),
/// ============================================================
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.bottomSpacing = 12});

  final String text;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Text(text, style: AppTheme.getHeadingSmall(context)),
    );
  }
}
