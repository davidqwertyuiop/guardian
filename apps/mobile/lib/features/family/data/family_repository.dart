import 'package:geolocator/geolocator.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/services/api/location_api_service.dart';
import 'package:guardian/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyRepository {
  Future<String> currentUserId() async {
    final prefs = locator<SharedPreferences>();
    return prefs.getString('user_id') ?? '';
  }

  Future<List<Map<String, dynamic>>> circles() async {
    return (await ApiService.getCircles()).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> members(String circleId) async {
    return (await ApiService.getCircleMembers(
      circleId,
    )).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> invite(String circleId) {
    return ApiService.getCircleInvite(circleId);
  }

  Future<Map<String, Map<String, dynamic>>> locations(String circleId) async {
    final rows = await LocationApiService.getCircleMemberLocations(circleId);
    return {for (final row in rows) '${row['user_id']}': row};
  }

  Future<Map<String, dynamic>> createCircle(String name) {
    return ApiService.createCircle(name);
  }

  Future<void> joinCircle(String codeOrLink) async {
    await ApiService.joinCircle(codeOrLink);
  }

  Future<void> leaveCircle(String circleId) async {
    await ApiService.leaveCircle(circleId);
  }

  Future<void> deleteCircle(String circleId) async {
    await ApiService.deleteCircle(circleId);
  }

  Future<void> removeMember(String circleId, String memberId) async {
    await ApiService.removeMember(circleId, memberId);
  }

  Future<void> updateMyLocation(
    String circleId,
    int battery,
    String network,
  ) async {
    if (!await Geolocator.isLocationServiceEnabled()) return;
    final pos = await Geolocator.getLastKnownPosition();
    if (pos == null) return;
    await ApiService.updateLocation(
      circleId: circleId,
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracy: pos.accuracy,
      batteryLevel: battery,
      connectivityType: network,
    );
  }
}
