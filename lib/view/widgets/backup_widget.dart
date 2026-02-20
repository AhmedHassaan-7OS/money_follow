import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/view/pages/backup_page.dart';

/// Simple backup widget that can be added to settings or main screen
class BackupWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      color: AppTheme.getCardColor(context),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryBlue,
          child: const Icon(Icons.backup, color: Colors.white),
        ),
        title: Text('Backup & Restore', style: AppTheme.getBodyLarge(context)),
        subtitle: Text(
          'Export or import your financial data',
          style: AppTheme.getBodyMedium(context),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.getTextSecondary(context),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BackupPage()),
          );
        },
      ),
    );
  }
}

/// Quick backup actions widget for dashboard
class QuickBackupActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.getCardColor(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Backup', style: AppTheme.getHeadingSmall(context)),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BackupPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BackupPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.upload, size: 18),
                    label: const Text('Import'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
