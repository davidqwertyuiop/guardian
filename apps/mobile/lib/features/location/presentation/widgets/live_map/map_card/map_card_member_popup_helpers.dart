part of '../map_card.dart';

extension MapCardMemberPopupHelpers on MapCardState {
  Map<String, dynamic> memberPopupData(String userId) {
    final memberLocationRaw = _serverLocations.cast<dynamic>().firstWhere(
      (item) => (item['user_id']?.toString() ?? '') == userId,
      orElse: () => <String, dynamic>{},
    );
    final memberProfileRaw = widget.members.cast<dynamic>().firstWhere(
      (item) => (item['user_id']?.toString() ?? '') == userId,
      orElse: () => <String, dynamic>{},
    );
    final memberLocation = Map<String, dynamic>.from(
      memberLocationRaw is Map ? memberLocationRaw : const <String, dynamic>{},
    );
    final memberProfile = Map<String, dynamic>.from(
      memberProfileRaw is Map ? memberProfileRaw : const <String, dynamic>{},
    );
    return {...memberProfile, ...memberLocation};
  }

  void focusMemberLocation({
    required BuildContext dialogContext,
    required double latitude,
    required double longitude,
  }) {
    safeAnimateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: widget.mapState == MapDisplayState.full ? 16 : 16.5,
          tilt: widget.mapState == MapDisplayState.full ? 45 : 30,
        ),
      ),
    );
    Navigator.of(dialogContext).pop();
  }

  Future<String> resolveMemberAddress(double latitude, double longitude) async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isEmpty) return 'Location available';
      final label = addressParts(
        placemarks.first,
      ).whereType<String>().where((part) => part.trim().isNotEmpty).join(', ');
      return label.isEmpty ? 'Location available' : label;
    } catch (_) {
      return 'Location available';
    }
  }

  Map<dynamic, dynamic>? activeSosBroadcastForUser(String userId) {
    for (final broadcast in widget.sosBroadcasts) {
      final data = broadcast is Map ? broadcast : const {};
      final status = data['status']?.toString().toLowerCase();
      if (status != 'active') continue;
      if (data['user_id']?.toString() == userId) return data;
    }
    return null;
  }

  String remainingSosText(Map<dynamic, dynamic>? broadcast) {
    if (broadcast == null) return '';
    final createdAt = DateTime.tryParse(
      broadcast['created_at']?.toString() ?? '',
    );
    if (createdAt == null) return 'SOS ACTIVE';
    final elapsed = DateTime.now().difference(createdAt.toLocal()).inMinutes;
    final remaining = (60 - elapsed).clamp(1, 60);
    return 'SOS ACTIVE · $remaining min remaining';
  }

  String relativeUpdatedLabel(String? updatedAt) {
    final parsed = DateTime.tryParse(updatedAt ?? '');
    if (parsed == null) return 'Updated recently';
    final diff = DateTime.now().difference(parsed.toLocal());
    if (diff.inSeconds < 60) return 'Updated just now';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours} hr ago';
    return 'Updated ${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
}
