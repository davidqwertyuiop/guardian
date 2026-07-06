# dependency_injection.dart

* **File Path:** `apps/mobile/lib/bootstrap/dependency_injection.dart`
* **Type:** `DART`

---

```dart
import 'package:guardian/export.dart';

final locator = GetIt.instance;

Future<AuthStep> initDependencies() async {
  // 1. External dependencies
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);

  const secureStorage = FlutterSecureStorage();
  locator.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Determine initial onboarding/authentication step
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  final token = await TokenManager().getAccessToken();
  final hasJwt = token != null && token.isNotEmpty;
  final initialStep = (onboardingCompleted && hasJwt)
      ? AuthStep.completed
      : AuthStep.welcome;

  return initialStep;
}

```
