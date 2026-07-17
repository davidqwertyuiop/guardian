part of '../map_card.dart';

class MapCardState extends State<MapCard> {
  GoogleMapController? _controller;
  BitmapDescriptor? _avatarTopMarker, _userLocationMarker, _sosMarker;
  Timer? _gpsTimer;
  List<dynamic> _serverLocations = [];
  Map<String, dynamic>? _nearestMemberInfo;
  String _currentUserId = '';
  double? _currentLatitude, _currentLongitude;
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
