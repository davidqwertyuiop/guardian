part of '../map_card.dart';

extension MapCardSync on MapCardState {
  void _startGpsTimer() {
    _gpsTimer?.cancel();
    _gpsTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await _syncLocationAndLoadData();
    });
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final prefs = locator<SharedPreferences>();
      _currentUserId = prefs.getString('user_id') ?? '';
    } catch (_) {}
  }

  Future<void> _syncLocationAndLoadData() async {
    if (!mounted) return;
    try {
      final loc = await GpsService().getCurrentLocation();
      final lat = loc['latitude'] ?? widget.userLatitude;
      final lon = loc['longitude'] ?? widget.userLongitude;

      if (widget.circleId.isNotEmpty) {
        await ApiService.updateLocation(
          circleId: widget.circleId,
          latitude: lat,
          longitude: lon,
          accuracy: 10.0,
        );
      }

      final serverLocs = widget.circleId.isNotEmpty
          ? await ApiService.getCircleMemberLocations(widget.circleId)
          : <dynamic>[];
      final nearest = widget.circleId.isNotEmpty
          ? await ApiService.getNearestMemberLocation(widget.circleId)
          : null;

      if (mounted) {
        refresh(() {
          _currentLatitude = lat;
          _currentLongitude = lon;
          _serverLocations = serverLocs;
          _nearestMemberInfo = nearest;
        });
      }

      for (final member in serverLocs) {
        preloadMemberMarker(member);
      }
    } catch (e) {
      log('Error in location background sync: $e');
    }
  }

  String _fallbackAvatarAsset(String seed) {
    final assets = [
      AppAssets.avatarTop,
      AppAssets.avatarLeft,
      AppAssets.avatarRight,
    ];
    final index =
        seed.codeUnits.fold<int>(0, (sum, unit) => sum + unit).abs() %
        assets.length;
    return assets[index];
  }
}
