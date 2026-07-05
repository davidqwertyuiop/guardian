import 'package:google_maps_flutter/google_maps_flutter.dart';

class MockPlace {
  final String name;
  final String address;
  final LatLng coordinates;

  const MockPlace({
    required this.name,
    required this.address,
    required this.coordinates,
  });
}

class LivePlace {
  final String placeId;
  final String name;
  final String address;

  const LivePlace({
    required this.placeId,
    required this.name,
    required this.address,
  });
}

class SelectedLivePlace {
  final String name;
  final String address;
  final LatLng coordinates;

  const SelectedLivePlace({
    required this.name,
    required this.address,
    required this.coordinates,
  });
}
