part of '../map_card.dart';

extension MapCardOverlays on MapCardState {
  Widget buildCompactOverlay(double opacity) {
    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: Stack(
          children: [
            Positioned(
              top: 14,
              left: 14,
              child: MapDistanceBadge(nearestMember: _nearestMemberInfo),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildExpandedOverlay(double opacity) {
    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: Stack(
          children: [
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(child: OpenMapButton(onTap: widget.onOpenMap)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFullOverlay(
    double opacity,
    bool isDark,
    LatLng userLoc,
    MapRouteInfo route,
  ) {
    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: Stack(
          children: [
            Positioned(
              right: 16,
              bottom: widget.selectedPlace != null ? 300 : 120,
              child: MapControlsColumn(
                isDark: isDark,
                onZoomIn: zoomIn,
                onZoomOut: zoomOut,
                onChangeMapType: () => cycleMapType(isDark),
                onRecenter: () => recenterMap(userLoc),
                mapTypeLabel: mapTypeLabel(isDark),
              ),
            ),
            if (widget.selectedPlace != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 100,
                child: DirectionsPanel(
                  place: widget.selectedPlace!,
                  distanceKm: route.distanceKm,
                  durationMins: route.durationMins,
                  isDark: isDark,
                  onStartNavigation: _launchDirections,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
