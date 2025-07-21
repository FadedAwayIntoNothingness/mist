plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.dravenhart.mist_aqi"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
        freeCompilerArgs = listOf("-Xlint:-options") // ปิด warning obsolete options
    }

    defaultConfig {
        applicationId = "com.example.mist_aqi"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
            // ปิด Werror เพื่อให้ build ไม่ล้มเพราะ warning
            isDebuggable = false
            // คุณอาจเพิ่ม options เพื่อไม่ให้ warnings เป็น error
            // หรือแก้ไขใน gradle.properties (ดูด้านล่าง)
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}

// flutter block ไม่ต้องแก้
flutter {
    source = "../.."
}
