part of '../map_card.dart';

extension MapCardController on MapCardState {
  Future<void> safeAnimateCamera(CameraUpdate update) async {
    final controller = _controller;
    if (controller == null || !mounted) return;
    try {
      await controller.animateCamera(update);
    } on StateError catch (error) {
      log('Ignoring stale GoogleMapController: $error');
      if (mounted) _controller = null;
    }
  }
}
