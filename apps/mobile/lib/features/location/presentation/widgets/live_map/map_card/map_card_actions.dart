part of '../map_card.dart';

extension MapCardActions on MapCardState {
  void preloadMemberMarker(dynamic member) {
    final uid = member['user_id'] ?? '';
    final url = member['avatar_url'] ?? '';
    final name = member['name'] ?? 'Member';
    if (uid.isEmpty || _loadingAvatars.containsKey(uid)) return;

    _loadingAvatars[uid] = true;
    (() async {
      try {
        final image = url.isNotEmpty ? await _loadNetworkImage(url) : null;
        final fallbackAsset = _fallbackAvatarAsset(uid);
        final googleMarker = await _createAvatarPinMarker(
          name,
          assetPath: image == null ? fallbackAsset : null,
          avatarImage: image,
        );
        if (mounted) {
          refresh(() {
            _googleMarkersCache[uid] = googleMarker;
          });
        }
      } catch (e) {
        log('Error creating member marker for $name: $e');
      }
    })();
  }

  void handleMapCardUpdate(MapCard oldWidget) {
    if (oldWidget.userLatitude == widget.userLatitude &&
        oldWidget.userLongitude == widget.userLongitude) {
      return;
    }
    final target = LatLng(
      _currentLatitude ?? widget.userLatitude,
      _currentLongitude ?? widget.userLongitude,
    );

    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: widget.mapState == MapDisplayState.full ? 15.0 : 16.0,
          tilt: 45.0,
        ),
      ),
    );
  }

  Future<void> _launchDirections() async {
    if (widget.selectedPlace == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination='
      '${widget.selectedPlace!.coordinates.latitude},'
      '${widget.selectedPlace!.coordinates.longitude}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    toastification.show(
      title: const Text('Navigation Error'),
      description: const Text('Could not open map navigation application.'),
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
}
