import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'app_model.dart';
import '../enums/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:convert';
import '../utils/saf.dart';


class ManualTrackEntry {
  final String uri;
  final String name;
  final Duration? duration;

  ManualTrackEntry({
    required this.uri,
    required this.name,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
    'uri': uri,
    'name': name,
    'duration': duration?.inMilliseconds, // null или int
  };

  factory ManualTrackEntry.fromJson(Map<String, dynamic> json) => ManualTrackEntry(
    uri: json['uri'],
    name: json['name'],
    duration: json['duration'] != null
        ? Duration(milliseconds: json['duration'] as int)
        : null,
  );
}


extension ReceiveSharing on PlaylistModel {
  void initReceiveSharing() {
    final sharing = ReceiveSharingIntent.instance;

    // Первый запуск (если приложение открыто с файлами)
    sharing.getInitialMedia().then((List<SharedMediaFile> value) async {
      if (value.isNotEmpty) {
        final files = value
            .map((f) => f.path)
            .where((path) => _isAudioFile(path))
            .toList();

        if (files.isNotEmpty) {
          await addFiles(files);

          // ставим ручной плейлист активным
          _app.setCurrentPlaylistSource(PlaylistSource.manual);

          // воспроизводим первый из добавленных файлов
          final startIndex = manualPlaylist.length - files.length;

          //await _app.playbackModel.playTrackAt(startIndex, autoplay: true);
        }
      }
    });

    // Поток новых файлов (если приложение уже открыто)
    sharing.getMediaStream().listen((List<SharedMediaFile> value) async {
      if (value.isNotEmpty) {
        final files = value
            .map((f) => f.path)
            .where((path) => _isAudioFile(path))
            .toList();

        if (files.isNotEmpty) {
          await addFiles(files);

          _app.setCurrentPlaylistSource(PlaylistSource.manual);

          final startIndex = _app.manualPlaylist.length - files.length;
          await _app.playbackModel.playTrackAt(startIndex, autoplay: true);
        }
      }
    }, onError: (err) {
      debugPrint("Ошибка получения shared file: $err");
    });
  }
}



class PlaylistModel extends ChangeNotifier {
  late AppModel _app;

  List<String> get trackPaths => manualPlaylist.map((e) => e.uri).toList();

  static const String _trackPathsKey = 'track_paths';
  List<ManualTrackEntry> manualPlaylist = [];

  void setAppModel(AppModel app) {
    _app = app;
  }


  Future<int> removeMissingTracks() async {
    final toRemove = <ManualTrackEntry>[];
    for (final entry in manualPlaylist) {
      bool exists;
      try {
        exists = await SAF.fileExists(entry.uri);
        print('[removeMissingTracks] Проверка: ${entry.name} (${entry.uri}) -> exists: $exists');
      } catch (e) {
        print('[removeMissingTracks] Ошибка проверки ${entry.name} (${entry.uri}): $e');
        exists = true;
      }
      if (!exists) {
        print('[removeMissingTracks] Файл НЕ найден, добавляю в toRemove: ${entry.name}');
        toRemove.add(entry);
      }
    }
    for (final entry in toRemove) {
      final index = manualPlaylist.indexOf(entry);
      print('[removeMissingTracks] Удаляю трек ${entry.name} (index: $index)');
      if (index != -1) await removeTrack(index);
    }
    print('[removeMissingTracks] Всего удалено: ${toRemove.length}');
    return toRemove.length;
  }


  List<int> shuffleHistory = [];



  void initializeShuffle({int? currentIndex}) {
    final list = _app.currentPlaylist;
    if (list.isEmpty) {
      _app.shuffleOrder = [];
      _app.shufflePointer = -1;
      _app.playedIndices.clear();
      shuffleHistory.clear(); // Новое!
      notifyListeners();
      return;
    }

    _app.shuffleOrder = List.generate(list.length, (i) => i)..shuffle();

    if (currentIndex != null && currentIndex >= 0 && currentIndex < list.length) {
      if (_app.shuffleOrder[0] != currentIndex) {
        _app.shuffleOrder.remove(currentIndex);
        _app.shuffleOrder.insert(0, currentIndex);
      }
      _app.shufflePointer = 0;
      _app.playedIndices
        ..clear()
        ..add(currentIndex);

      shuffleHistory
        ..clear()
        ..add(currentIndex); // Новое!
    } else {
      _app.shufflePointer = 0;
      _app.playedIndices
        ..clear()
        ..add(_app.shuffleOrder[0]);

      shuffleHistory
        ..clear()
        ..add(_app.shuffleOrder[0]); // Новое!
    }

    notifyListeners();
  }

