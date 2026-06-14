package com.example.italir_pothe

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val downloadChannelName = "italir_pothe/downloads"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, downloadChannelName)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                when (call.method) {
                    "savePdfToDownloads" -> savePdfToDownloads(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun savePdfToDownloads(call: MethodCall, result: MethodChannel.Result) {
        val fileName = call.argument<String>("fileName") ?: "my_cv.pdf"
        val bytes = call.argument<ByteArray>("bytes")

        if (bytes == null || bytes.isEmpty()) {
            result.error("invalid_file", "PDF file is empty.", null)
            return
        }

        try {
            val savedPath = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                saveWithMediaStore(fileName, bytes)
            } else {
                saveWithLegacyStorage(fileName, bytes)
            }
            result.success(savedPath)
        } catch (error: SecurityException) {
            result.error("permission_denied", error.message, null)
        } catch (error: Exception) {
            result.error("download_failed", error.message, null)
        }
    }

    private fun saveWithMediaStore(fileName: String, bytes: ByteArray): String {
        val resolver = applicationContext.contentResolver
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, sanitizeFileName(fileName))
            put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
            put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            put(MediaStore.Downloads.IS_PENDING, 1)
        }
        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("Unable to create download file.")

        resolver.openOutputStream(uri)?.use { outputStream ->
            outputStream.write(bytes)
            outputStream.flush()
        } ?: throw IllegalStateException("Unable to write download file.")

        values.clear()
        values.put(MediaStore.Downloads.IS_PENDING, 0)
        resolver.update(uri, values, null, null)
        return uri.toString()
    }

    private fun saveWithLegacyStorage(fileName: String, bytes: ByteArray): String {
        val downloadsDirectory = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_DOWNLOADS
        )
        if (!downloadsDirectory.exists()) {
            downloadsDirectory.mkdirs()
        }

        val file = File(downloadsDirectory, sanitizeFileName(fileName))
        file.writeBytes(bytes)
        sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(file)))
        return file.absolutePath
    }

    private fun sanitizeFileName(fileName: String): String {
        val sanitizedName = fileName
            .trim()
            .replace(Regex("[^a-zA-Z0-9._-]"), "_")
            .ifEmpty { "my_cv.pdf" }

        return if (sanitizedName.endsWith(".pdf", ignoreCase = true)) {
            sanitizedName
        } else {
            "$sanitizedName.pdf"
        }
    }
}
