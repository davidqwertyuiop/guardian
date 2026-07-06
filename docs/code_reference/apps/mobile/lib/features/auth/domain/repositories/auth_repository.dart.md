# auth_repository.dart

* **File Path:** `apps/mobile/lib/features/auth/domain/repositories/auth_repository.dart`
* **Type:** `DART`

---

```dart
abstract class AuthRepository {
  Future<String> firebaseExchange(String phone, String idToken);
}

```
