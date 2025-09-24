import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/providers/theme_provider.dart';
import 'package:money_follow/providers/localization_provider.dart';
import 'package:money_follow/providers/currency_provider.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/view/pages/backup_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer3<ThemeProvider, LocalizationProvider, CurrencyProvider>(
      builder:
          (
            context,
            themeProvider,
            localizationProvider,
            currencyProvider,
            child,
          ) {
            return Scaffold(
              backgroundColor: AppTheme.getBackgroundColor(context),
              appBar: AppBar(
                title: Text(l10n.settings),
                centerTitle: true,
                backgroundColor: AppTheme.getBackgroundColor(context),
                elevation: 0,
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _sectionTitle(context, l10n.appearance),
                  const SizedBox(height: 8),
                  _settingsCard(
                    context,
                    child: Column(
                      children: [
                        _settingsTile(
                          context,
                          icon: Icons.dark_mode_outlined,
                          title: l10n.darkMode,
                          subtitle: themeProvider.isDarkMode
                              ? l10n.darkThemeEnabled
                              : l10n.lightThemeEnabled,
                          trailing: Switch(
                            value: themeProvider.isDarkMode,
                            onChanged: (value) => themeProvider.toggleTheme(),
                            activeColor: AppTheme.primaryBlue,
                          ),
                        ),
                        _divider(context),
                        _settingsTile(
                          context,
                          icon: Icons.language_outlined,
                          title: l10n.language,
                          subtitle: localizationProvider.getLanguageName(
                            localizationProvider.locale.languageCode,
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () => _showLanguageDialog(
                            context,
                            localizationProvider,
                          ),
                        ),
                        _divider(context),
                        _settingsTile(
                          context,
                          icon: Icons.monetization_on_outlined,
                          title: l10n.currency,
                          subtitle:
                              '${currencyProvider.currencyName} (${currencyProvider.currencySymbol})',
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () =>
                              _showCurrencyDialog(context, currencyProvider),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle(context, l10n.dataManagement),
                  const SizedBox(height: 8),
                  _settingsCard(
                    context,
                    child: Column(
                      children: [
                        _settingsTile(
                          context,
                          icon: Icons.backup_outlined,
                          title: l10n.backupRestore,
                          subtitle: l10n.exportImportData,
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BackupPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle(context, l10n.about),
                  const SizedBox(height: 8),
                  _settingsCard(
                    context,
                    child: Column(
                      children: [
                        _settingsTile(
                          context,
                          icon: Icons.info_outline,
                          title: l10n.version,
                          subtitle: '1.0.0',
                          trailing: null,
                        ),
                        _divider(context),
                        _settingsTile(
                          context,
                          icon: Icons.description_outlined,
                          title: l10n.appTitle,
                          subtitle: l10n.appDescription,
                          trailing: null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    LocalizationProvider localizationProvider,
  ) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        title: Text(l10n.language, style: AppTheme.getHeadingSmall(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LocalizationProvider.supportedLocales.map((locale) {
            final isSelected =
                localizationProvider.locale.languageCode == locale.languageCode;
            return ListTile(
              title: Text(
                LocalizationProvider.languageNames[locale.languageCode] ??
                    'English',
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.getTextPrimary(context),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: AppTheme.primaryBlue)
                  : null,
              onTap: () {
                localizationProvider.setLocale(locale);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCurrencyDialog(
    BuildContext context,
    CurrencyProvider currencyProvider,
  ) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        title: Text(l10n.currency, style: AppTheme.getHeadingSmall(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencyProvider.supportedCurrencies.map((currencyCode) {
            final currencyInfo = currencyProvider.getCurrencyInfo(currencyCode);
            final isSelected = currencyProvider.currencyCode == currencyCode;
            return ListTile(
              title: Text(
                currencyInfo['name']!,
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.getTextPrimary(context),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                '${currencyInfo['symbol']} (${currencyInfo['code']})',
                style: TextStyle(color: AppTheme.getTextSecondary(context)),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: AppTheme.primaryBlue)
                  : null,
              onTap: () {
                currencyProvider.setCurrency(currencyCode);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: AppTheme.getHeadingSmall(context)),
  );

  Widget _settingsCard(BuildContext context, {required Widget child}) =>
      Container(
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

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) => ListTile(
    leading: Container(
      width: 40,
      height: 40,
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

  Widget _divider(BuildContext context) => Divider(
    height: 1,
    color: AppTheme.getTextSecondary(context).withOpacity(0.1),
  );
}
