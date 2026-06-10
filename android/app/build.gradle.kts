import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release imzasi: android/key.properties varsa onu kullanir, yoksa debug imzaya duser.
// CI, GitHub secret'larindan key.properties + upload-keystore.jks dosyalarini olusturur.
// Yerel gelistirmede hicbir sey yapmaniza gerek yok. Detay: docs/YAYINLAMA_REHBERI.md
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
val hasReleaseKeystore = keystoreProperties.getProperty("storeFile") != null

android {
    namespace = "io.github.tahir94510.quotecrack"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications gereksinimi (java.time desugar)
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "io.github.tahir94510.quotecrack"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // AdMob UYGULAMA kimligi (reklam birimi degil!).
        // Varsayilan deger Google'in resmi TEST app ID'sidir; uygulama bununla calisir
        // ama gercek gelir icin yayindan once kendi ID'nizle DEGISTIRIN:
        //   AdMob > Uygulamalar > Uygulama ayarlari > Uygulama kimligi
        // Ikinci ve son duzenleme yeri: lib/config/monetization_config.dart
        // Detay: docs/MONETIZASYON.md
        manifestPlaceholders["admobAppId"] = "ca-app-pub-3940256099942544~3347511713"
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
