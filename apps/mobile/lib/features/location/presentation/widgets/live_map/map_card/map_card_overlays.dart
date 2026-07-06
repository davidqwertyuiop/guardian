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
              top: context.w(88),
              left: 0,
              right: 0,
              child: Center(
                child: buildLocationPill(
                  _selectedMarkerLocationLabel ??
                      _currentLocationLabel ??
                      widget.activeSosAddress ??
                      'Finding nearby...',
                ),
              ),
            ),
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
    final routePlace = activeRoutePlace();
    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: Stack(
          children: [
            if (_selectedMarkerLocationLabel != null)
              Positioned(
                top: MediaQuery.paddingOf(context).top + context.w(72),
                left: 0,
                right: 0,
                child: Center(
                  child: buildLocationPill(_selectedMarkerLocationLabel!),
                ),
              ),
            Positioned(
              right: 16,
              bottom: routePlace != null ? 300 : 120,
              child: MapControlsColumn(
                isDark: isDark,
                onZoomIn: zoomIn,
                onZoomOut: zoomOut,
                onChangeMapType: () => cycleMapType(isDark),
                onRecenter: () => recenterMap(userLoc),
                mapTypeLabel: mapTypeLabel(isDark),
              ),
            ),
            if (routePlace != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 100,
                child: DirectionsPanel(
                  place: routePlace,
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

  Widget buildLocationPill(String label) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: context.w(236)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(14),
          vertical: context.w(10),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFBFC0C5).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: context.sp(13),
            height: 1,
          ),
        ),
      ),
    );
  }
}
