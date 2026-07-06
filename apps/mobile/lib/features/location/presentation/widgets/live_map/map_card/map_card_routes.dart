part of '../map_card.dart';

class MapRouteInfo {
  final Set<Polyline> polylines;
  final double distanceKm;
  final int durationMins;

  const MapRouteInfo({
    required this.polylines,
    required this.distanceKm,
    required this.durationMins,
  });
}

extension MapCardRoutes on MapCardState {
  MapRouteInfo buildRouteInfo(LatLng userLoc) {
    final destinationPlace = activeRoutePlace();
    if (destinationPlace == null) {
      return const MapRouteInfo(polylines: {}, distanceKm: 0, durationMins: 0);
    }

    refreshDirectionsIfNeeded(userLoc: userLoc);
    final destination = destinationPlace.coordinates;
    final routeKey = _routeKey(userLoc, destination);
    final hasDirectionsRoute =
        _directionsRouteKey == routeKey && _directionsPoints.isNotEmpty;
    final routePoints = hasDirectionsRoute
        ? _directionsPoints
        : generateRoutingCoordinates(userLoc, destination);
    final meters = Geolocator.distanceBetween(
      userLoc.latitude,
      userLoc.longitude,
      destination.latitude,
      destination.longitude,
    );
    final distanceKm = meters / 1000.0;

    return MapRouteInfo(
      polylines: {
        Polyline(
          polylineId: const PolylineId('route'),
          points: routePoints,
          color: AppColors.primary,
          width: 5,
          jointType: JointType.round,
        ),
      },
      distanceKm: hasDirectionsRoute && _directionsDistanceKm > 0
          ? _directionsDistanceKm
          : distanceKm,
      durationMins: hasDirectionsRoute && _directionsDurationMins > 0
          ? _directionsDurationMins
          : (distanceKm / 40.0 * 60.0).round().clamp(1, 120),
    );
  }

  void refreshDirectionsIfNeeded({LatLng? userLoc}) {
    final place = activeRoutePlace();
    final key = widget.mapsApiKey;
    if (place == null || key.isEmpty || _isLoadingDirections) return;

    final origin = userLoc ?? _currentUserLatLng();
    if (origin == null) return;

    final destination = place.coordinates;
    final routeKey = _routeKey(origin, destination);
    if (_directionsRouteKey == routeKey && _directionsPoints.isNotEmpty) return;

    _isLoadingDirections = true;
    _directionsRouteKey = routeKey;
    (() async {
      try {
        final url =
            Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
              'origin': '${origin.latitude},${origin.longitude}',
              'destination': '${destination.latitude},${destination.longitude}',
              'mode': 'driving',
              'key': key,
            });
        final response = await http
            .get(url)
            .timeout(const Duration(seconds: 8));
        if (response.statusCode != 200) {
          log('Google Directions HTTP error: ${response.statusCode}');
          clearDirectionsRoute(routeKey);
          return;
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] != 'OK') {
          log(
            'Google Directions status error: '
            '${data["status"]} ${data["error_message"] ?? ""}',
          );
          clearDirectionsRoute(routeKey);
          return;
        }

        final routes = data['routes'] as List<dynamic>? ?? [];
        if (routes.isEmpty) return;
        final route = routes.first as Map<String, dynamic>;
        final encoded = route['overview_polyline']?['points']?.toString();
        if (encoded == null || encoded.isEmpty) return;

        final legs = route['legs'] as List<dynamic>? ?? [];
        final leg = legs.isNotEmpty ? legs.first as Map<String, dynamic> : null;
        final distanceMeters = _readRouteNumber(leg?['distance']?['value']);
        final durationSeconds = _readRouteNumber(leg?['duration']?['value']);
        final points = decodePolyline(encoded);

        if (!mounted || points.isEmpty) return;
        refresh(() {
          _directionsPoints = points;
          _directionsDistanceKm = distanceMeters == null
              ? 0
              : distanceMeters / 1000.0;
          _directionsDurationMins = durationSeconds == null
              ? 0
              : (durationSeconds / 60).ceil().clamp(1, 999);
        });
      } catch (e) {
        log('Error loading Google Directions route: $e');
        clearDirectionsRoute(routeKey);
      } finally {
        _isLoadingDirections = false;
      }
    })();
  }

  void clearDirectionsRoute(String routeKey) {
    if (!mounted || _directionsRouteKey != routeKey) return;
    refresh(() {
      _directionsPoints = [];
      _directionsDistanceKm = 0;
      _directionsDurationMins = 0;
    });
  }

  LatLng? _currentUserLatLng() {
    final latitude = _currentLatitude ?? widget.userLatitude;
    final longitude = _currentLongitude ?? widget.userLongitude;
    return LatLng(latitude, longitude);
  }

  String _routeKey(LatLng origin, LatLng destination) {
    return '${origin.latitude.toStringAsFixed(5)},'
        '${origin.longitude.toStringAsFixed(5)}|'
        '${destination.latitude.toStringAsFixed(5)},'
        '${destination.longitude.toStringAsFixed(5)}';
  }

  SelectedLivePlace? activeRoutePlace() {
    if (widget.selectedPlace != null) return widget.selectedPlace;
    if (widget.isSosActive) return null;

    for (final broadcast in widget.sosBroadcasts) {
      final json = broadcast is Map ? broadcast : const {};
      final status = json['status']?.toString().trim().toLowerCase() ?? '';
      if (status != 'active') continue;

      final userId = json['user_id']?.toString() ?? '';
      if (userId.isNotEmpty && userId == _currentUserId) continue;

      final latitude = _readCoordinate(json['latitude']);
      final longitude = _readCoordinate(json['longitude']);
      if (latitude == null || longitude == null) continue;

      final name = json['name']?.toString() ?? json['user_name']?.toString();
      return SelectedLivePlace(
        name: name == null || name.isEmpty ? 'SOS location' : '$name SOS',
        address: json['address']?.toString() ?? 'Active SOS location',
        coordinates: LatLng(latitude, longitude),
      );
    }

    return null;
  }

  num? _readRouteNumber(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '');
  }

  List<LatLng> decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var latitude = 0;
    var longitude = 0;

    while (index < encoded.length) {
      final latResult = _decodePolylineValue(encoded, index);
      index = latResult.nextIndex;
      latitude += latResult.delta;

      final lngResult = _decodePolylineValue(encoded, index);
      index = lngResult.nextIndex;
      longitude += lngResult.delta;

      points.add(LatLng(latitude / 1E5, longitude / 1E5));
    }

    return points;
  }

  _PolylineDecodeResult _decodePolylineValue(String encoded, int startIndex) {
    var result = 0;
    var shift = 0;
    var index = startIndex;
    int byte;

    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1F) << shift;
      shift += 5;
    } while (byte >= 0x20 && index < encoded.length);

    final delta = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
    return _PolylineDecodeResult(delta: delta, nextIndex: index);
  }

  List<LatLng> generateRoutingCoordinates(LatLng start, LatLng end) {
    return [
      start,
      LatLng(
        start.latitude + (end.latitude - start.latitude) * 0.4,
        start.longitude,
      ),
      LatLng(
        start.latitude + (end.latitude - start.latitude) * 0.4,
        end.longitude,
      ),
      end,
    ];
  }
}

class _PolylineDecodeResult {
  final int delta;
  final int nextIndex;

  const _PolylineDecodeResult({required this.delta, required this.nextIndex});
}
