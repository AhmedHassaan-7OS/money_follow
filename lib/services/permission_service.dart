import 'package:flutter/material.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/utils/localization_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app permissions.
/// Modern Android uses scoped storage and SAF (Storage Access Framework),
/// meaning internal app storage and file picker operations require 0 permissions.
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  static const String _permissionRequestedKey = 'permission_requested_on_startup';
  static const String _permissionGrantedKey = 'storage_permission_granted';

  static Future<bool> wasPermissionRequestedOnStartup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionRequestedKey) ?? false;
  }

  static Future<void> markPermissionRequestedOnStartup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionRequestedKey, true);
  }

  static Future<void> savePermissionStatus(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionGrantedKey, granted);
  }

  static Future<bool> getSavedPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionGrantedKey) ?? true;
  }

  static Future<bool> requestPermissionsOnStartup(BuildContext context) async {
    await savePermissionStatus(true);
    return true;
  }

  static Future<bool> checkCurrentPermissionStatus() async {
    return true;
  }

  static Future<bool> requestPermissionsForBackup(BuildContext context) async {
    await savePermissionStatus(true);
    return true;
  }

  static Future<void> showPermissionStatusDialog(BuildContext context) async {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.permissionsGrantedTitle),
        content: Text(l10n.permissionsGrantedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.okLabel),
          ),
        ],
      ),
    );
  }
}
