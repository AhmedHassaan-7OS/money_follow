import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/cubit/bank_sms/bank_sms_cubit.dart';
import 'package:money_follow/core/cubit/commitment_reminder/commitment_reminder_cubit.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

import 'package:money_follow/view/pages/settings/widgets/appearance_section.dart';
import 'package:money_follow/view/pages/settings/widgets/data_management_section.dart';
import 'package:money_follow/view/pages/settings/widgets/bank_sms_section.dart';
import 'package:money_follow/view/pages/settings/widgets/commitment_reminder_section.dart';
import 'package:money_follow/view/pages/settings/widgets/about_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BankSmsCubit>().loadState();
    context.read<CommitmentReminderCubit>().loadSettings();
  }

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
