import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final String city;
  final double temperature;
  final double feelsLike;
  final String condition;
  final String description;
  final String iconUrl;
  final double windSpeed;
  final String windDirection;
  final int pressure;
  final int humidity;
  final int uvIndex;
  final double visibility;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.description,
    required this.iconUrl,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.humidity,
    this.uvIndex = 0,
    required this.visibility,
  });
}

class WeatherService {
  static const String _apiKey = 'a92b9a7a7b1e614f1e99ae19c7e92ae3';

  // Helper to convert wind degrees to direction
  static String _getWindDirection(int degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return directions[(degrees ~/ 45) % 8];
  }

  static Future<WeatherData?> getWeather(String city) async {
    try {
      // Get main weather data
      final url =
          'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Get wind direction from degrees
        final windDegrees = data['wind']['deg'] ?? 0;
        final windDirection = _getWindDirection(windDegrees);

        // Get UV Index data using OpenWeatherMap's OneCall API
        // Note: This requires coordinates from our first request
        int uvIndex = 0;

        try {
          final lat = data['coord']['lat'];
          final lon = data['coord']['lon'];
          final oneCallUrl =
              'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,daily,alerts&appid=$_apiKey';

          final uvResponse = await http.get(Uri.parse(oneCallUrl));

          if (uvResponse.statusCode == 200) {
            final uvData = jsonDecode(uvResponse.body);
            // The UV index is available in current.uvi
            if (uvData['current'] != null && uvData['current']['uvi'] != null) {
              uvIndex = uvData['current']['uvi'].round();
            }
          }
        } catch (e) {
          print('Error fetching UV data: $e');
          // Fallback to estimated UV Index if something goes wrong
          if (data['clouds'] != null && data['clouds']['all'] != null) {
            // Lower cloud coverage = higher UV
            final cloudCoverage = data['clouds']['all'];
            uvIndex = (11 * (1 - cloudCoverage / 100)).round();
          }
        }

        return WeatherData(
          city: data['name'],
          temperature: data['main']['temp'].toDouble(),
          feelsLike: data['main']['feels_like'].toDouble(),
          condition: data['weather'][0]['main'],
          description: data['weather'][0]['description'],
          iconUrl:
              'https://openweathermap.org/img/wn/${data['weather'][0]['icon']}@2x.png',
          windSpeed: data['wind']['speed'].toDouble(),
          windDirection: windDirection,
          pressure: data['main']['pressure'],
          humidity: data['main']['humidity'],
          uvIndex: uvIndex,
          visibility: data['visibility'] / 1000,
        );
      }
      return null;
    } catch (e) {
      print('Error fetching weather data: $e');
      return null;
    }
  }
}
