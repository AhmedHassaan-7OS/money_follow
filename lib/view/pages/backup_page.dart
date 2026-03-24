import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/core/cubit/backup/backup_cubit.dart';
import 'package:money_follow/core/cubit/backup/backup_state.dart';
import 'package:money_follow/models/backup_models.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/view/widgets/app_snack_bar.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  @override
  void initState() {
    super.initState();
    context.read<BackupCubit>().loadBackupSize();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(l10n.backupRestore),
        centerTitle: true,
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
      ),
      body: BlocConsumer<BackupCubit, BackupState>(
        listener: (context, state) {
          if (state.message != null) {
            state.isSuccess
                ? AppSnackBar.success(context, state.message!)
                : AppSnackBar.error(context, state.message!);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBlue));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoHeader(backupSize: state.backupSize),
                const SizedBox(height: 24),
                Text('Export Data',
                    style: AppTheme.getHeadingSmall(context)),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.share_outlined,
                  title: 'Share Backup File',
                  subtitle: 'Create and share backup file',
                  color: AppTheme.accentGreen,
                  onTap: () =>
                      context.read<BackupCubit>().shareBackup(context),
                ),
                const SizedBox(height: 8),
                _ActionCard(
                  icon: Icons.copy_outlined,
                  title: 'Copy to Clipboard',
                  subtitle: 'Copy backup data to clipboard',
                  color: AppTheme.lightBlue,
                  onTap: () =>
                      context.read<BackupCubit>().copyToClipboard(context),
                ),
                const SizedBox(height: 24),
                Text('Import Data',
                    style: AppTheme.getHeadingSmall(context)),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.file_upload_outlined,
                  title: 'Import from File',
                  subtitle: 'Pick backup.json file',
                  color: AppTheme.accentGreen,
                  onTap: () => _importFromFile(),
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.paste_outlined,
                  title: 'Paste from Clipboard',
                  subtitle: 'Import backup data from clipboard',
                  color: AppTheme.primaryBlue,
                  onTap: () => _importFromClipboard(),
                ),
                const SizedBox(height: 24),
                _NotesCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _importFromFile() async {
    final result =
        await context.read<BackupCubit>().pickAndImportFile(context);
    if (result.success && result.data != null && mounted) {
      _showImportDialog(result);
    } else if (mounted && result.message.isNotEmpty) {
      AppSnackBar.error(context, result.message);
    }
  }

  Future<void> _importFromClipboard() async {
    final result = await context.read<BackupCubit>().importFromClipboard();
    if (result.success && result.data != null && mounted) {
      _showImportDialog(result);
    } else if (mounted && result.message.isNotEmpty) {
      AppSnackBar.error(context, result.message);
    }
  }

  void _showImportDialog(BackupImportResult result) {
    showDialog(
      context: context,
      builder: (dc) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(dc),
        title: Text('Import Backup',
            style: AppTheme.getHeadingSmall(dc)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📅 Date: ${result.backupDate?.split('T')[0] ?? 'Unknown'}',
                style: AppTheme.getBodyMedium(dc)),
            Text('📊 Items: ${result.itemCount}',
                style: AppTheme.getBodyMedium(dc)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Icon(Icons.warning_outlined,
                    color: AppTheme.warningColor, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(
                    'This will replace all current data.',
                    style: TextStyle(
                        color: AppTheme.warningColor, fontSize: 12))),
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dc),
            child: Text('Cancel', style: TextStyle(
                color: AppTheme.getTextSecondary(dc))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dc);
              context.read<BackupCubit>().performRestore(result.data!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}

class _InfoHeader extends StatelessWidget {
  const _InfoHeader({required this.backupSize});
  final double backupSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.backup_outlined, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Text('Data Backup', style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          Text('Keep your financial data safe by creating backups.',
              style: TextStyle(color: Colors.white.withOpacity(0.9),
                  fontSize: 14)),
          const SizedBox(height: 8),
          Text('Current backup size: ${backupSize.toStringAsFixed(2)} MB',
              style: TextStyle(color: Colors.white.withOpacity(0.8),
                  fontSize: 12)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon, required this.title,
    required this.subtitle, required this.color, required this.onTap,
  });
  final IconData icon; final String title;
  final String subtitle; final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.getBodyLarge(context)),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTheme.getBodyMedium(context)),
            ],
          )),
          Icon(Icons.arrow_forward_ios,
              color: AppTheme.getTextSecondary(context), size: 16),
        ]),
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text('Important Notes', style: AppTheme.getBodyLarge(context)),
          ]),
          const SizedBox(height: 12),
          ...[
            '• Backup contains incomes, expenses, and commitments',
            '• Importing replaces all current data',
            '• Keep backup data in a safe location',
          ].map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(t, style: AppTheme.getBodySmall(context)),
              )),
        ],
      ),
    );
  }
}
