part of '../map_card.dart';

extension MapCardMarkerLoading on MapCardState {
  Future<void> _loadMarkerIcons() async {
    try {
      _userLocationMarker = await _createLocationPinMarker("Me");
      _avatarTopMarker = await _createAvatarPinMarker(
        "Dave",
        assetPath: AppAssets.avatarTop,
      );
      _sosMarker = await _createSosPinMarker();
      if (mounted) refresh(() {});
    } catch (e) {
      log('Error loading custom marker bitmaps: $e');
    }
  }

  Future<ui.Image?> _loadNetworkImage(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return null;
      final codec = await ui.instantiateImageCodec(response.bodyBytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      log('Error downloading avatar $url: $e');
      return null;
    }
  }

  Future<ui.Image> _loadUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
