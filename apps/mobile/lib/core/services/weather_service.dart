import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static Future<String> getWeatherGreeting(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true',
    );
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final current = data['current_weather'] as Map<String, dynamic>?;
        if (current != null) {
          final code = current['weathercode'] as int? ?? 0;
          return _mapWeatherCodeToGreeting(code);
        }
      }
    } catch (_) {
      // Fallback silently to default greeting on timeout/network issues
    }
    return "Lovely weather we're having today...";
  }

  static String _mapWeatherCodeToGreeting(int code) {
    switch (code) {
      case 0:
        return "Lovely clear skies today!";
      case 1:
      case 2:
      case 3:
        return "A bit cloudy outside today.";
      case 45:
      case 48:
        return "Watch out for the fog today!";
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return "Drizzle out there today, carry an umbrella.";
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return "Looks like it's raining outside, stay dry!";
      case 71:
      case 73:
      case 75:
      case 77:
        return "It is snowing outside, wrap up warm!";
      case 80:
      case 81:
      case 82:
        return "Watch out for rain showers outside!";
      case 85:
      case 86:
        return "Snow showers outside today.";
      case 95:
      case 96:
      case 99:
        return "Thunderstorms outside, stay safe indoors!";
      default:
        return "Lovely weather we're having today...";
    }
  }
}
