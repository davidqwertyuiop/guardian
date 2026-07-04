// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:guardian/main.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_state.dart';

void main() {
  testWidgets('Splash screen builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GuardianApp(initialStep: AuthStep.welcome));

    // Verify that splash logo or name is present
    expect(find.text('guardian'), findsOneWidget);

    // Settle the splash transition timer
    await tester.pumpAndSettle(const Duration(milliseconds: 3000));
  });
}
