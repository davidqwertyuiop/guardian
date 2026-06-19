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
    return await _secureStorage.read(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(_refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(_accessTokenKey);
    await _secureStorage.delete(_refreshTokenKey);
  }
}
