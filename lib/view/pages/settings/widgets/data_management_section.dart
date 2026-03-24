import 'package:flutter/material.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/view/pages/backup_page.dart';
import 'package:money_follow/view/pages/settings/widgets/settings_layout_helpers.dart';

class DataManagementSection extends StatelessWidget {
  const DataManagementSection({super.key, required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: l10n.dataManagement),
        SettingsCard(
          child: SettingsTile(
            icon: Icons.backup_outlined,
            title: l10n.backupRestore,
            subtitle: l10n.exportImportData,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BackupPage()),
              );
            },
          ),
        ),
      ],
    );
  }
}
