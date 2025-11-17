import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import '../models/app_theme_colors.dart';
import '../enums/enums.dart';
import '../widgets/icon_with_shadow.dart';

class PlaybackModeButton extends StatelessWidget {
  final bool playBetweenMarkers;
  final void Function(PlaybackMode) onModeChanged;
  final double? size; // <-- добавлено

  const PlaybackModeButton({
    Key? key,
    required this.playBetweenMarkers,
    required this.onModeChanged,
    this.size, // <-- добавлено
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final theme = app.themeColors;
    final mode = app.playbackMode;
    final isTablet = app.isTablet;

    double adaptiveSize(double phone, [double? tablet]) =>
        isTablet ? (tablet ?? phone * 1.4) : phone;

    IconData icon;
    switch (mode) {
      case PlaybackMode.singleOnce:
        icon = Icons.looks_one;
        break;
      case PlaybackMode.singleLoop:
        icon = Icons.repeat_one;
        break;
      case PlaybackMode.playlistOnce:
        icon = Icons.queue_music;
        break;
      case PlaybackMode.playlistLoop:
        icon = Icons.repeat;
        break;
      case PlaybackMode.shuffle:
        icon = Icons.shuffle;
        break;
    }

    // --- Размеры теперь могут быть переданы снаружи:
    final double iconSize = size ?? adaptiveSize(24, 32);      // ← Иконка
    final double buttonSize = (size != null)                   // ← Кнопка
        ? (size! * 2.0)
        : adaptiveSize(48, 64);

    return GestureDetector(
      onTap: () {
        app.playbackModel.cyclePlaybackMode();
        onModeChanged(app.playbackMode);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: Center(
          child: IconWithShadow(
            icon: icon,
            color: theme.displayIconActive.color,
            shadowColor: theme.displayIconActive.shadowColor,
            shadowBlur: theme.displayIconActive.shadowBlur,
            shadowEnabled: theme.displayIconActive.shadowEnabled,
            size: iconSize, // ← Адаптивный/заданный размер
          ),
        ),
      ),
    );
  }
}
