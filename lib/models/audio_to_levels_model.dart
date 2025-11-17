import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'playback_model.dart';
import 'app_model.dart';
import '../utils/temp_audio_files_utils.dart';
import '../utils/global_keys.dart';
import 'package:flutter/foundation.dart' show compute;
import '../utils/pcm_parser.dart'; // PcmArgs, parsePcmLevelsIsolate
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import '../models/app_model.dart';
import '../utils/saf.dart'; // ✅ добавь этот импорт



class AudioToLevelsModel extends ChangeNotifier {

//------------------------------------------Field-------------------------------
  late AppModel _app;
  String? _currentWavPath;
  String? _currentAnalyzedOriginalPath;
  String? get currentAnalyzedOriginalPath => _currentAnalyzedOriginalPath;


  bool _analyzingNow = false;
  bool get analyzingNow => _analyzingNow;

  bool _isAnalyzing = false;
  double _analyzeProgress = 0.0;
  bool get isAnalyzing => _isAnalyzing;
  double get analyzeProgress => _analyzeProgress;

  bool _reAnalyzeRequested = false;




  void setAppModel(AppModel app) {
    _app = app;
  }

//------------------------------------------Field End---------------------------

  void setPlayback(PlaybackModel playback) {
    _app.playbackModel = playback;
  }

  void _setAnalyzing(bool value) {
    if (_analyzingNow == value && _isAnalyzing == value) return; // реагируем только на смену
    _analyzingNow = value;
    _isAnalyzing = value; // ← ВАЖНО: синхронизируем флаг, который читает AppModel
    notifyListeners();
  }


  void _setAnalyzeProgress(double value) {
    if (_analyzeProgress == value) return;
    _analyzeProgress = value;
    notifyListeners();
  }

  void logAudioFileInfo(String label, String filePath) {
    debugPrint('[$label] Путь: $filePath');
    final file = File(filePath);
    final exists = file.existsSync();
    debugPrint('[$label] Файл существует: $exists');
    if (exists) {
      final size = file.lengthSync();
      debugPrint('[$label] Размер файла: $size байт');
    } else {
      debugPrint('[$label] Файл НЕ НАЙДЕН!');
    }
  }


  Future<void> cleanup() async {
    if (_currentWavPath != null) {
      final file = File(_currentWavPath!);
      if (await file.exists()) {
        await file.delete();
        print('🧹 Удалена .wav при cleanup');
      }
      _currentWavPath = null;
    }
  }

  Future<bool> _isValidWav(String path) async {
    try {
      final f = File(path);
      final bytes = await f.openRead(0, 12).fold<List<int>>([], (a, b) {
        a.addAll(b);
        return a;
      });
      if (bytes.length < 12) return false;
      final riff = String.fromCharCodes(bytes.sublist(0, 4));
      final wave = String.fromCharCodes(bytes.sublist(8, 12));
      return riff == 'RIFF' && wave == 'WAVE';
    } catch (_) {
      return false;
    }
  }



