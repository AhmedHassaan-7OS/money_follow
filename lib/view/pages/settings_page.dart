import 'package:flutter/material.dart';
import 'dart:io';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

import 'package:money_follow/view/widgets/settings/appearance_section.dart';
import 'package:money_follow/view/widgets/settings/data_management_section.dart';
import 'package:money_follow/view/widgets/settings/bank_sms_section.dart';
import 'package:money_follow/view/widgets/settings/commitment_reminder_section.dart';
import 'package:money_follow/view/widgets/settings/about_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
          AppearanceSection(l10n: l10n),
          const SizedBox(height: 24),
          DataManagementSection(l10n: l10n),
          const SizedBox(height: 24),
          if (Platform.isAndroid) ...[
            const BankSmsSection(),
            const SizedBox(height: 24),
            const CommitmentReminderSection(),
            const SizedBox(height: 24),
          ],
          AboutSection(l10n: l10n),
        ],
      ),
    );
  }
}
