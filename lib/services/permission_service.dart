import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:money_follow/utils/app_localizations_temp.dart';
import 'package:money_follow/utils/localization_extensions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app permissions, especially storage permissions.
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
    return prefs.getBool(_permissionGrantedKey) ?? false;
  }

  static Future<bool> requestPermissionsOnStartup(BuildContext context) async {
    try {
      if (await wasPermissionRequestedOnStartup()) {
        return await getSavedPermissionStatus();
      }

      if (!context.mounted) return false;
      await markPermissionRequestedOnStartup();

      if (!Platform.isAndroid && !Platform.isIOS) {
        await savePermissionStatus(true);
        return true;
      }

      final shouldRequest = await _showInitialPermissionDialog(context);
      if (!shouldRequest) {
        await savePermissionStatus(false);
        return false;
      }

      final hasPermission = Platform.isAndroid
          ? await _requestAndroidPermissions(context)
          : await _requestIOSPermissions(context);

      await savePermissionStatus(hasPermission);
      return hasPermission;
    } catch (e) {
      debugPrint('Error requesting permissions on startup: $e');
      await savePermissionStatus(false);
      return false;
    }
  }

  static Future<bool> checkCurrentPermissionStatus() async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        return true;
      }

      if (Platform.isAndroid) {
        return await _checkAndroidPermissions();
      }

      return await _checkIOSPermissions();
    } catch (e) {
      debugPrint('Error checking permission status: $e');
      return false;
    }
  }

  static Future<bool> requestPermissionsForBackup(BuildContext context) async {
    try {
      final currentStatus = await checkCurrentPermissionStatus();
      if (currentStatus) {
        await savePermissionStatus(true);
        return true;
      }

      if (!context.mounted) return false;
      final shouldRequest = await _showBackupPermissionDialog(context);
      if (!shouldRequest) {
        return false;
      }

      final hasPermission = Platform.isAndroid
          ? await _requestAndroidPermissions(context)
          : await _requestIOSPermissions(context);

      await savePermissionStatus(hasPermission);
      return hasPermission;
    } catch (e) {
      debugPrint('Error requesting permissions for backup: $e');
      return false;
    }
  }

  static Future<bool> _requestAndroidPermissions(BuildContext context) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;

      bool hasPermission = false;

      if (sdkVersion >= 33) {
        final statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();
        hasPermission = statuses.values.every((status) => status.isGranted);
      } else if (sdkVersion >= 30) {
        hasPermission = (await Permission.manageExternalStorage.request()).isGranted;
      } else {
        hasPermission = (await Permission.storage.request()).isGranted;
      }

      if (!hasPermission && context.mounted) {
        final shouldOpenSettings = await _showPermissionDeniedDialog(context);
        if (shouldOpenSettings) {
          await openAppSettings();
          await Future.delayed(const Duration(seconds: 2));
          hasPermission = await _checkAndroidPermissions();
        }
      }

      return hasPermission;
    } catch (e) {
      debugPrint('Error requesting Android permissions: $e');
      return false;
    }
  }

  static Future<bool> _requestIOSPermissions(BuildContext context) async {
    try {
      var hasPermission = (await Permission.photos.request()).isGranted;

      if (!hasPermission && context.mounted) {
        final shouldOpenSettings = await _showPermissionDeniedDialog(context);
        if (shouldOpenSettings) {
          await openAppSettings();
          await Future.delayed(const Duration(seconds: 2));
          hasPermission = await Permission.photos.status.isGranted;
        }
      }

      return hasPermission;
    } catch (e) {
      debugPrint('Error requesting iOS permissions: $e');
      return false;
    }
  }

  static Future<bool> _checkAndroidPermissions() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;

      if (sdkVersion >= 33) {
        return await Permission.photos.status.isGranted &&
            await Permission.videos.status.isGranted &&
            await Permission.audio.status.isGranted;
      }

      if (sdkVersion >= 30) {
        return await Permission.manageExternalStorage.status.isGranted;
      }

      return await Permission.storage.status.isGranted;
    } catch (e) {
      debugPrint('Error checking Android permissions: $e');
      return false;
    }
  }

  static Future<bool> _checkIOSPermissions() async {
    try {
      return await Permission.photos.status.isGranted;
    } catch (e) {
      debugPrint('Error checking iOS permissions: $e');
      return false;
    }
  }

  static Future<bool> _showInitialPermissionDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.permissionWelcomeTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.permissionStartupExplanation,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                for (final reason in l10n.permissionStartupReasons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $reason'),
                  ),
                const SizedBox(height: 12),
                Text(
                  l10n.permissionStartupFooter,
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.skipForNowLabel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.grantPermissionLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  static Future<bool> _showBackupPermissionDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.backupPermissionTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.backupPermissionExplanation),
                const SizedBox(height: 12),
                Text(l10n.permissionRequiredForLabel),
                const SizedBox(height: 4),
                for (final reason in l10n.backupPermissionReasons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $reason'),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.closeLabel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.grantPermissionLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  static Future<bool> _showPermissionDeniedDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.permissionDeniedTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.permissionDeniedMessage),
                const SizedBox(height: 12),
                Text(
                  l10n.permissionDeniedHint,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.continueWithoutPermissionLabel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.openSettingsLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  static Future<void> showPermissionStatusDialog(BuildContext context) async {
    final hasPermission = await checkCurrentPermissionStatus();
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          hasPermission ? l10n.permissionsGrantedTitle : l10n.permissionsDeniedTitle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasPermission
                  ? l10n.permissionsGrantedMessage
                  : l10n.permissionsDeniedMessage,
            ),
            if (!hasPermission) ...[
              const SizedBox(height: 12),
              Text(
                l10n.permissionsDeniedHint,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.okLabel),
          ),
          if (!hasPermission)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.openSettingsLabel),
            ),
        ],
      ),
    );
  }
}
