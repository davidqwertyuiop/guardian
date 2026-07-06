import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:guardian/core/security/token_manager.dart';
import 'api_base.dart';

/// Client for the SOS domain REST endpoints.
///
/// Endpoints:
///   POST /api/v1/sos                   — trigger an SOS broadcast.
///   GET  /api/v1/sos/circles/:id       — list broadcasts for a circle.
///   POST /api/v1/sos/:id/resolve       — resolve an active broadcast.
///   POST /api/v1/sos/:id/dismiss       — dismiss own broadcast.
abstract class SosApiService {
  static String get baseUrl => ApiBase.baseUrl;

  static Future<String> _requireAccessToken() async {
    final tokenManager = TokenManager();
    final accessToken = await tokenManager.getAccessToken();
    if (accessToken != null && accessToken.trim().isNotEmpty) {
      return accessToken;
    }

    final refreshToken = await tokenManager.getRefreshToken();
    if (refreshToken != null && refreshToken.trim().isNotEmpty) {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newToken = data['access_token'] as String?;
        if (newToken != null && newToken.trim().isNotEmpty) {
          await tokenManager.saveAccessToken(newToken);
          return newToken;
        }
      }
    }

    throw Exception('Your session has expired. Please sign in again.');
  }

  /// Triggers a new SOS broadcast for the given circle.
  /// Returns the created broadcast id and status.
  static Future<Map<String, dynamic>> triggerSos({
    required String circleId,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    final token = await _requireAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/sos');
    try {
      final body = <String, dynamic>{
        'circle_id': circleId,
        'latitude': ?latitude,
        'longitude': ?longitude,
        'address': ?address,
      };
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
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

  /// Returns all SOS broadcasts for a circle, newest first.
  /// Each item contains: id, user_id, name, avatar_url, latitude, longitude,
  /// address, status, created_at.
  static Future<List<dynamic>> getSosBroadcasts(
    String circleId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final token = await _requireAccessToken();
    final url = Uri.parse(
      '$baseUrl/api/v1/sos/circles/$circleId?limit=$limit&offset=$offset',
    );
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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

  /// Resolves an active SOS broadcast. Any circle member may call this.
  static Future<bool> resolveSos(String broadcastId) async {
    final token = await _requireAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/sos/$broadcastId/resolve');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      ApiBase.rethrowNetworkError(e);
    }
  }

  /// Dismisses the caller's own active SOS broadcast.
  static Future<bool> dismissSos(String broadcastId) async {
    final token = await _requireAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/sos/$broadcastId/dismiss');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      ApiBase.rethrowNetworkError(e);
    }
  }
}
