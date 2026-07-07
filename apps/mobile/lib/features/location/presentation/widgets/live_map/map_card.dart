import 'package:http/http.dart' as http;
import 'package:guardian/features/location/services/gps_service.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:guardian/export.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'map_distance_badge.dart';
import 'map_card/directions_panel.dart';
import 'map_card/map_controls_column.dart';
import 'map_card/open_map_button.dart';
import '../../../domain/models/live_map_models.dart';

part 'map_card/map_card_routes.dart';
part 'map_card/map_card_google_markers.dart';
part 'map_card/map_card_marker_loading.dart';
part 'map_card/map_card_location_markers.dart';
part 'map_card/map_card_avatar_markers.dart';
part 'map_card/map_card_avatar_image.dart';
part 'map_card/map_card_sync.dart';
part 'map_card/map_card_actions.dart';
part 'map_card/map_card_platform_map.dart';
part 'map_card/map_card_overlays.dart';
part 'map_card/map_card_camera_controls.dart';
part 'map_card/map_card_view.dart';

class MapCard extends StatefulWidget {
  final MapDisplayState mapState;
  final Animation<double> mapAnim;
  final Animation<double> fullAnim;
  final VoidCallback onTap;
  final VoidCallback onOpenMap;
  final VoidCallback onSosTap;
  final List<dynamic> members;
  final double userLatitude;
  final double userLongitude;
  final String circleId;
  final SelectedLivePlace? selectedPlace;
  final VoidCallback onClearSearch;
  final bool isSosActive;
  final String? activeSosAddress;
  final List<dynamic> sosBroadcasts;
  final String mapsApiKey;

  const MapCard({
    super.key,
    required this.mapState,
    required this.mapAnim,
    required this.fullAnim,
    required this.onTap,
    required this.onOpenMap,
    required this.onSosTap,
    required this.members,
    required this.userLatitude,
    required this.userLongitude,
    required this.circleId,
    required this.selectedPlace,
    required this.onClearSearch,
    required this.isSosActive,
    required this.activeSosAddress,
    required this.sosBroadcasts,
    required this.mapsApiKey,
  });

  @override
  State<MapCard> createState() => MapCardState();
}

class MapCardState extends State<MapCard> {
  GoogleMapController? _controller;

  BitmapDescriptor? _avatarTopMarker;
  BitmapDescriptor? _userLocationMarker;
  BitmapDescriptor? _sosMarker;

  Timer? _gpsTimer;
  List<dynamic> _serverLocations = [];
  Map<String, dynamic>? _nearestMemberInfo;
  String _currentUserId = '';
  double? _currentLatitude;
  double? _currentLongitude;
  MapType? _selectedMapType;
  List<LatLng> _directionsPoints = [];
  double _directionsDistanceKm = 0;
  int _directionsDurationMins = 0;
  String? _directionsRouteKey;
  bool _isLoadingDirections = false;
  String? _currentLocationLabel;
  String? _currentLocationKey;
  String? _selectedMarkerLocationLabel;

  final Map<String, BitmapDescriptor> _googleMarkersCache = {};
  final Map<String, bool> _loadingAvatars = {};

  void refresh(VoidCallback callback) => setState(callback);

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
    _loadCurrentUserId();
    _syncLocationAndLoadData();
    _startGpsTimer();
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    handleMapCardUpdate(oldWidget);
    refreshDirectionsIfNeeded();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) => buildMapCard(context);
}
