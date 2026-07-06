# api_base.dart

* **File Path:** `apps/mobile/lib/core/services/api/api_base.dart`
* **Type:** `DART`

---

```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class ApiBase {
  static const String baseUrl = 'https://guardian.shadowchat.xyz';

  static String extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      return decoded['message'] ?? 'An unknown error occurred.';
    } catch (_) {
      return 'Server error. Please try again.';
    }
  }

  static Never rethrowNetworkError(Object e) {
    if (e is http.ClientException || e is SocketException) {
      throw Exception(
        'Cannot connect to Guardian servers. Please check your connection.',
      );
    }
    throw e;
  }
}

```
