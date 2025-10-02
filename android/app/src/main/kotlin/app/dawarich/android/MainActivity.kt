package app.dawarich.android


import android.content.Context
import android.os.Build
import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val _channel = "app.dawarich.android/system_settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Lightweight channel registration; no heavy work here.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, _channel)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "isBatteryOptimizationEnabled" -> {
                            val enabled = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                                val isIgnoring = pm.isIgnoringBatteryOptimizations(packageName)
                                !isIgnoring
                            } else {
                                false
                            }
                            result.success(enabled)
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Throwable) {
                    result.success(false) // safe default
                }
            }
    }
}