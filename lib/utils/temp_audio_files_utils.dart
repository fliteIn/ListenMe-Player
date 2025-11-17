import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'saf.dart';


/// Удаляет кэшированную копию аудиофайла, если она существует
Future<void> deleteCachedCopyIfExists(String originalPath) async {
  final file = File(originalPath);
  final cacheDir = await getTemporaryDirectory();
  final filename = file.uri.pathSegments.last;
  final cachedPath = '${cacheDir.path}/$filename';
  final cachedFile = File(cachedPath);
  if (await cachedFile.exists()) {
    await cachedFile.delete();
    debugPrint('🧹 Удалена кэш-копия: $cachedPath');
  }
}

/// Удаляет временный файл по заданному пути
Future<void> deleteTempFile(String path) async {
  final file = File(path);
  if (await file.exists()) {
    await file.delete();
  }
}

/// Короткий стабильный хэш пути (base64url от SHA1, 10 символов)
String _hashPath(String s) {
  final bytes = utf8.encode(s);
  final digest = crypto.sha1.convert(bytes);
  final b64 = base64Url.encode(digest.bytes); // безопасно для имени файла
  return b64.substring(0, 10);
}

/// Единая функция формирования пути к WAV в кэше (уникально на основе пути)
Future<String> convertedWavPathFor(String originalPath) async {
  final tempDir = await getTemporaryDirectory();
  final baseName = p.basenameWithoutExtension(originalPath);
  final hashed = _hashPath(originalPath);
  // Пример: MySong_z3Uy8bP5gQ_converted.wav
  return p.join(tempDir.path, '${baseName}_${hashed}_converted.wav');
}

/// Создаёт .wav-копию для PCM-анализа, если она ещё не создана
Future<String?> createConvertedWavIfMissing(String originalPath) async {
  // 1. Проверяем — если content://, копируем во временный файл
  String pathForFFmpeg = originalPath;
  if (originalPath.startsWith('content://')) {
    debugPrint('[WAV] content:// detected, copying to temp...');
    // SAF.copySafUriToTempFile должен быть доступен здесь!
    final tempCopy = await SAF.copySafUriToTempFile(originalPath);
    if (tempCopy == null) {
      debugPrint('[WAV][ERROR] Failed to copy SAF URI to temp file');
      return null;
    }
    pathForFFmpeg = tempCopy;
    debugPrint('[WAV] Copied SAF URI to temp: $pathForFFmpeg');
  }

  final convertedPath = await convertedWavPathFor(originalPath);

  debugPrint('📂 Путь для создаваемого WAV: $convertedPath');

  final wavFile = File(convertedPath);
  if (await wavFile.exists()) {
    debugPrint('📁 WAV уже существует — используем его');
    return convertedPath;
  }

  debugPrint('🔄 Запуск конвертации в WAV...');
  final command =
      '-i "$pathForFFmpeg" -ac 1 -ar 8000 -sample_fmt s16 -f wav "$convertedPath"';

  final session = await FFmpegKit.execute(command);
  final returnCode = await session.getReturnCode();
  debugPrint('📜 FFmpeg завершил работу с кодом: $returnCode');

  if (await wavFile.exists()) {
    debugPrint('✅ WAV-файл успешно создан');
    return convertedPath;
  } else {
    debugPrint('❌ WAV-файл НЕ создан — возможно, ошибка конвертации');
    final logs = await session.getAllLogs();
    for (final log in logs) {
      debugPrint('FFmpeg Log: ${log.getMessage()}');
    }
    return null;
  }
}

/// Удаляет конкретный WAV-файл, соответствующий оригиналу (с учётом хэша)
Future<void> deleteConvertedWavFor(String originalPath) async {
  final convertedPath = await convertedWavPathFor(originalPath);
  final file = File(convertedPath);
  if (await file.exists()) {
    try {
      await file.delete();
      debugPrint('🧹 Удалён соответствующий WAV: $convertedPath');
    } catch (e) {
      debugPrint('⚠️ Ошибка при удалении WAV: $e');
    }
  }

  // Обратная совместимость: удалить старый вариант без хэша, если вдруг остался
  final tempDir = await getTemporaryDirectory();
  final legacyPath = p.join(
    tempDir.path,
    '${p.basenameWithoutExtension(originalPath)}_converted.wav',
  );
  final legacyFile = File(legacyPath);
  if (await legacyFile.exists()) {
    try {
      await legacyFile.delete();
      debugPrint('🧹 Удалён старый (legacy) WAV: $legacyPath');
    } catch (e) {
      debugPrint('⚠️ Ошибка при удалении legacy WAV: $e');
    }
  }
}

/// Очищает .wav-файлы из кэша, которые не соответствуют активным трекам.
/// `activeTracks` — это список ПУТЕЙ оригиналов (желательно полных).
/// Функция остаётся совместимой со "старыми" файлами без хэша.
Future<void> clearConvertedWavCache({List<String>? activeTracks}) async {
  final dir = await getTemporaryDirectory();
  final entries = dir.listSync().whereType<File>();

  // Формируем allowlist имен файлов для активных путей (и новый формат, и legacy)
  final allowed = <String>{};
  if (activeTracks != null) {
    for (final orig in activeTracks) {
      // новый формат
      final newPath = await convertedWavPathFor(orig);
      allowed.add(p.basename(newPath));
      // старый формат (legacy)
      final legacy = '${p.basenameWithoutExtension(orig)}_converted.wav';
      allowed.add(legacy);
    }
  }

  for (final file in entries) {
    if (p.extension(file.path).toLowerCase() != '.wav') continue;
    final name = p.basename(file.path);

    // интересуют только *_converted.wav (и наш новый *_<hash>_converted.wav)
    final isConverted = name.endsWith('_converted.wav');
    if (!isConverted) continue;

    // Если список активных не задан — чистим всё
    if (activeTracks == null) {
      try {
        await file.delete();
        debugPrint('🧹 Удалён временный WAV: ${file.path}');
      } catch (e) {
        debugPrint('⚠️ Ошибка при удалении файла: $e');
      }
      continue;
    }

    // Если активные заданы — удаляем только то, чего нет в allowlist
    if (!allowed.contains(name)) {
      try {
        await file.delete();
        debugPrint('🧹 Удалён временный WAV (не активный): ${file.path}');
      } catch (e) {
        debugPrint('⚠️ Ошибка при удалении файла: $e');
      }
    }
  }
}
