import 'dart:io';
import 'package:flutter/services.dart';

class TimerUtils {
  static const MethodChannel _channel =
      MethodChannel('com.example.actionbar/timer');

  static final Map<String, String> _clockPackages = {
    'oneplus': 'com.oneplus.deskclock',
    'default': 'com.android.deskclock',
    'samsung': 'com.sec.android.app.clockpackage',
    'xiaomi': 'com.android.deskclock',
    'oppo': 'com.oppo.clock',
    'vivo': 'com.android.deskclock',
    'huawei': 'com.android.deskclock',
  };

  static Future<bool> createTimer(String command) async {
    if (!command.startsWith('@t ')) {
      return false;
    }

    try {
      final timeString = command.substring(3).trim();

      int totalSeconds = 0;

      if (timeString.contains('hr') && timeString.contains('min')) {
        final hourPart = timeString.split('hr')[0].trim();
        final hourValue = int.parse(hourPart);

        final minPart = timeString.split('hr')[1].split('min')[0].trim();
        final minValue = int.parse(minPart);

        totalSeconds = (hourValue * 3600) + (minValue * 60);
      } else if (timeString.contains('hr')) {
        final hourValue = int.parse(timeString.split('hr')[0].trim());
        totalSeconds = hourValue * 3600;
      } else if (timeString.contains('min')) {
        final minValue = int.parse(timeString.split('min')[0].trim());
        totalSeconds = minValue * 60;
      } else {
        totalSeconds = int.parse(timeString) * 60;
      }

      if (totalSeconds <= 0) {
        return false;
      }

      if (Platform.isAndroid) {
        return await _launchAndroidTimer(totalSeconds);
      } else {
        return await _channel.invokeMethod('createTimer', {
          'seconds': totalSeconds,
        });
      }
    } catch (e) {
      print('Error creating timer: $e');
      return false;
    }
  }

  static Future<bool> _launchAndroidTimer(int seconds) async {
    try {
      final packageName =
          _clockPackages['oneplus'] ?? _clockPackages['default'];

      return await _channel.invokeMethod('launchAndroidTimer', {
        'packageName': packageName,
        'seconds': seconds,
      });
    } catch (e) {
      print('Error launching Android timer: $e');
      return false;
    }
  }

  static Future<bool> showTimers() async {
    try {
      if (Platform.isAndroid) {
        final packageName =
            _clockPackages['oneplus'] ?? _clockPackages['default'];
        return await _channel.invokeMethod('showAndroidTimers', {
          'packageName': packageName,
        });
      } else {
        return await _channel.invokeMethod('showTimers');
      }
    } catch (e) {
      print('Error showing timers: $e');
      return false;
    }
  }
}
