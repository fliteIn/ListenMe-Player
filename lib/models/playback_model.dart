import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../utils/jump_to_silence.dart';
import '../utils/saf.dart';
import '../enums/enums.dart';
import 'app_model.dart';
import 'dart:io' show Platform;

import 'package:shared_preferences/shared_preferences.dart';

class PlaybackModel extends ChangeNotifier {
  //------------------------------------------Field-------------------------------
  late AppModel _app;

  String? get currentTrack {
    final ix = _app.currentIndex;
    final list = _app.currentPlaylist;
    if (ix != null && ix >= 0 && ix < list.length) {
      return list[ix];
    }
    return null;
  }

  bool _handlingIndexChange = false;

  bool _zoneSeekingForward = true;

  Timer? _zoneSeekTimer;
  double _zoneSeekSpeed = 0.0;

  bool _wasZoneSeeking = false;

  bool _wasPlayingBeforeSeek = false;

  void setAppModel(AppModel app) {
    _app = app;
  }

  //  PlaybackMode? _previousPlaybackMode;
  //  PlaybackMode _lastSegmentPlaybackMode = PlaybackMode.singleOnce;

  //  bool _playBetweenMarkers = false;

  //------------------------------------------Field End---------------------------

  void setPlaybackMode(PlaybackMode mode) {
    _app.setPlaybackMode(mode);
  }

  void setUserSelectedPlaybackMode(PlaybackMode mode) {
    if (_app.playBetweenMarkers) {
      _app.lastSegmentPlaybackMode = mode;
    }
    setPlaybackMode(mode); // вызовет _app.setPlaybackMode(mode) + notify
  }

  Future<void> playTrackAt(int index, {bool autoplay = false}) async {
    final list = _app.currentPlaylist;
    if (index < 0 || index >= list.length) {
      print(
        '[DEBUG][playTrackAt] index $index is out of range for list of length ${list.length}',
      );
      return;
    }

    print('[DEBUG][playTrackAt] ====== START ======');
    print('[DEBUG][playTrackAt] index=$index autoplay=$autoplay');

    try {
      await _app.player.stop();
      await _app.player.setLoopMode(LoopMode.off);

      final path = list[index];
      print('[DEBUG][playTrackAt] SetAudioSource: $path');

      // ✅ Если это SAF content:// — копируем во временный файл
      String playablePath = path;
      if (playablePath.startsWith('content://')) {
        print(
          '[DEBUG][playTrackAt] SAF URI detected — copying to temp file via MethodChannel',
        );

        // === Проверка места в кэше перед копированием SAF ===
        const estimatedAudioCopySize =
            20 * 1024 * 1024; // примерно 20 MB на файл
        final enoughSpace = await _app.ensureCacheSpace(
          estimatedAudioCopySize,
          asyncCleanup: true,
        );
        if (!enoughSpace) {
          print('[CACHE] 🚫 Недостаточно места для копирования SAF-файла.');
          /*
          if (_app.contextMounted) {
            ScaffoldMessenger.of(_app.context!).showSnackBar(
              const SnackBar(content: Text('Недостаточно места в кэше для воспроизведения файла.')),
            );
          }*/
          return;
        }

        final tempPath = await SAF.copySafUriToTempFile(playablePath);
        if (tempPath == null) {
          print(
            '[DEBUG][playTrackAt][ERROR] Failed to copy SAF URI to temp file',
          );
          return;
        }
        playablePath = tempPath;
        print(
          '[DEBUG][playTrackAt] Copied SAF URI to temp path: $playablePath',
        );
      }

      final uri = Uri.file(playablePath);

      await _app.player.setAudioSource(AudioSource.uri(uri), preload: true);

      // Ожидаем установку длительности (до 500 мс максимум)
      Duration? duration;
      for (int i = 0; i < 10; i++) {
        duration = _app.player.duration;
        if (duration != null) break;
        await Future.delayed(const Duration(milliseconds: 50));
      }

      _app.duration = duration ?? Duration.zero;
      print('[DEBUG][playTrackAt] duration: ${_app.duration}');

      // --- ВСЕГДА ОБНОВЛЯЙ И СОХРАНЯЙ! ---
      _app.currentIndex = index;
      _app.lastExplicitTrackSwitch = index;
      await _app.updateCurrentTrackData(index, path);

      _app.persistentState.currentIndex = index;
      _app.persistentState.currentTrackPath = path;

      await _app.persistentState.save();

      // Устанавливаем позицию в 0 вручную
      await _app.withManualSeek(() async {
        await _app.player.seek(Duration.zero);
      });
      _app.positionVN.value = Duration.zero;

      if (autoplay) {
        print('[DEBUG][playTrackAt] CALL player.play()');
        await _app.player.play();
        print('[DEBUG][playTrackAt] player.play() выполнен');
      } else {
        print('[DEBUG][playTrackAt] CALL player.pause()');
        await _app.player.pause();
        print('[DEBUG][playTrackAt] player.pause() выполнен');
      }

      _app.startPositionPolling();

      print('[DEBUG][playTrackAt] playerState=${_app.player.playerState}');
    } catch (e, st) {
      print('[DEBUG][playTrackAt][ERROR] $e\n$st');
    }

    notifyListeners();
    print('[DEBUG][playTrackAt] ====== END ======');
  }





