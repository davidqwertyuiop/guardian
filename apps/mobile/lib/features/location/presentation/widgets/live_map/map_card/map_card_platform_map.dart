part of '../map_card.dart';

extension MapCardPlatformMap on MapCardState {
  Widget buildPlatformMap({
    required bool isDark,
    required bool isFull,
    required bool isCompact,
    required bool ignoreGestures,
    required LatLng userLoc,
    required Set<Marker> markers,
    required Set<Polyline> polylines,
  }) {
    return GoogleMap(
      key: ValueKey('live_map_${widget.mapState.name}'),
      initialCameraPosition: CameraPosition(
        target: userLoc,
        zoom: isFull ? 15.0 : 16.0,
        tilt: 45.0,
      ),
      onMapCreated: _onMapCreated,
      style: null,
      mapType: _effectiveMapType(isDark),
      markers: markers,
      polylines: polylines,
      buildingsEnabled: true,
      trafficEnabled: isFull,
      compassEnabled: false,
      mapToolbarEnabled: false,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: !ignoreGestures,
      scrollGesturesEnabled: !ignoreGestures,
      tiltGesturesEnabled: !ignoreGestures,
      rotateGesturesEnabled: !ignoreGestures,
      onTap: (_) => handlePlatformMapTap(isCompact, isFull),
    );
  }

  void handlePlatformMapTap(bool isCompact, bool isFull) {
    if (isFull && _selectedMarkerLocationLabel != null) {
      refresh(() => _selectedMarkerLocationLabel = null);
      return;
    }

    if (!isCompact && !isFull) widget.onTap();
  }
}
