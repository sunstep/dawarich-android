package com.sunstep.travel

import android.app.Application
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import android.hardware.TriggerEvent
import android.hardware.TriggerEventListener
import android.util.Log
import org.json.JSONObject
import java.io.File

/**
 * Custom Application class for FOSS builds.
 *
 * Uses the AOSP TYPE_SIGNIFICANT_MOTION hardware sensor to detect locomotion
 * without any dependency on Google Play Services. The sensor is a one-shot
 * hardware trigger (re-armed after each fire) so it consumes near-zero battery
 * while waiting.
 *
 * On trigger, writes the same JSON file that ActivityTransitionReceiver writes
 * on GMS builds. The Dart background service polls this file periodically via
 * ActivityTransitionDataClient to wake the tracker from passive mode.
 *
 * Falls back silently if the device lacks the sensor (uncommon but possible on
 * very old or stripped devices). In that case the tracker relies on GPS-based
 * mode switching only.
 */
class DawarichApplication : Application() {

    companion object {
        private const val TAG = "DawarichApplication"

        /** Shared with ActivityTransitionReceiver so both builds write to the same path. */
        const val TRANSITION_FILE = "activity_transition_event.json"
    }

    private var sensorManager: SensorManager? = null

    /**
     * One-shot TriggerEventListener. After each fire we re-arm immediately so
     * the next significant motion is also caught.
     */
    private val motionListener = object : TriggerEventListener() {
        override fun onTrigger(event: TriggerEvent) {
            Log.d(TAG, "Significant motion detected")
            writeTransitionFile()
            // TriggerEventListener auto-cancels after firing; re-arm for next event.
            sensorManager?.requestTriggerSensor(this, event.sensor)
        }
    }

    override fun onCreate() {
        super.onCreate()
        armSignificantMotion()
    }

    private fun armSignificantMotion() {
        val sm = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        if (sm == null) {
            Log.w(TAG, "SensorManager unavailable")
            return
        }

        val sensor = sm.getDefaultSensor(Sensor.TYPE_SIGNIFICANT_MOTION)
        if (sensor == null) {
            Log.w(TAG, "TYPE_SIGNIFICANT_MOTION not available on this device, passive wake disabled")
            return
        }

        sensorManager = sm
        sm.requestTriggerSensor(motionListener, sensor)
        Log.d(TAG, "Significant motion sensor armed")
    }

    private fun writeTransitionFile() {
        try {
            val json = JSONObject().apply {
                put("timestamp", System.currentTimeMillis())
                // No specific activity type available without GMS; Dart side only checks timestamp.
                put("activityType", -1)
            }
            File(filesDir, TRANSITION_FILE).writeText(json.toString())
            Log.d(TAG, "Transition file written (significant motion)")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to write transition file: ${e.message}")
        }
    }
}

