// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/main.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    
    // Register dependencies if they aren't already registered
    if (!locator.isRegistered<SharedPreferences>()) {
      locator.registerSingleton<SharedPreferences>(prefs);
    }
    if (!locator.isRegistered<FlutterSecureStorage>()) {
      locator.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
    }

    // Mock method channel for FlutterSecureStorage to prevent PlatformException
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.itrix.com.br/flutter_secure_storage'),
      (MethodCall methodCall) async {
        return null;
      },
    );
  });

  tearDown(() async {
    await locator.reset();
  });

  testWidgets('Splash screen builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GuardianApp(initialStep: AuthStep.splash));

    // Verify that splash logo or name is present
    expect(find.text('guardian'), findsOneWidget);

    // Settle the splash transition timer
    await tester.pumpAndSettle(const Duration(milliseconds: 3000));
  });
}