  int? getNextShuffleIndex() {
    final total = _app.currentPlaylist.length;
    if (total == 0) return null;

    if (_app.shuffleOrder.isEmpty || _app.shuffleOrder.length != total) {
      initializeShuffle(currentIndex: _app.currentIndex ?? 0);
    } else if (_app.shufflePointer < 0 || _app.shufflePointer >= _app.shuffleOrder.length) {
      final cur = _app.currentIndex ?? 0;
      _app.shufflePointer = _app.shuffleOrder.indexOf(cur);
      if (_app.shufflePointer < 0) _app.shufflePointer = 0;
    }

    // Если остался только 1 трек
    if (_app.shuffleOrder.length == 1) return _app.shuffleOrder[0];

    int targetPointer = _app.shufflePointer + 1;
    if (targetPointer >= _app.shuffleOrder.length) {
      // Новый цикл — перемешиваем снова!
      initializeShuffle(currentIndex: _app.currentIndex ?? 0);
      targetPointer = _app.shufflePointer + 1;
      if (targetPointer >= _app.shuffleOrder.length) {
        return null;
      }
    }

    _app.shufflePointer = targetPointer;
    final next = _app.shuffleOrder[_app.shufflePointer];

    // === Новое: пушим в историю ===
    if (shuffleHistory.isEmpty || shuffleHistory.last != next) {
      shuffleHistory.add(next);
    }

    _app.playedIndices.add(next);
    return next;
  }


  int? getPreviousShuffleIndex() {
    final playlist = _app.currentPlaylist;
    if (playlist.isEmpty) return null;

    // Если shuffleOrder некорректен — переинициализируем
    if (_app.shuffleOrder.isEmpty || _app.shuffleOrder.length != playlist.length) {
      initializeShuffle(currentIndex: _app.currentIndex ?? 0);
    }

    // Если только один трек
    if (_app.shuffleOrder.length == 1) return _app.shuffleOrder[0];

    // Если есть история — просто шагаем назад по ней
    if (shuffleHistory.length > 1) {
      shuffleHistory.removeLast();
      final prev = shuffleHistory.last;
      _app.shufflePointer = _app.shuffleOrder.indexOf(prev);
      return prev;
    }

    // Если дошли до начала истории — переходим к предыдущему элементу в shuffleOrder
    int pointer = _app.shufflePointer - 1;
    if (pointer < 0) {
      pointer = _app.shuffleOrder.length - 1; // зацикливаем в начало
    }

    _app.shufflePointer = pointer;
    final prev = _app.shuffleOrder[pointer];

    // Обновляем историю (теперь в начале истории — prev)
    shuffleHistory
      ..clear()
      ..add(prev);

    return prev;
  }




  Future<void> fillDurationsForManualPlaylist(
      Future<int?> Function(String uri) getDurationMs) async {
    for (int i = 0; i < manualPlaylist.length; i++) {
      final track = manualPlaylist[i];
      if (track.duration == null) {
        final durationMs = await getDurationMs(track.uri);
        if (durationMs != null) {
          // Обновляем объект — в Dart лучше создать новый с duration!
          manualPlaylist[i] = ManualTrackEntry(
            uri: track.uri,
            name: track.name,
            duration: Duration(milliseconds: durationMs),
          );
          notifyListeners();
        }
      }
    }
  }


  Future<void> addSafFiles(List<ManualTrackEntry> entries) async {
    print('[DEBUG:PlaylistModel] addSafFiles entries: ${entries.map((e) => e.uri).toList()}');
    final newTracks = <ManualTrackEntry>[];
    for (final entry in entries) {
      if (!manualPlaylist.any((t) => t.uri == entry.uri)) {
        newTracks.add(entry);
      }
    }
    print('[DEBUG:PlaylistModel] newTracks для добавления: ${newTracks.map((e) => e.uri).toList()}');
    if (newTracks.isEmpty) {
      print('[DEBUG:PlaylistModel] Нет новых треков для добавления');
      return;
    }

    manualPlaylist.addAll(newTracks);

    print('[DEBUG:PlaylistModel] manualPlaylist после добавления: ${manualPlaylist.map((e) => e.uri).toList()}');

    await saveTrackPaths();
    _app.setCurrentPlaylistSource(PlaylistSource.manual);
    notifyListeners();
  }

  Future<void> saveTrackPaths() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = manualPlaylist.map((e) => e.toJson()).toList();
    await prefs.setString('track_paths', jsonEncode(jsonList));
  }


  Future<void> addFiles(List<String> files) async {
    final newTracks = <ManualTrackEntry>[];
    for (final path in files) {
      if (!manualPlaylist.any((t) => t.uri == path)) {
        newTracks.add(ManualTrackEntry(uri: path, name: p.basename(path)));
      }
    }
    if (newTracks.isEmpty) return;
    manualPlaylist.addAll(newTracks);
    await saveTrackPaths();
    initializeShuffle(currentIndex: _app.currentIndex ?? 0);
    notifyListeners();
  }






