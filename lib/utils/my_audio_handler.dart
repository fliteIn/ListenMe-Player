import 'package:audio_service/audio_service.dart';

import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import '../models/app_model.dart'; // здесь твой PlaybackModel внутри AppModel
import '../models/playback_model.dart';


class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AppModel _app;
  final AudioPlayer _player;

  MyAudioHandler(this._app) : _player = _app.player {
    _notifyPlaybackState();
    _listenToPlayerEvents();
  }


  AudioProcessingState _transformProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }



  void _notifyPlaybackState() {
    final isPlaying = _player.playing;

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.rewind,         // index 0
        MediaControl.skipToPrevious, // index 1
        isPlaying ? MediaControl.pause : MediaControl.play, // index 2
        MediaControl.skipToNext,     // index 3
        MediaControl.fastForward,    // index 4
      ],
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: [1, 2, 3], // skipToPrevious, play/pause, skipToNext
      playing: isPlaying,
      processingState: _transformProcessingState(_player.processingState),
      updatePosition: _player.position,
    ));
  }



  Future<void> setMediaItem({
    required String title,
    Duration? duration,
  }) async {
    final item = MediaItem(
      id: 'track_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      duration: duration ?? Duration.zero,
     //artUri: Uri.parse('asset://assets/splash_fullscreen.png'), // 👈 используем icon.png
    );

    mediaItem.add(item);
  }


  void _listenToPlayerEvents() {
// --- синхронизация состояния воспроизведения ---
    _player.playingStream.listen((isPlaying) {
      _app.isPlaying = isPlaying;  // 🔄 обновляем AppModel
      _notifyPlaybackState();      // 🔁 синхронизируем UI и системный плейбек
    });

    _player.positionStream.listen((position) {
      final state = playbackState.value;
      playbackState.add(
        state.copyWith(
          updatePosition: position,
          bufferedPosition: _player.bufferedPosition,
          playing: _player.playing,
          controls: [
            MediaControl.rewind,
            MediaControl.skipToPrevious,
            _player.playing ? MediaControl.pause : MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.fastForward,
          ],
          androidCompactActionIndices: [1, 2, 3],
          processingState: _transformProcessingState(_player.processingState),
        ),
      );
    });



    _player.durationStream.listen((duration) {
   //   print('[DURATION_STREAM] $duration');
    });

    _player.currentIndexStream.listen((index) {
  //    print('[CURRENT_INDEX_STREAM] $index');
    });
  }







  @override
  Future<void> play() async => _player.play();

  @override
  Future<void> pause() async => _player.pause();

  @override
  Future<void> fastForward() async {
    final newPosition = _player.position + Duration(seconds: 10);
    await _player.seek(newPosition);
  }

  @override
  Future<void> rewind() async {
    final newPosition = _player.position - Duration(seconds: 10);
    await _player.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  @override
  Future<void> skipToNext() async {
    await _app.playbackModel.handleNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await _app.playbackModel.handlePrevious();
  }


  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }


}