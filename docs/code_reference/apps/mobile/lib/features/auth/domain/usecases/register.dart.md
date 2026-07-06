# register.dart

* **File Path:** `apps/mobile/lib/features/auth/domain/usecases/register.dart`
* **Type:** `DART`

---

```dart
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<void> execute(String name, String phone) async {
    // Perform registration
  }
}

```
