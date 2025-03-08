import 'dart:io';
import 'package:flutter/services.dart';

class AlarmUtils {
  static const MethodChannel _channel =
      MethodChannel('com.example.actionbar/alarm');

  /// Package names for different device manufacturers
  static final Map<String, String> _clockPackages = {
    'oneplus': 'com.oneplus.deskclock',
    'default': 'com.android.deskclock',
    'samsung': 'com.sec.android.app.clockpackage',
    'xiaomi': 'com.android.deskclock',
    'oppo': 'com.oppo.clock',
    'vivo': 'com.android.deskclock',
    'huawei': 'com.android.deskclock',
  };

  /// Creates an alarm based on a command string
  /// Format: "@a 5 30 am" or "@a 17 45" (24-hour format)
  static Future<bool> createAlarm(String command) async {
    if (!command.startsWith('@a ')) {
      return false;
    }

    try {
      // Remove the @a prefix and trim
      final timeString = command.substring(3).trim();

      // Parse the time components
      final components = timeString.split(' ');

      int hour;
      int minute;
      bool isPM = false;

      // Handle different formats
      if (components.length >= 3 &&
          (components[2].toLowerCase() == 'am' ||
              components[2].toLowerCase() == 'pm')) {
        // Format: "@a 5 30 am" or "@a 5 30 pm"
        hour = int.parse(components[0]);
        minute = int.parse(components[1]);
        isPM = components[2].toLowerCase() == 'pm';

        // Convert 12-hour to 24-hour if needed
        if (isPM && hour < 12) {
          hour += 12;
        } else if (!isPM && hour == 12) {
          hour = 0;
        }
      } else if (components.length >= 2) {
        // Format: "@a 17 45" (24-hour format)
        hour = int.parse(components[0]);
        minute = int.parse(components[1]);
      } else {
        return false;
      }

      // Validate time values
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return false;
      }

      if (Platform.isAndroid) {
        return await _launchAndroidAlarm(hour, minute);
      } else {
        // For iOS or other platforms
        return await _channel.invokeMethod('createAlarm', {
          'hour': hour,
          'minute': minute,
        });
      }
    } catch (e) {
      print('Error creating alarm: $e');
      return false;
    }
  }

  /// Launch the Android alarm intent
  static Future<bool> _launchAndroidAlarm(int hour, int minute) async {
    try {
      // Get the appropriate clock package - you can make this configurable
      final packageName =
          _clockPackages['oneplus'] ?? _clockPackages['default'];

      return await _channel.invokeMethod('launchAndroidAlarm', {
        'packageName': packageName,
        'hour': hour,
        'minute': minute,
      });
    } catch (e) {
      print('Error launching Android alarm: $e');
      return false;
    }
  }

  /// Shows the alarm list
  static Future<bool> showAlarms() async {
    try {
      if (Platform.isAndroid) {
        final packageName =
            _clockPackages['oneplus'] ?? _clockPackages['default'];
        return await _channel.invokeMethod('showAndroidAlarms', {
          'packageName': packageName,
        });
      } else {
        return await _channel.invokeMethod('showAlarms');
      }
    } catch (e) {
      print('Error showing alarms: $e');
      return false;
    }
  }
}
