import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:guardian/core/security/token_manager.dart';
import 'api_base.dart';

abstract class JourneyApiService {
  static String get baseUrl => ApiBase.baseUrl;

  /// POST /api/v1/journey/start (requires Bearer token)
  static Future<bool> startJourney({
    required String circleId,
    required String destination,
    required String duration,
  }) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/journey/start');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'circle_id': circleId,
          'destination': destination,
          'duration': duration,
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

  /// POST /api/v1/journey/stop (requires Bearer token)
  static Future<bool> stopJourney({
    required String circleId,
  }) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/journey/stop');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'circle_id': circleId,
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
}