  Future<void> analyzeTrack({
    bool full = true,
    bool force = false,
  }) async {

    final path = _app.originalTrackPath;
    debugPrint('=== [ANALYZE] analyzeTrack START (full=$full, force=$force) for $path ===');

    if (path == null || path.isEmpty) {
      debugPrint('[ANALYZE] originalTrackPath is null or empty — skipping analysis');
      _setAnalyzeProgress(0.0);
      return;
    }

    if (!_app.showSilenceControlBar) {
      debugPrint('[ANALYZE] Пропуск: silenceControlBar не активен');
      _setAnalyzeProgress(0.0);
      return;
    }

    if (_analyzingNow) {
      debugPrint('⏳ Анализ уже выполняется — ПРОПУСК');
      _reAnalyzeRequested = true;
      return;
    }
    _analyzingNow = true;
    _setAnalyzeProgress(0.01);

    try {
      // ВСЕГДА вычисляем актуальный путь к .wav:
      final wavPath = await convertedWavPathFor(path);

      // --- Быстрый путь: только анализ тишины ---
      if (!full) {
        if (wavPath == null || !(await File(wavPath).exists())) {
          debugPrint('🚫 [ANALYZE] Нет готового WAV-файла — нужен полный анализ');
          _setAnalyzeProgress(0.0);
          return;
        }
        _currentAnalyzedOriginalPath = path;
        _currentWavPath = wavPath;
        await _analyzeSilenceOnly();
        startLevelTracking();
        return;
      }

      // --- Проверяем: если wav не существует, сбрасываем переменные ---
      if (_currentWavPath != null && !await File(_currentWavPath!).exists()) {
        debugPrint('[ANALYZE] WAV-файл исчез — сбрасываю ссылки');
        _currentWavPath = null;
        _currentAnalyzedOriginalPath = null;
      }

      // --- Быстрый (кешированный) путь: тот же оригинал, wav уже есть ---
      final canFast =
      (_currentAnalyzedOriginalPath == path &&
          !force &&
          _currentWavPath != null &&
          await File(_currentWavPath!).exists());

      if (canFast) {
        debugPrint('⏭ [ANALYZE] Тот же оригинал и WAV уже готов — анализ только тишины');
        await _analyzeSilenceOnly();
        startLevelTracking();
        return;
      }

      // --- Создаём WAV, если его нет ---
      debugPrint('📝 [ANALYZE] Получение или создание WAV...');
      String? createdWavPath = wavPath;
      if (createdWavPath == null || !(await File(createdWavPath).exists()) || force) {


// 👇 Вот здесь вызываем очистку кэша!
        const estimatedWavSize = 60 * 1024 * 1024; // или точнее по вашей логике
        final enoughSpace = await _app.ensureCacheSpace(estimatedWavSize, asyncCleanup: true);
        if (!enoughSpace) {
          debugPrint('[CACHE][AudioToLevels] Недостаточно места для создания WAV.');
          _setAnalyzeProgress(0.0);
          _analyzingNow = false;
          return;
        }

        createdWavPath = await createConvertedWavIfMissing(path);
      }
      logAudioFileInfo('WAV', createdWavPath ?? 'null');

      if (createdWavPath == null || !(await File(createdWavPath).exists())) {
        debugPrint('🚫 [ANALYZE] WAV-файл не найден или не создан');
        return;
      }
      _currentAnalyzedOriginalPath = path;
      _currentWavPath = createdWavPath;

      // --- Быстрая проверка валидности WAV ---
      if (!await _isValidWav(createdWavPath)) {
        debugPrint('❌ [ANALYZE] WAV некорректен — удаляю и останавливаюсь.');
        try { await File(createdWavPath).delete(); } catch (_) {}
        _currentWavPath = null;
        return;
      }

      // --- Парсинг PCM ---
      _setAnalyzeProgress(0.15);
      final levels = await compute(parsePcmLevelsIsolate, PcmArgs(createdWavPath, 800));
      _app.pcmLevels = levels;
      debugPrint('📈 [ANALYZE] PCM уровней: ${levels.length}');

      // --- Поиск тишины ---
      _setAnalyzeProgress(0.7);
      await _analyzeSilenceOnly();

      // --- После получения PCM — отслеживание! ---
      startLevelTracking();

    } catch (e, st) {
      debugPrint('🚨 [ANALYZE] Ошибка: $e\n$st');
    } finally {
      _setAnalyzeProgress(0.0);
      _analyzingNow = false;
      debugPrint('🏁 [ANALYZE] Анализ завершён. _analyzingNow=false');

      if (_reAnalyzeRequested) {
        debugPrint('[ANALYZE] Повторный анализ по флагу _reAnalyzeRequested');
        _reAnalyzeRequested = false;
        Future.microtask(() => analyzeTrack(
          full: false,
          force: false,
        ));
      }
    }
  }


  Future<void> _analyzeSilenceOnly() async {
    debugPrint('🔎 [ANALYZE] Поиск тишины по $_currentWavPath...');
    if (_currentWavPath == null) return;
    _setAnalyzeProgress(0.9);
    try {
      final markers = await extractSilenceTimestamps(
        filePath: _currentWavPath!,
        thresholdDb: _app.silenceThresholdDb,
        app: _app,
      );
      _app.silences = markers;
      debugPrint('[ANALYZE] Silence markers found: ${_app.silences.length}');
    } catch (e, st) {
      debugPrint('❌ [ANALYZE] Ошибка поиска тишины: $e\n$st');
    }
  }



