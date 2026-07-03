import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';
import 'package:guardian/core/constants/app_colors.dart';
import 'package:guardian/core/constants/app_assets.dart';
import 'package:guardian/core/utils/responsive_scale.dart';

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

class FullMapScreen extends StatefulWidget {
  final double userLatitude;
  final double userLongitude;

  const FullMapScreen({
    super.key,
    this.userLatitude = 9.0578,
    this.userLongitude = 7.4951,
  });

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  GoogleMapController? _controller;
  final TextEditingController _searchController = TextEditingController();
  List<MockPlace> _allPlaces = [];
  List<MockPlace> _suggestions = [];
  MockPlace? _selectedPlace;
  bool _isSearching = false;

  BitmapDescriptor? _avatarTopMarker;
  BitmapDescriptor? _avatarLeftMarker;
  BitmapDescriptor? _avatarRightMarker;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _loadMarkerIcons();
  }

  Future<void> _loadPlaces() async {
    final prefs = locator<SharedPreferences>();
    final countryCode = prefs.getString('country_code') ?? 'NG';
    setState(() {
      _allPlaces = _getPlacesForCountry(countryCode);
    });
  }

  Future<void> _loadMarkerIcons() async {
    try {
      _avatarTopMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(36, 36)),
        AppAssets.avatarTop,
      );
      _avatarLeftMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(36, 36)),
        AppAssets.avatarLeft,
      );
      _avatarRightMarker = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(36, 36)),
        AppAssets.avatarRight,
      );
      if (mounted) setState(() {});
    } catch (_) {}
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

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    final filtered = _allPlaces
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.address.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _suggestions = filtered;
      _isSearching = true;
    });
  }

  void _selectPlace(MockPlace place) {
    setState(() {
      _selectedPlace = place;
      _isSearching = false;
      _suggestions = [];
      _searchController.text = place.name;
    });

    FocusScope.of(context).unfocus();

    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: place.coordinates,
          zoom: 15.5,
          tilt: 50.0,
        ),
      ),
    );
  }

  List<LatLng> _generateRoutingCoordinates(LatLng start, LatLng end) {
    final List<LatLng> points = [];
    points.add(start);

    // Weave intermediate points to simulate street turns
    final double midLat = (start.latitude + end.latitude) / 2;
    final double midLon = (start.longitude + end.longitude) / 2;

    points.add(LatLng(midLat + 0.0008, start.longitude + 0.0004));
    points.add(LatLng(end.latitude - 0.0008, midLon - 0.0004));

    points.add(end);
    return points;
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

  Future<void> _launchDirections() async {
    if (_selectedPlace == null) return;
    final dest = _selectedPlace!.coordinates;
    final url = Uri.parse('google.navigation:q=${dest.latitude},${dest.longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      final webUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${dest.latitude},${dest.longitude}');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _applyMapStyle();

    final userLoc = LatLng(widget.userLatitude, widget.userLongitude);

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

    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Maps
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: userLoc,
                zoom: 15.0,
                tilt: 45.0,
              ),
              onMapCreated: _onMapCreated,
              markers: markers,
              polylines: polylines,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              onTap: (_) {
                if (_isSearching) {
                  setState(() {
                    _isSearching = false;
                    _suggestions = [];
                  });
                }
              },
            ),
          ),

          // 2. Custom Controls (Zoom, Reset to User Location)
          Positioned(
            right: 16,
            bottom: _selectedPlace != null ? 220 : 40,
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

          // 3. Search Bar + Autocomplete Overlay
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
                        onPressed: () => Navigator.of(context).pop(),
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

          // 4. Directions Information Bottom Card
          if (_selectedPlace != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.all(20),
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
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedPlace!.address,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _launchDirections,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Start Navigation',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
    );
  }

  Widget _buildStatIcon(bool isDark, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
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
        icon: Icon(icon, color: isDark ? Colors.white : Colors.black),
        onPressed: onTap,
      ),
    );
  }
}
