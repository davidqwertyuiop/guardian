import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        throw Exception("Cannot connect to server. Please verify the backend is running.");
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
        return data['token'] as String;
      } else {
        final errorMsg = _extractErrorMessage(response.body);
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is http.ClientException || e is SocketException) {
        throw Exception("Cannot connect to server. Please verify the backend is running.");
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

  static String _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      return decoded['message'] ?? 'An unknown error occurred.';
    } catch (_) {
      return 'Server error. Please try again.';
    }
  }
}
