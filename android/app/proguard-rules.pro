# ============================================================================
# Reguli ProGuard / R8 pentru build-ul de release.
#
# isMinifyEnabled=true + proguard-android-optimize.txt eliminau clase ale
# plugin-urilor accesate prin reflexie => excepție în main() => ECRAN ALB.
# Regulile de mai jos păstrează clasele de care plugin-urile au nevoie.
# ============================================================================

# ---- Flutter engine + plugin registrant ----
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# ---- Entry point-ul aplicației (Activity-ul lansat din manifest) ----
-keep class ro.povestiromanesti.app.** { *; }

# ---- flutter_local_notifications (CAUZA PRINCIPALĂ) ----
# Plugin-ul serializează notificările programate cu Gson prin reflexie.
# Fără aceste reguli, zonedSchedule()/initialize() crapă în release.
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }

# ---- Gson (folosit intern de flutter_local_notifications) ----
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses,EnclosingMethod
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.TypeAdapter { *; }
-keep class * implements com.google.gson.TypeAdapterFactory { *; }
-keep class * implements com.google.gson.JsonSerializer { *; }
-keep class * implements com.google.gson.JsonDeserializer { *; }
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keepclassmembers enum * { *; }

# ---- Google Mobile Ads (google_mobile_ads) ----
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.ads.**

# ---- in_app_purchase / Google Play Billing ----
-keep class com.android.billingclient.** { *; }
-keep class com.android.vending.billing.** { *; }
-keep class io.flutter.plugins.inapppurchase.** { *; }
-dontwarn com.android.billingclient.**

# ---- flutter_tts ----
-keep class com.tundralabs.fluttertts.** { *; }

# ---- Play Core (Flutter deferred components / split install) ----
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# ---- Kotlin (unele plugin-uri folosesc metadata Kotlin la runtime) ----
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**
