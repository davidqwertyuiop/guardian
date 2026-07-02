import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_state.dart';
import 'package:guardian/features/journey/presentation/bloc/journey_bloc.dart';
import 'package:guardian/features/home/presentation/bloc/home_bloc.dart';
import 'package:guardian/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:guardian/core/security/token_manager.dart';
import 'package:guardian/core/services/firebase_auth_service.dart';

final locator = GetIt.instance;

Future<void> initDependencies() async {
  // 1. External dependencies
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  locator.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Determine initial onboarding/authentication step
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  final token = await TokenManager().getAccessToken();
  final hasJwt = token != null && token.isNotEmpty;
  final initialStep = (onboardingCompleted && hasJwt)
      ? AuthStep.completed
      : AuthStep.welcome;

  // 2. Services
  locator.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthService(),
  );

  // 3. Blocs
  locator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(initialStep: initialStep),
  );
  locator.registerLazySingleton<JourneyBloc>(() => JourneyBloc());
  locator.registerLazySingleton<HomeBloc>(() => HomeBloc());
  locator.registerLazySingleton<SettingsBloc>(() => SettingsBloc());
}
