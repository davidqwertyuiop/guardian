part of '../sos_bottom_sheet.dart';

extension _SosBottomSheetController on _SosBottomSheetState {
  Future<void> prepareLocation() async {
    var latitude = widget.fallbackLatitude;
    var longitude = widget.fallbackLongitude;

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        latitude = position.latitude;
        longitude = position.longitude;
      }
    } catch (_) {}

    final address = await resolveAddress(latitude, longitude);
    if (!mounted) return;
    refresh(() {
      _latitude = latitude;
      _longitude = longitude;
      _address = address;
    });
    widget.onLocationResolved?.call(latitude, longitude);
  }

  Future<String> resolveAddress(double latitude, double longitude) async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        latitude,
        longitude,
      );
      final parts = placemarks.isEmpty
          ? <String?>[]
          : addressParts(placemarks.first);
      if (parts.isNotEmpty) return parts.join(', ');
    } catch (_) {}
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  List<String?> addressParts(Placemark place) {
    return [
      if (place.subLocality != null && place.subLocality!.isNotEmpty)
        place.subLocality,
      if (place.locality != null && place.locality!.isNotEmpty) place.locality,
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty)
        place.administrativeArea,
    ];
  }

  void startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        timer.cancel();
        triggerSos();
        return;
      }
      refresh(() => _secondsRemaining--);
    });
  }
}
