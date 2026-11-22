# Flutter's own rules are added automatically by the Flutter Gradle plugin.

# Flutter references Play Core (deferred components) which most apps don't use;
# without this R8 can fail with "Missing class com.google.android.play.core..."
-dontwarn com.google.android.play.core.**
-keep class com.kurenai7968.volume_controller.** { *; }
# Keep native/JNI-bound classes used by plugins (flutter_angle, media_kit, etc.)
-keepclasseswithmembernames class * {
    native <methods>;
}