package com.example.campusgpt_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import android.database.Cursor
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.campusgpt_app/filepicker"
    private var pendingResult: MethodChannel.Result? = null
    private val REQUEST_CODE_PICK_FILE = 100

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickFile" -> {
                    pendingResult = result
                    pickFile()
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun pickFile() {
        val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
            type = "*/*"
            addCategory(Intent.CATEGORY_OPENABLE)
            putExtra(Intent.EXTRA_MIME_TYPES, arrayOf(
                "application/pdf",
                "application/msword",
                "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            ))
        }
        startActivityForResult(intent, REQUEST_CODE_PICK_FILE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_CODE_PICK_FILE) {
            if (resultCode == RESULT_OK && data != null) {
                val uri: Uri? = data.data
                if (uri != null) {
                    try {
                        // Copy file to cache directory
                        val copiedFilePath = copyFileToCache(uri)
                        if (copiedFilePath != null) {
                            println("✅ File picker: Selected file copied to $copiedFilePath")
                            pendingResult?.success(copiedFilePath)
                        } else {
                            println("❌ File picker: Failed to copy file")
                            pendingResult?.error("COPY_FAILED", "Failed to copy file", null)
                        }
                    } catch (e: Exception) {
                        println("❌ File picker error: ${e.message}")
                        pendingResult?.error("ERROR", e.message, null)
                    }
                } else {
                    println("❌ File picker: No URI provided")
                    pendingResult?.error("NO_FILE", "No file selected", null)
                }
            } else {
                println("❌ File picker: Cancelled or no data")
                pendingResult?.error("CANCELLED", "File picker cancelled", null)
            }
            pendingResult = null
        }
    }

    private fun copyFileToCache(uri: Uri): String? {
        return try {
            val inputStream = contentResolver.openInputStream(uri) ?: return null
            
            // Get original filename
            val fileName = getFileNameFromUri(uri) ?: "resume_${System.currentTimeMillis()}.pdf"
            
            // Create file in cache directory
            val cacheDir = cacheDir
            val cachedFile = File(cacheDir, fileName)
            
            // Copy file
            inputStream.use { input ->
                FileOutputStream(cachedFile).use { output ->
                    input.copyTo(output)
                }
            }
            
            cachedFile.absolutePath
        } catch (e: Exception) {
            println("❌ Error copying file: ${e.message}")
            e.printStackTrace()
            null
        }
    }

    private fun getFileNameFromUri(uri: Uri): String? {
        return when {
            uri.scheme == "content" -> {
                try {
                    val cursor = contentResolver.query(uri, arrayOf("_display_name"), null, null, null)
                    cursor?.use {
                        if (it.moveToFirst()) {
                            it.getString(0)
                        } else null
                    }
                } catch (e: Exception) {
                    null
                }
            }
            uri.scheme == "file" -> File(uri.path).name
            else -> null
        }
    }

    private fun getPathFromUri(uri: Uri): String? {
        return when {
            DocumentsContract.isDocumentUri(this, uri) -> {
                when {
                    isExternalStorageDocument(uri) -> {
                        val docId = DocumentsContract.getDocumentId(uri)
                        val split = docId.split(":")
                        if ("primary".equals(split[0], ignoreCase = true)) {
                            getExternalFilesDir(null)?.absolutePath + "/" + split[1]
                        } else {
                            "/storage/" + split[0] + "/" + split[1]
                        }
                    }
                    isDownloadsDocument(uri) -> {
                        val id = DocumentsContract.getDocumentId(uri)
                        getDataColumn(Uri.parse("content://downloads/public_downloads"), id)
                    }
                    isMediaDocument(uri) -> {
                        val docId = DocumentsContract.getDocumentId(uri)
                        val split = docId.split(":")
                        val type = split[0]
                        val id = split[1]
                        
                        val contentUri = when (type) {
                            "image" -> android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI
                            "video" -> android.provider.MediaStore.Video.Media.EXTERNAL_CONTENT_URI
                            "audio" -> android.provider.MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
                            else -> android.provider.MediaStore.Files.getContentUri("external")
                        }
                        getDataColumn(contentUri, id)
                    }
                    else -> null
                }
            }
            "content".equals(uri.scheme, ignoreCase = true) -> {
                if (isGooglePhotosUri(uri)) uri.lastPathSegment else getDataColumn(uri, null)
            }
            "file".equals(uri.scheme, ignoreCase = true) -> uri.path
            else -> null
        }
    }

    private fun getDataColumn(uri: Uri, id: String?): String? {
        return getDataColumn(uri, if (id != null) "_id=$id" else null, null)
    }

    private fun getDataColumn(uri: Uri, selection: String?, selectionArgs: Array<String>?): String? {
        var cursor: Cursor? = null
        val column = "_data"
        val projection = arrayOf(column)
        try {
            cursor = contentResolver.query(uri, projection, selection, selectionArgs, null)
            if (cursor != null && cursor.moveToFirst()) {
                val index = cursor.getColumnIndexOrThrow(column)
                return cursor.getString(index)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            cursor?.close()
        }
        return null
    }

    private fun isExternalStorageDocument(uri: Uri): Boolean {
        return "com.android.externalstorage.documents" == uri.authority
    }

    private fun isDownloadsDocument(uri: Uri): Boolean {
        return "com.android.providers.downloads.documents" == uri.authority
    }

    private fun isMediaDocument(uri: Uri): Boolean {
        return "com.android.providers.media.documents" == uri.authority
    }

    private fun isGooglePhotosUri(uri: Uri): Boolean {
        return "com.google.android.apps.photos.content" == uri.authority
    }
}

