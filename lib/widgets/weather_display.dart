import 'package:flutter/material.dart';
import '../utils/weather_service.dart';

class WeatherDisplay extends StatelessWidget {
  final WeatherData weatherData;
  final VoidCallback onClose;

  const WeatherDisplay({
    super.key,
    required this.weatherData,
    required this.onClose,
  });

  List<Color> _getWeatherGradient(String condition) {
    condition = condition.toLowerCase();

    if (condition.contains('clear')) {
      return [Colors.blue.shade400, Colors.blue.shade700];
    } else if (condition.contains('snow')) {
      return [Colors.lightBlue.shade200, Colors.blue.shade400];
    } else if (condition.contains('sunny')) {
      return [Colors.orange, Colors.yellow];
    } else if (condition.contains('cloud')) {
      return [Colors.grey.shade600, Colors.grey.shade700];
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return [Colors.blueGrey.shade700, Colors.blueGrey.shade900];
    } else if (condition.contains('thunderstorm')) {
      return [Colors.deepPurple.shade700, Colors.deepPurple.shade900];
    } else if (condition.contains('mist') ||
        condition.contains('fog') ||
        condition.contains('haze')) {
      return [Colors.grey.shade400, Colors.grey.shade600];
    } else {
      return [Colors.grey.shade700, Colors.grey.shade900];
    }
  }

  IconData _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('clear') || condition.contains('sunny')) {
      return Icons.wb_sunny;
    } else if (condition.contains('cloud')) {
      return Icons.cloud;
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return Icons.grain;
    } else if (condition.contains('thunderstorm')) {
      return Icons.flash_on;
    } else if (condition.contains('snow')) {
      return Icons.ac_unit;
    } else if (condition.contains('mist') ||
        condition.contains('fog') ||
        condition.contains('haze')) {
      return Icons.cloud_queue;
    } else {
      return Icons.wb_sunny_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherGradient = _getWeatherGradient(weatherData.condition);
    final weatherIcon = _getWeatherIcon(weatherData.condition);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenHeight * 0.02;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: weatherGradient,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    weatherData.city,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          weatherIcon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${weatherData.temperature.toStringAsFixed(0)}°C',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Feels like ${weatherData.feelsLike.toStringAsFixed(0)}°C. ${weatherData.description}.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                    child: Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final useWrap = constraints.maxWidth < 300;

                      return Column(
                        children: [
                          if (useWrap)
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                _buildInfoItem(Icons.air,
                                    '${weatherData.windSpeed.toStringAsFixed(1)}m/s ${weatherData.windDirection}'),
                                _buildInfoItem(Icons.gas_meter_outlined,
                                    '${weatherData.pressure}hPa'),
                              ],
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoItem(Icons.air,
                                    '${weatherData.windSpeed.toStringAsFixed(1)}m/s ${weatherData.windDirection}'),
                                _buildInfoItem(Icons.gas_meter_outlined,
                                    '${weatherData.pressure}hPa'),
                              ],
                            ),
                          SizedBox(height: screenHeight * 0.01),
                          if (useWrap)
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                _buildInfoItem(Icons.water_drop,
                                    'Humidity: ${weatherData.humidity}%'),
                                _buildInfoItem(Icons.wb_sunny_outlined,
                                    'UV: ${weatherData.uvIndex}'),
                              ],
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoItem(Icons.water_drop,
                                    'Humidity: ${weatherData.humidity}%'),
                                _buildInfoItem(Icons.wb_sunny_outlined,
                                    'UV: ${weatherData.uvIndex}'),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
