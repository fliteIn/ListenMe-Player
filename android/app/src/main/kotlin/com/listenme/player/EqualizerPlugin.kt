package com.listenme.player

import android.media.audiofx.Equalizer
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object EqualizerPlugin {
    private const val TAG = "EqualizerPlugin"
    private var equalizer: Equalizer? = null

    fun registerWith(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "equalizer_channel"
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "initEqualizer" -> {
                    try {
                        val sessionId = call.argument<Int>("sessionId") ?: 0
                        equalizer?.release()
                        equalizer = Equalizer(0, sessionId)
                        equalizer?.enabled = true
                        result.success(true)
                    } catch (t: Throwable) {
                        Log.e(TAG, "initEqualizer error", t)
                        result.error("EQ_INIT_ERROR", t.message, null)
                    }
                }

                "getBands" -> {
                    val eq = equalizer
                    if (eq != null) {
                        try {
                            val bands = ArrayList<Map<String, Any>>()
                            val nBands = eq.numberOfBands.toInt()
                            val minLevel = eq.bandLevelRange[0].toInt()
                            val maxLevel = eq.bandLevelRange[1].toInt()
                            for (i in 0 until nBands) {
                                val centerFreq = eq.getCenterFreq(i.toShort()) / 1000
                                val currentLevel = eq.getBandLevel(i.toShort()).toInt()
                                bands.add(
                                    mapOf(
                                        "band" to i,
                                        "centerFreq" to centerFreq,
                                        "minLevel" to minLevel,
                                        "maxLevel" to maxLevel,
                                        "currentLevel" to currentLevel
                                    )
                                )
                            }
                            result.success(bands)
                        } catch (t: Throwable) {
                            Log.e(TAG, "getBands error", t)
                            result.error("EQ_BANDS_ERROR", t.message, null)
                        }
                    } else {
                        result.error("NO_EQ", "Equalizer not initialized", null)
                    }
                }

                "setBandLevel" -> {
                    val eq = equalizer
                    if (eq != null) {
                        try {
                            val band = call.argument<Int>("band") ?: 0
                            val level = call.argument<Int>("level") ?: 0
                            eq.setBandLevel(band.toShort(), level.toShort())
                            result.success(true)
                        } catch (t: Throwable) {
                            Log.e(TAG, "setBandLevel error", t)
                            result.error("EQ_SET_BAND_ERROR", t.message, null)
                        }
                    } else {
                        result.error("NO_EQ", "Equalizer not initialized", null)
                    }
                }

                "setPreset" -> {
                    val eq = equalizer
                    if (eq != null) {
                        try {
                            val presetName = call.argument<String>("preset")
                            val presetIdx = findPresetIndex(eq, presetName)
                            eq.usePreset(presetIdx.toShort())
                            result.success(true)
                        } catch (t: Throwable) {
                            Log.e(TAG, "setPreset error", t)
                            result.error("EQ_PRESET_ERROR", t.message, null)
                        }
                    } else {
                        result.error("NO_EQ", "Equalizer not initialized", null)
                    }
                }

                "resetBands" -> {
                    val eq = equalizer
                    if (eq != null) {
                        try {
                            val flatIdx = findPresetIndex(eq, "flat")
                            eq.usePreset(flatIdx.toShort())
                            result.success(true)
                        } catch (t: Throwable) {
                            Log.e(TAG, "resetBands error", t)
                            result.error("EQ_RESET_ERROR", t.message, null)
                        }
                    } else {
                        result.error("NO_EQ", "Equalizer not initialized", null)
                    }
                }

                "setEnabled" -> {
                    val eq = equalizer
                    if (eq != null) {
                        try {
                            val enabled = call.argument<Boolean>("enabled") ?: true
                            eq.enabled = enabled
                            result.success(true)
                        } catch (t: Throwable) {
                            Log.e(TAG, "setEnabled error", t)
                            result.error("EQ_ENABLE_ERROR", t.message, null)
                        }
                    } else {
                        result.error("NO_EQ", "Equalizer not initialized", null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    // Вспомогательная функция поиска индекса пресета по названию
    private fun findPresetIndex(eq: Equalizer, name: String?): Int {
        if (name == null) return 0
        val lower = name.lowercase()
        for (i in 0 until eq.numberOfPresets) {
            val presetName = eq.getPresetName(i.toShort()).lowercase()
            if (presetName.contains(lower)) return i
        }
        return 0 // по умолчанию "flat"
    }
}
