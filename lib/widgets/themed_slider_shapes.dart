import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import '../widgets/gradient_divider.dart';
import '../models/app_theme_colors.dart';

class ThemedThumbShape extends SliderComponentShape {
  final Color color;
  final Color shadowColor;
  final double shadowBlur;
  final bool shadowEnabled;
  final double size;

  const ThemedThumbShape({
    required this.color,
    required this.shadowColor,
    required this.shadowBlur,
    required this.shadowEnabled,
    this.size = 20.0, // ← теперь можно менять размер (дефолт 20)
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(size / 2);

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

    if (shadowEnabled) {
      canvas.drawCircle(
        center + const Offset(0, 2),
        size / 2,
        Paint()
          ..color = shadowColor
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            shadowBlur > 0 ? shadowBlur : 0.1,
          ),
      );
    }

    canvas.drawCircle(
      center,
      size / 2,
      Paint()..color = color,
    );
  }
}

class DoubleShadowTrackShape extends SliderTrackShape {
  final ThemedColor active;
  final ThemedColor inactive;

  const DoubleShadowTrackShape({
    required this.active,
    required this.inactive,
  });

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4;
    final trackLeft = offset.dx + 8;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width - 16;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required TextDirection textDirection,
        required Offset thumbCenter,
        bool isEnabled = false,
        bool isDiscrete = false,
        Offset? secondaryOffset,
      }) {
    final canvas = context.canvas;
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );

    final inactiveRect = Rect.fromLTRB(
      thumbCenter.dx,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
    );

    if (active.shadowEnabled) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(activeRect.shift(const Offset(0, 2)), const Radius.circular(1)),
        Paint()
          ..color = active.shadowColor
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, active.shadowBlur),
      );
    }


    if (inactive.shadowEnabled) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(inactiveRect.shift(const Offset(0, 2)), const Radius.circular(1)),
        Paint()
          ..color = inactive.shadowColor
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, inactive.shadowBlur),
      );
    }


    canvas.drawRRect(
      RRect.fromRectAndRadius(activeRect, const Radius.circular(1)),
      Paint()..color = active.color,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(inactiveRect, const Radius.circular(1)),
      Paint()..color = inactive.color,
    );
  }
}