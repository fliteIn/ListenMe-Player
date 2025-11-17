import 'package:flutter/services.dart';

class SAF {
  static const MethodChannel _channel = MethodChannel('my.saf.channel');

  /// Открыть SAF-диалог для выбора папки (или файла)
  static Future<String?> openFilePicker() async {
    print('[DEBUG] CALLING SAF MethodChannel: openFilePicker');
    return await _channel.invokeMethod<String>('openFilePicker');
  }

  /// Получить список содержимого папки SAF.
  /// Возвращает List<Map<String, dynamic>> где каждый map содержит:
  /// - 'uri': String (uri или путь)
  /// - 'name': String (имя файла/папки)
  /// - 'isDirectory': bool
  static Future<List<Map<String, dynamic>>> getDirectoryContent(String directoryUri) async {
    try {
      print('[DEBUG] CALLING SAF MethodChannel: getDirectoryContent for $directoryUri');
      final result = await _channel.invokeMethod<List<dynamic>>(
        'getDirectoryContent',
        {'uri': directoryUri},
      );
      if (result == null) return [];
      return result
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      print('[ERROR][SAF] getDirectoryContent failed: $e');
      return [];
    }
  }

  static Future<String?> copySafUriToTempFile(String uri) async {
    return await _channel.invokeMethod('copySafUriToTempFile', {'uri': uri});
  }



  static Future<int?> getAudioDuration(String uri) async {
    final result = await _channel.invokeMethod('getAudioDuration', {'uri': uri});
    return result is int ? result : (result is double ? result.toInt() : null);
  }


  static Future<String?> getDisplayName(String uri) async {
    try {
      final result = await _channel.invokeMethod<String>('getDisplayName', {'uri': uri});
      return result;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getAudioMetadata(String uri) async {
    try {
      final result = await _channel.invokeMethod('getAudioMetadata', {'uri': uri});
      return result == null ? null : Map<String, dynamic>.from(result);
    } catch (e) {
      return null;
    }
  }

  /// Сохраняет постоянное разрешение на доступ к SAF-папке
  static Future<void> persistPermissions(String uri) async {
    try {
      await _channel.invokeMethod('persistPermissions', {'uri': uri});
      print('[SAF] ✅ persistPermissions OK for $uri');
    } catch (e) {
      print('[SAF] ❌ persistPermissions failed: $e');
    }
  }

  /// Проверяет, есть ли активное разрешение для указанного URI
  static Future<bool> checkUriPermission(String uri) async {
    try {
      final result = await _channel.invokeMethod('checkUriPermission', {'uri': uri});
      final has = result == true;
      print('[SAF] checkUriPermission($uri) => $has');
      return has;
    } catch (e) {
      print('[SAF] ❌ checkUriPermission failed: $e');
      return false;
    }
  }

  /// Получить список всех SAF-URI, на которые выданы разрешения
  static Future<List<String>> getPersistedUriPermissions() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getPersistedUriPermissions');
      return result.cast<String>();
    } catch (e) {
      print('[SAF] ❌ getPersistedUriPermissions failed: $e');
      return [];
    }
  }

  static Future<String?> openDocumentTree() async {
    try {
      final result = await _channel.invokeMethod('openDocumentTree');
      return result as String?;
    } catch (e) {
      print('[SAF] ❌ openDocumentTree failed: $e');
      return null;
    }
  }
  static Future<bool> fileExists(String uri) async {
    try {
      final result = await _channel.invokeMethod('fileExists', {'uri': uri});
      print('[SAF] fileExists($uri) -> $result');
      return result == true;
    } catch (e) {
      print('[SAF] ❌ fileExists failed: $e');
      return false;
    }
  }



}
