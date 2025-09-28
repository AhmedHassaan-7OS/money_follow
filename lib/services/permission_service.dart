import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app permissions, especially storage permissions
class PermissionService {
  // Singleton instance
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // SharedPreferences keys
  static const String _permissionRequestedKey = 'permission_requested_on_startup';
  static const String _permissionGrantedKey = 'storage_permission_granted';

  /// Check if permissions were already requested on app startup
  static Future<bool> wasPermissionRequestedOnStartup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionRequestedKey) ?? false;
  }

  /// Mark that permissions were requested on startup
  static Future<void> markPermissionRequestedOnStartup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionRequestedKey, true);
  }

  /// Save permission status
  static Future<void> savePermissionStatus(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionGrantedKey, granted);
  }

  /// Get saved permission status
  static Future<bool> getSavedPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionGrantedKey) ?? false;
  }

  /// Request storage permissions on app startup
  static Future<bool> requestPermissionsOnStartup(BuildContext context) async {
    try {
      // Check if already requested in this session
      if (await wasPermissionRequestedOnStartup()) {
        return await getSavedPermissionStatus();
      }

      // Mark as requested
      await markPermissionRequestedOnStartup();

      if (!Platform.isAndroid && !Platform.isIOS) {
        await savePermissionStatus(true);
        return true; // Other platforms don't need storage permissions
      }

      // Show initial dialog explaining why we need permissions
      final shouldRequest = await _showInitialPermissionDialog(context);
      if (!shouldRequest) {
        await savePermissionStatus(false);
        return false;
      }

      // Request permissions based on platform
      bool hasPermission = false;
      
      if (Platform.isAndroid) {
        hasPermission = await _requestAndroidPermissions(context);
      } else if (Platform.isIOS) {
        hasPermission = await _requestIOSPermissions(context);
      }

      await savePermissionStatus(hasPermission);
      return hasPermission;
    } catch (e) {
      print('Error requesting permissions on startup: $e');
      await savePermissionStatus(false);
      return false;
    }
  }

  /// Check current permission status without requesting
  static Future<bool> checkCurrentPermissionStatus() async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        return true; // Other platforms don't need storage permissions
      }

      if (Platform.isAndroid) {
        return await _checkAndroidPermissions();
      } else if (Platform.isIOS) {
        return await _checkIOSPermissions();
      }

      return false;
    } catch (e) {
      print('Error checking permission status: $e');
      return false;
    }
  }

  /// Request permissions for backup operations (with context for dialogs)
  static Future<bool> requestPermissionsForBackup(BuildContext context) async {
    try {
      // First check current status
      final currentStatus = await checkCurrentPermissionStatus();
      if (currentStatus) {
        await savePermissionStatus(true);
        return true;
      }

      // Show dialog explaining why we need permissions for backup
      final shouldRequest = await _showBackupPermissionDialog(context);
      if (!shouldRequest) {
        return false;
      }

      // Request permissions based on platform
      bool hasPermission = false;
      
      if (Platform.isAndroid) {
        hasPermission = await _requestAndroidPermissions(context);
      } else if (Platform.isIOS) {
        hasPermission = await _requestIOSPermissions(context);
      }

      await savePermissionStatus(hasPermission);
      return hasPermission;
    } catch (e) {
      print('Error requesting permissions for backup: $e');
      return false;
    }
  }

  /// Request Android permissions based on SDK version
  static Future<bool> _requestAndroidPermissions(BuildContext context) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;

      print('Android SDK Version: $sdkVersion');

      bool hasPermission = false;

      if (sdkVersion >= 33) {
        // Android 13+: Request granular media permissions
        final statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();
        
        hasPermission = statuses.values.every((status) => status.isGranted);
        print('Android 13+ permissions: ${hasPermission ? 'granted' : 'denied'}');
        
      } else if (sdkVersion >= 30) {
        // Android 11 & 12: Request manage external storage
        final status = await Permission.manageExternalStorage.request();
        hasPermission = status.isGranted;
        print('Manage external storage: ${hasPermission ? 'granted' : 'denied'}');
        
      } else {
        // Below Android 11: Request storage permission
        final status = await Permission.storage.request();
        hasPermission = status.isGranted;
        print('Storage permission: ${hasPermission ? 'granted' : 'denied'}');
      }

      // If permission denied, show settings dialog
      if (!hasPermission && context.mounted) {
        final shouldOpenSettings = await _showPermissionDeniedDialog(context);
        if (shouldOpenSettings) {
          await openAppSettings();
          await Future.delayed(const Duration(seconds: 2));
          
          // Re-check permissions after settings
          hasPermission = await _checkAndroidPermissions();
        }
      }

      return hasPermission;
    } catch (e) {
      print('Error requesting Android permissions: $e');
      return false;
    }
  }

  /// Request iOS permissions
  static Future<bool> _requestIOSPermissions(BuildContext context) async {
    try {
      // iOS uses photo library access for file operations
      final status = await Permission.photos.request();
      final hasPermission = status.isGranted;

      if (!hasPermission && context.mounted) {
        final shouldOpenSettings = await _showPermissionDeniedDialog(context);
        if (shouldOpenSettings) {
          await openAppSettings();
          await Future.delayed(const Duration(seconds: 2));
          
          // Re-check permissions after settings
          return await Permission.photos.status.isGranted;
        }
      }

      return hasPermission;
    } catch (e) {
      print('Error requesting iOS permissions: $e');
      return false;
    }
  }

  /// Check Android permissions without requesting
  static Future<bool> _checkAndroidPermissions() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;

      if (sdkVersion >= 33) {
        return await Permission.photos.status.isGranted &&
            await Permission.videos.status.isGranted &&
            await Permission.audio.status.isGranted;
      } else if (sdkVersion >= 30) {
        return await Permission.manageExternalStorage.status.isGranted;
      } else {
        return await Permission.storage.status.isGranted;
      }
    } catch (e) {
      print('Error checking Android permissions: $e');
      return false;
    }
  }

  /// Check iOS permissions without requesting
  static Future<bool> _checkIOSPermissions() async {
    try {
      return await Permission.photos.status.isGranted;
    } catch (e) {
      print('Error checking iOS permissions: $e');
      return false;
    }
  }

  /// Show initial permission dialog on app startup
  static Future<bool> _showInitialPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('مرحباً بك في Money Follow'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لتوفير أفضل تجربة لك، نحتاج إذن الوصول لملفات الجهاز لـ:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text('• إنشاء نسخ احتياطية من بياناتك المالية'),
            Text('• استيراد النسخ الاحتياطية السابقة'),
            Text('• مشاركة البيانات بين الأجهزة'),
            SizedBox(height: 12),
            Text(
              'يمكنك رفض هذا الإذن، لكن ستكون ميزات النسخ الاحتياطي محدودة.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('تخطي الآن'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('منح الإذن'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Show permission dialog for backup operations
  static Future<bool> _showBackupPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('إذن الوصول للملفات مطلوب'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لاستخدام ميزات النسخ الاحتياطي، نحتاج إذن الوصول لملفات الجهاز.',
            ),
            SizedBox(height: 12),
            Text('هذا الإذن ضروري لـ:'),
            Text('• حفظ ملفات النسخ الاحتياطية'),
            Text('• قراءة ملفات النسخ الاحتياطية'),
            Text('• مشاركة البيانات'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('منح الإذن'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Show permission denied dialog with option to open settings
  static Future<bool> _showPermissionDeniedDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('تم رفض الإذن'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لاستخدام ميزات النسخ الاحتياطي، يرجى منح إذن الوصول للملفات من إعدادات التطبيق.',
            ),
            SizedBox(height: 12),
            Text(
              'يمكنك فتح الإعدادات الآن أو المتابعة بدون هذه الميزة.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('المتابعة بدون الإذن'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Show permission status info dialog
  static Future<void> showPermissionStatusDialog(BuildContext context) async {
    final hasPermission = await checkCurrentPermissionStatus();
    
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(hasPermission ? 'الصلاحيات ممنوحة' : 'الصلاحيات مرفوضة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasPermission 
                ? 'تم منح جميع الصلاحيات المطلوبة. يمكنك استخدام جميع ميزات النسخ الاحتياطي.'
                : 'لم يتم منح صلاحيات الوصول للملفات. ميزات النسخ الاحتياطي محدودة.',
            ),
            if (!hasPermission) ...[
              const SizedBox(height: 12),
              const Text(
                'لتفعيل جميع الميزات، يرجى منح الصلاحيات من إعدادات التطبيق.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
          if (!hasPermission)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('فتح الإعدادات'),
            ),
        ],
      ),
    );
  }
}
