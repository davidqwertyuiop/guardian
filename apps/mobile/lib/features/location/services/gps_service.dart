import 'dart:developer';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardian/bootstrap/dependency_injection.dart';

class GpsService {
  Map<String, double> getDefaultLocationForCountry(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'NG':
        return {'latitude': 9.0578, 'longitude': 7.4951}; // Abuja, Nigeria
      case 'US':
        return {'latitude': 37.7749, 'longitude': -122.4194}; // San Francisco, USA
      case 'GB':
        return {'latitude': 51.5074, 'longitude': -0.1278}; // London, UK
      case 'CA':
        return {'latitude': 45.4215, 'longitude': -75.6972}; // Ottawa, Canada
      case 'AU':
        return {'latitude': -35.2809, 'longitude': 149.1300}; // Canberra, Australia
      case 'ZA':
        return {'latitude': -33.9249, 'longitude': 18.4241}; // Cape Town, South Africa
      case 'IN':
        return {'latitude': 28.6139, 'longitude': 77.2090}; // New Delhi, India
      default:
        return {'latitude': 9.0578, 'longitude': 7.4951}; // Abuja default fallback
    }
  }

  Future<Map<String, double>> getCurrentLocation() async {
    final prefs = locator<SharedPreferences>();
    final countryCode = prefs.getString('country_code') ?? 'NG';
    final fallback = getDefaultLocationForCountry(countryCode);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log('Location services are disabled.');
        return fallback;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log('Location permissions are denied.');
          return fallback;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        log('Location permissions are permanently denied.');
        return fallback;
      }

      LocationSettings locationSettings;
      if (Platform.isAndroid) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          forceLocationManager: true,
          timeLimit: const Duration(seconds: 8),
        );
      } else if (Platform.isIOS || Platform.isMacOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.high,
          activityType: ActivityType.fitness,
          distanceFilter: 0,
          pauseLocationUpdatesAutomatically: true,
          showBackgroundLocationIndicator: true,
          timeLimit: const Duration(seconds: 8),
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          timeLimit: Duration(seconds: 8),
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      log('Error getting location: $e. Fetching last known position.');
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          return {
            'latitude': lastKnown.latitude,
            'longitude': lastKnown.longitude,
          };
        }
      } catch (_) {}
      return fallback;
    }
  }
}
