# auth_repository_impl.dart

* **File Path:** `apps/mobile/lib/features/auth/data/repositories/auth_repository_impl.dart`
* **Type:** `DART`

---

```dart
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource = AuthRemoteDataSource();

  @override
  Future<String> firebaseExchange(String phone, String idToken) async {
    return await remoteDataSource.firebaseExchange(phone, idToken);
  }
}

```
