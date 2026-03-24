import 'package:flutter/material.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/view/widgets/settings/settings_layout_helpers.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key, required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: l10n.about),
        SettingsCard(
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.info_outline,
                title: l10n.version,
                subtitle: '1.0.0',
                trailing: null,
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.description_outlined,
                title: l10n.appTitle,
                subtitle: l10n.appDescription,
                trailing: null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
