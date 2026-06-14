import 'package:get_it/get_it.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/login.dart';

void initAuthInjection(GetIt locator) {
  // Repository
  locator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  // Usecases
  locator.registerLazySingleton(() => LoginUseCase(locator()));
}
