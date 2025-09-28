import 'package:flutter/material.dart';
import 'package:money_follow/config/app_theme.dart';
import 'package:money_follow/models/backup_models.dart';
import 'package:money_follow/services/backup_service.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _isLoading = false;
  double _backupSize = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBackupSize();
  }

  Future<void> _loadBackupSize() async {
    final size = await BackupService.getBackupSize();
    setState(() {
      _backupSize = size;
    });
  }

  Future<void> _exportBackup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await BackupService.shareBackup(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result
                  ? 'Backup exported successfully!'
                  : 'Failed to export backup',
            ),
            backgroundColor: result
                ? AppTheme.accentGreen
                : AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _copyToClipboard() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await BackupService.copyBackupToClipboard(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Backup copied to clipboard! You can paste it anywhere.'
                  : 'Failed to copy backup',
            ),
            backgroundColor: success
                ? AppTheme.accentGreen
                : AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _importFromClipboard() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await BackupService.importFromClipboard();

      if (mounted) {
        if (result.success && result.data != null) {
          _showImportDialog(result);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show import options dialog
  Future<void> _importFromFile() async {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.getCardColor(context),
          title: Text(
            'Import Backup',
            style: AppTheme.getHeadingSmall(context),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose how you want to import your backup:',
                style: AppTheme.getBodyMedium(context),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Tip: If file selection doesn\'t work, use manual input to paste your backup data.',
                  style: TextStyle(fontSize: 11, color: AppTheme.lightBlue),
                ),
              ),
              const SizedBox(height: 20),

              // Pick File Option
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.file_upload_outlined,
                    color: AppTheme.accentGreen,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Select File',
                  style: AppTheme.getBodyLarge(context),
                ),
                subtitle: Text(
                  'Choose backup.json file from device',
                  style: AppTheme.getBodySmall(context),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndImportFile();
                },
              ),

              const SizedBox(height: 8),

              // Manual Input Option
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Manual Input',
                  style: AppTheme.getBodyLarge(context),
                ),
                subtitle: Text(
                  'Select backup.json file or paste backup data manually',
                  style: AppTheme.getBodySmall(context),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _showManualInputDialog();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.getTextSecondary(context)),
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Pick and import backup file using file picker
  Future<void> _pickAndImportFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await BackupService.pickAndImportFile(context);

      if (mounted) {
        if (result.success && result.data != null) {
          _showImportDialog(result);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show manual input dialog for backup data
  Future<void> _showManualInputDialog() async {
    final TextEditingController textController = TextEditingController();

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.getCardColor(context),
          title: Text(
            'Manual Import',
            style: AppTheme.getHeadingSmall(context),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Paste your backup JSON data here:',
                  style: AppTheme.getBodyMedium(context),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Paste backup data...',
                  ),
                  maxLines: 8,
                  style: AppTheme.getBodyMedium(context),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.getTextSecondary(context)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _importFromText(textController.text);
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

  /// Import from text input
  Future<void> _importFromText(String backupText) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await BackupService.importFromText(backupText);

      if (mounted) {
        if (result.success && result.data != null) {
          _showImportDialog(result);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showImportDialog(BackupImportResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        title: Text('Import Backup', style: AppTheme.getHeadingSmall(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Backup Details:', style: AppTheme.getBodyLarge(context)),
            const SizedBox(height: 8),
            Text(
              '📅 Date: ${result.backupDate?.split('T')[0] ?? 'Unknown'}',
              style: AppTheme.getBodyMedium(context),
            ),
            Text(
              '📊 Items: ${result.itemCount}',
              style: AppTheme.getBodyMedium(context),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warningColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: AppTheme.warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will replace all your current data. This action cannot be undone.',
                      style: TextStyle(
                        color: AppTheme.warningColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.getTextSecondary(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performRestore(result.data!);
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

  Future<void> _performRestore(Map<String, dynamic> data) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await BackupService.restoreBackup(
        data,
        clearExisting: true,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Backup imported successfully!'
                  : 'Failed to import backup',
            ),
            backgroundColor: success
                ? AppTheme.accentGreen
                : AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        if (success) {
          // Refresh backup size
          _loadBackupSize();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.backup_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Data Backup',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Keep your financial data safe by creating backups. Export your data to share across devices or import previous backups.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Current backup size: ${_backupSize.toStringAsFixed(2)} MB',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Export Section
                  Text('Export Data', style: AppTheme.getHeadingSmall(context)),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.share_outlined,
                    title: 'Share Backup File',
                    subtitle: 'Create and share backup file',
                    color: AppTheme.accentGreen,
                    onTap: _exportBackup,
                  ),
                  const SizedBox(height: 8),
                  _buildActionCard(
                    icon: Icons.copy_outlined,
                    title: 'Copy to Clipboard',
                    subtitle: 'Copy backup data to clipboard',
                    color: AppTheme.lightBlue,
                    onTap: _copyToClipboard,
                  ),
                  const SizedBox(height: 24),

                  // Import Section
                  Text('Import Data', style: AppTheme.getHeadingSmall(context)),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.file_upload_outlined,
                    title: 'Import from File',
                    subtitle: 'Pick backup.json file or paste data manually',
                    color: AppTheme.accentGreen,
                    onTap: _importFromFile,
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    icon: Icons.paste_outlined,
                    title: 'Paste from Clipboard',
                    subtitle: 'Import backup data from clipboard',
                    color: AppTheme.primaryBlue,
                    onTap: _importFromClipboard,
                  ),
                  const SizedBox(height: 24),

                  // Warning Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.getTextSecondary(
                          context,
                        ).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Important Notes',
                              style: AppTheme.getBodyLarge(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoPoint(
                          '• Backup contains all your incomes, expenses, and commitments',
                        ),
                        _buildInfoPoint(
                          '• You can share backup files or copy to clipboard',
                        ),
                        _buildInfoPoint(
                          '• Import by selecting .json file or pasting data manually',
                        ),
                        _buildInfoPoint(
                          '• Importing a backup will replace all current data',
                        ),
                        _buildInfoPoint(
                          '• File import works with exported backup files',
                        ),
                        _buildInfoPoint(
                          '• Keep backup data in a safe location',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.getBodyLarge(context)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTheme.getBodyMedium(context)),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.getTextSecondary(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: AppTheme.getBodyMedium(context)),
    );
  }
}
