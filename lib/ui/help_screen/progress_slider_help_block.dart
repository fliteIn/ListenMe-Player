import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../models/app_theme_colors.dart';
import '../../widgets/progress_slider.dart';
import '../../widgets/playback_time.dart';
import '../../widgets/marker_slider.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/themed_text.dart';
import '../../widgets/numbered_description.dart';
import '../../widgets/gradient_divider.dart';
import '../../enums/enums.dart';

class ProgressSliderHelpBlock extends StatefulWidget {
  const ProgressSliderHelpBlock({super.key});

  @override
  State<ProgressSliderHelpBlock> createState() => _ProgressSliderHelpBlockState();
}

class _ProgressSliderHelpBlockState extends State<ProgressSliderHelpBlock> {
  Duration position = const Duration(seconds: 90);
  Duration duration = const Duration(minutes: 3);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final app = context.watch<AppModel>();
    final theme = app.themeColors;

    // Адаптивный боковой паддинг для блока в целом (например, 100 на планшете, 0 на телефоне)
    final double sidePadding = app.isTablet ? 120.0 : 0.0;

    // edgePadding для ProgressSlider и MarkerSlider (обычно 12 или 14)
    final double edgePadding = 14.0;

    // circlesPadding для кружков — настраивается отдельно!
    final double circlesPadding = app.isTablet ? 28.0 : 30.0;

    final labels = [
      loc.helpProgressSliderMinusButtons,
      loc.helpProgressSliderPosition,
      loc.helpProgressSliderMarkerA,
      loc.helpProgressSliderPlayHead,
      loc.helpProgressSliderMarkerB,
      loc.helpProgressSliderDuration,
      loc.helpProgressSliderPlusButtons,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Весь help-блок внутри sidePadding
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок по центру
              Center(
                child: buildShadowedText(
                  context,
                  loc.helpProgressSliderTitle,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),

              // Время
              Padding(
                padding: EdgeInsets.symmetric(horizontal: edgePadding),
                child: IgnorePointer(
                  child: PlaybackTime(
                    position: position,
                    duration: duration,
                    style: TimeDisplayStyle.mmss,
                    secondaryTimeType: SecondaryTimeType.remaining,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Верхний маркер
              Padding(
                padding: EdgeInsets.symmetric(horizontal: edgePadding),
                child: IgnorePointer(
                  child: MarkerSlider(
                    marker: Duration(seconds: 52),
                    duration: duration,
                    currentPosition: position,
                    onChanged: (_) {},
                    isUp: true,
                    height: 26.0,
                    buttonSize: 22.0,
                    thumbSize: 18.0,
                    trackHeight: 1.0,
                    edgePadding: edgePadding,
                  ),
                ),
              ),
              const SizedBox(height: 5),

              // Прогрессбар
              Padding(
                padding: EdgeInsets.symmetric(horizontal: edgePadding),
                child: IgnorePointer(
                  child: ProgressSlider(
                    position: position,
                    duration: duration,
                    markerA: Duration(seconds: 52),
                    markerB: Duration(seconds: 128),
                    onSeek: (_) {},
                    onSeekStart: () {},
                    onSeekEnd: () {},
                    showMarkers: true,
                    playBetweenMarkers: true,
                    height: 20,
                    thumbSize: 18,
                    trackHeight: 4,
                    sideButtonSize: 22,
                    sideGap: 5,
                  ),
                ),
              ),
              const SizedBox(height: 5),

              // Нижний маркер
              Padding(
                padding: EdgeInsets.symmetric(horizontal: edgePadding),
                child: IgnorePointer(
                  child: MarkerSlider(
                    marker: Duration(seconds: 128),
                    duration: duration,
                    currentPosition: position,
                    onChanged: (_) {},
                    isUp: false,
                    height: 26.0,
                    buttonSize: 22.0,
                    thumbSize: 18.0,
                    trackHeight: 1.0,
                    edgePadding: edgePadding,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Кружки — с отдельным circlesPadding!
              SizedBox(
                height: 32,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: circlesPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
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
          loc.helpProgressSliderDescription,
          textAlign: TextAlign.left,
        ),

        const SizedBox(height: 24),
        const GradientDivider(),
        const SizedBox(height: 24),
      ],
    );
  }
}
