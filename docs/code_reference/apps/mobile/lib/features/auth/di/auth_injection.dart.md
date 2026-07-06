# auth_injection.dart

* **File Path:** `apps/mobile/lib/features/auth/di/auth_injection.dart`
* **Type:** `DART`

---

```dart
import 'package:get_it/get_it.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';

void initAuthInjection(GetIt locator) {
  // Repository
  locator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
}

```
