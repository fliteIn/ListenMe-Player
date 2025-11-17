package com.listenme.player

import android.content.Context
import android.net.Uri
import android.provider.DocumentsContract
import android.os.Build
import android.webkit.MimeTypeMap
import androidx.documentfile.provider.DocumentFile
import android.app.Activity
import android.content.Intent
import android.util.Log
import android.media.MediaMetadataRetriever
import java.io.File
import android.media.MediaExtractor
import android.media.MediaFormat


object SafHelper {
    const val REQUEST_CODE_OPEN_FILE = 1001
    private var resultCallback: ((String?) -> Unit)? = null
    private var appContext: Context? = null

    fun init(context: Context) {
        appContext = context.applicationContext
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_CODE_OPEN_FILE && resultCode == Activity.RESULT_OK) {
            val uri: Uri? = data?.data
            if (uri != null) {
                try {
                    val flags = data.flags and
                            (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                    appContext?.contentResolver?.takePersistableUriPermission(uri, flags)
                    Log.d("SAF", "✅ Persisted permission for: $uri")
                } catch (e: Exception) {
                    Log.w("SAF", "⚠️ Failed to persist URI permission: $e")
                }
            }
            resultCallback?.invoke(uri?.toString())
            resultCallback = null
        }
    }

    fun getDirectoryContent(context: Context, uriString: String): List<Map<String, Any?>> {
        val uri = Uri.parse(uriString)
        val docFile = DocumentFile.fromTreeUri(context, uri)
        val result = mutableListOf<Map<String, Any?>>()
        if (docFile != null && docFile.isDirectory) {
            docFile.listFiles().forEach { file ->
                result.add(
                    mapOf(
                        "uri" to file.uri.toString(),
                        "name" to file.name,
                        "isDirectory" to file.isDirectory,
                        "isFile" to file.isFile,
                        "mimeType" to file.type
                    )
                )
            }
        }
        return result
    }

