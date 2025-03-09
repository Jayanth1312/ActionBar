import 'dart:io';
import 'package:flutter/services.dart';

class AlarmUtils {
  static const MethodChannel _channel =
      MethodChannel('com.example.actionbar/alarm');

  static final Map<String, String> _clockPackages = {
    'oneplus': 'com.oneplus.deskclock',
    'default': 'com.android.deskclock',
    'samsung': 'com.sec.android.app.clockpackage',
    'xiaomi': 'com.android.deskclock',
    'oppo': 'com.oppo.clock',
    'vivo': 'com.android.deskclock',
    'huawei': 'com.android.deskclock',
  };

  static Future<bool> createAlarm(String input) async {
    try {
      // Parse the input format '@a 8 30 am' or '@a 17 45'
      final parts = input.substring(3).trim().split(' ');

      if (parts.length < 1) return false;

      int hour;
      int minute = 0;
      bool isAM = false;

      // Check for AM/PM format
      if (parts.length >= 3 &&
          (parts[2].toLowerCase() == 'am' || parts[2].toLowerCase() == 'pm')) {
        hour = int.tryParse(parts[0]) ?? -1;
        minute = int.tryParse(parts[1]) ?? 0;
        isAM = parts[2].toLowerCase() == 'am';

        if (hour == -1) return false;

        // Convert to 24-hour format
        if (!isAM && hour < 12) {
          hour += 12;
        } else if (isAM && hour == 12) {
          hour = 0;
        }
      } else {
        // 24-hour format
        hour = int.tryParse(parts[0]) ?? -1;
        if (parts.length >= 2) {
          minute = int.tryParse(parts[1]) ?? 0;
        }

        if (hour == -1) return false;
      }

      // Validate time
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return false;
      }

      // Call native method to create and show the alarm
      final result = await _launchAndroidAlarm(hour, minute);

      return result;
    } catch (e) {
      print('Error creating alarm: $e');
      return false;
    }
  }

  /// Show a notification for the alarm instead of opening the clock app
  static Future<bool> _launchAndroidAlarm(int hour, int minute) async {
    try {
      return await _channel.invokeMethod('launchAndroidAlarm', {
        'hour': hour,
        'minute': minute,
      });
    } catch (e) {
      print('Error showing alarm notification: $e');
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
