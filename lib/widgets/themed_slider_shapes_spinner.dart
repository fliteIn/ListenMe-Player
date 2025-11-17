import 'package:flutter/material.dart';
import '../models/app_theme_colors.dart';

/// Обычный бегунок (как раньше)
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
    this.size = 20.0, // ← добавили size
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
    final double radius = size / 2;

    if (shadowEnabled) {
      canvas.drawCircle(
        center + const Offset(0, 2),
        radius,
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
      radius,
      Paint()..color = color,
    );
  }
}

/// Трек с активным/неактивным сегментами и тенями
class DoubleShadowTrackShape extends SliderTrackShape {
  final ThemedColor active;
  final ThemedColor inactive;
  final double? pcmProgress;       // 0..1, ширина подложки PCM
  final ThemedColor? pcmColor;     // цвет/тень подложки PCM
  final double pcmHeight;          // высота подложки PCM (px), чуть выше trackHeight

  const DoubleShadowTrackShape({
    required this.active,
    required this.inactive,
    this.pcmProgress,
    this.pcmColor,
    this.pcmHeight = 8.0,
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

    // 🔹 Рисуем уровень PCM ПОВЕРХ трека
    if (pcmProgress != null && pcmColor != null) {
      final pcmWidth = trackRect.width * pcmProgress!.clamp(0.0, 1.0);
      final pcmRect = Rect.fromLTWH(
        trackRect.left,
        trackRect.top - (pcmHeight - trackRect.height) / 2,
        // выравниваем по центру
        pcmWidth,
        pcmHeight,
      );

      if (pcmColor!.shadowEnabled) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              pcmRect.shift(const Offset(0, 1)), const Radius.circular(1)),
          Paint()
            ..color = pcmColor!.shadowColor
            ..maskFilter = MaskFilter.blur(
                BlurStyle.normal, pcmColor!.shadowBlur),
        );
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(pcmRect, const Radius.circular(3)),
        Paint()
          ..color = pcmColor!.color,
      );
    }
  }
}

/// НЕ используется в новой схеме, но оставлен, если вдруг понадобится
class HiddenThumbShape extends SliderComponentShape {
  const HiddenThumbShape();
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;
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
      }) {}
}

/// Обёртка над Slider, которая при isAnalyzing рисует СПИННЕР
/// ПОВЕРХ обычного бегунка (бегунок не скрывается)
class ThemedSliderWithSpinner extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final bool isAnalyzing;
  final ThemedColor trackActive;
  final ThemedColor trackInactive;
  final ThemedThumbShape themedThumb;
  final double spinnerSize;
  final EdgeInsets trackPadding; // гориз. отступы трека
  final double? trackHeight;
  final Color? spinnerColor; // ← цвет спиннера (по умолчанию — buttonIconText)

  const ThemedSliderWithSpinner({
    super.key,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.isAnalyzing,
    required this.trackActive,
    required this.trackInactive,
    required this.themedThumb,
    this.spinnerSize = 12,
    this.trackPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.trackHeight,
    this.spinnerColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth - trackPadding.horizontal;
        final range = (max - min) == 0 ? 1.0 : (max - min);
        final t = ((value - min) / range).clamp(0.0, 1.0);
        final thumbX = trackPadding.left + trackWidth * t;

        final sliderTheme = SliderTheme.of(context).copyWith(
          trackHeight: trackHeight ?? (SliderTheme.of(context).trackHeight ?? 4.0),
          trackShape: DoubleShadowTrackShape(active: trackActive, inactive: trackInactive),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
          // ВАЖНО: бегунок НЕ скрываем — он остаётся под спиннером
          thumbShape: themedThumb,
        );

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Базовый слайдер
            Padding(
              padding: trackPadding,
              child: SliderTheme(
                data: sliderTheme,
                child: Slider(
                  min: min,
                  max: max,
                  value: value.clamp(min, max),
                  onChanged: onChanged,
                ),
              ),
            ),

            // Спиннер поверх бегунка во время анализа
            if (isAnalyzing)
              Positioned(
                left: thumbX - spinnerSize / 2,
                top: (sliderTheme.trackHeight! - spinnerSize) / 2,
                child: IgnorePointer( // не перехватывает жесты
                  child: SizedBox(
                    width: spinnerSize,
                    height: spinnerSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        spinnerColor ?? themedThumb.color,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
