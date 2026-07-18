part of '../map_card.dart';

extension MapCardView on MapCardState {
  Widget buildMapCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userLoc = LatLng(
      _currentLatitude ?? widget.userLatitude,
      _currentLongitude ?? widget.userLongitude,
    );
    resolveCurrentLocationLabel(userLoc);
    final isCompact = widget.mapState == MapDisplayState.compact;
    final isFull = widget.mapState == MapDisplayState.full;
    final ignoreGestures = isCompact;
    final route = buildRouteInfo(userLoc);
    final markers = buildGoogleMarkers(userLoc);
    final screenSize = MediaQuery.sizeOf(context);
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Keep the native platform view stable while its Flutter parent animates.
    // Rebuilding/re-keying GoogleMap during every frame causes a visible hitch,
    // particularly on iOS where the underlying UIView is expensive to create.
    final mapWidget = buildPlatformMap(
      isDark: isDark,
      isFull: isFull,
      isCompact: isCompact,
      userLoc: userLoc,
      markers: markers,
      polylines: route.polylines,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([widget.mapAnim, widget.fullAnim]),
      builder: (context, _) {
        final mapVal = widget.mapAnim.value;
        final fullVal = widget.fullAnim.value;
        final compactHeight = context.w(168.0);
        final expandedHeight = context.w(320.0);
        final currentHeight =
            compactHeight +
            (expandedHeight - compactHeight) * mapVal +
            (screenHeight - expandedHeight) * fullVal;
        final currentSideMargin = context.w(20.0) * (1.0 - mapVal);
        final currentRadius = 24.0 * (1.0 - mapVal);
        final compactOpacity = (1.0 - mapVal).clamp(0.0, 1.0);
        final expandedOpacity = (mapVal * (1.0 - fullVal)).clamp(0.0, 1.0);
        final fullOpacity = fullVal.clamp(0.0, 1.0);
        return GestureDetector(
          onTap: isCompact ? widget.onTap : null,
          child: Container(
            height: currentHeight,
            width: double.infinity,
            margin: EdgeInsets.only(
              left: currentSideMargin,
              right: currentSideMargin,
            ),
            decoration: buildMapDecoration(isFull, currentRadius),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(currentRadius),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: OverflowBox(
                      alignment: Alignment.center,
                      minWidth: screenWidth,
                      maxWidth: screenWidth,
                      minHeight: screenHeight,
                      maxHeight: screenHeight,
                      child: SizedBox(
                        width: screenWidth,
                        height: screenHeight,
                        child: IgnorePointer(
                          ignoring: ignoreGestures,
                          child: mapWidget,
                        ),
                      ),
                    ),
                  ),
                  if (compactOpacity > 0.0) buildCompactOverlay(compactOpacity),
                  if (expandedOpacity > 0.0)
                    buildExpandedOverlay(expandedOpacity),
                  if (fullOpacity > 0.0)
                    buildFullOverlay(fullOpacity, isDark, userLoc, route),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration buildMapDecoration(bool isFull, double radius) {
    return BoxDecoration(
      color: const Color(0xFFEFF0F3),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: isFull
          ? []
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }
}
