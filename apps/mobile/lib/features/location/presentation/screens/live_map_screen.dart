import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/utils/fade_route.dart';
import 'package:guardian/core/utils/responsive_scale.dart';
import 'package:guardian/core/services/api/api_base.dart';
import 'package:guardian/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:guardian/features/home/presentation/bloc/home_bloc.dart';
import 'package:guardian/features/home/presentation/bloc/home_event.dart';
import 'package:guardian/features/home/presentation/bloc/home_state.dart';

// ─── Map Style Configs ────────────────────────────────────────────────────────

const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#151226"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#7c77a3"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#151226"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#28234a"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#28234a"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#383166"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#0a0814"}]
  }
]
''';

const String _lightMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#f2f0fc"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#5b568c"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#f2f0fc"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#ffffff"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#e1ddfa"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#d4d0f5"}]
  }
]
''';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen>
    with TickerProviderStateMixin {
  late final HomeBloc _bloc;
  late final AnimationController _mapAnim;
  late final AnimationController _fullAnim;

  @override
  void initState() {
    super.initState();
    _bloc = locator<HomeBloc>()..add(const LoadHomeData());
    _mapAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fullAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    _mapAnim.dispose();
    _fullAnim.dispose();
    super.dispose();
  }

  void _toggleMap() {
    final currentDisplayState = _bloc.state.mapDisplayState;
    if (currentDisplayState == MapDisplayState.full) return;

    if (currentDisplayState == MapDisplayState.compact) {
      _bloc.add(const ChangeMapState(MapDisplayState.expanded));
      _mapAnim.forward();
    } else {
      _bloc.add(const ChangeMapState(MapDisplayState.compact));
      _mapAnim.reverse();
    }
  }

  void _openFullMap() {
    _bloc.add(const ChangeMapState(MapDisplayState.full));
    _fullAnim.forward();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      bloc: _bloc,
      listener: (context, state) {
        switch (state.mapDisplayState) {
          case MapDisplayState.compact:
            if (_fullAnim.value > 0.0) _fullAnim.reverse();
            if (_mapAnim.value > 0.0) _mapAnim.reverse();
            break;
          case MapDisplayState.expanded:
            if (_fullAnim.value > 0.0) _fullAnim.reverse();
            if (_mapAnim.value < 1.0) _mapAnim.forward();
            break;
          case MapDisplayState.full:
            if (_mapAnim.value < 1.0) _mapAnim.forward();
            if (_fullAnim.value < 1.0) _fullAnim.forward();
            break;
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        bloc: _bloc,
        builder: (context, state) {
          final isFull = state.mapDisplayState == MapDisplayState.full;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              bottom: false,
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => _bloc.add(const LoadHomeData()),
                child: SingleChildScrollView(
                  physics: isFull
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: isFull ? 0 : 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animated collapsing top headers
                      AnimatedBuilder(
                        animation: _mapAnim,
                        builder: (context, child) {
                          final value = _mapAnim.value;
                          return Opacity(
                            opacity: (1.0 - value).clamp(0.0, 1.0),
                            child: Align(
                              heightFactor: (1.0 - value).clamp(0.0, 1.0),
                              alignment: Alignment.topCenter,
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            _TopBar(
                              onSosTap: () => Navigator.push(
                                context,
                                FadeRoute(page: const EmergencyScreen()),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _WelcomeHeader(
                              userName: state.userName,
                              weatherGreeting: state.weatherGreeting,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      
                      _MapCard(
                        mapState: state.mapDisplayState,
                        mapAnim: _mapAnim,
                        fullAnim: _fullAnim,
                        onTap: _toggleMap,
                        onOpenMap: _openFullMap,
                        onSosTap: () => Navigator.push(
                          context,
                          FadeRoute(page: const EmergencyScreen()),
                        ),
                        members: state.members,
                        userLatitude: state.userLatitude,
                        userLongitude: state.userLongitude,
                      ),
                      
                      // Animated collapsing bottom elements
                      AnimatedBuilder(
                        animation: _fullAnim,
                        builder: (context, child) {
                          final value = _fullAnim.value;
                          return Opacity(
                            opacity: (1.0 - value).clamp(0.0, 1.0),
                            child: Align(
                              heightFactor: (1.0 - value).clamp(0.0, 1.0),
                              alignment: Alignment.topCenter,
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _CircleCard(
                              circleName: state.circleName,
                              members: state.members,
                            ),
                            const SizedBox(height: 16),
                            const _HeadingOutButton(),
                            const SizedBox(height: 28),
                            const _SosBroadcastsSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onSosTap;
  const _TopBar({required this.onSosTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bell icon — circular grey pill
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                AppAssets.phBell,
                width: 20,
                height: 20,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: Color(0xFF555566),
                ),
              ),
            ),
          ),

          // Centre: Guardian home icon
          Image.asset(
            AppAssets.appHomeIcon,
            width: 42,
            height: 42,
            errorBuilder: (_, _, _) => Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 22),
            ),
          ),

          // SOS pill + grid icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SOS pill
              GestureDetector(
                onTap: onSosTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECF4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'SOS',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFF3380),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Image.asset(
                        AppAssets.sosIcon,
                        width: 20,
                        height: 20,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.warning_rounded,
                          size: 16,
                          color: Color(0xFFFF3380),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Grid / menu icon
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF3380),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Map Card ─────────────────────────────────────────────────────────────────

class _WelcomeHeader extends StatelessWidget {
  final String userName;
  final String weatherGreeting;
  const _WelcomeHeader({required this.userName, required this.weatherGreeting});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome $userName,',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: context.sp(26),
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            weatherGreeting,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Color(0xFF888899),
            ),
          ),
        ],
      ),
    );
  }
}

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

String getAddressFromCoordinates(double lat, double lon, String countryCode) {
  switch (countryCode.toUpperCase()) {
    case 'NG':
      return 'Mabushi, Abuja 900108';
    case 'US':
      return 'Union Square, San Francisco, CA 94108';
    case 'GB':
      return 'Westminster, London SW1A 0AA';
    case 'CA':
      return 'Ottawa, ON K1P 1J1, Canada';
    case 'AU':
      return 'Canberra ACT 2601, Australia';
    default:
      return 'Mabushi, Abuja 900108';
  }
}

class _MapCard extends StatefulWidget {
  final MapDisplayState mapState;
  final Animation<double> mapAnim;
  final Animation<double> fullAnim;
  final VoidCallback onTap;
  final VoidCallback onOpenMap;
  final VoidCallback onSosTap;
  final List<dynamic> members;
  final double userLatitude;
  final double userLongitude;

  const _MapCard({
    required this.mapState,
    required this.mapAnim,
    required this.fullAnim,
    required this.onTap,
    required this.onOpenMap,
    required this.onSosTap,
    required this.members,
    required this.userLatitude,
    required this.userLongitude,
  });

  @override
  State<_MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<_MapCard> {
  GoogleMapController? _controller;
  final TextEditingController _searchController = TextEditingController();
  String _mapsApiKey = '';
  List<LivePlace> _suggestions = [];
  SelectedLivePlace? _selectedPlace;
  bool _isSearching = false;
  
  BitmapDescriptor? _avatarTopMarker;
  BitmapDescriptor? _avatarLeftMarker;
  BitmapDescriptor? _avatarRightMarker;

  @override
  void initState() {
    super.initState();
    _fetchMapKeys();
    _loadMarkerIcons();
  }

  Future<void> _fetchMapKeys() async {
    try {
      final response = await http.get(Uri.parse('${ApiBase.baseUrl}/api/v1/config/maps'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final key = Platform.isIOS ? data['ios_key'] : data['android_key'];
        if (key != null && key.toString().isNotEmpty) {
          setState(() {
            _mapsApiKey = key.toString();
          });
        }
      }
    } catch (e) {
      log('Error fetching maps API key from backend: $e');
    }
  }

  Future<void> _loadMarkerIcons() async {
    try {
      _avatarTopMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(36, 36)),
        AppAssets.avatarTop,
      );
      _avatarLeftMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(36, 36)),
        AppAssets.avatarLeft,
      );
      _avatarRightMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(36, 36)),
        AppAssets.avatarRight,
      );
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant _MapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller != null &&
        (oldWidget.userLatitude != widget.userLatitude ||
            oldWidget.userLongitude != widget.userLongitude)) {
      _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(widget.userLatitude, widget.userLongitude),
            zoom: widget.mapState == MapDisplayState.full ? 15.0 : 16.0,
            tilt: 45.0,
          ),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _applyMapStyle();
  }

  void _applyMapStyle() {
    if (_controller == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _controller!.setMapStyle(isDark ? _darkMapStyle : _lightMapStyle);
  }

  List<MockPlace> _getPlacesForCountry(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'NG':
        return [
          const MockPlace(
            name: 'Wuse Market',
            address: 'Herbert Macaulay Way, Wuse, Abuja',
            coordinates: LatLng(9.0614, 7.4682),
          ),
          const MockPlace(
            name: 'Millennium Park',
            address: 'Three Arms Zone, Abuja 900103',
            coordinates: LatLng(9.0620, 7.5020),
          ),
          const MockPlace(
            name: 'Transcorp Hilton Abuja',
            address: '1 Aguiyi Ironsi St, Maitama, Abuja',
            coordinates: LatLng(9.0782, 7.4984),
          ),
          const MockPlace(
            name: 'Jabi Lake Mall',
            address: 'Bala Sokoto Way, Jabi, Abuja',
            coordinates: LatLng(9.0788, 7.4290),
          ),
          const MockPlace(
            name: 'Nnamdi Azikiwe Airport',
            address: 'Airport Road, Abuja',
            coordinates: LatLng(9.0067, 7.2631),
          ),
        ];
      case 'US':
        return [
          const MockPlace(
            name: 'Golden Gate Bridge',
            address: 'Golden Gate Bridge, San Francisco, CA',
            coordinates: LatLng(37.8199, -122.4783),
          ),
          const MockPlace(
            name: 'Fisherman\'s Wharf',
            address: 'Jefferson Street, San Francisco, CA',
            coordinates: LatLng(37.8080, -122.4177),
          ),
          const MockPlace(
            name: 'Union Square',
            address: '333 Post St, San Francisco, CA 94108',
            coordinates: LatLng(37.7876, -122.4066),
          ),
          const MockPlace(
            name: 'San Francisco Airport (SFO)',
            address: 'SFO Airport, CA 94128',
            coordinates: LatLng(37.6213, -122.3790),
          ),
        ];
      case 'GB':
        return [
          const MockPlace(
            name: 'Buckingham Palace',
            address: 'London SW1A 1AA, UK',
            coordinates: LatLng(51.5014, -0.1419),
          ),
          const MockPlace(
            name: 'London Eye',
            address: 'Riverside Building, County Hall, London',
            coordinates: LatLng(51.5033, -0.1195),
          ),
          const MockPlace(
            name: 'Heathrow Airport',
            address: 'Hounslow TW6, UK',
            coordinates: LatLng(51.4700, -0.4543),
          ),
          const MockPlace(
            name: 'Big Ben',
            address: 'London SW1A 0AA, UK',
            coordinates: LatLng(51.5007, -0.1246),
          ),
        ];
      default:
        return [
          const MockPlace(
            name: 'Central Park',
            address: 'Central Business District, Abuja',
            coordinates: LatLng(9.0538, 7.4891),
          ),
          const MockPlace(
            name: 'Wuse Market',
            address: 'Herbert Macaulay Way, Wuse, Abuja',
            coordinates: LatLng(9.0614, 7.4682),
          ),
          const MockPlace(
            name: 'Nnamdi Azikiwe Airport',
            address: 'Airport Road, Abuja',
            coordinates: LatLng(9.0067, 7.2631),
          ),
        ];
    }
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    final defaultKey = Platform.isIOS
        ? 'AIzaSyCHPSzdW1BqZR725BOBC7EeQbYZZ4JBtQs'
        : 'AIzaSyCrE5sgJcL8HmahdId4k2vbYtzrtDJCl2Q';
    final key = _mapsApiKey.isNotEmpty ? _mapsApiKey : defaultKey;

    final prefs = locator<SharedPreferences>();
    final countryCode = prefs.getString('country_code') ?? 'NG';

    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&key=$key'
        '&components=country:${countryCode.toLowerCase()}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
          final predictions = data['predictions'] as List<dynamic>? ?? [];
          final results = predictions.map((pred) {
            return LivePlace(
              placeId: pred['place_id'] as String,
              name: pred['structured_formatting']?['main_text'] as String? ?? pred['description'] as String,
              address: pred['structured_formatting']?['secondary_text'] as String? ?? '',
            );
          }).toList();

          setState(() {
            _suggestions = results;
            _isSearching = true;
          });
        } else {
          log('Google Places Autocomplete status error: ${data["status"]}');
        }
      }
    } catch (e) {
      log('Error querying Google Places API: $e');
    }
  }

  Future<void> _selectPlace(LivePlace place) async {
    final defaultKey = Platform.isIOS
        ? 'AIzaSyCHPSzdW1BqZR725BOBC7EeQbYZZ4JBtQs'
        : 'AIzaSyCrE5sgJcL8HmahdId4k2vbYtzrtDJCl2Q';
    final key = _mapsApiKey.isNotEmpty ? _mapsApiKey : defaultKey;

    final url = 'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=${place.placeId}'
        '&key=$key'
        '&fields=geometry';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']?['geometry']?['location'];
          if (location != null) {
            final lat = location['lat'] as double;
            final lng = location['lng'] as double;
            final selectedLatLng = LatLng(lat, lng);

            setState(() {
              _selectedPlace = SelectedLivePlace(
                name: place.name,
                address: place.address,
                coordinates: selectedLatLng,
              );
              _isSearching = false;
              _searchController.text = place.name;
              _suggestions = [];
            });

            _controller?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: selectedLatLng,
                  zoom: 15.5,
                  tilt: 45.0,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      log('Error getting place details: $e');
    }
  }

  List<LatLng> _generateRoutingCoordinates(LatLng start, LatLng end) {
    final List<LatLng> points = [];
    points.add(start);
    points.add(LatLng(start.latitude + (end.latitude - start.latitude) * 0.4, start.longitude));
    points.add(LatLng(start.latitude + (end.latitude - start.latitude) * 0.4, end.longitude));
    points.add(end);
    return points;
  }

  Future<void> _launchDirections() async {
    if (_selectedPlace == null) return;
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${_selectedPlace!.coordinates.latitude},${_selectedPlace!.coordinates.longitude}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      toastification.show(
        title: const Text('Navigation Error'),
        description: const Text('Could not open map navigation application.'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  Widget _buildMapControl(bool isDark, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: isDark ? Colors.white : Colors.black87),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildStatIcon(bool isDark, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _applyMapStyle();

    final userLoc = LatLng(widget.userLatitude, widget.userLongitude);

    final prefs = locator<SharedPreferences>();
    final countryCode = prefs.getString('country_code') ?? 'NG';
    final addressText = getAddressFromCoordinates(widget.userLatitude, widget.userLongitude, countryCode);

    final double screenHeight = MediaQuery.sizeOf(context).height;

    return AnimatedBuilder(
      animation: Listenable.merge([widget.mapAnim, widget.fullAnim]),
      builder: (context, _) {
        final mapVal = widget.mapAnim.value;
        final fullVal = widget.fullAnim.value;

        // Linear interpolation of height: Compact: 160, Expanded: 340, Full: screenHeight
        final double currentHeight = 160.0 + (340.0 - 160.0) * mapVal + (screenHeight - 340.0) * fullVal;
        
        final double currentMargin = 20.0 * (1.0 - fullVal);
        final double currentRadius = 24.0 * (1.0 - fullVal);

        final double compactOpacity = (1.0 - mapVal).clamp(0.0, 1.0);
        final double expandedOpacity = (mapVal * (1.0 - fullVal)).clamp(0.0, 1.0);
        final double fullOpacity = fullVal.clamp(0.0, 1.0);

        final bool isCompact = widget.mapState == MapDisplayState.compact;
        final bool isFull = widget.mapState == MapDisplayState.full;
        final bool ignoreGestures = isCompact;

        // Define markers list
        final Set<Marker> markers = {
          Marker(
            markerId: const MarkerId('user_loc'),
            position: userLoc,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
            infoWindow: const InfoWindow(title: 'You'),
          ),
        };

        if (_avatarTopMarker != null) {
          markers.add(
            Marker(
              markerId: const MarkerId('member_1'),
              position: LatLng(widget.userLatitude + 0.003, widget.userLongitude + 0.003),
              icon: _avatarTopMarker!,
              infoWindow: const InfoWindow(title: 'Olympic Blvd'),
            ),
          );
        }
        if (_avatarLeftMarker != null) {
          markers.add(
            Marker(
              markerId: const MarkerId('member_2'),
              position: LatLng(widget.userLatitude - 0.002, widget.userLongitude - 0.004),
              icon: _avatarLeftMarker!,
              infoWindow: const InfoWindow(title: 'WILSHIRE PA'),
            ),
          );
        }
        if (_avatarRightMarker != null) {
          markers.add(
            Marker(
              markerId: const MarkerId('member_3'),
              position: LatLng(widget.userLatitude + 0.002, widget.userLongitude - 0.003),
              icon: _avatarRightMarker!,
              infoWindow: const InfoWindow(title: 'Third Ave'),
            ),
          );
        }

        if (_selectedPlace != null) {
          markers.add(
            Marker(
              markerId: const MarkerId('destination'),
              position: _selectedPlace!.coordinates,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
              infoWindow: InfoWindow(title: _selectedPlace!.name),
            ),
          );
        }

        // Routing polylines
        Set<Polyline> polylines = {};
        double distanceKm = 0.0;
        int durationMins = 0;

        if (_selectedPlace != null) {
          final routeCoords = _generateRoutingCoordinates(userLoc, _selectedPlace!.coordinates);
          polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: routeCoords,
              color: AppColors.primary,
              width: 5,
              jointType: JointType.round,
            ),
          );

          final meters = Geolocator.distanceBetween(
            userLoc.latitude,
            userLoc.longitude,
            _selectedPlace!.coordinates.latitude,
            _selectedPlace!.coordinates.longitude,
          );
          distanceKm = meters / 1000.0;
          durationMins = (distanceKm / 40.0 * 60.0).round().clamp(1, 120);
        }

        final mapWidget = GoogleMap(
          initialCameraPosition: CameraPosition(
            target: userLoc,
            zoom: isFull ? 15.0 : 16.0,
            tilt: 45.0,
          ),
          onMapCreated: _onMapCreated,
          markers: markers,
          polylines: polylines,
          compassEnabled: false,
          mapToolbarEnabled: false,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: !ignoreGestures,
          scrollGesturesEnabled: !ignoreGestures,
          tiltGesturesEnabled: !ignoreGestures,
          rotateGesturesEnabled: !ignoreGestures,
          onTap: (latLng) {
            if (!isCompact && !isFull) {
              widget.onTap(); // Tapping collapses map
            }
          },
        );

        return GestureDetector(
          onTap: isCompact ? widget.onTap : null,
          child: Container(
            height: currentHeight,
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: currentMargin),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF0F3),
              borderRadius: BorderRadius.circular(currentRadius),
              boxShadow: isFull
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(currentRadius),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ignoreGestures
                        ? IgnorePointer(child: mapWidget)
                        : mapWidget,
                  ),

                  // Compact overlays
                  if (compactOpacity > 0.0)
                    Positioned.fill(
                      child: Opacity(
                        opacity: compactOpacity,
                        child: Stack(
                          children: [
                            Positioned(top: 14, left: 14, child: _MapDistanceBadge()),
                            const Positioned(
                              right: 16,
                              bottom: 14,
                              child: Text(
                                'COUNTRY\nCLUB PARK',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF4C5E87),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Expanded overlays
                  if (expandedOpacity > 0.0)
                    Positioned.fill(
                      child: Opacity(
                        opacity: expandedOpacity,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 14,
                              left: 14,
                              right: 14,
                              child: _ExpandedTopRow(
                                onSosTap: widget.onSosTap,
                                address: addressText,
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: widget.onOpenMap,
                                  child: Container(
                                    width: context.w(140),
                                    height: context.w(40),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8E9BFF),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          AppAssets.openMapIcon,
                                          width: context.w(16),
                                          height: context.w(16),
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Open map',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                            fontSize: context.sp(13),
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Full screen overlays (Search bar, suggestions list, custom zoom/recenter controls, directions card)
                  if (fullOpacity > 0.0)
                    Positioned.fill(
                      child: Opacity(
                        opacity: fullOpacity,
                        child: Stack(
                          children: [
                            // Top Search Bar
                            Positioned(
                              top: MediaQuery.paddingOf(context).top + 10,
                              left: 16,
                              right: 16,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.arrow_back_rounded,
                                            color: isDark ? Colors.white : Colors.black,
                                          ),
                                          onPressed: () {
                                            // Back resets from full to expanded state
                                            widget.onTap();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                          height: 52,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF1E1E24).withValues(alpha: 0.95)
                                                : Colors.white.withValues(alpha: 0.95),
                                            borderRadius: BorderRadius.circular(26),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.search_rounded,
                                                color: AppColors.primary,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: TextField(
                                                  controller: _searchController,
                                                  onChanged: _onSearchChanged,
                                                  decoration: const InputDecoration(
                                                    hintText: 'Search places...',
                                                    border: InputBorder.none,
                                                    isDense: true,
                                                  ),
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 14,
                                                    color: isDark ? Colors.white : Colors.black,
                                                  ),
                                                ),
                                              ),
                                              if (_searchController.text.isNotEmpty)
                                                IconButton(
                                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    setState(() {
                                                      _selectedPlace = null;
                                                      _suggestions = [];
                                                      _isSearching = false;
                                                    });
                                                  },
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_isSearching && _suggestions.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      constraints: const BoxConstraints(maxHeight: 220),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.15),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ListView.separated(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        shrinkWrap: true,
                                        itemCount: _suggestions.length,
                                        separatorBuilder: (_, __) => Divider(
                                          height: 1,
                                          color: isDark ? Colors.white10 : Colors.black12,
                                        ),
                                        itemBuilder: (context, index) {
                                          final place = _suggestions[index];
                                          return ListTile(
                                            leading: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                                            title: Text(
                                              place.name,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: isDark ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            subtitle: Text(
                                              place.address,
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            onTap: () => _selectPlace(place),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Right controls (Zoom In, Zoom Out, Recenter to user)
                            Positioned(
                              right: 16,
                              bottom: _selectedPlace != null ? 300 : 120,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildMapControl(isDark, Icons.add_rounded, () {
                                    _controller?.animateCamera(CameraUpdate.zoomIn());
                                  }),
                                  const SizedBox(height: 10),
                                  _buildMapControl(isDark, Icons.remove_rounded, () {
                                    _controller?.animateCamera(CameraUpdate.zoomOut());
                                  }),
                                  const SizedBox(height: 10),
                                  _buildMapControl(isDark, Icons.my_location_rounded, () {
                                    _controller?.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: userLoc,
                                          zoom: 15.5,
                                          tilt: 45.0,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),

                            // Bottom Directions Panel
                            if (_selectedPlace != null)
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 100,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1C1C22).withValues(alpha: 0.95)
                                        : Colors.white.withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedPlace!.name,
                                        style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _selectedPlace!.address,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          _buildStatIcon(
                                            isDark,
                                            Icons.directions_car_rounded,
                                            '${distanceKm.toStringAsFixed(1)} km',
                                          ),
                                          const SizedBox(width: 24),
                                          _buildStatIcon(
                                            isDark,
                                            Icons.access_time_filled_rounded,
                                            '$durationMins mins',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed: _launchDirections,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            'Start Navigation',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ExpandedTopRow extends StatelessWidget {
  final VoidCallback onSosTap;
  final String address;

  const _ExpandedTopRow({
    required this.onSosTap,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            toastification.show(
              context: context,
              title: const Text('Notifications'),
              description: const Text('You have no new notifications.'),
              type: ToastificationType.info,
              style: ToastificationStyle.flat,
              autoCloseDuration: const Duration(seconds: 3),
            );
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E24).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.notifications_none_rounded,
                size: 18,
                color: isDark ? Colors.white : const Color(0xFF444455),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C22).withValues(alpha: 0.85) : Colors.grey.shade700.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onSosTap,
          child: Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'SOS',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: Color(0xFFFF3380),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapDistanceBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.worldMap,
            width: 13,
            height: 13,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.public, size: 13, color: AppColors.primary),
          ),
          const SizedBox(width: 6),
          const Text(
            '20.2 km • 22 mins',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPin extends StatelessWidget {
  final LatLng position;
  final String label;

  const _LocationPin({
    required this.position,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Icon(
          Icons.location_on,
          color: Colors.black,
          size: 24,
        ),
      ],
    );
  }
}


class _AvatarPin extends StatelessWidget {
  final String asset;
  final String label;
  const _AvatarPin({required this.asset, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
            image: DecorationImage(image: AssetImage(asset), fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}

// ─── Circle Card ──────────────────────────────────────────────────────────────

class _CircleCard extends StatelessWidget {
  final String circleName;
  final List<dynamic> members;
  const _CircleCard({required this.circleName, required this.members});

  @override
  Widget build(BuildContext context) {
    final count = members.isNotEmpty ? members.length : 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FA),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left column: count label + circle name + circular member avatars
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count members',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF999AB0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    circleName.isNotEmpty ? circleName : "brother's\ncircle",
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Overlapping circular member avatars
                  _MemberAvatarRow(members: members),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right column: 2x2 square avatar grid
            _AvatarGrid(members: members),
          ],
        ),
      ),
    );
  }
}

/// 3 overlapping circles — flag/emoji style avatars matching the design.
class _MemberAvatarRow extends StatelessWidget {
  final List<dynamic> members;
  const _MemberAvatarRow({required this.members});

  // Fallback coloured backgrounds for when there are no real avatars
  static const _fallbackColors = [
    Color(0xFF2D7D32), // green (Nigerian flag)
    Color(0xFFF48FB1), // pink / floral
    Color(0xFF1565C0), // blue flag
  ];

  static const _fallbackAssets = [
    AppAssets.avatarTop,
    AppAssets.avatarLeft,
    AppAssets.avatarRight,
  ];

  @override
  Widget build(BuildContext context) {
    final displayCount = members.isEmpty ? 3 : members.length.clamp(1, 4);
    const avatarSize = 32.0;
    const overlap = 10.0;

    return SizedBox(
      height: avatarSize,
      width: avatarSize + (displayCount - 1) * (avatarSize - overlap),
      child: Stack(
        children: List.generate(displayCount, (i) {
          final String? url = members.isEmpty
              ? null
              : (members[i] as Map<String, dynamic>)['avatar_url'] as String?;

          final bool hasUrl = url != null && url.isNotEmpty;
          final String fallbackAsset = i < _fallbackAssets.length
              ? _fallbackAssets[i]
              : _fallbackAssets[0];
          final Color fallbackColor = i < _fallbackColors.length
              ? _fallbackColors[i]
              : _fallbackColors[0];

          return Positioned(
            left: i * (avatarSize - overlap),
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fallbackColor,
                border: Border.all(color: Colors.white, width: 2),
                image: DecorationImage(
                  image: hasUrl
                      ? NetworkImage(url) as ImageProvider
                      : AssetImage(fallbackAsset),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 2 × 2 grid of rounded-square avatar tiles (filled or empty placeholder).
class _AvatarGrid extends StatelessWidget {
  final List<dynamic> members;
  const _AvatarGrid({required this.members});

  static const _fallbackAssets = [
    AppAssets.avatarTop,
    AppAssets.avatarLeft,
    AppAssets.avatarRight,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 88,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_slot(0), const SizedBox(width: 6), _slot(1)],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_slot(2), const SizedBox(width: 6), _slot(3)],
          ),
        ],
      ),
    );
  }

  Widget _slot(int index) {
    final bool hasMember = index < members.length;
    if (!hasMember) {
      return Container(
        width: 40,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFE4E4EC),
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    final m = members[index] as Map<String, dynamic>;
    final url = m['avatar_url'] as String? ?? '';
    final fallback = index < _fallbackAssets.length
        ? _fallbackAssets[index]
        : _fallbackAssets[0];

    return Container(
      width: 40,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade300,
        image: DecorationImage(
          image: url.isNotEmpty
              ? NetworkImage(url) as ImageProvider
              : AssetImage(fallback),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ─── I'm Heading Out Button ───────────────────────────────────────────────────

class _HeadingOutButton extends StatelessWidget {
  const _HeadingOutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Journey request initiated!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          child: const Text(
            "I'm heading out",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SOS Broadcasts Section ───────────────────────────────────────────────────

class _SosBroadcastsSection extends StatelessWidget {
  const _SosBroadcastsSection();

  static const _broadcasts = [
    {
      'name': 'Mac',
      'location': 'LBS, Lekki',
      'date': '02/06/2024',
      'time': '2:20PM',
    },
    {
      'name': 'Olajire',
      'location': 'Alausa, Ikeja',
      'date': '02/06/2024',
      'time': '2:20PM',
    },
    {
      'name': 'Tunde',
      'location': 'Mabushi, Abuja',
      'date': '02/06/2024',
      'time': '3:50PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Image.asset(
                AppAssets.sosBroadcastIcon,
                width: 20,
                height: 20,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.campaign_rounded,
                  color: Color(0xFF3355FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 7),
              const Text(
                'SOS Broadcasts',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3355FF),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF888899),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Date group label
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 10),
          child: Text(
            'Today',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Color(0xFF888899),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Broadcast list
        ...List.generate(_broadcasts.length, (i) {
          final b = _broadcasts[i];
          return _BroadcastTile(
            name: b['name']!,
            location: b['location']!,
            date: b['date']!,
            time: b['time']!,
            avatarIndex: i,
          );
        }),
      ],
    );
  }
}

class _BroadcastTile extends StatelessWidget {
  final String name;
  final String location;
  final String date;
  final String time;
  final int avatarIndex;

  const _BroadcastTile({
    required this.name,
    required this.location,
    required this.date,
    required this.time,
    required this.avatarIndex,
  });

  static const _avatarAssets = [
    AppAssets.avatarTop,
    AppAssets.avatarLeft,
    AppAssets.avatarRight,
  ];

  @override
  Widget build(BuildContext context) {
    final asset = avatarIndex < _avatarAssets.length
        ? _avatarAssets[avatarIndex]
        : _avatarAssets[0];

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      child: Row(
        children: [
          // Circular avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              image: DecorationImage(
                image: AssetImage(asset),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFF888899),
                  ),
                ),
              ],
            ),
          ),

          // Date + time (right-aligned)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF888899),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF888899),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
