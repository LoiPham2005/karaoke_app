# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.** { *; }
-keep class androidx.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Gson rules
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep model classes
-keep class com.windx.wallpaperanime.** { *; }

# Wallpaper Manager rules
-keep class com.tekartik.sqflite.** { *; }
-keep class android.app.WallpaperManager { *; }
-keep class android.app.WallpaperManager$** { *; }

# Cache Manager rules
-keep class flutter_cache_manager.** { *; }
-keep class com.github.cachemanager.** { *; }

# Google Play Core rules (fixes R8 missing classes error)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Specifically keep the classes mentioned in the error
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep Flutter deferred components classes
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# Memory optimization
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep your model classes
-keep class com.example.flutter_base_template.data.models.** { *; }

# Retrofit
-keepattributes Signature
-keepattributes *Annotation*
-keep class retrofit2.** { *; }
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations

-keepattributes EnclosingMethod
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}
-keepclasseswithmembers interface * {
    @retrofit2.* <methods>;
}

# ProGuard rules for Flutter app

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class com.google.flutter.** { *; }

# Keep your app's main classes
-keep class com.example.flutter_base_template.** { *; }

# Keep model classes (Serializable)
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep Retrofit
-keep class retrofit2.** { *; }
-keep interface retrofit2.** { *; }
-keepattributes Signature

# Keep Gson
-keep class com.google.gson.** { *; }
-keepattributes EnclosingMethod
-keepclasseswithmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep SharedPreferences
-keep class android.content.SharedPreferences { *; }

# Remove logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
