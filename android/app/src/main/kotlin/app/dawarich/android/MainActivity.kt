package app.dawarich.android

import android.content.Context
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
class MainActivity: FlutterActivity() {

    private val CHANNEL = "app.dawarich.android/system_settings"

    // 1) Override configureFlutterEngine
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 2) Register your MethodChannel on that engine’s dartExecutor
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isBatteryOptimizationEnabled" -> {
                    // Android: check PowerManager
                    val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                    val ignoring = pm.isIgnoringBatteryOptimizations(packageName)
                    // If ignoring==true, optimizations are disabled → we return false
                    result.success(!ignoring)
                }
                else -> result.notImplemented()
            }
        }
    }
}

