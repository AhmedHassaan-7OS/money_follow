import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: AppTheme.getHeadingSmall(context)),
      );
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
              ),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
        ),
        title: Text(title, style: AppTheme.getBodyLarge(context)),
        subtitle: Text(subtitle, style: AppTheme.getBodyMedium(context)),
        trailing: trailing,
        onTap: onTap,
      );
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});
  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        color: AppTheme.getTextSecondary(context).withOpacity(0.1),
      );
}