  void selectNextTrack({bool autoplay = true}) {
    final list = _app.currentPlaylist;
    if (list.isEmpty) {
      print('[NEXT] ❌ Плейлист пуст — невозможно выбрать следующий трек');
      return;
    }

    final ix = _app.currentIndex;
    if (ix == null) return;

    int nextIndex;

    if (_app.playbackMode == PlaybackMode.shuffle) {
      // Простейший shuffle: новый индекс может совпасть с текущим, если только один трек.
      if (list.length == 1) {
        nextIndex = 0;
      } else {
        do {
          nextIndex = Random().nextInt(list.length);
        } while (nextIndex == ix);
      }
    } else {
      nextIndex = (ix + 1) % list.length;
    }

    print('[NEXT] Переключаюсь на трек $nextIndex: ${list[nextIndex]}');
    _app.currentIndex = nextIndex;
    notifyListeners();

    if (autoplay) {
      _app.playbackModel.playTrackAt(nextIndex, autoplay: true);
    }
  }


  Future<void> removeTrack(int index) async {
    if (index >= 0 && index < manualPlaylist.length) {
      manualPlaylist.removeAt(index);
      await saveTrackPaths();
      initializeShuffle(currentIndex: _app.currentIndex ?? 0);
      notifyListeners();
    }
  }





  void clearManualPlaylist() {
    manualPlaylist.clear();
    saveTrackPaths(); // если нужно сохранять/загружать список
    initializeShuffle(currentIndex: _app.currentIndex ?? 0);
    notifyListeners();
  }





  Future<void> loadManualPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('track_paths');
    if (saved != null) {
      final list = (jsonDecode(saved) as List)
          .map((e) => ManualTrackEntry.fromJson(e))
          .toList();
      manualPlaylist = list;
      initializeShuffle(currentIndex: _app.currentIndex ?? 0);
    }
    notifyListeners();
  }




  Future<void> reorderTracks(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    final item = manualPlaylist.removeAt(oldIndex);
    manualPlaylist.insert(newIndex, item);
    await saveTrackPaths();
    notifyListeners();
  }

  Future<void> loadFolderPlaylist() async {
    final folderPath = _app.persistentState.lastUsedFolderPath;

    if (folderPath == null || folderPath.isEmpty) {
      print('[loadFolderPlaylist] ❌ Путь к папке не задан');
      return;
    }

    print('[loadFolderPlaylist] 📂 Путь к папке: $folderPath');

    final dir = Directory(folderPath);
    final exists = await dir.exists();

    if (!exists) {
      print('[loadFolderPlaylist] ❌ Папка не существует: $folderPath');
      return;
    }

    final entries = await dir.list().toList();
    final audioFiles = entries
        .whereType<File>()
        .where((e) => _isAudioFile(e.path))
        .map((e) => e.path)
        .toList()
      ..sort(); // <-- сортируем, чтобы всегда был одинаковый порядок

    if (audioFiles.isEmpty) {
      print('[loadFolderPlaylist] ❌ Нет аудиофайлов в папке: $folderPath');
      return;
    }

    print('[loadFolderPlaylist] ✅ Найдено аудиофайлов: ${audioFiles.length}');

    // Просто сохраняем список файлов
    _app.folderPlaylist = audioFiles;

    initializeShuffle(currentIndex: _app.currentIndex ?? 0);

    // Сохраняем только путь к папке, но НЕ трек, НЕ индекс, НЕ инициализируем плеер!
    _app.persistentState.lastUsedFolderPath = folderPath;
    await _app.persistentState.save();
  }




  bool _isAudioFile(String path) {
    final ext = p.extension(path).toLowerCase();
    return ['.mp3', '.wav', '.m4a', '.aac', '.ogg', '.flac'].contains(ext);
  }





  Future<void> onManualTrackSelected(int index) async {
    print('[UI] 👆 Тап по треку из ручного плейлиста: $index');
    _app.setCurrentPlaylistSource(PlaylistSource.manual);
    await _app.playbackModel.playTrackAt(index, autoplay: true);
  }

  Future<void> onFolderTrackSelected(int index) async {
    print('[UI] 👆 Тап по треку из папки: $index');
    _app.setCurrentPlaylistSource(PlaylistSource.folder);
    await _app.playbackModel.playTrackAt(index, autoplay: true);
  }




  Future<void> stopIfPlayingDeletedTrack(String deletedPath) async {
    if (_app.originalTrackPath == null) return;

    final deletedName = p.basename(deletedPath);
    final currentName = p.basename(_app.originalTrackPath!);

    if (deletedName == currentName) {
      print('⏹ Удалённый трек был активным — останавливаю плеер и сбрасываю состояние.');

      await _app.player.stop();
      // Не нужно setAudioSource с пустым плейлистом — достаточно остановить плеер!

      _app.currentTrackPath = null;
      _app.originalTrackPath = null;
      _app.position = Duration.zero;
      _app.duration = Duration.zero;
      _app.pcmLevels.clear();
      _app.currentPcmLevel = 0.0;

      notifyListeners();
    }
  }










}
