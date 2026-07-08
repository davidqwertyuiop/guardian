import 'package:guardian/export.dart';
import 'package:guardian/features/family/di/family_injection.dart';
import 'package:guardian/features/notifications/data/notification_repository.dart';

final locator = GetIt.instance;

Future<AuthStep> initDependencies() async {
  // 1. External dependencies
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);

  const secureStorage = FlutterSecureStorage();
  locator.registerSingleton<FlutterSecureStorage>(secureStorage);
  locator.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(),
  );
  initFamilyInjection(locator);

  // Determine initial onboarding/authentication step
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  final token = await TokenManager().getAccessToken();
  final hasJwt = token != null && token.isNotEmpty;
  final initialStep = (onboardingCompleted && hasJwt)
      ? AuthStep.completed
      : AuthStep.welcome;

  return initialStep;
}
