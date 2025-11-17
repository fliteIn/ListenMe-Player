package com.listenme.player

import androidx.core.view.WindowCompat
import android.util.Log
import android.os.Bundle
import android.graphics.Color
import android.app.Activity
import android.content.Intent
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {

    companion object {
        const val SAF_CHANNEL = "my.saf.channel"
        const val APP_CHANNEL = "com.listenme.player/app"
        const val REQUEST_CODE_OPEN_DOCUMENT_TREE = 1001
    }

    private var pendingResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Log.d("MainActivity", "onCreate: setting transparent background")

        WindowCompat.setDecorFitsSystemWindows(window, false)
        window.setBackgroundDrawableResource(android.R.color.transparent)
        window.decorView.setBackgroundColor(Color.TRANSPARENT)

        // ✅ Инициализируем SAF-контекст (однократно)
        SafHelper.init(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 🔹 Канал для работы с SAF
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SAF_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                // === 📂 Открытие диалога выбора папки ===
                "openFilePicker" -> {
                    if (pendingResult != null) {
                        Log.w("SAF", "⚠️ SAF picker already active, ignoring new request")
                        result.error("SAF_BUSY", "SAF picker already active", null)
                        return@setMethodCallHandler
                    }

                    pendingResult = result
                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                        addFlags(
                            Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                                    Intent.FLAG_GRANT_PREFIX_URI_PERMISSION
                        )
                    }
                    startActivityForResult(intent, REQUEST_CODE_OPEN_DOCUMENT_TREE)
                }

                // === Остальные методы SAF ===
                "getDirectoryContent" -> {
                    val uriString = call.argument<String>("uri")
                    if (uriString == null) {
                        result.error("INVALID_URI", "URI is null", null)
                        return@setMethodCallHandler
                    }
                    val files = SafHelper.getDirectoryContent(this, uriString)
                    result.success(files)
                }

                "getAudioDuration" -> {
                    val uriString = call.argument<String>("uri")
                    val durationMs = SafHelper.getAudioDurationSaf(this, uriString)
                    result.success(durationMs)
                }

                "getDisplayName" -> {
                    val uriString = call.argument<String>("uri")
                    val name = SafHelper.getDisplayName(this, uriString)
                    result.success(name)
                }

                "getAudioMetadata" -> {
                    val uriString = call.argument<String>("uri")
                    val meta = SafHelper.getAudioMetadataSaf(this, uriString)
                    result.success(meta)
                }

                "copySafUriToTempFile" -> {
                    val uriString = call.argument<String>("uri")
                    Thread {
                        val tempPath = SafHelper.copySafUriToTempFile(this, uriString)
                        runOnUiThread { result.success(tempPath) }
                    }.start()
                }

                "persistPermissions" -> {
                    val uriString = call.argument<String>("uri")
                    Log.d("SAF_DEBUG", "📂 persistPermissions called for: $uriString")
                    val success = SafHelper.persistPermissions(this, uriString)
                    Log.d("SAF_DEBUG", "✅ persistPermissions result: $success")
                    result.success(success)
                }


                "checkUriPermission" -> {
                    val uriString = call.argument<String>("uri")
                    Log.d("SAF_DEBUG", "🔍 checkUriPermission called for: $uriString")
                    val has = SafHelper.checkUriPermission(this, uriString)
                    Log.d("SAF_DEBUG", "🔍 checkUriPermission result: $has")
                    result.success(has)
                }
                "getPersistedUriPermissions" -> {
                    // Получаем все выданные SAF URI
                    val perms = contentResolver.persistedUriPermissions
                    val uris = perms.map { it.uri.toString() }
                    result.success(uris)
                }
                "openDocumentTree" -> {
                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
                    startActivityForResult(intent, REQUEST_CODE_OPEN_DOCUMENT_TREE)
                    pendingResult = result
                }
                "fileExists" -> {
                    val uriString = call.argument<String>("uri")
                    val exists = SafHelper.exists(this, uriString)
                    result.success(exists)
                }



                else -> result.notImplemented()
            }
        }

        // 🔹 Канал для moveTaskToBack
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            APP_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "moveTaskToBack") {
                moveTaskToBack(true)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        // (Оставь, если используешь эквалайзер-плагин)
        EqualizerPlugin.registerWith(flutterEngine)
    }

    // ✅ Возврат результата выбора папки в Dart
    @Deprecated("Deprecated in Activity")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_CODE_OPEN_DOCUMENT_TREE) {
            if (pendingResult == null) {
                Log.w("SAF", "⚠️ onActivityResult called but no pendingResult set")
                return
            }

            if (resultCode == Activity.RESULT_OK && data?.data != null) {
                val uri = data.data!!
                try {
                    val flags = data.flags and
                            (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                    contentResolver.takePersistableUriPermission(uri, flags)
                    Log.d("SAF", "✅ Persisted permission for: $uri")
                    pendingResult?.success(uri.toString()) // Возвращаем в Dart
                } catch (e: Exception) {
                    Log.e("SAF", "❌ Failed to persist URI permission: $e")
                    pendingResult?.success(uri.toString()) // Всё равно возвращаем
                }
            } else {
                Log.d("SAF", "📂 Picker cancelled")
                pendingResult?.success(null)
            }

            pendingResult = null
        } else {
            // Обработка остальных запросов SAF
            SafHelper.handleActivityResult(requestCode, resultCode, data)
        }
    }
}
