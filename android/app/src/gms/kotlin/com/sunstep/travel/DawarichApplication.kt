package com.sunstep.travel

import android.app.Application
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 * Custom Application class for GMS builds.
 *
 * Registers the GMS Activity Transition API once at process start so that
 * locomotion ENTER events are delivered to ActivityTransitionReceiver via
 * PendingIntent even when the app is killed. Done here rather than inside a
 * Flutter plugin to avoid plugin-registration race conditions in the background
 * engine.
 */
class DawarichApplication : Application() {

    companion object {
        private const val TAG = "DawarichApplication"

        /**
         * Request code for the Activity Transition PendingIntent.
         * Using a distinct value from flutter_activity_recognition (which uses 0)
         * avoids PendingIntent collisions.
         */
        private const val TRANSITION_PENDING_INTENT_CODE = 1001
    }

    override fun onCreate() {
        super.onCreate()
        registerActivityTransitions()
    }

    /**
     * Registers locomotion ENTER transitions with the GMS Activity Transition API.
     * Results are delivered to ActivityTransitionReceiver via PendingIntent.
     */
    private fun registerActivityTransitions() {
        try {
            val locomotionTypes = listOf(
                com.google.android.gms.location.DetectedActivity.WALKING,
                com.google.android.gms.location.DetectedActivity.RUNNING,
                com.google.android.gms.location.DetectedActivity.ON_BICYCLE,
                com.google.android.gms.location.DetectedActivity.IN_VEHICLE,
            )

            val transitions = locomotionTypes.map { activityType ->
                com.google.android.gms.location.ActivityTransition.Builder()
                    .setActivityType(activityType)
                    .setActivityTransition(
                        com.google.android.gms.location.ActivityTransition.ACTIVITY_TRANSITION_ENTER
                    )
                    .build()
            }

            val request = com.google.android.gms.location.ActivityTransitionRequest(transitions)

            // Explicit intent targeting our BroadcastReceiver.
            val intent = Intent(this, ActivityTransitionReceiver::class.java).apply {
                action = "com.sunstep.travel.ACTIVITY_TRANSITION"
            }

            var flags = PendingIntent.FLAG_UPDATE_CURRENT
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                flags = flags or PendingIntent.FLAG_MUTABLE
            }

            val pendingIntent = PendingIntent.getBroadcast(
                this, TRANSITION_PENDING_INTENT_CODE, intent, flags
            )

            com.google.android.gms.location.ActivityRecognition.getClient(this)
                .requestActivityTransitionUpdates(request, pendingIntent)
                .addOnSuccessListener {
                    Log.d(TAG, "Activity Transition API registered successfully")
                }
                .addOnFailureListener { e ->
                    Log.w(TAG, "Failed to register Activity Transition API: ${e.message}")
                }

        } catch (e: Throwable) {
            // Defensive: catches any unexpected runtime failure in GMS registration.
            Log.w(TAG, "Activity Transition registration failed unexpectedly: ${e.message}")
        }
    }
}
