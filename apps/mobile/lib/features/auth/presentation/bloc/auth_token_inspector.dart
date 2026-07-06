import 'dart:convert';
import 'dart:developer';

class AuthTokenInspector {
  const AuthTokenInspector._();

  static bool isExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = _decodePayload(parts[1]);
      final exp = payload['exp'];
      if (exp is! int) return false;

      final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now()
          .add(const Duration(seconds: 10))
          .isAfter(expiryTime);
    } catch (e) {
      log('Error decoding JWT token: $e');
      return true;
    }
  }

  static Map<String, dynamic> _decodePayload(String encodedPayload) {
    final normalized = base64Url.normalize(encodedPayload);
    final payloadText = utf8.decode(base64Url.decode(normalized));
    return json.decode(payloadText) as Map<String, dynamic>;
  }
}
