import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/cubit/theme/theme_cubit.dart';
import 'package:money_follow/core/cubit/theme/theme_state.dart';
import 'package:money_follow/core/cubit/localization/localization_cubit.dart';
import 'package:money_follow/core/cubit/localization/localization_state.dart';
import 'package:money_follow/core/cubit/currency/currency_cubit.dart';
import 'package:money_follow/core/cubit/currency/currency_state.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/view/pages/settings/widgets/settings_layout_helpers.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key, required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: l10n.appearance),
        SettingsCard(
          child: Column(
            children: [
              _ThemeTile(l10n: l10n),
              const SettingsDivider(),
              _LanguageTile(l10n: l10n),
              const SettingsDivider(),
              _CurrencyTile(l10n: l10n),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return SettingsTile(
          icon: Icons.dark_mode_outlined,
          title: l10n.darkMode,
          subtitle: state.isDarkMode ? l10n.darkThemeEnabled : l10n.lightThemeEnabled,
          trailing: Switch(
            value: state.isDarkMode,
            onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
            activeColor: AppTheme.primaryBlue,
          ),
        );
      },
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationCubit, LocalizationState>(
      builder: (context, state) {
        final cubit = context.read<LocalizationCubit>();
        return SettingsTile(
          icon: Icons.language_outlined,
          title: l10n.language,
          subtitle: cubit.getLanguageName(state.locale.languageCode),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLanguageDialog(context, cubit, state.locale, l10n),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, LocalizationCubit cubit, Locale current, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dc) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        title: Text(l10n.language, style: AppTheme.getHeadingSmall(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LocalizationCubit.supportedLocales.map((locale) {
            final isSelected = current.languageCode == locale.languageCode;
            return ListTile(
              title: Text(
                cubit.getLanguageName(locale.languageCode),
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.getTextPrimary(context),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryBlue) : null,
              onTap: () {
                cubit.setLocale(locale);
                Navigator.pop(dc);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, state) {
        final cubit = context.read<CurrencyCubit>();
        return SettingsTile(
          icon: Icons.monetization_on_outlined,
          title: l10n.currency,
          subtitle: '${state.currencyName} (${state.currencySymbol})',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showCurrencyDialog(context, cubit, state, l10n),
        );
      },
    );
  }

  void _showCurrencyDialog(BuildContext context, CurrencyCubit cubit, CurrencyState state, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dc) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        title: Text(l10n.currency, style: AppTheme.getHeadingSmall(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: CurrencyData.supportedCurrencies.map((code) {
            final info = CurrencyData.getCurrencyInfo(code);
            final isSelected = state.currencyCode == code;
            return ListTile(
              title: Text(info['name']!, style: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : AppTheme.getTextPrimary(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              )),
              subtitle: Text('${info['symbol']} (${info['code']})', style: TextStyle(color: AppTheme.getTextSecondary(context))),
              trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryBlue) : null,
              onTap: () {
                cubit.setCurrency(code);
                Navigator.pop(dc);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
