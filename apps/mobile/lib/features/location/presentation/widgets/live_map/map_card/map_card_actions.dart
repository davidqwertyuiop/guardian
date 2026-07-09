part of '../map_card.dart';

extension MapCardActions on MapCardState {
  void selectMarkerLocation(String label) {
    final trimmedLabel = label.trim();
    if (trimmedLabel.isEmpty) return;
    refresh(() => _selectedMarkerLocationLabel = trimmedLabel);
  }

  void resolveCurrentLocationLabel(LatLng userLoc) {
    final key =
        '${userLoc.latitude.toStringAsFixed(4)},'
        '${userLoc.longitude.toStringAsFixed(4)}';
    if (_currentLocationKey == key) return;
    _currentLocationKey = key;
    (() async {
      try {
        final placemarks = await Geocoding().placemarkFromCoordinates(
          userLoc.latitude,
          userLoc.longitude,
        );
        if (!mounted || placemarks.isEmpty) return;
        final label = addressParts(placemarks.first)
            .whereType<String>()
            .where((part) => part.trim().isNotEmpty)
            .join(', ');
        if (label.isEmpty) return;
        refresh(() => _currentLocationLabel = label);
      } catch (e) {
        log('Error resolving map location label: $e');
      }
    })();
  }

  List<String?> addressParts(Placemark place) {
    return [place.subLocality, place.locality, place.administrativeArea];
  }

  void handleMapCardUpdate(MapCard oldWidget) {
    if (oldWidget.userLatitude == widget.userLatitude &&
        oldWidget.userLongitude == widget.userLongitude) {
      return;
    }
    _currentLatitude = widget.userLatitude;
    _currentLongitude = widget.userLongitude;
    final target = LatLng(widget.userLatitude, widget.userLongitude);
    safeAnimateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: widget.mapState == MapDisplayState.full ? 15.0 : 16.0,
          tilt: 45.0,
        ),
      ),
    );
  }

  Future<void> _launchDirections() async {
    final routePlace = activeRoutePlace();
    if (routePlace == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination='
      '${routePlace.coordinates.latitude},'
      '${routePlace.coordinates.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    toastification.show(
      title: const Text('Navigation Error'),
      description: const Text('Could not open map navigation application.'),
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
}