  void togglePlayBetweenMarkers() {
    final before = _app.playBetweenMarkers;
    _app.playBetweenMarkers = !before;

    // Если значение не изменилось — маркеры невалидны, ничего не делаем
    if (_app.playBetweenMarkers == before) {
      return;
    }

    if (_app.playBetweenMarkers) {
      // Сохраняем режим до включения маркеров
      _app.previousPlaybackMode = _app.playbackMode;

      // Восстанавливаем последний режим для сегмента (singleOnce/singleLoop)
      final lastMode = _app.lastSegmentPlaybackMode;
      if (lastMode == PlaybackMode.singleOnce ||
          lastMode == PlaybackMode.singleLoop) {
        setPlaybackMode(lastMode);
      } else {
        // Если вдруг он другой — ставим singleOnce по умолчанию
        setPlaybackMode(PlaybackMode.singleOnce);
      }
    } else {
      // Сохраняем последний режим для сегмента
      _app.lastSegmentPlaybackMode = _app.playbackMode;

      // Восстанавливаем предыдущий режим (до маркеров), если был
      if (_app.previousPlaybackMode != null) {
        setPlaybackMode(_app.previousPlaybackMode!);
      }
    }

    notifyListeners();
  }

  void rememberSegmentPlaybackMode() {
    if (_app.playbackMode == PlaybackMode.singleOnce ||
        _app.playbackMode == PlaybackMode.singleLoop) {
      _app.lastSegmentPlaybackMode = _app.playbackMode;
    }
  }

  void cyclePlaybackMode() {
    final availableModes = _app.playBetweenMarkers
        ? [PlaybackMode.singleOnce, PlaybackMode.singleLoop]
        : PlaybackMode.values;

    final currentMode = _app.playbackMode;
    final currentIndex = availableModes.indexOf(currentMode);
    final nextMode = availableModes[(currentIndex + 1) % availableModes.length];

    _app.setPlaybackMode(nextMode);

    if (_app.playBetweenMarkers) {
      _app.lastSegmentPlaybackMode = nextMode;
    }
  }

  Future<void> playlistPrevious() async {
    final currentPlaylist = _app.currentPlaylist;
    if (currentPlaylist.length < 2) return;

    final ix = _app.currentIndex;
    if (ix == null) return;

    int prevIndex = ix - 1;
    if (prevIndex < 0) {
      // loop: prevIndex = currentPlaylist.length - 1;
      return;
    }
    final wasPlaying = _app.player.playing;
    await playTrackAt(prevIndex, autoplay: wasPlaying);
  }

