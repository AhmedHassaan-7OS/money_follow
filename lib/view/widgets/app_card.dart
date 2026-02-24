import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';

/// ============================================================
/// AppCard — بطاقة موحدة تحل محل الـ BoxDecoration المتكررة.
///
/// كان الكود ده بيتكرر +20 مرة في المشروع:
///   Container(
///     decoration: BoxDecoration(
///       color: AppTheme.getCardColor(context),
///       borderRadius: BorderRadius.circular(16),
///       boxShadow: [ BoxShadow(...) ],
///     ),
///     child: ...
///   )
///
/// دلوقتي:
///   AppCard(child: ...)
///
/// SOLID — SRP: الكارد مسئول بس عن الشكل الموحد.
/// ============================================================
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? 16.0;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(radius),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
