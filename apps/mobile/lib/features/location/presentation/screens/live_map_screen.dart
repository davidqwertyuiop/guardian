import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:guardian/export.dart';
import '../../domain/models/live_map_models.dart';
import '../widgets/live_map/broadcast_bottom_panel.dart';
import '../widgets/live_map/broadcast_controls.dart';
import '../widgets/live_map/map_card.dart';
import '../widgets/live_map/place_suggestions_overlay.dart';
import '../widgets/live_map/sos_bottom_sheet.dart';
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
  double _broadcastPanelHeight = 260;

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

  void _closeFullMap() {
    HapticFeedback.lightImpact();
    _bloc.add(const ChangeMapState(MapDisplayState.expanded));
  }

  void _resizeBroadcastPanel(double delta) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final minHeight = context.w(220);
    final maxHeight = screenHeight * 0.48;

    setState(() {
      _broadcastPanelHeight = (_broadcastPanelHeight - delta).clamp(
        minHeight,
        maxHeight,
      );
    });
  }

  void _showStopBroadcastSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          const YouAreLiveBottomSheet(destination: '', isConfirmStop: true),
    );
  }

  void _showSosSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SosBottomSheet(
        circleId: _bloc.state.circleId,
        fallbackLatitude: _bloc.state.userLatitude,
        fallbackLongitude: _bloc.state.userLongitude,
        onClosed: () => _bloc.add(const LoadHomeData()),
      ),
    );
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
          final isCompact = state.mapDisplayState == MapDisplayState.compact;
          final isExpanded = state.mapDisplayState == MapDisplayState.expanded;
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
                              if (isActive && isCompact) ...[
                                BroadcastControls(
                                  journeyState: journeyState,
                                  onStopPressed: _showStopBroadcastSheet,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.w(20),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              MapCard(
                                mapState: state.mapDisplayState,
                                mapAnim: _mapAnim,
                                fullAnim: _fullAnim,
                                onTap: _toggleMap,
                                onOpenMap: _openFullMap,
                                onSosTap: _showSosSheet,
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
                              if (isActive && isExpanded) ...[
                                BroadcastBottomPanel(
                                  journeyState: journeyState,
                                  circleName: state.circleName,
                                  members: state.members,
                                  height: _broadcastPanelHeight,
                                  onDragDelta: _resizeBroadcastPanel,
                                  onStopPressed: _showStopBroadcastSheet,
                                  onSeeMore: () {
                                    _bloc.add(
                                      const ChangeMapState(
                                        MapDisplayState.compact,
                                      ),
                                    );
                                  },
                                ),
                              ] else if (isActive) ...[
                                CircleCard(
                                  circleName: state.circleName,
                                  members: state.members,
                                  isLoading: state.status == HomeStatus.loading,
                                ),
                                const SizedBox(height: 28),
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
                              ] else ...[
                                CircleCard(
                                  circleName: state.circleName,
                                  members: state.members,
                                  isLoading: state.status == HomeStatus.loading,
                                ),
                                const SizedBox(height: 16),
                                HeadingOutButton(
                                  circleId: state.circleId,
                                  circleName: state.circleName,
                                  members: state.members,
                                ),
                                const SizedBox(height: 28),
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
                            ],
                          );
                        },
                      ),
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
                          onSosTap: _showSosSheet,
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
                          showBackButton: displayState == MapDisplayState.full,
                          onBackPressed: _closeFullMap,
                        ),
                      );
                    },
                  ),

                  PlaceSuggestionsOverlay(
                    isVisible:
                        state.mapDisplayState != MapDisplayState.compact &&
                        _isSearching,
                    suggestions: _suggestions,
                    onSuggestionTap: _selectPlace,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
