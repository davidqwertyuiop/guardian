import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:guardian/core/security/token_manager.dart';
import 'api_base.dart';

/// Client for the Location domain REST endpoints.
/// 
/// Endpoints:
///   PUT  /api/v1/location               — upsert caller's GPS fix for a circle.
///   GET  /api/v1/location/circles/:id   — fetch all member locations for the map.
abstract class LocationApiService {
  static String get baseUrl => ApiBase.baseUrl;

  /// Pushes the device's current GPS fix to the backend for a specific circle.
  /// Called periodically while the app is in the foreground.
  static Future<void> updateLocation({
    required String circleId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? heading,
    double? speed,
  }) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/location');
    try {
      final body = <String, dynamic>{
        'circle_id': circleId,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': ?accuracy,
        'heading': ?heading,
        'speed': ?speed,
      };
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode != 200) {
        throw Exception(ApiBase.extractErrorMessage(response.body));
      }
    } catch (e) {
      ApiBase.rethrowNetworkError(e);
    }
  }

  /// Returns the latest known GPS location for every member of a circle.
  /// Each item contains: user_id, name, avatar_url, latitude, longitude,
  /// accuracy, updated_at.
  static Future<List<dynamic>> getCircleMemberLocations(
    String circleId,
  ) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/location/circles/$circleId');
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
}
