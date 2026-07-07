import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:guardian/core/security/token_manager.dart';
import 'api_base.dart';

abstract class CirclesApiService {
  static String get baseUrl => ApiBase.baseUrl;

  /// POST /api/v1/circles (requires Bearer token)
  static Future<Map<String, dynamic>> createCircle(String name) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/circles');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name}),
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

  /// POST /api/v1/circles/join/code or /join/link depending on the format (requires Bearer token)
  static Future<bool> joinCircle(String inviteCodeOrLink) async {
    final token = await TokenManager().getAccessToken();

    String cleanParam = inviteCodeOrLink.trim();
    bool isLink = false;

    if (cleanParam.startsWith('http://') || cleanParam.startsWith('https://')) {
      isLink = true;
      final uri = Uri.parse(cleanParam);
      cleanParam = uri.pathSegments.last;
    } else if (cleanParam.contains('/')) {
      isLink = true;
      cleanParam = cleanParam.split('/').last;
    } else if (cleanParam.length > 8) {
      isLink = true;
    }

    final endpoint = isLink ? 'join/link' : 'join/code';
    final key = isLink ? 'token' : 'code';

    final url = Uri.parse('$baseUrl/api/v1/circles/$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({key: cleanParam}),
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

  /// GET /api/v1/circles (requires Bearer token)
  static Future<List<dynamic>> getCircles() async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/circles');
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

  /// GET /api/v1/circles/{id}/members (requires Bearer token)
  static Future<List<dynamic>> getCircleMembers(String circleId) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/circles/$circleId/members');
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

  static Future<bool> checkCircleHasMembers(String inviteCodeOrLink) async {
    return true;
  }

  /// GET /api/v1/circles/{id}/locations (requires Bearer token)
  static Future<List<dynamic>> getMemberLocations(String circleId) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/circles/$circleId/locations');
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
        // Fallback or empty if endpoint not fully ready
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// GET /api/v1/sos/broadcasts (requires Bearer token)
  static Future<List<dynamic>> getSosBroadcasts(String circleId) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/sos/broadcasts?circle_id=$circleId');
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
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// POST /api/v1/circles/{id}/leave (requires Bearer token)
  static Future<bool> leaveCircle(String circleId) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/circles/$circleId/leave');
    try {
      final response = await http.post(
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

  /// GET /api/v1/circles/{id}/invite (requires Bearer token)
  static Future<Map<String, dynamic>> getCircleInvite(String circleId) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/circles/$circleId/invite');
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

  /// DELETE /api/v1/circles/{id} (requires Bearer token)
  static Future<bool> deleteCircle(String circleId) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/circles/$circleId');
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

  /// DELETE /api/v1/circles/{id}/members/{memberId} (requires Bearer token)
  static Future<bool> removeMember(String circleId, String memberId) async {
    final token = await TokenManager().getAccessToken();
    final url = Uri.parse('$baseUrl/api/v1/circles/$circleId/members/$memberId');
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
