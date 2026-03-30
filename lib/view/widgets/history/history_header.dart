import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/utils/localization_extensions.dart';

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({super.key, required this.itemCount, required this.l10n});
  final int itemCount;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            l10n.transactionHistoryLabel,
            style: AppTheme.getHeadingMedium(context),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              l10n.itemsLabel(itemCount),
              style: AppTheme.getBodyMedium(context),
            ),
          ),
        ],
      ),
    );
  }
}
