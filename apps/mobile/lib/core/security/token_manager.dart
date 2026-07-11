import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:guardian/core/services/api/api_base.dart';
import 'secure_storage.dart';

class TokenManager {
  final SecureStorage _secureStorage = SecureStorage();
  static const String _accessTokenKey = 'jwt_access_token';
  static const String _refreshTokenKey = 'jwt_refresh_token';

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(_accessTokenKey, token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(_refreshTokenKey, token);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  Future<String?> getAccessToken() async {
    final token = await _secureStorage.read(_accessTokenKey);
    if (token == null || token.isEmpty) return null;

    if (_isExpired(token)) {
      final refreshToken = await getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty && !_isExpired(refreshToken)) {
        final newAccessToken = await _performRefresh(refreshToken);
        if (newAccessToken != null) {
          return newAccessToken;
        }
      }
    }
    return token;
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(_refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(_accessTokenKey);
    await _secureStorage.delete(_refreshTokenKey);
  }

  bool _isExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final encodedPayload = parts[1];
      final normalized = base64Url.normalize(encodedPayload);
      final payloadText = utf8.decode(base64Url.decode(normalized));
      final payload = json.decode(payloadText) as Map<String, dynamic>;

      final exp = payload['exp'];
      if (exp is! int) return false;

      final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      // Expired if within 10 seconds of actual expiration to avoid race conditions
      return DateTime.now()
          .add(const Duration(seconds: 10))
          .isAfter(expiryTime);
    } catch (_) {
      return true;
    }
  }

  Future<String?> _performRefresh(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiBase.baseUrl}/api/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String;
        await saveAccessToken(newAccessToken);
        return newAccessToken;
      }
    } catch (_) {
      // Network/server failure: fallback will return existing token
    }
    return null;
  }
}
