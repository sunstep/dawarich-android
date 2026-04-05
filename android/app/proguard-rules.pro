-keep class androidx.window.** { *; }
-dontwarn androidx.window.**

# Prevent BadParcelableException on process/activity restore in minified builds.
-keepclassmembers class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}
