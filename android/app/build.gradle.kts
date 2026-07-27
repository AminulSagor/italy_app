import java.io.FileInputStream
import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { inputStream ->
        keystoreProperties.load(inputStream)
    }
}

val requiredKeystoreProperties = listOf(
    "keyAlias",
    "keyPassword",
    "storeFile",
    "storePassword",
)

val missingKeystoreProperties = requiredKeystoreProperties.filter {
    keystoreProperties.getProperty(it).isNullOrBlank()
}

val hasReleaseKeystore =
    keystorePropertiesFile.exists() &&
            missingKeystoreProperties.isEmpty()

val releaseStoreFile = keystoreProperties
    .getProperty("storeFile")
    ?.trim()
    ?.takeIf { it.isNotEmpty() }
    ?.let { file(it) }


val isReleaseBuildRequested = gradle.startParameter.taskNames.any { taskName ->
    taskName.contains("release", ignoreCase = true)
}

if (isReleaseBuildRequested) {
    if (!keystorePropertiesFile.exists()) {
        throw GradleException(
            "Release build blocked: android/key.properties is missing.",
        )
    }

    if (missingKeystoreProperties.isNotEmpty()) {
        throw GradleException(
            "Release build blocked: missing key.properties values: " +
                    missingKeystoreProperties.joinToString(),
        )
    }

    if (releaseStoreFile == null || !releaseStoreFile.exists()) {
        throw GradleException(
            "Release build blocked: upload keystore was not found at " +
                    "${releaseStoreFile?.absolutePath}",
        )
    }
}


val requiredTargetSdk = 36

android {
    namespace = "com.shafacode.italir_pothe"

    compileSdk = maxOf(
        flutter.compileSdkVersion,
        requiredTargetSdk,
    )


    ndkVersion = "28.0.13004108"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.shafacode.italir_pothe"

        minSdk = flutter.minSdkVersion
        targetSdk = requiredTargetSdk

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias =
                    keystoreProperties.getProperty("keyAlias")

                keyPassword =
                    keystoreProperties.getProperty("keyPassword")

                storeFile = releaseStoreFile

                storePassword =
                    keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        getByName("release") {

            if (hasReleaseKeystore) {
                signingConfig =
                    signingConfigs.getByName("release")
            }

            proguardFiles(
                getDefaultProguardFile(
                    "proguard-android-optimize.txt",
                ),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.5",
    )
}