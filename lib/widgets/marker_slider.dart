import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import '../models/app_theme_colors.dart';
import 'themed_symbol_button.dart';
import 'dart:async';
import 'dart:math';

class MarkerSlider extends StatefulWidget {
  final Duration marker;
  final Duration duration;
  final Duration currentPosition;
  final ValueChanged<Duration> onChanged;
  final bool isUp;
  final double? height;
  final double? buttonSize;
  final double? thumbSize;
  final double? trackHeight;
  final double? edgePadding;

  const MarkerSlider({
    super.key,
    required this.marker,
    required this.duration,
    required this.currentPosition,
    required this.onChanged,
    required this.isUp,
    this.height,
    this.buttonSize,
    this.thumbSize,
    this.trackHeight,
    this.edgePadding,
  });

  @override
  State<MarkerSlider> createState() => _MarkerSliderState();
}

class _MarkerSliderState extends State<MarkerSlider> {
  Timer? _holdTimer;
  int _tick = 0;
  bool _holdingPlus = false;
  bool _holdingMinus = false;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  double _durationToValue(Duration d) => widget.duration.inMilliseconds == 0
      ? 0.0
      : d.inMilliseconds / widget.duration.inMilliseconds;

  Duration _valueToDuration(double value) =>
      Duration(milliseconds: (value * widget.duration.inMilliseconds).round());

  Duration _clampDuration(Duration value, Duration min, Duration max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  void _startHold(bool increase) {
    _holdTimer?.cancel();
    _tick = 0;
    _holdingPlus = increase;
    _holdingMinus = !increase;

    _holdTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      _tick++;
      final delta = _calculateDelta();
      final currentMarker = widget.marker;
      final duration = widget.duration;

      final newMarker = increase
          ? _clampDuration(currentMarker + delta, Duration.zero, duration)
          : _clampDuration(currentMarker - delta, Duration.zero, duration);

      widget.onChanged(newMarker);
    });
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _holdingPlus = false;
    _holdingMinus = false;
  }

  Duration _calculateDelta() {
    final millis = (200 * pow(1.14, _tick)).toInt();
    final clamped = millis.clamp(200, 8000);
    return Duration(milliseconds: clamped);
  }

  void _adjustOnce(bool increase) {
    const delta = Duration(milliseconds: 200);
    final newMarker = increase ? widget.marker + delta : widget.marker - delta;
    widget.onChanged(_clampDuration(newMarker, Duration.zero, widget.duration));
  }

  void _syncToCurrentPosition() {
    widget.onChanged(
        _clampDuration(widget.currentPosition, Duration.zero, widget.duration));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final colors = app.themeColors;
    final control = colors.controlElements;
    final text = colors.buttonIconText;

    // --- Адаптивные параметры
    final double _height = widget.height ?? 26.0;
    final double _buttonSize = widget.buttonSize ?? 32.0;
    final double _thumbSize = widget.thumbSize ?? 24.0;
    final double _trackHeight = widget.trackHeight ?? 1.0;
    final double _edgePadding = widget.edgePadding ?? 14.0;

    return SizedBox(
      height: _height,
      child: Row(
        children: [
          SizedBox(width: _edgePadding),
          Listener(
            onPointerDown: (_) => _startHold(false),
            onPointerUp: (_) => _stopHold(),
            onPointerCancel: (_) => _stopHold(),
            child: ThemedSymbolButton(
              symbol: '−',
              onTap: () => _adjustOnce(false),
              background: control,
              foreground: text,
              size: _buttonSize,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: 1,
                child: GestureDetector(
                  onDoubleTap: _syncToCurrentPosition,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: _trackHeight,
                      activeTrackColor: colors.sliderInactiveSegment.color,
                      inactiveTrackColor: colors.sliderInactiveSegment.color,
                      thumbColor: control.color,
                      thumbShape: LabelIconThumbShape(
                        isUp: widget.isUp,
                        themedColor: control,
                        size: _thumbSize,
                      ),
                      trackShape: const RectangularSliderTrackShape(),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Slider(
                        value: _durationToValue(widget.marker).clamp(0.0, 1.0),
                        onChanged: (v) => widget.onChanged(_valueToDuration(v)),
                        onChangeEnd: (value) {
                          final millis = (value * widget.duration.inMilliseconds).toInt();
                          final app = context.read<AppModel>();
                          if (widget.isUp) {
                            app.markerA = Duration(milliseconds: millis);
                          } else {
                            app.markerB = Duration(milliseconds: millis);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 7),
          Listener(
            onPointerDown: (_) => _startHold(true),
            onPointerUp: (_) => _stopHold(),
            onPointerCancel: (_) => _stopHold(),
            child: ThemedSymbolButton(
              symbol: '+',
              onTap: () => _adjustOnce(true),
              background: control,
              foreground: text,
              size: _buttonSize,
            ),
          ),
          SizedBox(width: _edgePadding),
        ],
      ),
    );
  }
}

class LabelIconThumbShape extends SliderComponentShape {
  final bool isUp;
  final ThemedColor themedColor;
  final double size;

  const LabelIconThumbShape({
    required this.isUp,
    required this.themedColor,
    this.size = 24.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(size, size);

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final canvas = context.canvas;
    final icon = Icons.label;
    final color = sliderTheme.thumbColor ?? Colors.indigo;

    final textStyle = TextStyle(
      fontSize: size,
      fontFamily: icon.fontFamily,
      package: icon.fontPackage,
      color: color,
    );

    final shadowStyle = TextStyle(
      fontSize: size,
      fontFamily: icon.fontFamily,
      package: icon.fontPackage,
      color: themedColor.shadowColor,
      shadows: themedColor.shadowEnabled
          ? [
        Shadow(
          color: themedColor.shadowColor,
          blurRadius:
          themedColor.shadowBlur > 0 ? themedColor.shadowBlur : 0.1,
          offset: const Offset(0, 0),
        )
      ]
          : [],
    );

    final shadowPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: shadowStyle,
      ),
      textDirection: textDirection,
    )..layout();

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: textStyle,
      ),
      textDirection: textDirection,
    )..layout();

    canvas.save();
    canvas.translate(center.dx, center.dy);

    if (themedColor.shadowEnabled) {
      canvas.save();
      canvas.translate(0, 0);
      canvas.rotate(isUp ? 1.5708 : -1.5708);
      canvas.translate(-shadowPainter.width / 2, -shadowPainter.height / 2);
      shadowPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }

    canvas.rotate(isUp ? 1.5708 : -1.5708);
    canvas.translate(-iconPainter.width / 2, -iconPainter.height / 2);
    iconPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }
}
