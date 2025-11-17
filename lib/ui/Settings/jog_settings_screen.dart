import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_model.dart';
import '../../models/app_theme_colors.dart';
import '../../widgets/top_menu_bar.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/themed_text.dart';
import '../../widgets/themed_slider_shapes.dart';

// Адаптивный горизонтальный паддинг через AppModel
double getAdaptiveHorizontalPadding(BuildContext context) {
  final app = Provider.of<AppModel>(context, listen: false);
  return app.isTablet ? 64.0 : 32.0;
}

class JogSettingsScreen extends StatelessWidget {
  const JogSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final theme = app.themeColors;
    final loc = AppLocalizations.of(context)!;

    app.updateSystemUi(theme);

    final adaptivePadding = getAdaptiveHorizontalPadding(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          //TopMenuBar(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: adaptivePadding,
                vertical: 16,
              ),
              children: [
                // Разрешение джога (15 по умолчанию)
                GestureDetector(
                  onDoubleTap: () => app.setJogResolution(5),
                  child: _buildSliderBlock(
                    context: context,
                    title: loc.jogResolution,
                    value: app.jogResolutionSecondsPerRevolution,
                    unit: loc.secondsPerRevolution,
                    min: 1,
                    max: 60,
                    divisions: 59,
                    onChanged: (value) => app.setJogResolution(value.round()),
                    theme: theme,
                  ),
                ),

                // Минимальная скорость перемотки (200 по умолчанию)
                GestureDetector(
                  onDoubleTap: () => app.setMinJogSkipSpeed(200),
                  child: _buildSliderBlock(
                    context: context,
                    title: loc.minSeekSpeed,
                    value: app.minJogSkipSpeedMsPerSec,
                    unit: loc.msPerSec,
                    min: 50,
                    max: 1000,
                    divisions: 19,
                    onChanged: (value) => app.setMinJogSkipSpeed(value.round()),
                    theme: theme,
                  ),
                ),

                // Максимальная скорость перемотки (20000 по умолчанию)
                GestureDetector(
                  onDoubleTap: () => app.setMaxJogSkipSpeed(20000),
                  child: _buildSliderBlock(
                    context: context,
                    title: loc.maxSeekSpeed,
                    value: app.maxJogSkipSpeedMsPerSec,
                    unit: loc.msPerSec,
                    min: 2000,
                    max: 60000,
                    divisions: 29,
                    onChanged: (value) => app.setMaxJogSkipSpeed(value.round()),
                    theme: theme,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderBlock({
    required BuildContext context,
    required String title,
    required int value,
    required String unit,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required AppThemeColors theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildShadowedText(
            context,
            title,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          buildShadowedText(
            context,
            '$value $unit',
            fontSize: 14,
            textAlign: TextAlign.center,
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: ThemedThumbShape(
                color: theme.controlElements.color,
                shadowColor: theme.controlElements.shadowColor,
                shadowBlur: theme.controlElements.shadowBlur,
                shadowEnabled: theme.controlElements.shadowEnabled,
              ),
              trackShape: DoubleShadowTrackShape(
                active: theme.sliderActiveSegment,
                inactive: theme.sliderInactiveSegment,
              ),
            ),
            child: Slider(
              value: value.toDouble(),
              onChanged: onChanged,
              min: min,
              max: max,
              divisions: divisions,
            ),
          )
        ],
      ),
    );
  }
}
