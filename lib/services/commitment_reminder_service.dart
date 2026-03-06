import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:money_follow/models/commitment_model.dart';
import 'package:money_follow/repository/commitment_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommitmentReminderSettings {
  const CommitmentReminderSettings({
    required this.enabled,
    required this.hoursBefore,
  });

  final bool enabled;
  final int hoursBefore;
}

class CommitmentReminderService {
  CommitmentReminderService._();

  static const String _enabledKey = 'commitment_reminder_enabled';
  static const String _hoursBeforeKey = 'commitment_reminder_hours_before';
  static const String _notifiedPrefix = 'commitment_notified_';

  static const int _channelId = 7001;
  static const String _channelKey = 'commitment_reminders_channel';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static bool _pluginAvailable = false;

  static bool get isSupportedPlatform => !kIsWeb;

  static Future<void> initialize() async {
    if (!isSupportedPlatform) {
      _pluginAvailable = false;
      return;
    }
    if (_isInitialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    try {
      await _plugin.initialize(settings).timeout(const Duration(seconds: 2));
      _pluginAvailable = true;
      _isInitialized = true;
    } on MissingPluginException {
      _pluginAvailable = false;
    } catch (_) {
      _pluginAvailable = false;
    }
  }

  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<CommitmentReminderSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return CommitmentReminderSettings(
      enabled: prefs.getBool(_enabledKey) ?? false,
      hoursBefore: prefs.getInt(_hoursBeforeKey) ?? 24,
    );
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  static Future<void> setHoursBefore(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hoursBeforeKey, hours);
  }

  static Future<void> checkAndNotifyDueCommitments() async {
    if (!isSupportedPlatform) return;
    if (!_isInitialized) {
      await initialize();
    }
    if (!_pluginAvailable) return;

    final settings = await getSettings();
    if (!settings.enabled) return;

    final commitments = await CommitmentRepository().getAllSortedByDueDate();
    final now = DateTime.now();

    for (final commitment in commitments.where((c) => !c.isCompleted)) {
      final dueDate = DateTime.tryParse(commitment.dueDate);
      final id = commitment.id;
      if (dueDate == null || id == null) continue;

      final dueMoment = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        9,
      );
      final remindFrom = dueMoment.subtract(Duration(hours: settings.hoursBefore));

      if (now.isBefore(remindFrom) || now.isAfter(dueMoment)) {
        continue;
      }

      final marker = _markerKey(
        commitmentId: id,
        dueDate: commitment.dueDate,
        hoursBefore: settings.hoursBefore,
      );
      if (await _wasNotified(marker)) {
        continue;
      }

      await _showReminder(commitment, dueMoment);
      await _markNotified(marker);
    }
  }

  static Future<void> _showReminder(
    CommitmentModel commitment,
    DateTime dueMoment,
  ) async {
    if (!_pluginAvailable) return;

    const androidDetails = AndroidNotificationDetails(
      _channelKey,
      'Commitment Reminders',
      channelDescription: 'Reminders for upcoming commitments',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);
    final dueText =
        '${dueMoment.year}-${dueMoment.month.toString().padLeft(2, '0')}-${dueMoment.day.toString().padLeft(2, '0')}';

    try {
      await _plugin.show(
        _channelId + (commitment.id ?? 0),
        'Commitment is due soon',
        '${commitment.title} - $dueText',
        details,
        payload: '${commitment.id}',
      ).timeout(const Duration(seconds: 2));
    } on MissingPluginException {
      _pluginAvailable = false;
    } catch (_) {
      _pluginAvailable = false;
    }
  }

  static String _markerKey({
    required int commitmentId,
    required String dueDate,
    required int hoursBefore,
  }) {
    return '$_notifiedPrefix${commitmentId}_${dueDate}_$hoursBefore';
  }

  static Future<bool> _wasNotified(String markerKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(markerKey) ?? false;
  }

  static Future<void> _markNotified(String markerKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(markerKey, true);
  }

  static Future<void> clearReminderMarkersForCommitment(int commitmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where(
      (key) => key.startsWith('$_notifiedPrefix$commitmentId'),
    );

    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  @visibleForTesting
  static Future<void> clearAllReminderMarkers() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_notifiedPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
