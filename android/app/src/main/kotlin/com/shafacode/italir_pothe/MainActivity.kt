package com.shafacode.italir_pothe

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.view.View
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private val downloadChannelName =
        "italir_pothe/downloads"

    private val systemInsetsChannelName =
        "italir_pothe/system_insets"

    private var navigationBarBottomInsetPx: Int = 0
    private var aiVoiceAudioEngine: AiVoiceAudioEngine? = null

    override fun onCreate(
        savedInstanceState: Bundle?
    ) {
        super.onCreate(savedInstanceState)

        /*
         * Allow Flutter to draw behind Android system bars.
         *
         * Without this, Android may reserve the navigation-bar
         * area before Flutter lays out the page, which can create
         * unwanted bottom space.
         */
        WindowCompat.enableEdgeToEdge(window)

        /*
         * Remove Android's automatic navigation-bar contrast
         * background on Android 10 and newer.
         */
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            window.isNavigationBarContrastEnforced = false
        }

        /*
         * The application uses light backgrounds, so keep the
         * status-bar and navigation-bar icons dark.
         */
        WindowCompat.getInsetsController(
            window,
            window.decorView
        ).apply {
            isAppearanceLightStatusBars = true
            isAppearanceLightNavigationBars = true
        }

        val insetTarget = getInsetTargetView()

        /*
         * Listen for Android system-inset changes.
         *
         * This handles:
         * - Three-button navigation
         * - Gesture navigation
         * - Orientation changes
         * - System-bar visibility changes
         */
        ViewCompat.setOnApplyWindowInsetsListener(
            insetTarget
        ) { _, insets ->

            navigationBarBottomInsetPx =
                readNavigationBarBottomInset(insets)

            /*
             * Do not consume the insets.
             *
             * Flutter and other Android views must still receive
             * the original inset information.
             */
            insets
        }

        /*
         * Request the first inset calculation after the Android
         * content view has been attached.
         */
        insetTarget.post {
            ViewCompat.requestApplyInsets(insetTarget)
        }
    }

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        registerDownloadChannel(flutterEngine)
        registerSystemInsetsChannel(flutterEngine)
        aiVoiceAudioEngine = AiVoiceAudioEngine(
            applicationContext,
            flutterEngine.dartExecutor.binaryMessenger
        ).also { it.register() }
    }

    override fun onDestroy() {
        aiVoiceAudioEngine?.dispose()
        aiVoiceAudioEngine = null
        super.onDestroy()
    }

    /*
     * Returns the Android content view used for reading
     * WindowInsets.
     */
    private fun getInsetTargetView(): View {
        return findViewById<View>(
            android.R.id.content
        ) ?: window.decorView
    }

    /*
     * Existing PDF download channel.
     */
    private fun registerDownloadChannel(
        flutterEngine: FlutterEngine
    ) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            downloadChannelName
        ).setMethodCallHandler {
                call: MethodCall,
                result: MethodChannel.Result ->

            when (call.method) {
                "savePdfToDownloads" -> {
                    savePdfToDownloads(
                        call,
                        result
                    )
                }

                else -> result.notImplemented()
            }
        }
    }

    /*
     * Provides Android's native bottom navigation-control
     * inset to Flutter.
     */
    private fun registerSystemInsetsChannel(
        flutterEngine: FlutterEngine
    ) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            systemInsetsChannelName
        ).setMethodCallHandler {
                call: MethodCall,
                result: MethodChannel.Result ->

            when (call.method) {
                "getNavigationBarBottomInset" -> {
                    val insetTarget =
                        getInsetTargetView()

                    ViewCompat.requestApplyInsets(
                        insetTarget
                    )

                    val currentInsets =
                        ViewCompat.getRootWindowInsets(
                            insetTarget
                        )

                    val bottomInsetPx =
                        currentInsets?.let {
                            readNavigationBarBottomInset(it)
                        } ?: navigationBarBottomInsetPx

                    val density =
                        resources.displayMetrics.density

                    /*
                     * Convert Android physical pixels to Flutter
                     * logical pixels.
                     */
                    val bottomInsetDp =
                        bottomInsetPx.toDouble() /
                                density.toDouble()

                    result.success(bottomInsetDp)
                }

                else -> result.notImplemented()
            }
        }
    }

    /*
     * Returns only the area occupied by persistent tappable
     * navigation controls, such as Android three-button navigation.
     *
     * Gesture-navigation space is intentionally not returned, so
     * Flutter does not add a large empty bottom gap.
     */
    private fun readNavigationBarBottomInset(
        insets: WindowInsetsCompat
    ): Int {
        return insets.getInsets(
            WindowInsetsCompat.Type.navigationBars()
        ).bottom
    }

    private fun savePdfToDownloads(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val fileName =
            call.argument<String>("fileName")
                ?: "my_cv.pdf"

        val bytes =
            call.argument<ByteArray>("bytes")

        if (bytes == null || bytes.isEmpty()) {
            result.error(
                "invalid_file",
                "PDF file is empty.",
                null
            )
            return
        }

        try {
            val savedPath =
                if (
                    Build.VERSION.SDK_INT >=
                    Build.VERSION_CODES.Q
                ) {
                    saveWithMediaStore(
                        fileName,
                        bytes
                    )
                } else {
                    saveWithLegacyStorage(
                        fileName,
                        bytes
                    )
                }

            result.success(savedPath)
        } catch (error: SecurityException) {
            result.error(
                "permission_denied",
                error.message,
                null
            )
        } catch (error: Exception) {
            result.error(
                "download_failed",
                error.message,
                null
            )
        }
    }

    private fun saveWithMediaStore(
        fileName: String,
        bytes: ByteArray
    ): String {
        val resolver =
            applicationContext.contentResolver

        val values =
            ContentValues().apply {
                put(
                    MediaStore.Downloads.DISPLAY_NAME,
                    sanitizeFileName(fileName)
                )

                put(
                    MediaStore.Downloads.MIME_TYPE,
                    "application/pdf"
                )

                put(
                    MediaStore.Downloads.RELATIVE_PATH,
                    Environment.DIRECTORY_DOWNLOADS
                )

                put(
                    MediaStore.Downloads.IS_PENDING,
                    1
                )
            }

        val uri =
            resolver.insert(
                MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                values
            ) ?: throw IllegalStateException(
                "Unable to create download file."
            )

        resolver.openOutputStream(uri)?.use {
                outputStream ->

            outputStream.write(bytes)
            outputStream.flush()
        } ?: throw IllegalStateException(
            "Unable to write download file."
        )

        values.clear()

        values.put(
            MediaStore.Downloads.IS_PENDING,
            0
        )

        resolver.update(
            uri,
            values,
            null,
            null
        )

        return uri.toString()
    }

    private fun saveWithLegacyStorage(
        fileName: String,
        bytes: ByteArray
    ): String {
        val downloadsDirectory =
            Environment
                .getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_DOWNLOADS
                )

        if (!downloadsDirectory.exists()) {
            downloadsDirectory.mkdirs()
        }

        val file =
            File(
                downloadsDirectory,
                sanitizeFileName(fileName)
            )

        file.writeBytes(bytes)

        sendBroadcast(
            Intent(
                Intent.ACTION_MEDIA_SCANNER_SCAN_FILE,
                Uri.fromFile(file)
            )
        )

        return file.absolutePath
    }

    private fun sanitizeFileName(
        fileName: String
    ): String {
        val sanitizedName =
            fileName
                .trim()
                .replace(
                    Regex("[^a-zA-Z0-9._-]"),
                    "_"
                )
                .ifEmpty {
                    "my_cv.pdf"
                }

        return if (
            sanitizedName.endsWith(
                ".pdf",
                ignoreCase = true
            )
        ) {
            sanitizedName
        } else {
            "$sanitizedName.pdf"
        }
    }
}
