import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:guardian/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardian/features/journey/presentation/bloc/journey_bloc.dart';

final locator = GetIt.instance;

Future<void> initDependencies() async {
  // 1. External dependencies
  final prefs = await SharedPreferences.getInstance();
  locator.registerSingleton<SharedPreferences>(prefs);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  locator.registerSingleton<FlutterSecureStorage>(secureStorage);

  // 2. Blocs
  locator.registerLazySingleton<AuthBloc>(() => AuthBloc());
  locator.registerLazySingleton<JourneyBloc>(() => JourneyBloc());
}
