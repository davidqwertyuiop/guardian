# live_map_screen.dart

* **File Path:** `apps/mobile/lib/features/location/presentation/screens/live_map_screen.dart`
* **Type:** `DART`

---

```dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:guardian/features/location/presentation/widgets/live_map/member_avatar_row.dart';
import 'package:http/http.dart' as http;
import 'package:guardian/export.dart';
import '../../domain/models/live_map_models.dart';
import '../widgets/live_map/map_card.dart';
import '../widgets/live_map/top_bar.dart';
import '../widgets/live_map/welcome_header.dart';
import '../widgets/live_map/circle_card.dart';
import '../widgets/live_map/heading_out_button.dart';

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

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _mapsApiKey = '';
  List<LivePlace> _suggestions = [];
  SelectedLivePlace? _selectedPlace;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<HomeBloc>()..add(const LoadHomeData());
    _mapAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fullAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fetchMapKeys();
  }

  @override
  void dispose() {
    _mapAnim.dispose();
    _fullAnim.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchMapKeys() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiBase.baseUrl}/api/v1/config/maps'),
      );
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

  Future<void> _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    final defaultKey = Platform.isIOS
        ? EnvConfig.googleMapsIosKey
        : EnvConfig.googleMapsAndroidKey;
    final key = _mapsApiKey.isNotEmpty ? _mapsApiKey : defaultKey;

    final prefs = locator<SharedPreferences>();
    final countryCode = prefs.getString('country_code') ?? 'NG';

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
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
              name:
                  pred['structured_formatting']?['main_text'] as String? ??
                  pred['description'] as String,
              address:
                  pred['structured_formatting']?['secondary_text'] as String? ??
                  '',
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
        ? EnvConfig.googleMapsIosKey
        : EnvConfig.googleMapsAndroidKey;
    final key = _mapsApiKey.isNotEmpty ? _mapsApiKey : defaultKey;

    final url =
        'https://maps.googleapis.com/maps/api/place/details/json'
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
            _searchFocusNode.unfocus();
          }
        }
      }
    } catch (e) {
      log('Error getting place details: $e');
    }
  }

  void _toggleMap() {
    final currentDisplayState = _bloc.state.mapDisplayState;
    if (currentDisplayState == MapDisplayState.full) return;

    final isBroadcasting =
        context.read<JourneyBloc>().state.status == JourneyStatus.active;

    if (currentDisplayState == MapDisplayState.compact) {
      if (isBroadcasting) {
        _openFullMap();
      } else {
        _bloc.add(const ChangeMapState(MapDisplayState.expanded));
        _mapAnim.forward();
      }
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
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  // Main scrollable content
                  RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => _bloc.add(const LoadHomeData()),
                    child: SingleChildScrollView(
                      physics: isFull
                          ? const NeverScrollableScrollPhysics()
                          : const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: isFull ? 0 : 120),
                      child: BlocBuilder<JourneyBloc, JourneyState>(
                        builder: (context, journeyState) {
                          final isActive =
                              journeyState.status == JourneyStatus.active;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedBuilder(
                                animation: _mapAnim,
                                builder: (context, child) {
                                  final val = _mapAnim.value;
                                  return SizedBox(
                                    height: context.w(100) * (1.0 - val),
                                  );
                                },
                              ),
                              AnimatedBuilder(
                                animation: _mapAnim,
                                builder: (context, child) {
                                  final val = _mapAnim.value;
                                  final opacity = (1.0 - val).clamp(0.0, 1.0);
                                  return Opacity(
                                    opacity: opacity,
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      heightFactor: 1.0 - val,
                                      child: child,
                                    ),
                                  );
                                },
                                child: isActive
                                    ? const SizedBox.shrink()
                                    : WelcomeHeader(
                                        userName: state.userName,
                                        weatherGreeting: state.weatherGreeting,
                                        isLoading:
                                            state.status == HomeStatus.loading,
                                      ),
                              ),
                              AnimatedBuilder(
                                animation: _mapAnim,
                                builder: (context, child) {
                                  final val = _mapAnim.value;
                                  return SizedBox(height: 8.0 * (1.0 - val));
                                },
                              ),
                              if (isActive)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20.0,
                                    right: 20.0,
                                    top: 16.0,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Orange Box: Broadcasting status info
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFF99000,
                                          ), // Vibrant orange
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Color(
                                                  0xFF00FF66,
                                                ), // Green dot
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Builder(
                                              builder: (context) {
                                                final now = DateTime.now();
                                                final start =
                                                    journeyState.startTime ??
                                                    now;
                                                final duration =
                                                    journeyState
                                                        .durationMinutes ??
                                                    30;
                                                final elapsed = now
                                                    .difference(start)
                                                    .inMinutes;
                                                final remaining =
                                                    duration - elapsed;
                                                final remainingText =
                                                    remaining > 0
                                                    ? '$remaining min remaining'
                                                    : 'completed';
                                                return Text(
                                                  'Broadcasting · $remainingText',
                                                  style: const TextStyle(
                                                    fontFamily: 'Outfit',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Black Box: Stop button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder: (context) =>
                                                  const YouAreLiveBottomSheet(
                                                    destination: '',
                                                    isConfirmStop: true,
                                                  ),
                                            );
                                          },
                                          child: const Text(
                                            'Stop',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              MapCard(
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
                                circleId: state.circleId,
                                selectedPlace: _selectedPlace,
                                onClearSearch: () {
                                  _searchController.clear();
                                  setState(() {
                                    _selectedPlace = null;
                                    _suggestions = [];
                                    _isSearching = false;
                                  });
                                },
                              ),

                              const SizedBox(height: 16),
                              CircleCard(
                                circleName: state.circleName,
                                members: state.members,
                                isLoading: state.status == HomeStatus.loading,
                              ),
                              const SizedBox(height: 16),
                              if (!isActive)
                                HeadingOutButton(
                                  circleId: state.circleId,
                                  circleName: state.circleName,
                                  members: state.members,
                                ),
                              if (!isActive) const SizedBox(height: 28),
                              SosBroadcastsSection(
                                broadcasts: state.sosBroadcasts,
                                onSeeAllTap: () {
                                  if (state.circleId.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      FadeRoute(
                                        page: SosBroadcastsScreen(
                                          circleId: state.circleId,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  // Floating Persistent Bottom Overlays when map is full
                  if (state.mapDisplayState == MapDisplayState.full)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: BlocBuilder<JourneyBloc, JourneyState>(
                        builder: (context, journeyState) {
                          if (journeyState.status == JourneyStatus.active) {
                            final now = DateTime.now();
                            final start = journeyState.startTime ?? now;
                            final duration = journeyState.durationMinutes ?? 30;
                            final elapsed = now.difference(start).inMinutes;
                            final remaining = duration - elapsed;
                            final remainingText = remaining > 0
                                ? '$remaining min remaining'
                                : 'completed';

                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                top: 80,
                                left: 20,
                                right: 20,
                                bottom: Platform.isIOS ? 140.0 : 140.0,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    (isDark
                                            ? const Color(0xFF1E1E24)
                                            : Colors.white)
                                        .withValues(alpha: 0.0),
                                    (isDark
                                            ? const Color(0xFF1E1E24)
                                            : Colors.white)
                                        .withValues(alpha: 0.7),
                                    (isDark
                                        ? const Color(0xFF1E1E24)
                                        : Colors.white),
                                    (isDark
                                        ? const Color(0xFF1E1E24)
                                        : Colors.white),
                                  ],
                                  stops: const [0.0, 0.4, 0.7, 1.0],
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Orange Box: Broadcasting status info
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFF99000,
                                      ), // Vibrant orange
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(
                                              0xFF00FF66,
                                            ), // Green dot
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Broadcasting · $remainingText',
                                          style: const TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Black Box: Stop button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) =>
                                              const YouAreLiveBottomSheet(
                                                destination: '',
                                                isConfirmStop: true,
                                              ),
                                        );
                                      },
                                      child: const Text(
                                        'Stop',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Circle Card with "See more"
                                  _buildOverlayCircleCard(
                                    context: context,
                                    circleName: state.circleName,
                                    members: state.members,
                                    isDark: isDark,
                                    onSeeMore: () {
                                      // Handle see more: return to compact view
                                      context.read<HomeBloc>().add(
                                        const ChangeMapState(
                                          MapDisplayState.compact,
                                        ),
                                      );
                                      _mapAnim.reverse();
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),

                  // Floating Persistent TopBar
                  AnimatedBuilder(
                    animation: _mapAnim,
                    builder: (context, child) {
                      final displayState = state.mapDisplayState;
                      return Positioned(
                        top: MediaQuery.paddingOf(context).top + 24,
                        left: 0,
                        right: 0,
                        child: LiveMapTopBar(
                          showSearch: displayState != MapDisplayState.compact,
                          onSosTap: () => Navigator.push(
                            context,
                            FadeRoute(page: const EmergencyScreen()),
                          ),
                          latitude: state.userLatitude,
                          longitude: state.userLongitude,
                          searchController: _searchController,
                          onSearchChanged: _onSearchChanged,
                          onClearSearch: () {
                            _searchController.clear();
                            setState(() {
                              _selectedPlace = null;
                              _suggestions = [];
                              _isSearching = false;
                            });
                          },
                          searchFocusNode: _searchFocusNode,
                        ),
                      );
                    },
                  ),

                  // Autocomplete suggestions overlay
                  if (state.mapDisplayState != MapDisplayState.compact &&
                      _isSearching &&
                      _suggestions.isNotEmpty)
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 10 + 48 + 8,
                      left: 20,
                      right: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E24)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shrinkWrap: true,
                          itemCount: _suggestions.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                          itemBuilder: (context, idx) {
                            final suggestion = _suggestions[idx];
                            return ListTile(
                              leading: const Icon(
                                Icons.location_on_rounded,
                                color: AppColors.primary,
                              ),
                              title: Text(
                                suggestion.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              subtitle: suggestion.address.isNotEmpty
                                  ? Text(
                                      suggestion.address,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    )
                                  : null,
                              onTap: () => _selectPlace(suggestion),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverlayCircleCard({
    required BuildContext context,
    required String circleName,
    required List<dynamic> members,
    required bool isDark,
    required VoidCallback onSeeMore,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${members.length} members",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  circleName.isNotEmpty ? circleName : "My Circle",
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                MemberAvatarRow(members: members),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: onSeeMore,
            child: const Text(
              "See more",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

```
