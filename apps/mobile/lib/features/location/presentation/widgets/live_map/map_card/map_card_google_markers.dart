part of '../map_card.dart';

extension MapCardGoogleMarkers on MapCardState {
  Set<Marker> buildGoogleMarkers(LatLng userLoc) {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('user_loc'),
        position: userLoc,
        icon:
            _userLocationMarker ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: const InfoWindow(title: 'You'),
      ),
    };

    markers.addAll(buildGoogleMemberMarkers());
    markers.addAll(buildSosMarkers(userLoc));

    if (widget.selectedPlace != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: widget.selectedPlace!.coordinates,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
          infoWindow: InfoWindow(title: widget.selectedPlace!.name),
        ),
      );
    }

    return markers;
  }

  Iterable<Marker> buildGoogleMemberMarkers() sync* {
    for (final member in _serverLocations) {
      final uid = member['user_id'] ?? '';
      if (uid == _currentUserId) continue;
      final latitude = _readCoordinate(member['latitude']);
      final longitude = _readCoordinate(member['longitude']);
      if (latitude == null || longitude == null) continue;

      final icon = _googleMarkersCache[uid] ?? _avatarTopMarker;
      if (icon == null) continue;

      yield Marker(
        markerId: MarkerId('member_$uid'),
        position: LatLng(latitude, longitude),
        icon: icon,
        infoWindow: InfoWindow(title: member['name'] ?? 'Member'),
      );
    }
  }

  Iterable<Marker> buildSosMarkers(LatLng userLoc) sync* {
    if (widget.isSosActive) {
      yield Marker(
        markerId: const MarkerId('local_active_sos'),
        position: userLoc,
        icon:
            _sosMarker ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        zIndexInt: 20,
        infoWindow: InfoWindow(
          title: 'SOS active',
          snippet: widget.activeSosAddress ?? 'Current location',
        ),
      );
    }

    for (final broadcast in widget.sosBroadcasts) {
      final json = broadcast is Map ? broadcast : const {};
      final status = json['status']?.toString().toLowerCase() ?? '';
      if (status.isNotEmpty && status != 'active') continue;

      final latitude = _readCoordinate(json['latitude']);
      final longitude = _readCoordinate(json['longitude']);
      final id = json['id']?.toString();
      if (latitude == null || longitude == null || id == null) continue;

      yield Marker(
        markerId: MarkerId('sos_$id'),
        position: LatLng(latitude, longitude),
        icon:
            _sosMarker ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        zIndexInt: 19,
        infoWindow: InfoWindow(
          title: '${json['name'] ?? json['user_name'] ?? 'Member'} SOS',
          snippet: json['address']?.toString() ?? 'SOS location',
        ),
      );
    }
  }

  double? _readCoordinate(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