  void startLevelTracking() {
    _app.pcmTimer?.cancel();

    _app.pcmTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final position = _app.player.position;
      final index = (position.inMilliseconds / 100).floor();

      final level = (index >= 0 && index < _app.pcmLevels.length)
          ? _app.pcmLevels[index]
          : 0.0;

      final currentLevel = _app.player.playing ? level : 0.0;

      _app.currentPcmLevel = currentLevel;

      //debugPrint('📊 currentPcmLevel = $currentLevel (index: $index, playing: ${_app.player.playing})');

      notifyListeners();
    });

    print('▶ Уровень PCM отслеживается через таймер');
  }


  Future<void> _parseSilenceLog(String logData, AppModel app) async {
    int silenceFound = 0;
    const int silenceEndShiftMs = 350;

    final lines = logData.split('\n');
    for (final message in lines) {
      if (message.contains('silence_end:')) {
        final match = RegExp(r'silence_end:\s*(\d+(\.\d+)?)').firstMatch(message);
        if (match != null) {
          final seconds = double.tryParse(match.group(1)!) ?? 0.0;
          int millis = (seconds * 1000).toInt() - silenceEndShiftMs;
          if (millis < 0) millis = 0;
          final duration = Duration(milliseconds: millis);
          app.silences.add(duration);
          silenceFound++;
          debugPrint('[SILENCE] Detected silence_end at ${duration.inMilliseconds} ms ($duration)');
        }
      } else if (message.contains('silence_start:')) {
        final match = RegExp(r'silence_start:\s*(\d+(\.\d+)?)').firstMatch(message);
        if (match != null) {
          final seconds = double.tryParse(match.group(1)!) ?? 0.0;
          final duration = Duration(milliseconds: (seconds * 1000).toInt());
          debugPrint('[SILENCE] Detected silence_start at ${duration.inMilliseconds} ms ($duration)');
        }
      }
    }

    debugPrint('[SILENCE] Total detected silence_end markers: $silenceFound');
    debugPrint('[SILENCE] All detected silence_end markers: ${app.silences}');
  }



  Future<List<Duration>> extractSilenceTimestamps({
    required String filePath,
    required double thresholdDb,
    required AppModel app,
  }) async {
    debugPrint('==== [SILENCE] ====');
    debugPrint('[SILENCE] START extractSilenceTimestamps');
    debugPrint('[SILENCE] filePath: $filePath');
    debugPrint('[SILENCE] thresholdDb: $thresholdDb');
    app.silences.clear();

    // --- Для SAF URI копируем в temp-файл ---
    String inputPath = filePath;
    if (inputPath.startsWith('content://')) {
      debugPrint('[SILENCE] SAF URI detected — copying to temp file via MethodChannel');
      final tempPath = await SAF.copySafUriToTempFile(inputPath);
      if (tempPath == null) {
        debugPrint('[SILENCE][ERROR] Failed to copy SAF URI to temp file');
        return [];
      }
      inputPath = tempPath;
      debugPrint('[SILENCE] Copied SAF URI to temp path: $inputPath');
    }

    // --- Формируем команду FFmpeg ---
    final command =
        '-hide_banner -loglevel info -i "$inputPath" -af silencedetect=n=${thresholdDb}dB:d=0.3 -f null -';
    debugPrint('[SILENCE] FFmpeg command: $command');

    try {
      final session = await FFmpegKit.execute(command);
      debugPrint('[SILENCE] ▶ FFmpegKit.execute() completed');

      final returnCode = await session.getReturnCode();
      final logs = await session.getAllLogs();
      final output = await session.getOutput();

      debugPrint('[SILENCE] FFmpeg returnCode: $returnCode');
      debugPrint('[SILENCE] FFmpeg logs count: ${logs.length}');
      if (logs.isEmpty) debugPrint('[SILENCE] FFmpeg logs are EMPTY!');

      if (returnCode == null || !returnCode.isValueSuccess()) {
        debugPrint('[SILENCE][WARN] FFmpeg finished with error return code!');
        for (final log in logs) {
          debugPrint('[SILENCE][FULL LOG]: ${log.getMessage()}');
        }
      }

      // Собираем текст логов для парсинга
      final combinedLogs = (logs.isNotEmpty)
          ? logs.map((l) => l.getMessage()).join('\n')
          : output ?? '';

      await _parseSilenceLog(combinedLogs, app);
      debugPrint('[SILENCE] END extractSilenceTimestamps');
      debugPrint('===================');
      return app.silences;
    } catch (e, s) {
      debugPrint('[SILENCE][ERROR] Exception: $e');
      debugPrint('[SILENCE][STACKTRACE]\n$s');
      debugPrint('[SILENCE] END extractSilenceTimestamps with exception');
      return [];
    }
  }

  Future<String?> getPlayableOrLocalPath(String path) async {
    if (path.startsWith('content://')) {
      return await SAF.copySafUriToTempFile(path);
    }
    return path;
  }




  Future<String> getWavPathFor(String originalPath) async {
    final cacheDir = (await getTemporaryDirectory()).path;
    final wavName = '${p.basename(originalPath)}_converted.wav';
    return p.join(cacheDir, wavName);
  }



}