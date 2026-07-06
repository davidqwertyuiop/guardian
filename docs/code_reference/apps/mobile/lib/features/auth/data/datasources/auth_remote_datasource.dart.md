# auth_remote_datasource.dart

* **File Path:** `apps/mobile/lib/features/auth/data/datasources/auth_remote_datasource.dart`
* **Type:** `DART`

---

```dart
import 'package:guardian/core/services/api_service.dart';

class AuthRemoteDataSource {
  Future<String> firebaseExchange(String phone, String idToken) async {
    final response = await ApiService.firebaseExchange(phone, idToken);
    return response['access_token'] as String;
  }
}

```
