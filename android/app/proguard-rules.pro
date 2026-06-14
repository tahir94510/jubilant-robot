# R8/ProGuard keep rules for the RELEASE build.
#
# Flutter enables R8 code shrinking for `--release` automatically
# (FlutterPlugin sets isMinifyEnabled = true) and auto-applies THIS file.
# Several dependencies load classes by reflection or (de)serialize models,
# so R8 must be told not to strip them — otherwise the app crashes at
# startup in release while working fine in debug (which never shrinks).
#
# The instant-close we hit was exactly this: R8 stripped Room's generated
# `WorkDatabase_Impl`, so WorkManager (pulled in by Google Mobile Ads and
# initialised through androidx.startup at app launch) threw
# "Failed to create an instance of androidx.work.impl.WorkDatabase" from a
# ContentProvider, before Flutter even started.

# ---- Room (the generated *_Impl databases load via reflection) ----
-keep class * extends androidx.room.RoomDatabase { <init>(); *; }
-keep class androidx.room.** { *; }
-keep class androidx.sqlite.** { *; }
-keep class **_Impl { *; }
-keepclassmembers class **_Impl { *; }
-dontwarn androidx.room.**

# ---- WorkManager + App Startup (GMA initialises these at launch) ----
-keep class androidx.work.** { *; }
-keep class androidx.startup.** { *; }
-dontwarn androidx.work.**

# ---- Google Mobile Ads (AdMob) ----
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.internal.ads.** { *; }
-dontwarn com.google.android.gms.**

# ---- Play Billing (in_app_purchase) ----
-keep class com.android.billingclient.** { *; }
-keep class com.android.vending.billing.** { *; }

# ---- flutter_local_notifications (serialises models with Gson) ----
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses,EnclosingMethod

# ---- General safety nets ----
# Enums (values()/valueOf used reflectively by several libraries).
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
# Parcelable CREATOR fields.
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}
# JNI / native callbacks.
-keepclasseswithmembernames class * {
    native <methods>;
}