    fun getAudioDurationSaf(context: Context, uriString: String?): Long? {
        if (uriString == null) return null
        val uri = Uri.parse(uriString)
        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(context, uri)
            val durationStr =
                retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
            return durationStr?.toLongOrNull()
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            retriever.release()
        }
        return null
    }

    fun getDisplayName(context: Context, uriString: String?): String? {
        if (uriString == null) return null
        return try {
            val uri = Uri.parse(uriString)
            val docFile = DocumentFile.fromSingleUri(context, uri)
            docFile?.name
        } catch (e: Exception) {
            null
        }
    }

    fun getAudioMetadataSaf(context: Context, uriString: String?): Map<String, Any?>? {
        if (uriString == null) return null
        val uri = Uri.parse(uriString)
        val retriever = MediaMetadataRetriever()
        var channels: Int? = null
        var sampleRate: Int? = null
        var fileName: String? = null

        try {
            // --- Извлекаем базовые метаданные ---
            context.contentResolver.openFileDescriptor(uri, "r")?.use { pfd ->
                retriever.setDataSource(pfd.fileDescriptor)
            }

            val title = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)
            val artist = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)
            val album = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM)
            val genre = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_GENRE)
            val duration = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
            val bitrate = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITRATE)
            val mime = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_MIMETYPE)

            // --- Получаем точные значения каналов и частоты ---
            try {
                val extractor = MediaExtractor()
                context.contentResolver.openAssetFileDescriptor(uri, "r")?.use { afd ->
                    extractor.setDataSource(afd.fileDescriptor)
                }

                for (i in 0 until extractor.trackCount) {
                    val format: MediaFormat = extractor.getTrackFormat(i)
                    if (format.containsKey(MediaFormat.KEY_CHANNEL_COUNT))
                        channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                    if (format.containsKey(MediaFormat.KEY_SAMPLE_RATE))
                        sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                }
                extractor.release()
            } catch (e: Exception) {
                e.printStackTrace()
            }


            // --- Получаем DocumentFile, чтобы вытащить имя и размер ---
            val docFile: DocumentFile? = if (uriString.contains("/tree/")) {
                DocumentFile.fromTreeUri(context, uri)
            } else {
                DocumentFile.fromSingleUri(context, uri)
            }

            val fileName = docFile?.name ?: uri.lastPathSegment
            val fileSize = docFile?.length()


            // --- Формируем итоговую структуру ---
            val format = mutableMapOf<String, Any?>(
                "format_name" to mime,
                "duration" to (duration?.toDoubleOrNull()?.div(1000.0)?.toString() ?: "0"),
                "bit_rate" to bitrate,
                "size" to fileSize?.toString(),
                "tags" to mapOf(
                    "title" to title,
                    "artist" to artist,
                    "album" to album,
                    "genre" to genre
                )
            )

            val stream = mutableMapOf<String, Any?>(
                "codec_name" to mime,
                "sample_rate" to (sampleRate ?: 0).toString(),
                "channels" to (channels ?: 0),
                "bit_rate" to bitrate
            )

            return mapOf(
                "name" to fileName,
                "format" to format,
                "streams" to listOf(stream)
            )
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            retriever.release()
        }
        return null
    }


    fun copySafUriToTempFile(context: Context, uriString: String?): String? {
        if (uriString == null) return null
        return try {
            val uri = Uri.parse(uriString)
            val inputStream = context.contentResolver.openInputStream(uri)
            val tempFile = File.createTempFile("saf_temp_", ".audio", context.cacheDir)
            inputStream?.use { input ->
                tempFile.outputStream().use { output ->
                    input.copyTo(output)
                }
            }
            tempFile.absolutePath
        } catch (e: Exception) {
            Log.e("SafHelper", "Ошибка при копировании SAF URI: $e")
            null
        }
    }

    // ✅ Сохраняет постоянное разрешение на доступ к папке
    fun persistPermissions(context: Context, uriString: String?): Boolean {
        Log.d("SAF_DEBUG", "persistPermissions(): entering with $uriString")

        if (uriString == null) return false
        return try {
            val uri = Uri.parse(uriString)
            context.contentResolver.takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            )
            Log.d("SafHelper", "✅ Persisted permission for: $uri")
            true
        } catch (e: Exception) {
            Log.e("SafHelper", "❌ persistPermissions failed: $e")
            false
        }
    }

    // ✅ Проверяет, есть ли сохранённый SAF-доступ
    fun checkUriPermission(context: Context, uriString: String?): Boolean {
        if (uriString == null) {
            Log.w("SafHelper", "⚠️ checkUriPermission: uriString is null")
            return false
        }

        return try {
            val uri = Uri.parse(uriString)
            val perms = context.contentResolver.persistedUriPermissions

            Log.d("SafHelper", "🔍 Checking SAF permission for: $uri")
            if (perms.isEmpty()) {
                Log.w("SafHelper", "⚠️ No persisted SAF permissions found at all.")
            } else {
                Log.d("SafHelper", "🔒 Persisted SAF permissions (${perms.size}):")
                for (perm in perms) {
                    Log.d(
                        "SafHelper",
                        "   • URI=${perm.uri}  read=${perm.isReadPermission}  write=${perm.isWritePermission}"
                    )
                }
            }

            // Сравниваем URI с сохранёнными
            val has = perms.any { it.uri == uri && it.isReadPermission }

            Log.d("SafHelper", "✅ checkUriPermission($uri) => $has")
            has
        } catch (e: Exception) {
            Log.e("SafHelper", "❌ checkUriPermission failed: ${e.message}", e)
            false
        }
    }
    fun exists(context: Context, uriString: String?): Boolean {
        if (uriString == null) {
            Log.d("SAF", "exists: uriString == null");
            return false
        }
        return try {
            val uri = Uri.parse(uriString)
            val docFile = DocumentFile.fromSingleUri(context, uri)
            val result = docFile?.exists() == true
            Log.d("SAF", "exists: $uriString -> $result")
            result
        } catch (e: Exception) {
            Log.e("SAF", "exists: Exception for $uriString", e)
            false
        }
    }




}
