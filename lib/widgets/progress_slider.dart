import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import '../models/app_theme_colors.dart';
import 'themed_slider_shapes.dart';
import 'themed_symbol_button.dart';

class ProgressSlider extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Duration markerA;
  final Duration markerB;
  final ValueChanged<Duration> onSeek;
  final bool showMarkers;
  final bool playBetweenMarkers;
  final VoidCallback? onSeekStart;
  final VoidCallback? onSeekEnd;
  final double? height;
  final double? thumbSize;
  final double? trackHeight;
  final EdgeInsetsGeometry? horizontalPadding;
  final double? sideButtonSize;
  final double? sideGap; // ← новый параметр

  const ProgressSlider({
    Key? key,
    required this.position,
    required this.duration,
    required this.markerA,
    required this.markerB,
    required this.onSeek,
    required this.showMarkers,
    required this.playBetweenMarkers,
    required this.onSeekStart,
    required this.onSeekEnd,
    this.height,
    this.thumbSize,
    this.trackHeight,
    this.horizontalPadding,
    this.sideButtonSize,
    this.sideGap, // ← новый параметр
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final colors = app.themeColors;

    final ThemedColor activeSegment = colors.sliderActiveSegment;
    final ThemedColor inactiveSegment = colors.sliderInactiveSegment;
    final ThemedColor thumb = colors.controlElements;

    final double total = duration.inMilliseconds.toDouble();
    final double safeTotal = total == 0 ? 1 : total;
    final double pos = position.inMilliseconds.clamp(0, safeTotal).toDouble();

    final double a = markerA.inMilliseconds.toDouble();
    final double b = markerB.inMilliseconds.toDouble();
    final double left = a < b ? a : b;
    final double right = a > b ? a : b;

    final double leftFraction = (left / safeTotal).clamp(0.0, 1.0);
    final double rightFraction = (right / safeTotal).clamp(0.0, 1.0);

    // --- Адаптивные параметры
    final double _height = height ?? 30.0;
    final double _thumbSize = thumbSize ?? 18.0;
    final double _trackHeight = trackHeight ?? 4.0;
    final EdgeInsetsGeometry _horizontalPadding =
        horizontalPadding ?? const EdgeInsets.symmetric(horizontal: 16);
    final double _sideButtonSize = sideButtonSize ?? 32.0;
    final double _sideGap = sideGap ??
        (app.isTablet ? 18.0 : 7.0); // ← если sideGap не передан, дефолтное значение

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
          ),
        ]
            : [],
      );
    }

    return SizedBox(
      height: _height,
      child: Row(
        children: [
          IgnorePointer(
            ignoring: true,
            child: Opacity(
              opacity: 0.0,
              child: ThemedSymbolButton(
                symbol: '−',
                onTap: () {},
                background: colors.controlElements,
                foreground: colors.buttonIconText,
                size: _sideButtonSize,
              ),
            ),
          ),
          SizedBox(width: _sideGap),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: _horizontalPadding,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double halfThumb = _thumbSize / 2;
                    final double sliderWidth = constraints.maxWidth - _thumbSize;
                    final double progressWidth = sliderWidth * (pos / safeTotal);

                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Track (inactive)
                        Positioned(
                          left: halfThumb,
                          width: sliderWidth,
                          child: Container(
                            height: _trackHeight,
                            decoration: themedBoxDecoration(inactiveSegment),
                          ),
                        ),
                        // Active segment
                        if (showMarkers && playBetweenMarkers)
                          Positioned(
                            left: halfThumb + sliderWidth * leftFraction,
                            child: Container(
                              height: _trackHeight,
                              width: sliderWidth * (rightFraction - leftFraction),
                              decoration: themedBoxDecoration(activeSegment),
                            ),
                          )
                        else
                          Positioned(
                            left: halfThumb,
                            child: Container(
                              height: _trackHeight,
                              width: progressWidth,
                              decoration: themedBoxDecoration(activeSegment),
                            ),
                          ),
                        // Thumb
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: _trackHeight,
                            overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 0),
                            activeTrackColor: Colors.transparent,
                            inactiveTrackColor: Colors.transparent,
                            thumbShape: ThemedThumbShape(
                              color: thumb.color,
                              shadowColor: thumb.shadowColor,
                              shadowBlur: thumb.shadowBlur,
                              shadowEnabled: thumb.shadowEnabled,
                              size: _thumbSize,
                            ),
                          ),
                          child: Slider(
                            value: pos,
                            max: safeTotal,
                            onChanged: (newValue) {
                              final duration =
                              Duration(milliseconds: newValue.toInt());
                              onSeek(app.clampToMarkers(duration));
                            },
                            onChangeStart: (_) => onSeekStart?.call(),
                            onChangeEnd: (_) => onSeekEnd?.call(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: _sideGap),
          IgnorePointer(
            ignoring: true,
            child: Opacity(
              opacity: 0.0,
              child: ThemedSymbolButton(
                symbol: '+',
                onTap: () {},
                background: colors.controlElements,
                foreground: colors.buttonIconText,
                size: _sideButtonSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
