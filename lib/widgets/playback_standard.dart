import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import '../widgets/icon_with_shadow.dart';

class PlaybackStandard extends StatelessWidget {
  final AppModel app;
  final double? iconSize;
  final double? playIconSize;
  final double? switchTrackIconSize;
  final double? buttonSize;
  final double? spacing;
  final double? bigSpacing;
  final double? height;

  const PlaybackStandard({
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
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final colors = app.themeColors;
    final themed = colors.controlElements;

    // --- Адаптивные размеры ---
    final iconSize = this.iconSize ?? 30.0;
    final playIconSize = this.playIconSize ?? 42.0;
    final switchTrackIconSize = this.switchTrackIconSize ?? 36.0;
    final buttonSize = this.buttonSize ?? 36.0;
    final spacing = this.spacing ?? 0.0;
    final bigSpacing = this.bigSpacing ?? 12.0;
    final rowHeight = this.height ?? (playIconSize + 18);

    final isPlaylistEmpty = app.currentPlaylist.isEmpty ||
        app.currentIndex == null ||
        app.currentIndex! < 0 ||
        app.currentIndex! >= app.currentPlaylist.length;

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

      // --- Глобальное ограничение в пределах трека ---
      if (total > Duration.zero) {
        if (newPos < Duration.zero) newPos = Duration.zero;
        if (newPos > total) newPos = total;
      }

      // --- Дополнительно учитываем активные маркеры ---
      final clamped = app.clampToMarkers(newPos);

      app.player.seek(clamped);
    }


    return SizedBox(
      height: rowHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Prev track
          smallIconButton(
            icon: Icons.skip_previous,
            iconSize: switchTrackIconSize,
            buttonSize: buttonSize,
            onPressed: app.playbackModel.handlePrevious,
            disabled: isPlaylistEmpty,
          ),
          SizedBox(width: bigSpacing),
          // Jump -5s
          smallIconButton(
            icon: Icons.replay_5,
            iconSize: iconSize,
            buttonSize: buttonSize,
            onPressed: () => jumpBy(const Duration(seconds: -5)),
            disabled: isPlaylistEmpty,
          ),
          SizedBox(width: bigSpacing),
          // Play/Pause
          smallIconButton(
            icon: app.isPlaying
                ? Icons.pause_circle_filled
                : Icons.play_circle_filled,
            iconSize: playIconSize,
            buttonSize: playIconSize,
            onPressed: app.playbackModel.handlePlayPause,
            disabled: isPlaylistEmpty,
          ),
          SizedBox(width: bigSpacing),
          // Jump +5s
          smallIconButton(
            icon: Icons.forward_5,
            iconSize: iconSize,
            buttonSize: buttonSize,
            onPressed: () => jumpBy(const Duration(seconds: 5)),
            disabled: isPlaylistEmpty,
          ),
          SizedBox(width: bigSpacing),
          // Next track
          smallIconButton(
            icon: Icons.skip_next,
            iconSize: switchTrackIconSize,
            buttonSize: buttonSize,
            onPressed: app.playbackModel.handleNext,
            disabled: isPlaylistEmpty,
          ),
        ],
      ),
    );
  }
}
