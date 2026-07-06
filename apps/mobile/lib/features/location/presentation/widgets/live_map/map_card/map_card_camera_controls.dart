part of '../map_card.dart';

extension MapCardCameraControls on MapCardState {
  void zoomIn() {
    _controller?.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    _controller?.animateCamera(CameraUpdate.zoomOut());
  }

  void recenterMap(LatLng userLoc) {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: userLoc, zoom: 15.5, tilt: 45.0),
      ),
    );
  }

  MapType _effectiveMapType(bool isDark) {
    return _selectedMapType ?? (isDark ? MapType.hybrid : MapType.normal);
  }

  String mapTypeLabel(bool isDark) {
    return switch (_effectiveMapType(isDark)) {
      MapType.normal => 'Default',
      MapType.hybrid => 'Hybrid',
      MapType.satellite => 'Satellite',
      MapType.terrain => 'Terrain',
      _ => 'Map',
    };
  }

  void cycleMapType(bool isDark) {
    final current = _effectiveMapType(isDark);
    final next = switch (current) {
      MapType.normal => MapType.hybrid,
      MapType.hybrid => MapType.satellite,
      MapType.satellite => MapType.terrain,
      MapType.terrain => MapType.normal,
      _ => MapType.normal,
    };
    refresh(() => _selectedMapType = next);
  }
}
