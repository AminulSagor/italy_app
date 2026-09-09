import java.io.FileInputStream
import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
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

val localDebugStoreFile = file("debug-local.keystore")


val isReleaseBuildRequested = gradle.startParameter.taskNames.any { taskName ->
    taskName.contains("release", ignoreCase = true)
}

val facebookAppId = providers.gradleProperty("FACEBOOK_APP_ID").orElse("0").get()
val facebookClientToken = providers.gradleProperty("FACEBOOK_CLIENT_TOKEN").orElse("0").get()

if (isReleaseBuildRequested) {
    if (facebookAppId == "0" || facebookClientToken == "0") {
        throw GradleException(
            "Release build blocked: FACEBOOK_APP_ID and FACEBOOK_CLIENT_TOKEN " +
                    "must be set in android/gradle.properties or ~/.gradle/gradle.properties.",
        )
    }
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

    packaging {
        jniLibs {
            excludes += "**/libagora_screen_capture_extension.so"
            excludes += "**/libagora_lip_sync_extension.so"
            excludes += "**/libagora_clear_vision_extension.so"
            excludes += "**/libagora_spatial_audio_extension.so"
            excludes += "**/libagora_segmentation_extension.so"
            excludes += "**/libagora_audio_beauty_extension.so"
            excludes += "**/libagora_face_capture_extension.so"
            excludes += "**/libagora_content_inspect_extension.so"
            excludes += "**/libagora_face_detection_extension.so"
            excludes += "**/libagora_ai_echo_cancellation_extension.so"
            excludes += "**/libagora_ai_echo_cancellation_ll_extension.so"
            excludes += "**/libagora_ai_noise_suppression_extension.so"
            excludes += "**/libagora_ai_noise_suppression_ll_extension.so"
            excludes += "**/libagora_video_quality_analyzer_extension.so"
            excludes += "**/libagora_video_av1_encoder_extension.so"
        }
    }


    ndkVersion = "28.2.13676358"

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

        resValue("string", "facebook_app_id", facebookAppId)
        resValue("string", "facebook_client_token", facebookClientToken)
        resValue("string", "fb_login_protocol_scheme", "fb$facebookAppId")
    }

    signingConfigs {
        if (localDebugStoreFile.exists()) {
            getByName("debug") {
                storeFile = localDebugStoreFile
                storePassword = "android"
                keyAlias = "androiddebugkey"
                keyPassword = "android"
            }
        }

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

            isMinifyEnabled = true
            isShrinkResources = true

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

    // in_app_purchase_android 0.5.1 declares Billing 8.0.0. Keep the same
    // compatible major API while taking Google's later native bug fixes.
    implementation("com.android.billingclient:billing:8.2.1")
}
