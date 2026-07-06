import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get googleMapsIosKey =>
      dotenv.env['GOOGLE_MAPS_IOS_KEY'] ??
      dotenv.env['MAPS_API_KEY_IOS'] ??
      dotenv.env['MAPS_API_KEY'] ??
      '';

  static String get googleMapsAndroidKey =>
      dotenv.env['GOOGLE_MAPS_ANDROID_KEY'] ??
      dotenv.env['MAPS_API_KEY_ANDROID'] ??
      dotenv.env['MAPS_API_KEY'] ??
      '';
}
