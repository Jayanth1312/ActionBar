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
import android.net.Uri
import android.provider.MediaStore

class MainActivity : FlutterActivity() {
    companion object {
        private const val ALARM_CHANNEL = "com.example.actionbar/alarm"
        private const val TIMER_CHANNEL = "com.example.actionbar/timer"
        private const val LENS_CHANNEL = "com.example.actionbar/lens"
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
                        try {
                            val timerPackageName = call.argument<String>("packageName")
                            val seconds = call.argument<Int>("seconds") ?: 0

                            Log.d(TAG, "Starting timer for $seconds seconds with package: $timerPackageName")

                            if (seconds <= 0) {
                                Log.e(TAG, "Invalid timer duration: $seconds seconds")
                                result.error("INVALID_DURATION", "Timer duration must be greater than 0", null)
                                return@setMethodCallHandler
                            }

                            val timerResult = launchAndroidTimer(timerPackageName, seconds)
                            result.success(timerResult)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error in launchAndroidTimer: ${e.message}")
                            result.error("TIMER_ERROR", "Could not start timer. Use format: minutes or hours/minutes", e.message)
                        }
                    }
                    "showAndroidTimers" -> {
                        try {
                            val showTimersPackage = call.argument<String>("packageName")
                            val showTimersResult = showAndroidTimers(showTimersPackage)
                            result.success(showTimersResult)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error in showAndroidTimers: ${e.message}")
                            result.error("TIMER_ERROR", "Could not show timers", e.message)
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }

        // Google Lens Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LENS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openGoogleLens" -> {
                        try {
                            val lensResult = openGoogleLens()
                            result.success(lensResult)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error in openGoogleLens: ${e.message}")
                            result.error("LENS_ERROR", "Could not open Google Lens", e.message)
                        }
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
            Log.d(TAG, "Attempting to launch timer with ACTION_SET_TIMER")
            val intent = Intent(AlarmClock.ACTION_SET_TIMER).apply {
                putExtra(AlarmClock.EXTRA_LENGTH, seconds)
                putExtra(AlarmClock.EXTRA_MESSAGE, "Timer set from ActionBar")
                putExtra(AlarmClock.EXTRA_SKIP_UI, false) // Show UI for confirmation

                if (!packageName.isNullOrEmpty()) {
                    setPackage(packageName)
                    Log.d(TAG, "Setting package to: $packageName")
                }
            }

            startActivity(intent)
            Log.d(TAG, "Timer intent started successfully")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error launching timer intent: ${e.message}", e)

            // Fallback to just opening the clock app
            try {
                Log.d(TAG, "Attempting fallback to launch clock app")
                val launchIntent = packageName?.let { packageManager.getLaunchIntentForPackage(it) }
                if (launchIntent != null) {
                    startActivity(launchIntent)
                    Log.d(TAG, "Fallback successful - opened clock app")
                    return true
                } else {
                    Log.e(TAG, "No launch intent found for package: $packageName")
                }
            } catch (ex: Exception) {
                Log.e(TAG, "Fallback failed: ${ex.message}", ex)
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

    private fun openGoogleLens(): Boolean {
        return try {
            Log.d(TAG, "Attempting to open Google Lens")

            // Try multiple approaches to open Google Lens
            try {
                // Approach 1: Try Google Lens directly
                val intent = Intent().apply {
                    action = Intent.ACTION_VIEW
                    component = ComponentName(
                        "com.google.ar.lens",
                        "com.google.vr.apps.ornament.app.lens.LensLauncherActivity"
                    )
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(intent)
                Log.d(TAG, "Opened Google Lens via direct component")
                return true
            } catch (e: Exception) {
                Log.e(TAG, "Direct component approach failed: ${e.message}")

                // Approach 2: Try Google app's Lens feature
                try {
                    val intent = Intent().apply {
                        action = Intent.ACTION_VIEW
                        component = ComponentName(
                            "com.google.android.googlequicksearchbox",
                            "com.google.android.apps.search.lens.LensActivity"
                        )
                    }
                    startActivity(intent)
                    Log.d(TAG, "Opened Google Lens via Google app component")
                    return true
                } catch (e: Exception) {
                    Log.e(TAG, "Google app component approach failed: ${e.message}")

                    // Approach 3: Try Google app with lens URI
                    try {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("googleapp://lens"))
                        startActivity(intent)
                        Log.d(TAG, "Opened Google Lens via URI")
                        return true
                    } catch (e: Exception) {
                        Log.e(TAG, "URI approach failed: ${e.message}")

                        // Approach 4: Try camera with specific action
                        try {
                            val intent = Intent(MediaStore.INTENT_ACTION_STILL_IMAGE_CAMERA)
                            startActivity(intent)
                            Log.d(TAG, "Opened camera as fallback")
                            return true
                        } catch (e: Exception) {
                            Log.e(TAG, "Camera fallback failed: ${e.message}")
                        }
                    }
                }
            }

            // If all approaches failed, try web version
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://lens.google.com"))
            startActivity(intent)
            Log.d(TAG, "Opened Google Lens web version")
            true
        } catch (e: Exception) {
            Log.e(TAG, "All Google Lens approaches failed: ${e.message}")
            false
        }
    }
}
