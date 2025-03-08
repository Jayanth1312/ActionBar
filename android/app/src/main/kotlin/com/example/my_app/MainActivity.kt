package com.example.my_app

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.Intent
import android.provider.AlarmClock
import android.content.ComponentName
import android.util.Log
import android.os.Bundle

class MainActivity : FlutterActivity() {
    companion object {
        private const val ALARM_CHANNEL = "com.example.actionbar/alarm"
        private const val TIMER_CHANNEL = "com.example.actionbar/timer"
        private const val TAG = "MainActivity"
    }

    // Add this method to remove the splash screen
    override fun onCreate(savedInstanceState: Bundle?) {
        // Remove the splash screen when creating the activity
        setTheme(R.style.LaunchTheme)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Alarm Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "launchAndroidAlarm" -> {
                        val alarmPackageName = call.argument<String>("packageName")
                        val hour = call.argument<Int>("hour") ?: 0
                        val minute = call.argument<Int>("minute") ?: 0
                        val alarmResult = launchAndroidAlarm(alarmPackageName, hour, minute)
                        result.success(alarmResult)
                    }
                    "showAndroidAlarms" -> {
                        val showAlarmsPackage = call.argument<String>("packageName")
                        val showAlarmsResult = showAndroidAlarms(showAlarmsPackage)
                        result.success(showAlarmsResult)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }

        // Timer Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TIMER_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "launchAndroidTimer" -> {
                        val timerPackageName = call.argument<String>("packageName")
                        val seconds = call.argument<Int>("seconds") ?: 0
                        val timerResult = launchAndroidTimer(timerPackageName, seconds)
                        result.success(timerResult)
                    }
                    "showAndroidTimers" -> {
                        val showTimersPackage = call.argument<String>("packageName")
                        val showTimersResult = showAndroidTimers(showTimersPackage)
                        result.success(showTimersResult)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    private fun launchAndroidAlarm(packageName: String?, hour: Int, minute: Int): Boolean {
        return try {
            // Try the standard Intent first (works on most Android devices)
            val intent = Intent(AlarmClock.ACTION_SET_ALARM).apply {
                putExtra(AlarmClock.EXTRA_HOUR, hour)
                putExtra(AlarmClock.EXTRA_MINUTES, minute)
                putExtra(AlarmClock.EXTRA_MESSAGE, "Alarm set from ActionBar")
                putExtra(AlarmClock.EXTRA_SKIP_UI, false) // Show UI for confirmation

                // For OnePlus devices, sometimes we need to specify the component
                if (!packageName.isNullOrEmpty()) {
                    setPackage(packageName)

                    // Try manufacturer specific extras (uncomment if needed)
                    // if (packageName.contains("oneplus")) {
                    //     setComponent(ComponentName(packageName, "$packageName.DeskClock"))
                    // }
                }
            }

            startActivity(intent)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error launching alarm intent: ${e.message}")

            // Fallback to just opening the clock app
            try {
                val launchIntent = packageName?.let { packageManager.getLaunchIntentForPackage(it) }
                if (launchIntent != null) {
                    startActivity(launchIntent)
                    return true
                }
            } catch (ex: Exception) {
                Log.e(TAG, "Fallback failed: ${ex.message}")
            }

            false
        }
    }

    private fun showAndroidAlarms(packageName: String?): Boolean {
        return try {
            val intent = Intent(AlarmClock.ACTION_SHOW_ALARMS).apply {
                if (!packageName.isNullOrEmpty()) {
                    setPackage(packageName)
                }
            }

            startActivity(intent)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error showing alarms: ${e.message}")
            false
        }
    }

    private fun launchAndroidTimer(packageName: String?, seconds: Int): Boolean {
        return try {
            val intent = Intent(AlarmClock.ACTION_SET_TIMER).apply {
                putExtra(AlarmClock.EXTRA_LENGTH, seconds)
                putExtra(AlarmClock.EXTRA_MESSAGE, "Timer set from ActionBar")
                putExtra(AlarmClock.EXTRA_SKIP_UI, false) // Show UI for confirmation

                if (!packageName.isNullOrEmpty()) {
                    setPackage(packageName)
                }
            }

            startActivity(intent)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error launching timer intent: ${e.message}")

            // Fallback to just opening the clock app
            try {
                val launchIntent = packageName?.let { packageManager.getLaunchIntentForPackage(it) }
                if (launchIntent != null) {
                    startActivity(launchIntent)
                    return true
                }
            } catch (ex: Exception) {
                Log.e(TAG, "Fallback failed: ${ex.message}")
            }

            false
        }
    }

    private fun showAndroidTimers(packageName: String?): Boolean {
        return try {
            val intent = Intent(AlarmClock.ACTION_SHOW_TIMERS).apply {
                if (!packageName.isNullOrEmpty()) {
                    setPackage(packageName)
                }
            }

            startActivity(intent)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error showing timers: ${e.message}")
            false
        }
    }
}
