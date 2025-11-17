import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../models/app_theme_colors.dart';
import '../../widgets/jog_wheel.dart';
import '../../widgets/rewind_fast_forward.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/themed_text.dart';
import '../../widgets/numbered_description.dart';
import '../../widgets/gradient_divider.dart';

class JogHelpBlock extends StatelessWidget {
  const JogHelpBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final app = context.watch<AppModel>();
    final theme = app.themeColors;

    // 1. Определяем планшет/телефон и функцию адаптации
    final isTablet = app.isTablet;
    double adaptiveSize(bool isTablet, double phone, [double? tablet]) =>
        isTablet ? (tablet ?? phone * 1.4) : phone;

    // 2. Все размеры - только тут, далее только переменные!
    final double jogSize         = adaptiveSize(isTablet, 140.0, 140.0);
    final double sideButtonHeight = adaptiveSize(isTablet, 170.0, 170.0);
    final double rewindButtonWidth = adaptiveSize(isTablet, 54.0, 54.0);
    final double trackSwitchWidth  = adaptiveSize(isTablet, 28.0, 28.0);
    final double sideSpacing       = adaptiveSize(isTablet, 0.0, 0.0);
    final double knobSize          = adaptiveSize(isTablet, 20.0, 20.0);
    final double innerButtonSize   = adaptiveSize(isTablet, 54.0, 54.0);
    final double gap               = adaptiveSize(isTablet, 3.0, 3.0);

    final double circleSize        = 20.0;
    final double circleFontSize    = 12.0;

    // — Названия и нумерация для описаний (нужно подогнать под твои нужды)
    final labels = [
      loc.helpJogPrevTrack,
      loc.helpJogRewind,
      loc.helpJogPlayPauseKnob,
      loc.helpJogFastForward,
      loc.helpJogNextTrack,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // — Заголовок по центру
        Center(
          child: buildShadowedText(
            context,
            loc.helpJogTitle,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),

        // — Центральная композиция (две боковых кнопки + джог)
        SizedBox(
          height: sideButtonHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Левая кнопка
              IgnorePointer(
                child: CurvedRewindButton(
                  side: ButtonSide.left,
                  size: adaptiveSize(isTablet, 140.0, 140.0),
                  rewindButtonWidth: adaptiveSize(isTablet, 54.0, 54.0),
                  trackSwitchWidth: adaptiveSize(isTablet, 28.0, 28.0),
                  gap: adaptiveSize(isTablet, 3.0, 3.0),
                  iconSize: adaptiveSize(isTablet, 20.0, 20.0), // ← размер иконки внутри кнопки перемотки
                  trackSwitchIconSize: adaptiveSize(isTablet, 26.0, 26.0), // ← размер иконки skip
                  onPanStart: (_, __) {},
                  onPanUpdate: (_, __) {},
                  onPanEnd: () {},
                ),
              ),
              SizedBox(width: sideSpacing),
              // Джог
              IgnorePointer(
                child: JogWheel(
                  staticMode: true,
                  position: Duration.zero,     // <-- Всегда 0!
                  duration: app.duration,
                  isPlaying: false,
                  onPlayPauseToggle: () {},
                  onKnobPanEnd: (_) {},
                  onKnobPanUpdate: (_) {},
                  markerA: null,
                  markerB: null,
                  playBetweenMarkers: false,
                  size: adaptiveSize(isTablet, 140.0, 140.0),
                  // <-- Внешний размер джога (у тебя уже есть)
                  knobSize: adaptiveSize(isTablet, 18.0, 18.0),
                  // <-- Размер кноба (кружок по кругу)
                  innerButtonSize: adaptiveSize(isTablet, 54.0, 54.0),
                ),
              ),
              SizedBox(width: sideSpacing),
              // Правая кнопка
              IgnorePointer(
                child: CurvedRewindButton(
                  side: ButtonSide.right,
                  size: adaptiveSize(isTablet, 140.0, 140.0),
                  rewindButtonWidth: adaptiveSize(isTablet, 54.0, 54.0),
                  trackSwitchWidth: adaptiveSize(isTablet, 28.0, 28.0),
                  gap: adaptiveSize(isTablet, 3.0, 3.0),
                  iconSize: adaptiveSize(isTablet, 20.0, 20.0), // ← размер иконки внутри кнопки перемотки
                  trackSwitchIconSize: adaptiveSize(isTablet, 26.0, 26.0), // ← размер иконки skip
                  onPanStart: (_, __) {},
                  onPanUpdate: (_, __) {},
                  onPanEnd: () {},
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // — Ряд кружков под элементами (5 штук)
        SizedBox(
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: trackSwitchWidth,
                child: Center(
                  child: buildThemedCircle(
                    text: '1',
                    background: theme.controlElements,
                    foreground: theme.buttonIconText,
                    size: circleSize,
                    fontSize: circleFontSize,
                  ),
                ),
              ),
              SizedBox(
                width: rewindButtonWidth,
                child: Center(
                  child: buildThemedCircle(
                    text: '2',
                    background: theme.controlElements,
                    foreground: theme.buttonIconText,
                    size: circleSize,
                    fontSize: circleFontSize,
                  ),
                ),
              ),
              SizedBox(
                width: jogSize,
                child: Center(
                  child: buildThemedCircle(
                    text: '3',
                    background: theme.controlElements,
                    foreground: theme.buttonIconText,
                    size: circleSize,
                    fontSize: circleFontSize,
                  ),
                ),
              ),
              SizedBox(
                width: rewindButtonWidth,
                child: Center(
                  child: buildThemedCircle(
                    text: '4',
                    background: theme.controlElements,
                    foreground: theme.buttonIconText,
                    size: circleSize,
                    fontSize: circleFontSize,
                  ),
                ),
              ),
              SizedBox(
                width: trackSwitchWidth,
                child: Center(
                  child: buildThemedCircle(
                    text: '5',
                    background: theme.controlElements,
                    foreground: theme.buttonIconText,
                    size: circleSize,
                    fontSize: circleFontSize,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // — Градиентный разделитель
        const GradientDivider(),
        const SizedBox(height: 16),

        // — Описания к каждой кнопке с паддингом
        ...List.generate(labels.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: numberedDescription(context, '${i + 1}', labels[i], theme),
          );
        }),

        const SizedBox(height: 12),

        // — Длинное описание (если оно есть), с паддингом
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: buildShadowedText(
            context,
            loc.helpJogDescription,
            textAlign: TextAlign.left,
          ),
        ),

        const SizedBox(height: 24),
        const GradientDivider(),
        const SizedBox(height: 24),
      ],
    );
  }
}
