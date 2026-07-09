part of '../map_card.dart';

extension MapCardCameraControls on MapCardState {
  void zoomIn() {
    safeAnimateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    safeAnimateCamera(CameraUpdate.zoomOut());
  }

  void recenterMap(LatLng userLoc) {
    safeAnimateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: userLoc, zoom: 15.5, tilt: 45.0),
      ),
    );
  }

  MapType _effectiveMapType(bool isDark) {
    return _selectedMapType ?? _themeMapType(isDark);
  }

  MapType _themeMapType(bool isDark) {
    return isDark ? MapType.hybrid : MapType.normal;
  }

  String mapTypeLabel(bool isDark) {
    return switch (_effectiveMapType(isDark)) {
      MapType.normal => 'Default',
      MapType.hybrid => 'Satellite',
      MapType.satellite => 'Satellite',
      _ => 'Map',
    };
  }

  void cycleMapType(bool isDark) {
    final current = _effectiveMapType(isDark);
    final next = current == MapType.normal ? MapType.hybrid : MapType.normal;
    refresh(() => _selectedMapType = next);
  }
}
