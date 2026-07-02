import 'api/api_base.dart';
import 'api/auth_api_service.dart';
import 'api/circles_api_service.dart';

/// Guardian API Service Facade
/// delegates calls to modular, domain-specific api sub-services.
class ApiService {
  static String get baseUrl => ApiBase.baseUrl;

  // ── Auth Endpoints ──────────────────────────────────────────────────────────
  static Future<bool> sendOtp(String phone) => AuthApiService.sendOtp(phone);
  static Future<Map<String, dynamic>> verifyOtp(String phone, String code) => AuthApiService.verifyOtp(phone, code);
  static Future<bool> updateProfile(String name) => AuthApiService.updateProfile(name);
  static Future<bool> updatePreferences(bool location, bool notifications) => AuthApiService.updatePreferences(location, notifications);
  static Future<String> refreshToken(String token) => AuthApiService.refreshToken(token);
  static Future<Map<String, dynamic>> getMe() => AuthApiService.getMe();
  static Future<List<dynamic>> getSessions() => AuthApiService.getSessions();
  static Future<bool> revokeSession(String hash) => AuthApiService.revokeSession(hash);

  // ── Circles Endpoints ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> createCircle(String name) => CirclesApiService.createCircle(name);
  static Future<bool> joinCircle(String codeOrLink) => CirclesApiService.joinCircle(codeOrLink);
  static Future<List<dynamic>> getCircles() async => CirclesApiService.getCircles();
  static Future<List<dynamic>> getCircleMembers(String circleId) => CirclesApiService.getCircleMembers(circleId);
  static Future<bool> checkCircleHasMembers(String code) => CirclesApiService.checkCircleHasMembers(code);
}
