import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.bank_sha"
    compileSdk = flutter.compileSdkVersion
    //  ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Aktifkan desugaring untuk mendukung library flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.bank_sha"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdkVersion(flutter.minSdkVersion)
        targetSdkVersion(flutter.targetSdkVersion)
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Provide Google Maps API key to the manifest via placeholder.
        // Reads from local.properties (MAPS_API_KEY=...), falls back to env var, then empty.
    val props = Properties()
        val lpFile = File(rootDir, "local.properties")
        if (lpFile.exists()) {
            lpFile.inputStream().use { props.load(it) }
        }
        val mapsApiKey = (props.getProperty("MAPS_API_KEY") ?: System.getenv("MAPS_API_KEY") ?: "")
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Tambahkan library desugaring yang diperlukan untuk flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

// Task untuk menyalin APK ke lokasi yang diharapkan Flutter
tasks.register<Copy>("copyApkToExpectedLocation") {
    from("C:/FlutterBuild/Gerobaks_Build/android/app/outputs/flutter-apk")
    into("${project.rootProject.projectDir}/../build/app/outputs/flutter-apk")
    
    doFirst {
        val targetDir = File("${project.rootProject.projectDir}/../build/app/outputs/flutter-apk")
        targetDir.mkdirs()
    }
}

// Pastikan task copyApk dijalankan setelah assembleDebug
afterEvaluate {
    tasks.findByName("assembleDebug")?.finalizedBy("copyApkToExpectedLocation")
}
