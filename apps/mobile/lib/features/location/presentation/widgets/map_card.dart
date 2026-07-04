import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'package:guardian/export.dart';

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



class MapCard extends StatefulWidget {
  final MapDisplayState mapState;
  final Animation<double> mapAnim;
  final Animation<double> fullAnim;
  final VoidCallback onTap;
  final VoidCallback onOpenMap;
  final VoidCallback onSosTap;
  final VoidCallback onBack;
  final List<dynamic> members;
  final double userLatitude;
  final double userLongitude;

  const MapCard({
    super.key,
    required this.mapState,
    required this.mapAnim,
    required this.fullAnim,
    required this.onTap,
    required this.onOpenMap,
    required this.onSosTap,
    required this.onBack,
    required this.members,
    required this.userLatitude,
    required this.userLongitude,
  });

  @override
  State<MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<MapCard> {
  GoogleMapController? _controller;
  final TextEditingController _searchController = TextEditingController();
  String _mapsApiKey = '';
  List<LivePlace> _suggestions = [];
  SelectedLivePlace? _selectedPlace;
  bool _isSearching = false;
  
  String _currentAddress = 'Loading address...';
  bool _is3D = true;
  bool _isDarkModeOverride = false;
  bool _useDarkOverride = false; // toggle usage
  
  BitmapDescriptor? _avatarTopMarker;
  BitmapDescriptor? _avatarLeftMarker;
  BitmapDescriptor? _avatarRightMarker;

  @override
  void initState() {
    super.initState();
    _fetchMapKeys();
    _loadMarkerIcons();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    try {
      final placemarks = await geocoding.Geocoding().placemarkFromCoordinates(
        widget.userLatitude,
        widget.userLongitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        if (mounted) {
          setState(() {
            _currentAddress = '${place.street}, ${place.locality}';
          });
        }
      }
    } catch (e) {
      log('Error reverse geocoding: $e');
      if (mounted) {
        setState(() {
          _currentAddress = 'Unknown location';
        });
      }
    }
  }

  Future<void> _fetchMapKeys() async {
    try {
      final response = await http.get(Uri.parse('${ApiBase.baseUrl}/api/v1/config/maps'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final key = Platform.isIOS ? data['ios_key'] : data['android_key'];
        if (key != null && key.toString().isNotEmpty) {
          if (!mounted) return;
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
  void didUpdateWidget(covariant MapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLatitude != widget.userLatitude ||
        oldWidget.userLongitude != widget.userLongitude) {
      _fetchAddress();
      if (_controller != null) {
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
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.isEmpty) {
      if (!mounted) return;
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

          if (!mounted) return;
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

            if (!mounted) return;
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
    final isDark = _useDarkOverride ? _isDarkModeOverride : (Theme.of(context).brightness == Brightness.dark);

    final userLoc = LatLng(widget.userLatitude, widget.userLongitude);

    final double screenHeight = MediaQuery.sizeOf(context).height;

    return AnimatedBuilder(
      animation: Listenable.merge([widget.mapAnim, widget.fullAnim]),
      builder: (context, _) {
        final mapVal = widget.mapAnim.value;
        final fullVal = widget.fullAnim.value;

        // Interpolate height: Compact: 168, Expanded & Full: screenHeight
        final double currentHeight = 168.0 + (screenHeight - 168.0) * mapVal;
        
        final double currentMargin = 20.0 * (1.0 - mapVal);
        final double currentRadius = 24.0 * (1.0 - mapVal);

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

        for (var i = 0; i < widget.members.length; i++) {
          final member = widget.members[i];
          // Fallback to static offsets if real lat/lng isn't implemented in backend yet,
          // but parse them if they exist to be ready for the backend endpoint.
          final lat = member['latitude'] as double? ?? (widget.userLatitude + (i == 0 ? 0.003 : (i == 1 ? -0.002 : 0.002)));
          final lng = member['longitude'] as double? ?? (widget.userLongitude + (i == 0 ? 0.003 : (i == 1 ? -0.004 : -0.003)));
          final name = member['name'] as String? ?? 'Member ${i + 1}';
          
          final icon = (i % 3 == 0) ? _avatarTopMarker 
                     : (i % 3 == 1) ? _avatarLeftMarker 
                     : _avatarRightMarker;

          markers.add(
            Marker(
              markerId: MarkerId('member_$i'),
              position: LatLng(lat, lng),
              icon: icon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
              infoWindow: InfoWindow(title: name),
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
          style: isDark ? _darkMapStyle : _lightMapStyle,
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
                            Positioned(top: 14, left: 14, child: _MapDistanceBadge(members: widget.members, userLat: widget.userLatitude, userLng: widget.userLongitude)),
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
                                address: _currentAddress,
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
                                            widget.onBack();
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
                                                    if (!mounted) return;
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
                                        separatorBuilder: (_, _) => Divider(
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
                                          tilt: _is3D ? 45.0 : 0.0,
                                        ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 10),
                                  _buildMapControl(isDark, _is3D ? Icons.map_outlined : Icons.layers_outlined, () {
                                    setState(() {
                                      _is3D = !_is3D;
                                      _controller?.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                            target: userLoc,
                                            zoom: 15.5,
                                            tilt: _is3D ? 45.0 : 0.0,
                                          ),
                                        ),
                                      );
                                    });
                                  }),
                                  const SizedBox(height: 10),
                                  _buildMapControl(isDark, isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, () {
                                    setState(() {
                                      _useDarkOverride = true;
                                      _isDarkModeOverride = !isDark;
                                    });
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
  final List<dynamic> members;
  final double userLat;
  final double userLng;

  const _MapDistanceBadge({
    required this.members,
    required this.userLat,
    required this.userLng,
  });

  @override
  Widget build(BuildContext context) {
    double minDistance = double.infinity;
    for (var member in members) {
      final lat = member['latitude'] as double?;
      final lng = member['longitude'] as double?;
      if (lat != null && lng != null) {
        final dist = Geolocator.distanceBetween(userLat, userLng, lat, lng);
        if (dist < minDistance) minDistance = dist;
      }
    }

    String distanceStr = "No members";
    if (minDistance != double.infinity) {
      final distKm = minDistance / 1000.0;
      final mins = (distKm / 40.0 * 60).round().clamp(1, 999);
      distanceStr = '${distKm.toStringAsFixed(1)} km • $mins mins';
    }

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
          Text(
            distanceStr,
            style: const TextStyle(
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

class LivePlace {
  final String placeId;
  final String name;
  final String address;

  LivePlace({
    required this.placeId,
    required this.name,
    required this.address,
  });
}

class SelectedLivePlace {
  final String name;
  final String address;
  final LatLng coordinates;

  SelectedLivePlace({
    required this.name,
    required this.address,
    required this.coordinates,
  });
}
