import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_model.dart';
import '../../../enums/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/themed_text.dart';
import '../../widgets/themed_slider_shapes.dart';

double getAdaptiveHorizontalPadding(BuildContext context) {
  final app = Provider.of<AppModel>(context, listen: false);
  return app.isTablet ? 64.0 : 16.0;
}


class PlaybackSettingsScreen extends StatelessWidget {
  const PlaybackSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final theme = app.themeColors;
    final control = theme.controlElements;
    final currentText = theme.currentValueText;
    final loc = AppLocalizations.of(context)!;

    final adaptivePadding = getAdaptiveHorizontalPadding(context);

    app.updateSystemUi(theme);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // Playback Button Style Block
                Padding(
                  padding: EdgeInsets.fromLTRB(adaptivePadding, 24, adaptivePadding, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildShadowedText(
                        context,
                        loc.playbackButtonType,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      ...[
                        [PlaybackButtonStyle.standard, loc.standard],
                        [PlaybackButtonStyle.extended, loc.extended],
                        [PlaybackButtonStyle.precise, loc.precise],
                      ].map(
                            (entry) => RadioListTile<PlaybackButtonStyle>(
                              contentPadding: EdgeInsets.zero, // <--- Добавь это!
                              title: buildShadowedText(
                                context,
                                entry[1] as String,
                                fontSize: 16,
                                textAlign: TextAlign.left,
                              ),
                              value: entry[0] as PlaybackButtonStyle,
                              groupValue: app.playbackButtonStyle,
                              onChanged: (value) => app.setPlaybackButtonStyle(value!),
                              activeColor: currentText.color,
                              fillColor: MaterialStateProperty.resolveWith((states) {
                                return currentText.color.withOpacity(
                                  states.contains(MaterialState.selected) ? 1.0 : 0.6,
                                );
                              }),
                            ),

                      ),
                    ],
                  ),
                ),

                // Speed Range Block
                Padding(
                  padding: EdgeInsets.fromLTRB(adaptivePadding, 24, adaptivePadding, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildShadowedText(
                        context,
                        loc.playbackSpeedRange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      buildShadowedText(
                        context,
                        '${loc.min}: ${app.minSpeed.toStringAsFixed(1)}x',
                        fontSize: 14,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      // Минимальная скорость (0.1 по умолчанию)
                      GestureDetector(
                        onDoubleTap: () => app.setMinSpeed(0.5),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            overlayShape: SliderComponentShape.noOverlay,
                            thumbShape: ThemedThumbShape(
                              color: control.color,
                              shadowColor: control.shadowColor,
                              shadowBlur: control.shadowBlur,
                              shadowEnabled: control.shadowEnabled,
                            ),
                            trackShape: DoubleShadowTrackShape(
                              active: theme.sliderActiveSegment,
                              inactive: theme.sliderInactiveSegment,
                            ),
                          ),
                          child: Slider(
                            min: 0.1,
                            max: 0.5,
                            value: app.minSpeed,
                            onChanged: app.setMinSpeed,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      buildShadowedText(
                        context,
                        '${loc.max}: ${app.maxSpeed.toStringAsFixed(1)}x',
                        fontSize: 14,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),

                      // Максимальная скорость (2.0 по умолчанию)
                      GestureDetector(
                        onDoubleTap: () => app.setMaxSpeed(2.0),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            overlayShape: SliderComponentShape.noOverlay,
                            thumbShape: ThemedThumbShape(
                              color: control.color,
                              shadowColor: control.shadowColor,
                              shadowBlur: control.shadowBlur,
                              shadowEnabled: control.shadowEnabled,
                            ),
                            trackShape: DoubleShadowTrackShape(
                              active: theme.sliderActiveSegment,
                              inactive: theme.sliderInactiveSegment,
                            ),
                          ),
                          child: Slider(
                            min: 2.0,
                            max: 10.0,
                            value: app.maxSpeed,
                            onChanged: app.setMaxSpeed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
