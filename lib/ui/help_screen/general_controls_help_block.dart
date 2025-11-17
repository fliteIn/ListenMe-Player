import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../models/app_theme_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/themed_text.dart';
import '../../widgets/numbered_description.dart';
import '../../widgets/general_controls.dart'; // Подключи путь, если отличается
import '../../widgets/gradient_divider.dart';

class GeneralControlsHelpBlock extends StatelessWidget {
  const GeneralControlsHelpBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = context.watch<AppModel>().themeColors;

    // Список описаний для кружочков (замени на актуальные, если нужно)
    final labels = [
      loc.helpGeneralControlsSchowSilenceControlBar,
      loc.helpGeneralControlsSchowPlayback,
      loc.helpGeneralControlsSchowJog,
      loc.helpGeneralControlsSchowSpeedSlider,
      loc.helpGeneralControlsPlaybackMode,
      loc.helpGeneralControlsSchowMarkers,
      loc.helpGeneralControlsActivatePlayBetweenMarkers,
    ];

    // 1. Заголовок и описание с отступом
    // 2. Виджет GeneralControls — на всю ширину (без horizontal отступа)
    // 3. Кружки — строго под кнопками (на всю ширину)
    // 4. Описания с отступом
    // 5. Длинное описание (если нужно)
    final app = context.watch<AppModel>();
    final isTablet = app.isTablet;
    double adaptiveSize(bool isTablet, double phone, [double? tablet]) =>
        isTablet ? (tablet ?? phone * 1.4) : phone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Center(
          child: buildShadowedText(
            context,
            loc.helpGeneralControlsTitle,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 8),

        // GeneralControls на всю ширину, без паддингов!
        IgnorePointer(
          child: GeneralControls(
            iconSize: adaptiveSize(isTablet, 24, 24),
            iconBtnSize: adaptiveSize(isTablet, 48, 48),
            controlBarHeight: adaptiveSize(isTablet, 60, 60),
            iconGap: adaptiveSize(isTablet, 0, 0),
            topPadding: 0,
            helpPreviewMode: true, // Вот здесь!

          ),
        ),

        // Кружки — строго под иконками
        SizedBox(
          height: 32,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double itemWidth = 47.7;
              const int count = 7; // число иконок
              final double totalWidth = itemWidth * count;
              final double screenWidth = constraints.maxWidth;
              final double horizontalPadding =
                  screenWidth > totalWidth ? (screenWidth - totalWidth) / 2 : 0;

              // Сдвиг всей линии кружков влево
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Transform.translate(
                  offset: const Offset(1.2, 0),
                  // Попробуй -6, -8 или другое по скрину
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(count, (i) {
                      return SizedBox(
                        width: itemWidth,
                        child: Center(
                          child: buildThemedCircle(
                            text: '${i + 1}',
                            background: theme.controlElements,
                            foreground: theme.buttonIconText,
                            size: 20,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ),

        // Отступ после кружков
        const SizedBox(height: 16),
        GradientDivider(),
        const SizedBox(height: 16),

        // Описания кнопок
        ...List.generate(labels.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: numberedDescription(context, '${i + 1}', labels[i], theme),
          );
        }),

        // Если нужно длинное описание или дополнительный блок
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: buildShadowedText(
            context,
            loc.helpGeneralControlsDescription,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(height: 16),
        GradientDivider(),
        const SizedBox(height: 16),
      ],
    );
  }
}