  Future<void> playlistNext() async {
    final currentPlaylist = _app.currentPlaylist;
    if (currentPlaylist.isEmpty) return;

    final ix = _app.currentIndex;
    if (ix == null) return;

    int? nextIndex;

    // Режим SHUFFLE — отдельная логика!
    if (_app.playbackMode == PlaybackMode.shuffle) {
      nextIndex = _app.playlist.getNextShuffleIndex();
      if (nextIndex == null) {
        // Все проиграны — стоп
        await _app.player.pause();
        return;
      }
    } else {
      // Обычные режимы
      if (ix + 1 >= currentPlaylist.length) {
        if (_app.playbackMode == PlaybackMode.playlistLoop) {
          nextIndex = 0; // По кругу на первый трек
        } else {
          // playlistOnce — просто стоп, не переключаемся
          await _app.player.pause();
          return;
        }
      } else {
        nextIndex = ix + 1;
      }
    }

    // Был ли playing до этого? Обычно нужно всегда autoplay:true!
    await playTrackAt(nextIndex!, autoplay: true);
  }

  // ───────────────── tickZoneSeek ─────────────────
  // Плавно смещаем ТОЛЬКО UI (app.position) без реального seek()
  void tickZoneSeek() {
    final pos = _app.latestSeekTouch;
    final h = _app.latestSeekHeight;
    if (pos == null || h == null || h <= 0) return;

    // Нормируем вертикаль: 0.0 внизу, 1.0 вверху
    double t = 1.0 - (pos.dy / h);
    if (t.isNaN) return;
    t = t.clamp(0.0, 1.0);

    // Берём скорость из настроек (мс/сек) и интерполируем от min к max
    final int minMsPerSec = _app.minJogSkipSpeedMsPerSec; // напр. 50
    final int maxMsPerSec = _app.maxJogSkipSpeedMsPerSec; // напр. 60000
    final double msPerSec = minMsPerSec + (maxMsPerSec - minMsPerSec) * t;

    // Сколько миллисекунд добавлять за один тик (33 мс)
    const tick = 33; // мс
    final int deltaMsMagnitude = (msPerSec * (tick / 1000.0)).round();

    // Направление: правая кнопка (forward=true) — только вперёд, левая — назад
    final int signedDeltaMs = _zoneSeekingForward
        ? deltaMsMagnitude
        : -deltaMsMagnitude;

    final Duration curr = _app.position;
    final Duration total = _app.duration ?? Duration.zero;

    Duration next = curr + Duration(milliseconds: signedDeltaMs);

    // Ограничиваем перемотку по маркерам если активен playBetweenMarkers и маркеры не совпадают
    if (_app.playBetweenMarkers && _app.markerA != _app.markerB) {
      final leftMarker = _app.markerA < _app.markerB
          ? _app.markerA
          : _app.markerB;
      final rightMarker = _app.markerA > _app.markerB
          ? _app.markerA
          : _app.markerB;

      if (next < leftMarker) next = leftMarker;
      if (next > rightMarker) next = rightMarker;
    } else {
      if (next < Duration.zero) next = Duration.zero;
      if (total > Duration.zero && next > total) next = total;
    }

    // Обновляем ТОЛЬКО UI: время, прогресс, джог
    _app.position = next;

    // если у PlaybackModel есть слушатели — оповестим
    notifyListeners();
  }

  Future<void> handlePrevious() async {
    final player = _app.player;

    // 1. Если активен режим по маркерам
    if (_app.playBetweenMarkers && _app.markerA != _app.markerB) {
      final leftMarker = _app.markerA < _app.markerB
          ? _app.markerA
          : _app.markerB;
      await player.seek(leftMarker);
      if (!player.playing) await player.pause();
      return;
    }

    // 2. Обычные режимы
    switch (_app.playbackMode) {
      case PlaybackMode.singleOnce:
      case PlaybackMode.singleLoop:
        await player.seek(Duration.zero);
        if (!player.playing) await player.pause();
        break;

      case PlaybackMode.playlistOnce:
        if (_app.currentIndex != null) {
          if (_app.currentIndex! > 0) {
            await playTrackAt(_app.currentIndex! - 1, autoplay: player.playing);
          } else {
            // первый трек — просто в начало
            await player.seek(Duration.zero);
            if (!player.playing) await player.pause();
          }
        }
        break;

      case PlaybackMode.playlistLoop:
        if (_app.currentIndex != null) {
          final ix = _app.currentIndex!;
          final list = _app.currentPlaylist;
          final prevIx = (ix - 1 + list.length) % list.length;
          await playTrackAt(prevIx, autoplay: player.playing);
        }
        break;

      case PlaybackMode.shuffle:
        final prevIx = _app.playlist.getPreviousShuffleIndex();
        if (prevIx != null) {
          await playTrackAt(prevIx, autoplay: player.playing);
        } else {
          final nextIx = _app.playlist.getNextShuffleIndex();
          if (nextIx != null) {
            await playTrackAt(nextIx, autoplay: player.playing);
          } else {
            await player.pause();
          }
        }
        break;
    }
  }

