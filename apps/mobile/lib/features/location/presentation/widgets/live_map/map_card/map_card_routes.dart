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
    if (widget.selectedPlace == null) {
      return const MapRouteInfo(polylines: {}, distanceKm: 0, durationMins: 0);
    }

    final destination = widget.selectedPlace!.coordinates;
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
          points: generateRoutingCoordinates(userLoc, destination),
          color: AppColors.primary,
          width: 5,
          jointType: JointType.round,
        ),
      },
      distanceKm: distanceKm,
      durationMins: (distanceKm / 40.0 * 60.0).round().clamp(1, 120),
    );
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
