# token_model.dart

* **File Path:** `apps/mobile/lib/features/auth/data/models/token_model.dart`
* **Type:** `DART`

---

```dart
class TokenModel {
  final String accessToken;
  final String refreshToken;

  TokenModel({required this.accessToken, required this.refreshToken});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}

```
