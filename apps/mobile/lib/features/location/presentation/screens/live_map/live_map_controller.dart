part of '../live_map_screen.dart';

extension _LiveMapController on _LiveMapScreenState {
  void handleScroll() {
    final nextValue =
        _scrollController.hasClients && _scrollController.offset > 24;
    if (nextValue == _isHomeScrolled) return;
    updateUi(() => _isHomeScrolled = nextValue);
  }

  Future<void> fetchMapKeys() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiBase.baseUrl}/api/v1/config/maps'),
      );
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      final key = Platform.isIOS ? data['ios_key'] : data['android_key'];
      if (key == null || key.toString().isEmpty) return;

      updateUi(() => _mapsApiKey = key.toString());
    } catch (e) {
      log('Error fetching maps API key from backend: $e');
    }
  }

  Future<void> onSearchChanged(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      clearSearch();
      return;
    }

    final key = mapsKey;
    if (key.isEmpty) {
      log('Google Places search skipped: missing Maps API key.');
      return;
    }
    final prefs = locator<SharedPreferences>();
    final countryCode = prefs.getString('country_code') ?? 'NG';
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(trimmedQuery)}'
        '&key=$key'
        '&components=country:${countryCode.toLowerCase()}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
        log(
          'Google Places Autocomplete status error: '
          '${data["status"]} ${data["error_message"] ?? ""}',
        );
        return;
      }

      final predictions = data['predictions'] as List<dynamic>? ?? [];
      updateUi(() {
        _suggestions = predictions.map((pred) {
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
        _isSearching = true;
      });
    } catch (e) {
      log('Error querying Google Places API: $e');
    }
  }

  String get mapsKey {
    if (_mapsApiKey.isNotEmpty) return _mapsApiKey;
    return Platform.isIOS
        ? EnvConfig.googleMapsIosKey
        : EnvConfig.googleMapsAndroidKey;
  }

  void clearSearch() {
    _searchController.clear();
    updateUi(() {
      _selectedPlace = null;
      _suggestions = [];
      _isSearching = false;
    });
  }
}
