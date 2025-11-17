import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import '../models/app_theme_colors.dart';
import '../widgets/playback_mode_button.dart';
import '../widgets/icon_with_shadow.dart';
import '../enums/enums.dart';

class GeneralControls extends StatelessWidget {
  final double iconSize;
  final double iconBtnSize;
  final double controlBarHeight;
  final double iconGap;
  final double topPadding;
  final bool helpPreviewMode;
  const GeneralControls({
    Key? key,
    required this.iconSize,
    required this.iconBtnSize,
    required this.controlBarHeight,
    required this.iconGap,
    this.topPadding = 0,
    this.helpPreviewMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final sectionSlots = app.sectionSlots;

    // --- Левая четверка иконок ---
    const List<PlayerSection> iconSections = [
      PlayerSection.silenceControlBar,
      PlayerSection.playback,
      PlayerSection.jogWheel,
      PlayerSection.speedSlider,
    ];

    List<Widget> leftIcons;
    if (helpPreviewMode) {
      // В режиме help — все четыре иконки, строго в правильном порядке, все активные
      leftIcons = [
        SizedBox(
          width: iconBtnSize,
          height: iconBtnSize,
          child: _buildBtn(
            context,
            icon: Icons.graphic_eq,
            onTap: null,
            isActive: true,
            iconSize: iconSize,
          ),
        ),
        SizedBox(
          width: iconBtnSize,
          height: iconBtnSize,
          child: _buildBtn(
            context,
            icon: Icons.play_circle,
            onTap: null,
            isActive: true,
            iconSize: iconSize,
          ),
        ),
        SizedBox(
          width: iconBtnSize,
          height: iconBtnSize,
          child: _buildBtn(
            context,
            icon: Icons.radio_button_checked,
            onTap: null,
            isActive: true,
            iconSize: iconSize,
          ),
        ),
        SizedBox(
          width: iconBtnSize,
          height: iconBtnSize,
          child: _buildBtn(
            context,
            icon: Icons.speed,
            onTap: null,
            isActive: true,
            iconSize: iconSize,
          ),
        ),
      ];
    } else {
      // Обычная логика: только активные секции, сортировка по positionY
      final activeSections = sectionSlots
          .where((s) => iconSections.contains(s.type) && s.active)
          .toList()
        ..sort((a, b) => a.positionY.compareTo(b.positionY));

      leftIcons = List.generate(4, (i) => SizedBox(width: iconBtnSize, height: iconBtnSize));

      for (int i = 0; i < activeSections.length && i < 4; i++) {
        final section = activeSections[i];
        late Widget iconBtn;
        bool isActive = false;
        switch (section.type) {
          case PlayerSection.silenceControlBar:
            isActive = app.showSilenceControlBar;
            iconBtn = _buildBtn(
              context,
              icon: Icons.graphic_eq,
              onTap: () => app.setShowSilenceControlBar(!app.showSilenceControlBar, context),
              isActive: isActive,
              iconSize: iconSize,
            );
            break;
          case PlayerSection.playback:
            isActive = app.showPlaybackButtons;
            iconBtn = _buildBtn(
              context,
              icon: Icons.play_circle,
              onTap: () => app.showPlaybackButtons = !app.showPlaybackButtons,
              isActive: isActive,
              iconSize: iconSize,
            );
            break;
          case PlayerSection.jogWheel:
            isActive = app.showJogAndSeekButtons;
            iconBtn = _buildBtn(
              context,
              icon: Icons.radio_button_checked,
              onTap: () => app.showJogAndSeekButtons = !app.showJogAndSeekButtons,
              isActive: isActive,
              iconSize: iconSize,
            );
            break;
          case PlayerSection.speedSlider:
            isActive = app.showSpeedSlider;
            iconBtn = _buildBtn(
              context,
              icon: Icons.speed,
              onTap: () => app.showSpeedSlider = !app.showSpeedSlider,
              isActive: isActive,
              iconSize: iconSize,
            );
            break;
          default:
            iconBtn = SizedBox(width: iconBtnSize, height: iconBtnSize);
        }
        leftIcons[i] = SizedBox(width: iconBtnSize, height: iconBtnSize, child: iconBtn);
      }
    }

    // ---- Правый блок: Repeat, Markers, PlaybackModeButton ----
    final double rightIconSize = iconSize * 0.92;

    Widget repeatBtn, markerBtn, playbackModeBtn;

    if (helpPreviewMode) {
      // Все кнопки справа — активные и неинтерактивные
      repeatBtn = SizedBox(
        width: iconBtnSize,
        height: iconBtnSize,
        child: _buildBtn(
          context,
          icon: Icons.repeat_on,
          onTap: null,
          isActive: true,
          iconSize: rightIconSize,
          override: Transform.translate(
            offset: const Offset(0, 1),
            child: IconWithShadow(
              icon: Icons.repeat_on,
              color: app.themeColors.displayIconActive.color,
              shadowColor: app.themeColors.displayIconActive.shadowColor,
              shadowBlur: app.themeColors.displayIconActive.shadowBlur,
              shadowEnabled: app.themeColors.displayIconActive.shadowEnabled,
              size: rightIconSize,
            ),
          ),
        ),
      );

      markerBtn = SizedBox(
        width: iconBtnSize,
        height: iconBtnSize,
        child: _buildBtn(
          context,
          icon: Icons.label,
          onTap: null,
          isActive: true,
          iconSize: rightIconSize,
          override: Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: const Offset(0, 1),
              child: Transform.rotate(
                angle: 3.1415926535 / 2,
                child: IconWithShadow(
                  icon: Icons.label,
                  color: app.themeColors.displayIconActive.color,
                  shadowColor: app.themeColors.displayIconActive.shadowColor,
                  shadowBlur: app.themeColors.displayIconActive.shadowBlur,
                  shadowEnabled: app.themeColors.displayIconActive.shadowEnabled,
                  shadowOffset: const Offset(2, 0),
                  size: rightIconSize,
                ),
              ),
            ),
          ),
        ),
      );

      playbackModeBtn = SizedBox(
        width: iconBtnSize,
        height: iconBtnSize,
        child: PlaybackModeButton(
          playBetweenMarkers: true,
          onModeChanged: (_) {},
          size: iconSize,
          // Можно добавить isActive: true, если у тебя реализовано в PlaybackModeButton
        ),
      );
    } else {
      // Обычный режим
      repeatBtn = SizedBox(width: iconBtnSize, height: iconBtnSize);
      if (app.showMarkers) {
        repeatBtn = SizedBox(
          width: iconBtnSize,
          height: iconBtnSize,
          child: _buildBtn(
            context,
            icon: Icons.repeat_on,
            onTap: () => app.playbackModel.togglePlayBetweenMarkers(),
            iconSize: rightIconSize,
            override: Transform.translate(
              offset: const Offset(0, 1),
              child: IconWithShadow(
                icon: Icons.repeat_on,
                color: app.playBetweenMarkers
                    ? app.themeColors.displayIconActive.color
                    : app.themeColors.displayIconInactive.color,
                shadowColor: app.playBetweenMarkers
                    ? app.themeColors.displayIconActive.shadowColor
                    : app.themeColors.displayIconInactive.shadowColor,
                shadowBlur: app.playBetweenMarkers
                    ? app.themeColors.displayIconActive.shadowBlur
                    : app.themeColors.displayIconInactive.shadowBlur,
                shadowEnabled: app.playBetweenMarkers
                    ? app.themeColors.displayIconActive.shadowEnabled
                    : app.themeColors.displayIconInactive.shadowEnabled,
                size: rightIconSize,
              ),
            ),
          ),
        );
      }

      markerBtn = SizedBox(
        width: iconBtnSize,
        height: iconBtnSize,
        child: _buildBtn(
          context,
          icon: Icons.label,
          onTap: () => app.toggleShowMarkers(),
          iconSize: rightIconSize,
          override: Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: const Offset(0, 1),
              child: Transform.rotate(
                angle: 3.1415926535 / 2,
                child: IconWithShadow(
                  icon: Icons.label,
                  color: app.showMarkers
                      ? app.themeColors.displayIconActive.color
                      : app.themeColors.displayIconInactive.color,
                  shadowColor: app.showMarkers
                      ? app.themeColors.displayIconActive.shadowColor
                      : app.themeColors.displayIconInactive.shadowColor,
                  shadowBlur: app.showMarkers
                      ? app.themeColors.displayIconActive.shadowBlur
                      : app.themeColors.displayIconInactive.shadowBlur,
                  shadowEnabled: app.showMarkers
                      ? app.themeColors.displayIconActive.shadowEnabled
                      : app.themeColors.displayIconInactive.shadowEnabled,
                  shadowOffset: const Offset(2, 0),
                  size: rightIconSize,
                ),
              ),
            ),
          ),
        ),
      );

      playbackModeBtn = SizedBox(
        width: iconBtnSize,
        height: iconBtnSize,
        child: PlaybackModeButton(
          playBetweenMarkers: true,
          onModeChanged: (mode) => app.playbackModel.setUserSelectedPlaybackMode(mode),
          size: iconSize,
        ),
      );
    }

    // --- Итоговый список (левая + Spacer + правая) ---
    final List<Widget> controlsRow = [];
    // Добавляем левые иконки с зазорами
    for (int i = 0; i < leftIcons.length; i++) {
      controlsRow.add(leftIcons[i]);
      if (i != leftIcons.length - 1) {
        controlsRow.add(SizedBox(width: iconGap));
      }
    }
    // Добавляем правый блок
    controlsRow.add(SizedBox(width: iconGap));
    controlsRow.add(repeatBtn);
    controlsRow.add(SizedBox(width: iconGap));
    controlsRow.add(markerBtn);
    controlsRow.add(SizedBox(width: iconGap));
    controlsRow.add(playbackModeBtn);

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: SizedBox(
        height: controlBarHeight,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: controlsRow,
          ),
        ),
      ),
    );
  }

  static Widget _buildBtn(
      BuildContext context, {
        required IconData icon,
        required VoidCallback? onTap,
        Widget? override,
        double iconSize = 24,
        EdgeInsets padding = const EdgeInsets.all(12),
        bool isActive = false,
      }) {
    final colors = context.read<AppModel>().themeColors;
    final themed = isActive ? colors.displayIconActive : colors.displayIconInactive;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: padding,
        child: override ??
            IconWithShadow(
              icon: icon,
              color: themed.color,
              shadowColor: themed.shadowColor,
              shadowBlur: themed.shadowBlur,
              shadowEnabled: themed.shadowEnabled,
              size: iconSize,
            ),
      ),
    );
  }
}
