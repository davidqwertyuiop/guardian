import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardian/core/security/token_manager.dart';

/// Guardian API Service — v2
/// All calls go through the Shuttle-hosted Rust backend.
/// Base URL is set to the live Shuttle deployment URL after first deploy.
class ApiService {
  // ── Base URL ──────────────────────────────────────────────────────────────
  // After running `shuttle deploy`, replace this with your .shuttleapp.com URL.
  static const String _baseUrl = 'https://guardian-2vex.onrender.com';

  static String get baseUrl => _baseUrl;

  // ── Auth: v2 endpoints ────────────────────────────────────────────────────

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
        throw Exception(_extractErrorMessage(response.body));
      }
    } catch (e) {
      _rethrowNetworkError(e);
    }
  }

  /// POST /api/v1/auth/verify-otp
  /// Returns the full auth response map (access_token, refresh_token, user_id, phone, is_profile_complete).
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
        throw Exception(_extractErrorMessage(response.body));
      }
    } catch (e) {
      _rethrowNetworkError(e);
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
        throw Exception(_extractErrorMessage(response.body));
      }
    } catch (e) {
      _rethrowNetworkError(e);
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
        throw Exception(_extractErrorMessage(response.body));
      }
    } catch (e) {
      _rethrowNetworkError(e);
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
        throw Exception(_extractErrorMessage(response.body));
      }
    } catch (e) {
      _rethrowNetworkError(e);
    }
  }

  // ── Circles (to be implemented in circles domain) ─────────────────────────

  static Future<bool> createCircle(String phone, String circleName) async {
    throw UnimplementedError('circles domain not yet implemented');
  }

  static Future<bool> joinCircle(String phone, String inviteCode) async {
    throw UnimplementedError('circles domain not yet implemented');
  }

  static Future<bool> checkCircleHasMembers(String inviteCode) async {
    // Default to true (don't block user) until circles domain is built
    return true;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      return decoded['message'] ?? 'An unknown error occurred.';
    } catch (_) {
      return 'Server error. Please try again.';
    }
  }

  static Never _rethrowNetworkError(Object e) {
    if (e is http.ClientException || e is SocketException) {
      throw Exception(
          'Cannot connect to Guardian servers. Please check your connection.');
    }
    throw e;
  }
}
