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

        // AdMob UYGULAMA kimligi (gercek deger yerlestirildi).
        // Reklam birimi kimlikleri: lib/config/monetization_config.dart
        // Not: debug derlemeler her zaman Google TEST reklami gosterir.
        manifestPlaceholders["admobAppId"] = "ca-app-pub-6486621084238367~2935153669"

        // AppLovin mediation SDK anahtari (AppLovin paneli > Account > Keys).
        // BOS oldugu surece AppLovin adaptoru pasif kalir ve AdMob tek basina
        // (+ diger bidder'lar) calisir; hesap acilinca TEK yapilacak sey bu
        // degeri doldurmak. Ayrintili kurulum: docs/MONETIZASYON.md (Mediation).
        manifestPlaceholders["applovinSdkKey"] = ""
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
            // R8 tam mod: olu kodu/kaynagi ayiklar, kalani optimize/kucuklestirir.
            // Play Console'un "R8 ile bellek ve performansi artirin" uyarisini
            // kaldirir; APK/AAB boyutunu ve soguk baslangic bellegini dusurur.
            // Guvenlik: Flutter'in kendi kurallari + her eklentinin AAR consumer
            // ProGuard kurallari (google_mobile_ads ve mediation adaptorleri,
            // in_app_purchase, vb. kendi keep'lerini tasir) OTOMATIK uygulanir;
            // proguard-rules.pro yalnizca reflection'a dayanan ve consumer kurali
            // tasimayan parcalari (flutter_local_notifications'in Gson modelleri)
            // korur. shrinkResources yalnizca minify ile birlikte gecerlidir.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
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
