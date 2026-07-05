import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get googleMapsIosKey => dotenv.env['GOOGLE_MAPS_IOS_KEY'] ?? '';
  static String get googleMapsAndroidKey => dotenv.env['GOOGLE_MAPS_ANDROID_KEY'] ?? '';
}
