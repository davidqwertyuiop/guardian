import 'api/api_base.dart';
import 'api/auth_api_service.dart';
import 'api/circles_api_service.dart';
import 'api/sos_api_service.dart';
import 'api/location_api_service.dart';
import 'api/journey_api_service.dart';

/// Guardian API Service Facade
/// delegates calls to modular, domain-specific api sub-services.
class ApiService {
  static String get baseUrl => ApiBase.baseUrl;

  // ── Auth Endpoints ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> firebaseExchange(
    String phone,
    String idToken,
  ) => AuthApiService.firebaseExchange(phone, idToken);
  static Future<bool> updateProfile(String name) =>
      AuthApiService.updateProfile(name);
  static Future<bool> updatePreferences(bool location, bool notifications) =>
      AuthApiService.updatePreferences(location, notifications);
  static Future<String> refreshToken(String token) =>
      AuthApiService.refreshToken(token);
  static Future<Map<String, dynamic>> getMe() => AuthApiService.getMe();
  static Future<List<dynamic>> getSessions() => AuthApiService.getSessions();
  static Future<bool> revokeSession(String hash) =>
      AuthApiService.revokeSession(hash);
  static Future<bool> registerDevice(String fcmToken, String platform) =>
      AuthApiService.registerDevice(fcmToken, platform);

  // ── Circles Endpoints ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> createCircle(String name) =>
      CirclesApiService.createCircle(name);
  static Future<bool> joinCircle(String codeOrLink) =>
      CirclesApiService.joinCircle(codeOrLink);
  static Future<List<dynamic>> getCircles() async =>
      CirclesApiService.getCircles();
  static Future<List<dynamic>> getCircleMembers(String circleId) =>
      CirclesApiService.getCircleMembers(circleId);
  static Future<bool> checkCircleHasMembers(String code) =>
      CirclesApiService.checkCircleHasMembers(code);
  static Future<List<dynamic>> getSosBroadcasts(String circleId) =>
      SosApiService.getSosBroadcasts(circleId);
  static Future<Map<String, dynamic>> triggerSos({
    required String circleId,
    double? latitude,
    double? longitude,
    String? address,
  }) => SosApiService.triggerSos(
    circleId: circleId,
    latitude: latitude,
    longitude: longitude,
    address: address,
  );
  static Future<bool> dismissSos(String broadcastId) =>
      SosApiService.dismissSos(broadcastId);
  static Future<bool> leaveCircle(String circleId) =>
      CirclesApiService.leaveCircle(circleId);
  static Future<Map<String, dynamic>> getCircleInvite(String circleId) =>
      CirclesApiService.getCircleInvite(circleId);
  static Future<bool> deleteCircle(String circleId) =>
      CirclesApiService.deleteCircle(circleId);
  static Future<bool> removeMember(String circleId, String memberId) =>
      CirclesApiService.removeMember(circleId, memberId);
  static Future<bool> startJourney({
    required String circleId,
    required String destination,
    required String duration,
  }) => JourneyApiService.startJourney(
    circleId: circleId,
    destination: destination,
    duration: duration,
  );
  static Future<bool> stopJourney({required String circleId}) =>
      JourneyApiService.stopJourney(circleId: circleId);

  // ── Location Endpoints ──────────────────────────────────────────────────────
  static Future<void> updateLocation({
    required String circleId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? heading,
    double? speed,
    int? batteryLevel,
    String? connectivityType,
  }) => LocationApiService.updateLocation(
    circleId: circleId,
    latitude: latitude,
    longitude: longitude,
    accuracy: accuracy,
    heading: heading,
    speed: speed,
    batteryLevel: batteryLevel,
    connectivityType: connectivityType,
  );

  static Future<List<dynamic>> getCircleMemberLocations(String circleId) =>
      LocationApiService.getCircleMemberLocations(circleId);

  static Future<Map<String, dynamic>?> getNearestMemberLocation(
    String circleId,
  ) => LocationApiService.getNearestMemberLocation(circleId);
}
