import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardian/core/security/token_manager.dart';
import 'api_base.dart';

abstract class AuthApiService {
  static String get baseUrl => ApiBase.baseUrl;

  /// POST /api/v1/auth/send-otp
  static Future<bool> sendOtp(String phone) async {
    final url = Uri.parse('$baseUrl/api/v1/auth/send-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(ApiBase.extractErrorMessage(response.body));
      }
    } catch (e) {
      ApiBase.rethrowNetworkError(e);
    }
  }

  /// POST /api/v1/auth/verify-otp
  static Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'code': code}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Persist tokens securely
        final tokenMgr = TokenManager();
        await tokenMgr.saveAccessToken(data['access_token'] as String);
        await tokenMgr.saveRefreshToken(data['refresh_token'] as String);

        final prefs = await SharedPreferences.getInstance();
        if (data['user_id'] != null) {
          await prefs.setString('user_id', data['user_id'] as String);
        }

        return data;
      } else {
        throw Exception(ApiBase.extractErrorMessage(response.body));
      }
    } catch (e) {
      ApiBase.rethrowNetworkError(e);
    }
  }

  /// PATCH /api/v1/auth/profile  (requires Bearer token)
  static Future<bool> updateProfile(String name) async {
    final tokenMgr = TokenManager();
    final token = await tokenMgr.getAccessToken();

    final url = Uri.parse('$baseUrl/api/v1/auth/profile');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();
        if (data['user_id'] != null) {
          await prefs.setString('user_id', data['user_id'] as String);
        }
        await prefs.setString('username', name);
        return true;
      } else {
        throw Exception(ApiBase.extractErrorMessage(response.body));
      }
    } catch (e) {
      ApiBase.rethrowNetworkError(e);
    }
  }

  /// PATCH /api/v1/auth/preferences  (requires Bearer token)
  static Future<bool> updatePreferences(bool locationEnabled, bool notificationsEnabled) async {
    final tokenMgr = TokenManager();
    final token = await tokenMgr.getAccessToken();

    final url = Uri.parse('$baseUrl/api/v1/auth/preferences');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'location_enabled': locationEnabled,
          'notifications_enabled': notificationsEnabled,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(ApiBase.extractErrorMessage(response.body));
      }
    } catch (e) {
      ApiBase.rethrowNetworkError(e);
    }
  }

  /// POST /api/v1/auth/refresh
  static Future<String> refreshToken(String refreshToken) async {
    final url = Uri.parse('$baseUrl/api/v1/auth/refresh');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newToken = data['access_token'] as String;
        await TokenManager().saveAccessToken(newToken);
        return newToken;
      } else {
        throw Exception(ApiBase.extractErrorMessage(response.body));
      }
    } catch (e) {
      ApiBase.rethrowNetworkError(e);
    }
  }

  /// GET /api/v1/auth/me  (requires Bearer token)
  static Future<Map<String, dynamic>> getMe() async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/auth/me');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(ApiBase.extractErrorMessage(response.body));
      }
    } catch (e) {
      ApiBase.rethrowNetworkError(e);
    }
  }

  /// GET /api/v1/auth/sessions  (requires Bearer token)
  static Future<List<dynamic>> getSessions() async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/auth/sessions');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception(ApiBase.extractErrorMessage(response.body));
      }
    } catch (e) {
      ApiBase.rethrowNetworkError(e);
    }
  }

  /// DELETE /api/v1/auth/sessions/{hash} (requires Bearer token)
  static Future<bool> revokeSession(String hash) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/auth/sessions/$hash');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(ApiBase.extractErrorMessage(response.body));
      }
    } catch (e) {
      ApiBase.rethrowNetworkError(e);
    }
  }
}
