# Оставить Flutter и платформенный канал
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.FlutterInjector { *; }
-keep class io.flutter.FlutterMain { *; }
-keep class io.flutter.util.** { *; }

# Оставить классы используемых плагинов
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.**.ffmpegkit.** { *; }
-keep class com.**.ffmpeg.** { *; }
-keep class com.**.justaudio.** { *; }
-keep class com.**.just_audio.** { *; }
-keep class com.**.filepicker.** { *; }
-keep class com.**.file_picker.** { *; }
-keep class com.**.sqflite.** { *; }
-keep class com.**.permissionhandler.** { *; }
-keep class com.**.permission_handler.** { *; }

# Не обфусцировать классы, которые вызываются из нативного кода/FFI
-keepclasseswithmembers class * {
    native <methods>;
}
-keep class * extends java.lang.Exception
-keep class * extends java.lang.RuntimeException

# FFmpegKit specific — особенно если использовались full_gpl/min_gpl
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.antonkarpenko.ffmpegkit.** { *; }
-keep class com.arthenica.** { *; }

# ---- Play Core (SplitInstall / SplitCompat) ----
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# ---- Flutter deferred components ----
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# ---- Google Mobile Ads (AdMob) ----
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

-keep class com.listenme.player.MainActivity { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Для моделей и JSON
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keepclassmembers class * {
    public <init>(...);
}
-keep class * implements java.io.Serializable { *; }

-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.just_audio_background.** { *; }
-keep class com.ryanheise.audio_session.** { *; }

# --- AudioService (Ryan Heise) ---
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.audio_service.** { *; }   # на случай разных путей
-dontwarn com.ryanheise.audioservice.**
-dontwarn com.ryanheise.audio_service.**

# --- Твой кастомный AudioHandler ---
-keep class com.listenme.player.utils.MyAudioHandler { *; }

# --- Для других вспомогательных классов твоего пакета ---
-keep class com.listenme.player.** { *; }
