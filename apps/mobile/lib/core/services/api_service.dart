import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    return 'https://guardian-backend-qp3j.onrender.com';
  }

  /// Send OTP code to the given phone number
  static Future<bool> sendOtp(String phone) async {
    final url = Uri.parse('$baseUrl/auth/send-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorMsg = _extractErrorMessage(response.body);
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is http.ClientException || e is SocketException) {
        throw Exception(
          "Cannot connect to server. Please verify the backend is running.",
        );
      }
      rethrow;
    }
  }

  /// Verify OTP code and return JWT token
  static Future<String> verifyOtp(String phone, String code) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'code': code}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String;

        final prefs = await SharedPreferences.getInstance();
        if (data['user_id'] != null) {
          await prefs.setString('user_id', data['user_id'] as String);
        }
        if (data['name'] != null) {
          await prefs.setString('username', data['name'] as String);
        }

        return token;
      } else {
        final errorMsg = _extractErrorMessage(response.body);
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is http.ClientException || e is SocketException) {
        throw Exception(
          "Cannot connect to server. Please verify the backend is running.",
        );
      }
      rethrow;
    }
  }

  /// Update user profile name in the database
  static Future<bool> updateProfile(String phone, String name) async {
    final url = Uri.parse('$baseUrl/auth/profile');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'name': name}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        if (data['user_id'] != null) {
          await prefs.setString('user_id', data['user_id'] as String);
        }
        await prefs.setString('username', name);
        return true;
      } else {
        final errorMsg = _extractErrorMessage(response.body);
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is http.ClientException || e is SocketException) {
        throw Exception(
          "Cannot connect to server. Please verify the backend is running.",
        );
      }
      rethrow;
    }
  }

  /// Fetch the latest generated OTP from the server (dev helper)
  static Future<String?> getLatestOtp() async {
    final url = Uri.parse('$baseUrl/auth/latest-otp');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] != null) {
          return data['code'] as String;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Create a new circle
  static Future<bool> createCircle(String phone, String circleName) async {
    final url = Uri.parse('$baseUrl/auth/create-circle');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'circle_name': circleName}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(_extractErrorMessage(response.body));
      }
    } catch (e) {
      if (e is http.ClientException || e is SocketException) {
        throw Exception("Cannot connect to server.");
      }
      rethrow;
    }
  }

  /// Join an existing circle using invite code
  static Future<bool> joinCircle(String phone, String inviteCode) async {
    final url = Uri.parse('$baseUrl/auth/join-circle');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'invite_code': inviteCode}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(_extractErrorMessage(response.body));
      }
    } catch (e) {
      if (e is http.ClientException || e is SocketException) {
        throw Exception("Cannot connect to server.");
      }
      rethrow;
    }
  }

  static String _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      return decoded['message'] ?? 'An unknown error occurred.';
    } catch (_) {
      return 'Server error. Please try again.';
    }
  }
}
