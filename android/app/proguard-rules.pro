# Steps to Recovery — ProGuard / R8 rules
# These rules prevent R8 from stripping classes required at runtime by Flutter plugins.

# ─── Flutter ────────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# ─── workmanager (background sync isolate) ──────────────────────────────────
# The CallbackDispatcher is referenced by class name at runtime; must not be renamed.
-keep class be.tramckrijte.workmanager.** { *; }
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

# ─── flutter_secure_storage ─────────────────────────────────────────────────
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# ─── local_auth (biometric) ─────────────────────────────────────────────────
-keep class androidx.biometric.** { *; }
-keep class androidx.fragment.app.FragmentActivity { *; }
-dontwarn androidx.biometric.**

# ─── encrypt / pointycastle (AES-256) ───────────────────────────────────────
# PointyCastle registers algorithm names by reflection.
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# ─── Sentry (keep source file names for readable stack traces) ───────────────
-keepattributes SourceFile,LineNumberTable
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**

# ─── Supabase / Realtime / http ──────────────────────────────────────────────
-keep class io.supabase.** { *; }
-dontwarn io.supabase.**
-keep class com.squareup.okhttp3.** { *; }
-dontwarn com.squareup.okhttp3.**

# ─── Google Generative AI ────────────────────────────────────────────────────
-keep class com.google.ai.** { *; }
-dontwarn com.google.ai.**

# ─── flutter_local_notifications ─────────────────────────────────────────────
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# ─── General Android safety rules ────────────────────────────────────────────
# Keep Parcelable implementations (used by platform channels)
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}
# Keep serializable classes intact
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    !private <fields>;
    !private <methods>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
