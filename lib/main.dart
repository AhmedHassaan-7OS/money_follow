import 'package:flutter/material.dart';
import 'package:money_follow/core/app_material.dart';
import 'package:money_follow/core/app_providers.dart';
import 'package:money_follow/core/app_lifecycle_manager.dart';
import 'package:money_follow/services/commitment_reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await CommitmentReminderService.initialize();
  } catch (_) {
    // Reminder initialization is optional on unsupported platforms.
  }

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
