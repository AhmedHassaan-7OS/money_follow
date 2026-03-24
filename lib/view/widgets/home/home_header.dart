import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/view/pages/settings_page.dart';
import 'package:money_follow/view/pages/statistics_page.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back!', style: AppTheme.getBodySmall(context).copyWith(color: AppTheme.getTextSecondary(context))),
            Text(l10n.overview, style: AppTheme.getHeadingMedium(context)),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsPage())),
              icon: const Icon(Icons.analytics_outlined),
              color: AppTheme.primaryBlue,
            ),
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
              icon: const Icon(Icons.settings_outlined),
              color: AppTheme.getTextSecondary(context),
            ),
          ],
        ),
      ],
    );
  }
}
