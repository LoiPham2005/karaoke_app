import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

// Add these lines to read key.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.flutter_base_template"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.flutter.base"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        //  versionCode = 101
        //  versionName = "1.0.1"
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            // Chỉ load config nếu file keystore thực sự tồn tại
            val storeFileVal = keystoreProperties["storeFile"] as String?
            if (storeFileVal != null) {
                val keyFile = rootProject.file(storeFileVal)
                if (keyFile.exists()) {
                    storeFile = keyFile
                    keyAlias = keystoreProperties["keyAlias"] as String?
                    keyPassword = keystoreProperties["keyPassword"] as String?
                    storePassword = keystoreProperties["storePassword"] as String?
                } else {
                    println("⚠️ [Build] Release keystore file '$storeFileVal' not found. Will use DEBUG signing config.")
                }
            }
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                file("proguard-rules.pro")
            )

            // Logic thông minh: Kiểm tra xem release config có valid không
            val releaseConfig = signingConfigs.getByName("release")
            if (releaseConfig.storeFile != null && releaseConfig.storeFile?.exists() == true) {
                signingConfig = releaseConfig
            } else {
                println("⚠️ [Build] Using DEBUG signing config for RELEASE build (Keystore not found).")
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }

    bundle {
        language {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
        density {
            enableSplit = true
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}

// =========================================================
//  Tách các custom tasks ra file riêng cho dễ quản lý
// =========================================================
apply { from("flavorizr.gradle.kts") }     // flavor
apply(from = "rename-outputs.gradle.kts")  // Rename APK + AAB
apply(from = "open-folder.gradle.kts")     // Auto open folder after build
