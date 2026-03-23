plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.steps_recovery_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // Load signing properties from key.properties file (local) or environment variables (CI)
    val keystorePropertiesFile = rootProject.file("key.properties")
    val hasKeystoreFile = keystorePropertiesFile.exists()
    val keystoreProperties = if (hasKeystoreFile) {
        java.util.Properties().apply { load(keystorePropertiesFile.inputStream()) }
    } else null

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties?.getProperty("keyAlias")
                ?: System.getenv("KEY_ALIAS") ?: ""
            keyPassword = keystoreProperties?.getProperty("keyPassword")
                ?: System.getenv("KEY_PASSWORD") ?: ""
            storeFile = (keystoreProperties?.getProperty("storeFile")
                ?: System.getenv("KEY_STORE_FILE"))?.let { file(it) }
            storePassword = keystoreProperties?.getProperty("storePassword")
                ?: System.getenv("KEY_STORE_PASSWORD") ?: ""
        }
    }

    defaultConfig {
        applicationId = "com.example.steps_recovery_flutter"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            val releaseConfig = signingConfigs.getByName("release")
            // Use release signing if keystore is configured, otherwise fall back to debug for local dev
            signingConfig = if (releaseConfig.storeFile != null) releaseConfig
                            else signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// Copy APK to Flutter's expected output location
afterEvaluate {
    tasks.named<com.android.build.gradle.tasks.PackageApplication>("packageDebug") {
        doLast {
            val flutterApkDir = file("${rootProject.projectDir}/../build/app/outputs/flutter-apk")
            flutterApkDir.mkdirs()
            val apkFile = file("${project.buildDir}/outputs/apk/debug/app-debug.apk")
            if (apkFile.exists()) {
                apkFile.copyTo(file("${flutterApkDir}/app-debug.apk"), overwrite = true)
            }
        }
    }
}