  Future<void> handleNext() async {
    final player = _app.player;

    // 1. Если активен режим по маркерам — ВСЕГДА: seek к правому и pause
    if (_app.playBetweenMarkers && _app.markerA != _app.markerB) {
      final leftMarker = _app.markerA < _app.markerB
          ? _app.markerA
          : _app.markerB;
      final rightMarker = _app.markerA > _app.markerB
          ? _app.markerA
          : _app.markerB;

      await player.seek(rightMarker);
      await player.pause();
      // Не запускаем play даже для singleLoop!
      return;
    }

    // 2. Обычные режимы
    switch (_app.playbackMode) {
      case PlaybackMode.singleOnce:
        await player.seek(_app.duration);
        await player.pause();
        break;

      case PlaybackMode.singleLoop:
        if (player.playing) {
          await player.seek(Duration.zero);
          await player.play();
        } else {
          await player.seek(_app.duration);
          await player.pause();
        }
        break;

      case PlaybackMode.playlistOnce:
        if (_app.currentIndex != null &&
            _app.currentIndex! + 1 < _app.currentPlaylist.length) {
          await playTrackAt(_app.currentIndex! + 1, autoplay: player.playing);
        } else {
          await player.pause();
        }
        break;

      case PlaybackMode.playlistLoop:
        if (_app.currentIndex != null) {
          final ix = _app.currentIndex!;
          final list = _app.currentPlaylist;
          final nextIx = (ix + 1) % list.length;
          await playTrackAt(nextIx, autoplay: player.playing);
        }
        break;

      case PlaybackMode.shuffle:
        // Попытка взять следующий трек по shuffle
        var nextIx = _app.playlist.getNextShuffleIndex();
        if (nextIx != null) {
          await playTrackAt(nextIx, autoplay: player.playing);
        } else {
          // Если не получилось — возможно, список был обновлён или цикл закончен.
          // Пробуем переинициализировать shuffle (новый цикл)
          _app.playlist.initializeShuffle(currentIndex: _app.currentIndex ?? 0);
          nextIx = _app.playlist.getNextShuffleIndex();
          if (nextIx != null) {
            await playTrackAt(nextIx, autoplay: player.playing);
          } else {
            // Если всё равно ничего — пауза
            await player.pause();
          }
        }
        break;
    }
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  Future<void> handlePlayPause() async {
    final list = _app.currentPlaylist;
    final ix = _app.currentIndex;
    final player = _app.player;

    // --- Проверка на валидность индекса и списка ---
    if (list.isEmpty || ix == null || ix < 0 || ix >= list.length) {
      print(
        '[LOG][PlaybackModel] Play запрещён: плейлист пуст или некорректный индекс',
      );
      _app.position = Duration.zero; // Сброс позиции на 0 для UI
      _app.isPlaying = false;
      notifyListeners();
      return;
    }

    print('[LOG][PlaybackModel] handlePlayPause: isPlaying=${_app.isPlaying}');

    // --- Если сейчас воспроизводится, просто ставим на паузу ---
    if (_app.isPlaying) {
      await player.pause();
      print('[LOG][PlaybackModel] pause() called');
    } else {
      final position = _app.position;
      final duration = _app.duration ?? Duration.zero;

      // --- Проверка: если playhead в конце трека ---
      final bool atEnd =
          duration > Duration.zero &&
          (position >= duration - const Duration(milliseconds: 200));

      if (atEnd && !player.playing) {
        print(
          '[LOG][PlaybackModel] handlePlayPause → playhead at end, simulate track end',
        );
        await handleTrackOrSegmentEnd();
        return;
      }

      // --- Проверка для режима воспроизведения между маркерами ---
      if (_app.playBetweenMarkers && _app.markerA != _app.markerB) {
        final a = _app.markerA.inMilliseconds;
        final b = _app.markerB.inMilliseconds;
        final leftMarker = Duration(milliseconds: a < b ? a : b);
        final rightMarker = Duration(milliseconds: a > b ? a : b);

        // Если находимся на правом маркере
        final atRightMarker =
            (_app.position >= rightMarker - const Duration(milliseconds: 50));

        if (atRightMarker) {
          if (_app.playbackMode == PlaybackMode.singleOnce) {
            print(
              '[LOG][PlaybackModel] Воспроизведение запрещено: playhead на правом маркере (singleOnce)',
            );
            return;
          } else if (_app.playbackMode == PlaybackMode.singleLoop) {
            print(
              '[LOG][PlaybackModel] На правом маркере (singleLoop) — возвращаемся к левому маркеру',
            );
            await _app.player.seek(leftMarker);
            await _app.player.play();
            return;
          }
        }

        // Если позиция вне диапазона — не начинаем воспроизведение
        if (_app.position < leftMarker || _app.position >= rightMarker) {
          print(
            '[LOG][PlaybackModel] Play запрещён: position=${_app.position}, range=[$leftMarker, $rightMarker)',
          );
          return;
        }
      }

      await player.play();
      print('[LOG][PlaybackModel] play() called');
    }

    notifyListeners();
    print('[LOG][PlaybackModel] notifyListeners() called');
  }

  /// Этот метод нужно вызывать на событие окончания трека ИЛИ отрезка
  Future<void> handleTrackOrSegmentEnd() async {
    print(
      '[DEBUG][handleTrackOrSegmentEnd] ENTERED | hashCode: ${this.hashCode} | DateTime: ${DateTime.now().toIso8601String()}',
    );
    print(
      '[DEBUG][handleTrackOrSegmentEnd] playBetweenMarkers: ${_app.playBetweenMarkers}',
    );
    print(
      '[DEBUG][handleTrackOrSegmentEnd] markerA: ${_app.markerA}, markerB: ${_app.markerB}',
    );
    print(
      '[DEBUG][handleTrackOrSegmentEnd] playbackMode: ${_app.playbackMode}',
    );
    print(
      '[DEBUG][handleTrackOrSegmentEnd] currentIndex: ${_app.currentIndex} | playlist.length: ${_app.currentPlaylist.length}',
    );

    final markerA = _app.markerA;
    final markerB = _app.markerB;
    final leftMarker = markerA < markerB ? markerA : markerB;
    final rightMarker = markerA > markerB ? markerA : markerB;

    // 1. Воспроизведение отрезка между маркерами
    if (_app.playBetweenMarkers && markerA != markerB) {
      if (_app.playbackMode == PlaybackMode.singleLoop) {
        if (_app.player.playing) {
          // Только если ВОСПРОИЗВЕДЕНИЕ реально идёт — циклить
          await _app.player.seek(leftMarker);
          await _app.player.play();
        } else {
          // Если paused — остаться на правом маркере, ничего не делать
          print(
            '[DEBUG][handleTrackOrSegmentEnd] paused, remain at right marker',
          );
        }
      } else {
        // Любой другой режим — просто пауза
        await _app.player.pause();
      }
      print(
        '[DEBUG][handleTrackOrSegmentEnd] [hashCode: ${this.hashCode}] EXIT (segment)',
      );
      return;
    }

    // 2. Обычные режимы
    switch (_app.playbackMode) {
      case PlaybackMode.singleOnce:
        print(
          '[DEBUG][handleTrackOrSegmentEnd] [hashCode: ${this.hashCode}] MODE: singleOnce — just pause',
        );
        await _app.player.pause();
        break;

      case PlaybackMode.singleLoop:
        print(
          '[DEBUG][handleTrackOrSegmentEnd] [hashCode: ${this.hashCode}] MODE: singleLoop — seek to 0 & play',
        );
        await _app.player.seek(Duration.zero);
        await _app.player.play();
        break;

      case PlaybackMode.playlistOnce:
        {
          final ix = _app.currentIndex;
          final list = _app.currentPlaylist;
          if (ix != null && ix + 1 < list.length) {
            print(
              '[DEBUG][handleTrackOrSegmentEnd] [hashCode: ${this.hashCode}] MODE: playlistOnce — move to next track',
            );
            await playTrackAt(ix + 1, autoplay: true);
          } else {
            print(
              '[DEBUG][handleTrackOrSegmentEnd] [hashCode: ${this.hashCode}] MODE: playlistOnce — last track, pause',
            );
            await _app.player.pause();
          }
        }
        break;

      case PlaybackMode.playlistLoop:
        {
          final ix = _app.currentIndex;
          final list = _app.currentPlaylist;
          if (ix != null && list.isNotEmpty) {
            int nextIx = (ix + 1) % list.length;
            print(
              '[DEBUG][handleTrackOrSegmentEnd] [hashCode: ${this.hashCode}] MODE: playlistLoop — next or loop',
            );
            await playTrackAt(nextIx, autoplay: true);
          }
        }
        break;

      case PlaybackMode.shuffle:
        {
          print(
            '[DEBUG][handleTrackOrSegmentEnd] [hashCode: ${this.hashCode}] MODE: shuffle — start',
          );
          final nextIx = _app.playlist.getNextShuffleIndex();

          if (nextIx != null) {
            print(
              '[DEBUG][handleTrackOrSegmentEnd] [hashCode: ${this.hashCode}] MODE: shuffle — next shuffle track: $nextIx',
            );
            await playTrackAt(nextIx, autoplay: true);
          } else {
            print(
              '[DEBUG][handleTrackOrSegmentEnd] [hashCode: ${this.hashCode}] MODE: shuffle — all tracks played, reinitialize shuffle',
            );
            final current = _app.currentIndex;
            if (current != null) {
              _app.playlist.initializeShuffle(currentIndex: current);
              final newIx = _app.playlist.getNextShuffleIndex();
              if (newIx != null) {
                print(
                  '[DEBUG][handleTrackOrSegmentEnd] [hashCode: ${this.hashCode}] MODE: shuffle — restarting shuffle at: $newIx',
                );
                await playTrackAt(newIx, autoplay: true);
              } else {
                print(
                  '[DEBUG][handleTrackOrSegmentEnd] [hashCode: ${this.hashCode}] MODE: shuffle — still null after reinit, pause',
                );
                await _app.player.pause();
              }
            } else {
              print(
                '[DEBUG][handleTrackOrSegmentEnd] [hashCode: ${this.hashCode}] MODE: shuffle — no currentIndex, pause',
              );
              await _app.player.pause();
            }
          }
        }
        break;
    }

    print(
      '[DEBUG][handleTrackOrSegmentEnd] [hashCode: ${this.hashCode}] EXIT\n',
    );
  }

  void handleSeekStart() {
    if (_app.isSeeking) return;

    _app.wasPlayingBeforeSeek = _app.isPlaying;
    _app.isSeeking = true;

    if (_app.wasPlayingBeforeSeek) {
      _app.player.pause();
    }
  }

  void handleSeekEnd() {
    if (_app.wasPlayingBeforeSeek) {
      _app.player.play();
    }

    _app.isSeeking = false;
  }

  void seekRelative(Duration delta) {
    final newPosition = _app.position + delta;

    Duration minPos = Duration.zero;
    Duration maxPos = _app.duration;

    if (_app.playBetweenMarkers) {
      minPos = Duration(
        milliseconds: min(
          _app.markerA.inMilliseconds,
          _app.markerB.inMilliseconds,
        ),
      );
      maxPos = Duration(
        milliseconds: max(
          _app.markerA.inMilliseconds,
          _app.markerB.inMilliseconds,
        ),
      );
    }

    final clampedMs = newPosition.inMilliseconds.clamp(
      minPos.inMilliseconds,
      maxPos.inMilliseconds,
    );
    final clamped = Duration(milliseconds: clampedMs);

    _app.player.seek(clamped);
  }

  void handleKnobTouchStart() {
    print('🟡 handleKnobTouchStart — ${hashCode}');
    if (_app.player.playing) {
      print('⏸ Плеер воспроизводит, ставим на паузу');
      _app.wasPlayingBeforeKnob = true;
      _app.player.pause();
    } else {
      print('▶️ Плеер уже на паузе');
      _app.wasPlayingBeforeKnob = false;
    }
  }

  void handleKnobTouchEnd() {
    print('🟢 handleKnobTouchEnd');
    if (_app.wasPlayingBeforeKnob) {
      print('▶️ Возобновляем воспроизведение');
      _app.player.play();
    } else {
      print('⏸ Оставляем на паузе');
    }
  }

  void changeSpeed(double speed) {
    _app.playbackSpeed = speed;
    _app.player.setSpeed(speed);
    notifyListeners();
  }

  void jumpToPrevSilencefromWidget() {
    final minBound = _app.playBetweenMarkers
        ? Duration(
            milliseconds: min(
              _app.markerA.inMilliseconds,
              _app.markerB.inMilliseconds,
            ),
          )
        : Duration.zero;
    debugPrint('[JUMP] jumpToPrevSilencefromWidget:');
    debugPrint('  position: ${_app.position}');
    debugPrint('  minBound: $minBound');
    debugPrint('  silenceMarkers: ${_app.silences}');
    debugPrint('  playBetweenMarkers: ${_app.playBetweenMarkers}');
    debugPrint('  markerA: ${_app.markerA}, markerB: ${_app.markerB}');
    _app.manualSeek = true;
    jumpToPrevSilence(
      player: _app.player,
      position: _app.position,
      silenceMarkers: _app.silences,
      minBound: minBound,
    );
  }

  void jumpToNextSilencefromWidget() {
    final maxBound = _app.playBetweenMarkers
        ? Duration(
            milliseconds: max(
              _app.markerA.inMilliseconds,
              _app.markerB.inMilliseconds,
            ),
          )
        : _app.duration;
    debugPrint('[JUMP] jumpToNextSilencefromWidget:');
    debugPrint('  position: ${_app.position}');
    debugPrint('  maxBound: $maxBound');
    debugPrint('  silenceMarkers: ${_app.silences}');
    debugPrint('  playBetweenMarkers: ${_app.playBetweenMarkers}');
    debugPrint('  markerA: ${_app.markerA}, markerB: ${_app.markerB}');
    _app.manualSeek = true;
    jumpToNextSilence(
      player: _app.player,
      position: _app.position,
      silenceMarkers: _app.silences,
      maxBound: maxBound,
    );
  }

  // ───────────────── startZoneSeek ─────────────────
  void startZoneSeek(Offset localPosition, double height, bool forward) {
    _zoneSeekingForward = forward;
    _app.latestSeekTouch = localPosition;
    _app.latestSeekHeight = height;

    _wasZoneSeeking = true;

    // если таймер уже был — остановим
    stopZoneSeek();

    // 30 FPS для плавного обновления UI
    _zoneSeekTimer = Timer.periodic(
      const Duration(milliseconds: 33),
      (_) => tickZoneSeek(),
    );
  }

  // ───────────────── updateZoneSeekSpeed ─────────────────
  void updateZoneSeekSpeed(Offset localPosition, double height) {
    _app.latestSeekTouch = localPosition;
    _app.latestSeekHeight = height;
    // скорость читаем в tickZoneSeek() из последних координат
  }

  // ───────────────── stopZoneSeek ─────────────────
  // Останавливаем таймер и делаем один реальный seek() на текущую UI-позицию
  void stopZoneSeek() {
    _zoneSeekTimer?.cancel();
    _zoneSeekTimer = null;

    if (!_wasZoneSeeking) return; // <== важно!

    _wasZoneSeeking = false;

    Duration target = _app.position;

    // Ограничиваем позицию по маркерам, если включён режим playBetweenMarkers
    if (_app.playBetweenMarkers && _app.markerA != _app.markerB) {
      final leftMarker = _app.markerA < _app.markerB
          ? _app.markerA
          : _app.markerB;
      final rightMarker = _app.markerA > _app.markerB
          ? _app.markerA
          : _app.markerB;

      if (target < leftMarker) target = leftMarker;
      if (target > rightMarker) target = rightMarker;
    }

    _app.withManualSeek(() async {
      await _app.player.seek(target);
    });
  }
}
