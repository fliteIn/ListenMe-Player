import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../models/app_theme_colors.dart';
import '../../widgets/silence_control_bar.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/themed_text.dart';
import '../../widgets/numbered_description.dart';
import '../../widgets/gradient_divider.dart';

class SilenceControlHelpBlock extends StatelessWidget {
  const SilenceControlHelpBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final app = context.watch<AppModel>();
    final theme = app.themeColors;

    // Адаптивный боковой паддинг для всего блока (например, 100 для планшета, 0 для телефона)
    final double sidePadding = app.isTablet ? 100.0 : 0.0;
    // Адаптивный паддинг для кружков (подбирай по необходимости)
    final double circlesPadding = app.isTablet ? 60.0 : 60.0;

    // Подписи к кружкам
    final labels = [
      loc.helpSilenceControlBarJumpPrevPhrase,
      loc.helpSilenceControlBarPCMLevel,
      loc.helpSilenceControlBarThumb,
      loc.helpSilenceControlBarJumpNextPhrase,
    ];

    const double circleSize = 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок по центру
        Center(
          child: buildShadowedText(
            context,
            loc.helpSilenceControlBarTitle,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),

        // Сам SilenceControlBar (на всю ширину блока)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child: IgnorePointer(
            child: SilenceControlBar(
              silenceThresholdDb: -21,
              currentPcmLevel: 0.3,
              pcmLevels: const [],
              onJumpToPrevSilence: () {},
              onJumpToNextSilence: () {},
              onThresholdChanged: (_) {},
              onThresholdChangeEnd: () {},
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Кружки равномерно под элементами SilenceControlBar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: circlesPadding + sidePadding),
          child: SizedBox(
            height: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (i) {
                return buildThemedCircle(
                  text: '${i + 1}',
                  background: theme.controlElements,
                  foreground: theme.buttonIconText,
                  size: circleSize,
                  fontSize: 12,
                );
              }),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Градиентный разделитель
        const GradientDivider(),
        const SizedBox(height: 16),

        // Описания к кружкам (вне паддинга)
        ...List.generate(labels.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: numberedDescription(context, '${i + 1}', labels[i], theme),
          );
        }),

        const SizedBox(height: 12),

        // Длинное описание
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: buildShadowedText(
            context,
            loc.helpSilenceControlBarDescription,
            textAlign: TextAlign.left,
          ),
        ),

        const SizedBox(height: 60),
      ],
    );
  }
}
