part of '../live_map_screen.dart';

extension _LiveMapActions on _LiveMapScreenState {
  Future<void> selectPlace(LivePlace place) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=${place.placeId}'
        '&key=$mapsKey'
        '&fields=name,formatted_address,geometry';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      final result = data['result'];
      final location = result?['geometry']?['location'];
      if (data['status'] != 'OK' || location == null) return;
      final latitude = readPlaceCoordinate(location['lat']);
      final longitude = readPlaceCoordinate(location['lng']);
      if (latitude == null || longitude == null) return;

      updateUi(() {
        _selectedPlace = SelectedLivePlace(
          name: result['name'] as String? ?? place.name,
          address: result['formatted_address'] as String? ?? place.address,
          coordinates: LatLng(latitude, longitude),
        );
        _isSearching = false;
        _searchController.text = place.name;
        _suggestions = [];
      });
      _searchFocusNode.unfocus();
    } catch (e) {
      log('Error getting place details: $e');
    }
  }

  double? readPlaceCoordinate(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  void toggleMap() {
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

  void openFullMap() {
    _bloc.add(const ChangeMapState(MapDisplayState.full));
    _fullAnim.forward();
  }

  void closeFullMap() {
    HapticFeedback.lightImpact();
    _bloc.add(const ChangeMapState(MapDisplayState.expanded));
  }

  void resizeBroadcastPanel(double delta) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final minHeight = context.w(220);
    final maxHeight = screenHeight * 0.48;

    updateUi(() {
      _broadcastPanelHeight = (_broadcastPanelHeight - delta).clamp(
        minHeight,
        maxHeight,
      );
    });
  }
}
