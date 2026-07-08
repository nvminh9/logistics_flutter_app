package com.example.nalogistics_app

import android.app.DownloadManager
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.provider.OpenableColumns
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val channelName = "nalogistics_app/attachments"
    private val pickAttachmentRequestCode = 6107
    private var pendingPickResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickAttachment" -> pickAttachment(result)
                    "downloadAttachment" -> {
                        val url = call.argument<String>("url").orEmpty()
                        val fileName = call.argument<String>("fileName").orEmpty()
                        downloadAttachment(url, fileName, result)
                    }
                    "saveBytesToDownloads" -> {
                        val bytes = call.argument<ByteArray>("bytes")
                        val fileName = call.argument<String>("fileName").orEmpty()
                        saveBytesToDownloads(bytes, fileName, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun pickAttachment(result: MethodChannel.Result) {
        if (pendingPickResult != null) {
            result.error("PICK_IN_PROGRESS", "A file picker is already open.", null)
            return
        }

        pendingPickResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
            putExtra(
                Intent.EXTRA_MIME_TYPES,
                arrayOf(
                    "image/*",
                    "application/pdf",
                    "application/vnd.ms-excel",
                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    "application/msword",
                    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                    "text/plain"
                )
            )
        }
        startActivityForResult(intent, pickAttachmentRequestCode)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != pickAttachmentRequestCode) return

        val result = pendingPickResult
        pendingPickResult = null

        val uri = data?.data
        if (resultCode != RESULT_OK || uri == null) {
            result?.success(null)
            return
        }

        try {
            val fileName = queryFileName(uri)
            val destination = File(cacheDir, "attachments/${System.currentTimeMillis()}_$fileName")
            destination.parentFile?.mkdirs()

            contentResolver.openInputStream(uri).use { input ->
                FileOutputStream(destination).use { output ->
                    input?.copyTo(output) ?: error("Cannot open selected file.")
                }
            }

            result?.success(destination.absolutePath)
        } catch (e: Exception) {
            result?.error("PICK_FAILED", e.message, null)
        }
    }

    private fun queryFileName(uri: Uri): String {
        contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (nameIndex >= 0 && cursor.moveToFirst()) {
                return sanitizeFileName(cursor.getString(nameIndex))
            }
        }
        return "attachment_${System.currentTimeMillis()}"
    }

    private fun sanitizeFileName(fileName: String): String {
        return fileName.replace(Regex("[\\\\/:*?\"<>|]"), "_")
    }

    private fun downloadAttachment(url: String, fileName: String, result: MethodChannel.Result) {
        if (url.isBlank()) {
            result.error("INVALID_URL", "Attachment URL is empty.", null)
            return
        }

        try {
            val downloadManager = getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
            val request = DownloadManager.Request(Uri.parse(url)).apply {
                setTitle(if (fileName.isBlank()) "attachment" else fileName)
                setDescription("Downloading order attachment")
                setNotificationVisibility(
                    DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED
                )
                setDestinationInExternalPublicDir(
                    Environment.DIRECTORY_DOWNLOADS,
                    if (fileName.isBlank()) Uri.parse(url).lastPathSegment ?: "attachment" else fileName
                )
                setAllowedOverMetered(true)
                setAllowedOverRoaming(true)
            }
            val downloadId = downloadManager.enqueue(request)
            result.success(downloadId)
        } catch (e: Exception) {
            result.error("DOWNLOAD_FAILED", e.message, null)
        }
    }

    private fun saveBytesToDownloads(
        bytes: ByteArray?,
        fileName: String,
        result: MethodChannel.Result
    ) {
        if (bytes == null || bytes.isEmpty()) {
            result.error("INVALID_BYTES", "File data is empty.", null)
            return
        }

        val safeName = sanitizeFileName(if (fileName.isBlank()) "attachment.pdf" else fileName)

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val values = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, safeName)
                    put(MediaStore.MediaColumns.MIME_TYPE, "application/pdf")
                    put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                }

                val uri = contentResolver.insert(
                    MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                    values
                ) ?: error("Cannot create file in Downloads.")

                contentResolver.openOutputStream(uri).use { output ->
                    output?.write(bytes) ?: error("Cannot open Downloads file.")
                }
            } else {
                val downloads = Environment.getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_DOWNLOADS
                )
                if (!downloads.exists()) {
                    downloads.mkdirs()
                }

                val file = File(downloads, safeName)
                FileOutputStream(file).use { output ->
                    output.write(bytes)
                }
            }

            result.success("Downloads/$safeName")
        } catch (e: Exception) {
            result.error("SAVE_DOWNLOAD_FAILED", e.message, null)
        }
    }
}
