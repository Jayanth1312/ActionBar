import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  String? get apiKey {
    return dotenv.env['OPENWEATHER_API_KEY'];
  }

  Future<void> fetchWeather(String city) async {
    final key = apiKey;
    if (key == null) {
      throw Exception('OpenWeather API key not found in environment');
    }

    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$key';

    print('Fetching weather data from: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Weather data: $data');
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }
}
