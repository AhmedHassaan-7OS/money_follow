import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';

/// ============================================================
/// PrimaryButton — زر الحفظ/التحديث الموحد Full-Width.
///
/// كان بيتكرر في كل الفورمات:
///   SizedBox(width: double.infinity, height: 56,
///     child: ElevatedButton(
///       style: ElevatedButton.styleFrom(
///         backgroundColor: ..., borderRadius: ..., ...
///       ),
///       child: isLoading ? CircularProgressIndicator : Text(label),
///     )
///   )
///
/// دلوقتي:
///   PrimaryButton(label: l10n.save, onPressed: _save)
///   PrimaryButton(label: l10n.save, isLoading: true)
///   PrimaryButton(label: l10n.save, color: AppTheme.accentGreen, ...)
/// ============================================================
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.color,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// لو null يستخدم primaryBlue الافتراضي.
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppTheme.primaryBlue;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: btnColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
