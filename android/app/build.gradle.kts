plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin") // No version needed, managed by Flutter
    // id("com.google.gms.google-services") // Commented out to disable auto-initialization
}

android {
    namespace = "com.example.courier_application"
    compileSdk = 36
    ndkVersion = "27.2.12479018"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.courier_application"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.9.0")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.0") // Updated to match Kotlin plugin version
    // Removed Firebase BOM and specific implementations to avoid auto-init
    // If needed, add back with manual configuration:
    // implementation("com.google.firebase:firebase-core:21.1.1")
    // implementation("com.google.firebase:firebase-analytics-ktx:22.5.0")
}

flutter {
    source = "../.."
}