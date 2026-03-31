pluginManagement {
    fun discoverFlutterSdkPath(): String? {
        val localPropertiesFile = file("local.properties")
        if (localPropertiesFile.exists()) {
            val properties = java.util.Properties()
            localPropertiesFile.inputStream().use { input ->
                properties.load(input)
            }

            val localFlutterSdk = properties.getProperty("flutter.sdk")
            if (!localFlutterSdk.isNullOrBlank()) {
                return localFlutterSdk
            }
        }

        val flutterRoot = System.getenv("FLUTTER_ROOT")
        if (!flutterRoot.isNullOrBlank()) {
            return flutterRoot
        }

        val discoveryCommand =
            if (System.getProperty("os.name").startsWith("Windows", ignoreCase = true)) {
                listOf("where", "flutter")
            } else {
                listOf("which", "flutter")
            }

        return runCatching {
            val process = ProcessBuilder(discoveryCommand)
                .redirectErrorStream(true)
                .start()

            val flutterExecutable = process.inputStream.bufferedReader().use { reader ->
                reader.lineSequence()
                    .map { line -> line.trim() }
                    .firstOrNull { line -> line.isNotEmpty() }
            }

            if (process.waitFor() == 0 && flutterExecutable != null) {
                file(flutterExecutable).parentFile?.parentFile?.absolutePath
            } else {
                null
            }
        }.getOrNull()
    }

    val flutterSdkPath =
        discoverFlutterSdkPath()
            ?: error(
                "Flutter SDK not found. Set flutter.sdk in local.properties, set FLUTTER_ROOT, or add flutter to PATH."
            )

    System.setProperty("codex.flutterSdkPath", flutterSdkPath)
    settings.extra["flutterSdkPath"] = flutterSdkPath
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
