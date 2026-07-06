part of '../live_map_screen.dart';

extension _LiveMapController on _LiveMapScreenState {
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

  String get mapsKey {
    if (_mapsApiKey.isNotEmpty) return _mapsApiKey;
    return Platform.isIOS
        ? EnvConfig.googleMapsIosKey
        : EnvConfig.googleMapsAndroidKey;
  }
}
