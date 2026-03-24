import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_follow/core/app_material.dart';
import 'package:money_follow/core/app_providers.dart';
import 'package:money_follow/core/app_lifecycle_manager.dart';

void main() {
  testWidgets('App initializes without crashing', (WidgetTester tester) async {
    final navKey = GlobalKey<NavigatorState>();
    
    await tester.pumpWidget(
      AppProviders(
        child: AppLifecycleManager(
          navigatorKey: navKey,
          child: AppMaterial(navigatorKey: navKey),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(AppMaterial), findsOneWidget);
  });
}
