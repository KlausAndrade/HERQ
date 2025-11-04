# Flutter ProGuard Rules
# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Supabase classes
-keep class io.supabase.** { *; }
-keepclassmembers class io.supabase.** { *; }

# Keep Facebook SDK classes
-keep class com.facebook.** { *; }
-keepclassmembers class com.facebook.** { *; }

# Keep notification classes
-keep class com.dexterous.** { *; }
-keep class androidx.work.** { *; }

# Keep model classes (if you use reflection or JSON serialization)
-keep class com.herq.app.** { *; }

# Gson/JSON serialization
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep setters in Views so that animations can still work
-keepclassmembers public class * extends android.view.View {
   void set*(***);
   *** get*();
}

# Optimization settings
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose

