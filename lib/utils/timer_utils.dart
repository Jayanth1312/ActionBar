import 'dart:io';
import 'package:flutter/services.dart';

class TimerUtils {
  // Change the channel name to match MainActivity.kt
  static const platform = MethodChannel('com.example.actionbar/timer');

  static final Map<String, String> _clockPackages = {
    'oneplus': 'com.oneplus.deskclock',
    'default': 'com.android.deskclock',
    'samsung': 'com.sec.android.app.clockpackage',
    'xiaomi': 'com.android.deskclock',
    'oppo': 'com.oppo.clock',
    'vivo': 'com.android.deskclock',
    'huawei': 'com.android.deskclock',
  };

  static Future<bool> createTimer(String input) async {
    try {
      // Parse the input format '@t 5min' or '@t 1hr 30min'
      final timeString = input.substring(3).trim().toLowerCase();

      int minutes = 0;

      if (timeString.contains('hr')) {
        final parts = timeString.split('hr');
        final hours = int.tryParse(parts[0].trim()) ?? 0;
        minutes += hours * 60;

        if (parts.length > 1 && parts[1].contains('min')) {
          final minPart = parts[1].trim().split('min')[0].trim();
          final mins = int.tryParse(minPart) ?? 0;
          minutes += mins;
        }
      } else if (timeString.contains('min')) {
        final minPart = timeString.split('min')[0].trim();
        minutes = int.tryParse(minPart) ?? 0;
      } else {
        // Try to parse as just minutes
        minutes = int.tryParse(timeString) ?? 0;
      }

      if (minutes <= 0) {
        return false;
      }

      if (Platform.isAndroid) {
        return await _launchAndroidTimer(minutes * 60);
      }

      // Call native method
      final result = await platform.invokeMethod('createTimer', {
        'minutes': minutes,
      });

      return result == true;
    } catch (e) {
      print('Error creating timer: $e');
      return false;
    }
  }

  /// Show a notification for the timer instead of opening the clock app
  static Future<bool> _launchAndroidTimer(int seconds) async {
    try {
      // Get the appropriate package name based on device manufacturer
      final packageName =
          _clockPackages['oneplus'] ?? _clockPackages['default'];

      return await platform.invokeMethod('launchAndroidTimer', {
        'seconds': seconds,
        'packageName': packageName, // Add the missing packageName parameter
      });
    } catch (e) {
      print('Error showing timer notification: $e');
      return false;
    }
  }

  static Future<bool> showTimers() async {
    try {
      if (Platform.isAndroid) {
        final packageName =
            _clockPackages['oneplus'] ?? _clockPackages['default'];
        return await platform.invokeMethod('showAndroidTimers', {
          'packageName': packageName,
        });
      } else {
        return await platform.invokeMethod('showTimers');
      }
    } catch (e) {
      print('Error showing timers: $e');
      return false;
    }
  }
}
