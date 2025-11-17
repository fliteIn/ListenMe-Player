import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../models/app_theme_colors.dart';
import '../../widgets/speed_slider.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/themed_text.dart';
import '../../widgets/numbered_description.dart';
import '../../widgets/gradient_divider.dart';

class SpeedSliderHelpBlock extends StatelessWidget {
  const SpeedSliderHelpBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final app = context.watch<AppModel>();
    final theme = app.themeColors;

    // Адаптивный боковой паддинг для всего блока (например, 100 для планшета, 0 для телефона)
    final double sidePadding = app.isTablet ? 120.0 : 0.0;
    // Адаптивный паддинг для кружков
    final double circlesPadding = app.isTablet ? 13.0 : 13.0;

    final labels = [
      loc.helpSpeedSliderMinusButton,
      loc.helpSpeedSliderThumb,
      loc.helpSpeedSliderPlusButton,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Весь блок внутри sidePadding
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок по центру
              Center(
                child: buildShadowedText(
                  context,
                  loc.helpSpeedSliderTitle,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),

              // Сам SpeedSlider
              IgnorePointer(
                child: SpeedSlider(
                  playbackSpeed: 1.2,
                  onSpeedChanged: (_) {},
                  height: 50,          // Высота всей секции
                  sliderHeight: 28,    // Высота слайдера
                  thumbSize: 18,       // Размер бегунка
                  buttonSize: 22,      // Кнопки "+" и "−"
                  fontSize: 14,        // Размер текста
                  trackHeight: 4,       // Высота трека слайдера
                  symbolSpacing: 4,   // Отступ между кнопками/слайдером
                  edgePadding: 12,

                ),
              ),
              const SizedBox(height: 8),

              // Кружки равномерно под кнопками и центральным бегунком
              SizedBox(
                height: 32,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: circlesPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (i) {
                      return buildThemedCircle(
                        text: '${i + 1}',
                        background: theme.controlElements,
                        foreground: theme.buttonIconText,
                        size: 20,
                        fontSize: 12,
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // Divider вне паддинга
        const GradientDivider(),
        const SizedBox(height: 16),

        // Описания вне паддинга
        ...List.generate(labels.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: numberedDescription(context, '${i + 1}', labels[i], theme),
          );
        }),

        const SizedBox(height: 12),

        buildShadowedText(
          context,
          loc.helpSpeedSliderDescription,
          textAlign: TextAlign.left,
        ),

        const SizedBox(height: 24),
        const GradientDivider(),
        const SizedBox(height: 24),
      ],
    );
  }
}
