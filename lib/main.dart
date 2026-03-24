import 'package:flutter/material.dart';
import 'package:money_follow/core/app_material.dart';
import 'package:money_follow/core/app_providers.dart';
import 'package:money_follow/core/app_lifecycle_manager.dart';
import 'package:money_follow/utils/system_detection_helper.dart';
import 'package:money_follow/services/commitment_reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await CommitmentReminderService.initialize();
  } catch (e) {
    debugPrint('Commitment reminders plugin unavailable: $e');
  }
  SystemDetectionHelper.printSystemInfo();
  
  final navigatorKey = GlobalKey<NavigatorState>();
  
  runApp(
    AppProviders(
      child: AppLifecycleManager(
        navigatorKey: navigatorKey,
        child: AppMaterial(navigatorKey: navigatorKey),
      ),
    ),
  );
}
