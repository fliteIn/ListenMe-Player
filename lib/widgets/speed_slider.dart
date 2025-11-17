import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import '../widgets/gradient_divider.dart';
import '../models/app_theme_colors.dart';
import 'themed_slider_shapes.dart';
import 'themed_symbol_button.dart';

class SpeedSlider extends StatelessWidget {
  final double playbackSpeed;
  final ValueChanged<double> onSpeedChanged;

  // --- Адаптивные параметры ---
  final double? height;
  final double? sliderHeight;
  final double? thumbSize;
  final double? buttonSize;
  final double? fontSize;
  final double? trackHeight;
  final double? symbolSpacing;
  final double? edgePadding;

  const SpeedSlider({
    Key? key,
    required this.playbackSpeed,
    required this.onSpeedChanged,
    this.height,
    this.sliderHeight,
    this.thumbSize,
    this.buttonSize,
    this.fontSize,
    this.trackHeight,
    this.symbolSpacing,
    this.edgePadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final colors = app.themeColors;

    // ---- Адаптивные значения ----
    final double _height = height ?? 48.0;
    final double _sliderHeight = sliderHeight ?? 26.0;
    final double _thumbSize = thumbSize ?? 18.0;
    final double _buttonSize = buttonSize ?? 36.0;
    final double _fontSize = fontSize ?? 14.0;
    final double _trackHeight = trackHeight ?? 4.0;
    final double _symbolSpacing = symbolSpacing ?? 10.0;
    final double edgePadding = this.edgePadding ?? 14.0;

    void _changeSpeed(double newSpeed) {
      final clamped = newSpeed.clamp(app.minSpeed, app.maxSpeed);
      onSpeedChanged(clamped);
    }

    BoxDecoration themedBoxDecoration(ThemedColor themedColor) {
      final blur = themedColor.shadowEnabled
          ? (themedColor.shadowBlur > 0 ? themedColor.shadowBlur : 0.1)
          : 0.0;

      return BoxDecoration(
        color: themedColor.color,
        borderRadius: BorderRadius.circular(1),
        boxShadow: themedColor.shadowEnabled
            ? [
          BoxShadow(
            color: themedColor.shadowColor,
            blurRadius: blur,
            offset: const Offset(0, 2),
          )
        ]
            : [],
      );
    }

    TextStyle themedTextStyle(ThemedColor themedColor, double fontSize,
        {bool bold = false, bool withShadow = true}) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        color: themedColor.color,
        shadows: (withShadow && themedColor.shadowEnabled)
            ? [
          Shadow(
            color: themedColor.shadowColor,
            blurRadius:
            themedColor.shadowBlur > 0 ? themedColor.shadowBlur : 0.1,
            offset: const Offset(0, 2),
          )
        ]
            : [],
      );
    }

    return SizedBox(
      height: _height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Текст скорости
          Text(
            '${playbackSpeed.toStringAsFixed(1)}x',
            style: themedTextStyle(colors.currentValueText, _fontSize),
          ),
          SizedBox(
            height: _sliderHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: edgePadding),
              child: Row(
                children: [
                  ThemedSymbolButton(
                    symbol: '−',
                    onTap: () => _changeSpeed(playbackSpeed - 0.1),
                    background: colors.controlElements,
                    foreground: colors.buttonIconText,
                    size: _buttonSize,
                    fontSize: _fontSize,
                  ),
                  SizedBox(width: _symbolSpacing),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final min = app.minSpeed;
                        final max = app.maxSpeed;
                        final thumb = colors.controlElements;

                        final double thumbPaddingLeft = _thumbSize / 2;
                        final double thumbPaddingRight = _thumbSize / 2;

                        final trackWidth = constraints.maxWidth - thumbPaddingLeft - thumbPaddingRight;
                        final fraction = ((playbackSpeed - min) / (max - min)).clamp(0.0, 1.0);
                        final activeWidth = trackWidth * fraction;

                        return GestureDetector(
                          onDoubleTap: () => _changeSpeed(1.0),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: trackWidth,
                                  height: _trackHeight,
                                  decoration: themedBoxDecoration(colors.sliderInactiveSegment),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: thumbPaddingLeft),
                                  child: Container(
                                    width: activeWidth,
                                    height: _trackHeight,
                                    decoration: themedBoxDecoration(colors.sliderActiveSegment),
                                  ),
                                ),
                              ),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: _trackHeight,
                                  activeTrackColor: Colors.transparent,
                                  inactiveTrackColor: Colors.transparent,
                                  overlayShape: SliderComponentShape.noOverlay,
                                  showValueIndicator: ShowValueIndicator.never,
                                  thumbShape: ThemedThumbShape(
                                    color: thumb.color,
                                    shadowColor: thumb.shadowColor,
                                    shadowBlur: thumb.shadowBlur,
                                    shadowEnabled: thumb.shadowEnabled,
                                    size: _thumbSize,
                                  ),
                                ),
                                child: Slider(
                                  value: playbackSpeed.clamp(min, max),
                                  min: min,
                                  max: max,
                                  onChanged: _changeSpeed,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: _symbolSpacing),
                  ThemedSymbolButton(
                    symbol: '+',
                    onTap: () => _changeSpeed(playbackSpeed + 0.1),
                    background: colors.controlElements,
                    foreground: colors.buttonIconText,
                    size: _buttonSize,
                    fontSize: _fontSize,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
