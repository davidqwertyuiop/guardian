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
import 'member_map_popup.dart';
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
part 'map_card/map_card_member_popup_actions.dart';
part 'map_card/map_card_member_popup_builder.dart';
part 'map_card/map_card_member_popup_helpers.dart';
part 'map_card/map_card_platform_map.dart';
part 'map_card/map_card_overlays.dart';
part 'map_card/map_card_camera_controls.dart';
part 'map_card/map_card_controller.dart';
part 'map_card/map_card_state.dart';
part 'map_card/map_card_view.dart';

class MapCard extends StatefulWidget {
  final MapDisplayState mapState;
  final Animation<double> mapAnim, fullAnim;
  final VoidCallback onTap, onOpenMap, onSosTap, onClearSearch;
  final List<dynamic> members, sosBroadcasts;
  final double userLatitude, userLongitude;
  final String circleId, mapsApiKey;
  final SelectedLivePlace? selectedPlace;
  final bool isSosActive;
  final String? activeSosAddress;

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
