package com.sunstep.dawarich

import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val _channel = "com.sunstep.dawarich/system_settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, _channel)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "isBatteryOptimizationEnabled" -> {
                            val pm = getSystemService(POWER_SERVICE) as PowerManager
                            val isIgnoring = pm.isIgnoringBatteryOptimizations(packageName)
                            val isBatteryOptimizationEnabled = isIgnoring.not()

                            result.success(isBatteryOptimizationEnabled)
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Throwable) {
                    result.success(false) // safe default
                }
            }
    }
}