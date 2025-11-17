import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import 'dart:async';
import 'dart:math';
import '../widgets/icon_with_shadow.dart';

class PlaybackPrecise extends StatefulWidget {
  final AppModel app;
  final double? iconSize;
  final double? playIconSize;
  final double? switchTrackIconSize;
  final double? buttonSize;
  final double? spacing;
  final double? bigSpacing;
  final double? height;

  const PlaybackPrecise({
    Key? key,
    required this.app,
    this.iconSize,
    this.playIconSize,
    this.switchTrackIconSize,
    this.buttonSize,
    this.spacing,
    this.bigSpacing,
    this.height,
  }) : super(key: key);

  @override
  State<PlaybackPrecise> createState() => _PlaybackPreciseState();
}

class _PlaybackPreciseState extends State<PlaybackPrecise> {
  Timer? _seekTimer;
  bool _isSeekingForward = true;
  int _tickCount = 0;

  static const Duration _timerInterval = Duration(milliseconds: 16);

  void _startSmoothSeekLoop(bool forward) {
    final app = widget.app;

    _isSeekingForward = forward;
    _tickCount = 0;

    app.playbackModel.handleSeekStart();

    _seekTimer = Timer.periodic(_timerInterval, (_) {
      _tickCount++;

      final offset = _calculateDelta();
      final shift = _isSeekingForward ? offset : -offset;

      Duration newPosition = app.positionVN.value + shift;

// Ограничение по длительности
      final total = app.duration;
      if (total > Duration.zero) {
        if (newPosition < Duration.zero) newPosition = Duration.zero;
        if (newPosition > total) newPosition = total;
      }

// Дополнительно ограничиваем по маркерам, если они активны
      newPosition = app.clampToMarkers(newPosition);

      app.positionVN.value = newPosition;

    });
  }

  void _stopSeekLoop() {
    if (_seekTimer != null) {
      final app = widget.app;
      _seekTimer?.cancel();
      _seekTimer = null;
      app.player.seek(app.clampToMarkers(app.positionVN.value));
      app.playbackModel.handleSeekEnd();
    }
  }

  Duration _calculateDelta() {
    int elapsedMs = _tickCount * _timerInterval.inMilliseconds;
    double elapsedSec = elapsedMs / 1000.0;
    final millis = (90 * pow(5.0, elapsedSec)).toInt();
    final clamped = millis.clamp(60, 10000);
    return Duration(milliseconds: clamped);
  }

  @override
  void dispose() {
    _seekTimer?.cancel();
    _seekTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final colors = app.themeColors;
    final themed = colors.controlElements;

    // --- Адаптивные размеры ---
    final iconSize = widget.iconSize ?? 30.0;
    final playIconSize = widget.playIconSize ?? 42.0;
    final switchTrackIconSize = widget.switchTrackIconSize ?? 36.0;
    final buttonSize = widget.buttonSize ?? 36.0;
    final spacing = widget.spacing ?? 0.0;
    final bigSpacing = widget.bigSpacing ?? 12.0;
    final rowHeight = widget.height ?? (playIconSize + 18); // ← добавил высоту

    final isPlaylistEmpty = app.currentPlaylist.isEmpty ||
        app.currentIndex == null ||
        app.currentIndex! < 0 ||
        app.currentIndex! >= app.currentPlaylist.length;

    Widget seekHoldButton({
      required IconData icon,
      required bool forward,
      double? iconSize,
      double? buttonSize,
      bool disabled = false,
    }) {
      return SizedBox(
        width: buttonSize ?? 36,
        height: buttonSize ?? 36,
        child: Listener(
          onPointerDown: disabled ? null : (_) {
            _startSmoothSeekLoop(forward);
          },
          onPointerUp: disabled ? null : (_) {
            _stopSeekLoop();
          },
          onPointerCancel: disabled ? null : (_) {
            _stopSeekLoop();
          },
          child: Center(
            child: IconWithShadow(
              icon: icon,
              size: iconSize ?? 30,
              color: themed.color,
              shadowColor: themed.shadowColor,
              shadowBlur: themed.shadowBlur,
              shadowEnabled: themed.shadowEnabled,
            ),
          ),
        ),
      );
    }

    Widget smallIconButton({
      required IconData icon,
      required double iconSize,
      required VoidCallback onPressed,
      double? buttonSize,
      bool disabled = false,
    }) {
      return SizedBox(
        width: buttonSize ?? 36,
        height: buttonSize ?? 36,
        child: IconButton(
          icon: IconWithShadow(
            icon: icon,
            size: iconSize,
            color: themed.color,
            shadowColor: themed.shadowColor,
            shadowBlur: themed.shadowBlur,
            shadowEnabled: themed.shadowEnabled,
          ),
          onPressed: disabled ? null : onPressed,
          splashRadius: (buttonSize ?? 36) / 2,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      );
    }

    void jumpBy(Duration offset) {
      final list = app.currentPlaylist;
      final ix = app.currentIndex;
      if (list.isEmpty || ix == null || ix < 0 || ix >= list.length) return;
      final total = app.duration;
      Duration newPos = app.positionVN.value + offset;

// Глобальное ограничение
      if (total > Duration.zero) {
        if (newPos < Duration.zero) newPos = Duration.zero;
        if (newPos > total) newPos = total;
      }

// Учитываем активные маркеры
      final clamped = app.clampToMarkers(newPos);

      app.player.seek(clamped);

    }

    return SizedBox(
      height: rowHeight,
      child: Center( // <-- Это гарантирует центрирование по высоте!
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            smallIconButton(
              icon: Icons.skip_previous,
              iconSize: switchTrackIconSize,
              onPressed: () => app.playbackModel.handlePrevious(),
              buttonSize: buttonSize,
              disabled: isPlaylistEmpty,
            ),
            SizedBox(width: bigSpacing),
            seekHoldButton(
              icon: Icons.fast_rewind,
              forward: false,
              iconSize: iconSize,
              buttonSize: buttonSize,
              disabled: isPlaylistEmpty,
            ),
            SizedBox(width: spacing),
            smallIconButton(
              icon: Icons.replay_5,
              iconSize: iconSize,
              onPressed: () => jumpBy(const Duration(seconds: -5)),
              buttonSize: buttonSize,
              disabled: isPlaylistEmpty,
            ),
            SizedBox(width: bigSpacing),
            smallIconButton(
              icon: app.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
              iconSize: playIconSize,
              buttonSize: playIconSize,
              onPressed: () => app.playbackModel.handlePlayPause(),
              disabled: isPlaylistEmpty,
            ),
            SizedBox(width: bigSpacing),
            smallIconButton(
              icon: Icons.forward_5,
              iconSize: iconSize,
              onPressed: () => jumpBy(const Duration(seconds: 5)),
              buttonSize: buttonSize,
              disabled: isPlaylistEmpty,
            ),
            SizedBox(width: spacing),
            seekHoldButton(
              icon: Icons.fast_forward,
              forward: true,
              iconSize: iconSize,
              buttonSize: buttonSize,
              disabled: isPlaylistEmpty,
            ),
            SizedBox(width: bigSpacing),
            smallIconButton(
              icon: Icons.skip_next,
              iconSize: switchTrackIconSize,
              onPressed: () => app.playbackModel.handleNext(),
              buttonSize: buttonSize,
              disabled: isPlaylistEmpty,
            ),
          ],
        ),
      ),
    );
  }
}
