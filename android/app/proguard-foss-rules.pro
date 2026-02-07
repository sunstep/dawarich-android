# In FOSS builds, geolocator's fused (GMS) implementation is unusable.

-assumenosideeffects class com.baseflow.geolocator.location.FusedLocationClient {
  *;
}

-dontwarn com.baseflow.geolocator.location.FusedLocationClient
-dontwarn com.baseflow.geolocator.location.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.android.gms.location.**
-dontwarn com.google.android.gms.tasks.**