import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import '../models/audio_to_levels_model.dart';

import 'themed_slider_shapes_spinner.dart';
import 'dart:math' as math;

class SilenceControlBar extends StatelessWidget {
  final double silenceThresholdDb;
  final double currentPcmLevel;
  final List<double> pcmLevels;
  final VoidCallback onJumpToPrevSilence;
  final VoidCallback onJumpToNextSilence;
  final ValueChanged<double> onThresholdChanged;
  final VoidCallback onThresholdChangeEnd;

  // --- Адаптивные параметры
  final double? height;
  final double? fontSize;
  final double? sideButtonWidth;
  final double? triangleSize;
  final double? sliderHeight;
  final double? sliderThumbRadius;
  final double? spinnerSize;
  final double? trackHeight;

  const SilenceControlBar({
    super.key,
    required this.silenceThresholdDb,
    required this.currentPcmLevel,
    required this.pcmLevels,
    required this.onJumpToPrevSilence,
    required this.onJumpToNextSilence,
    required this.onThresholdChanged,
    required this.onThresholdChangeEnd,
    this.height,
    this.fontSize,
    this.sideButtonWidth,
    this.triangleSize,
    this.sliderHeight,
    this.sliderThumbRadius,
    this.spinnerSize,
    this.trackHeight,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final colors = app.themeColors;

    // --- Адаптивные размеры
    final double _height = height ?? 56.0;
    final double _fontSize = fontSize ?? 14.0;
    final double _sideButtonWidth = sideButtonWidth ?? 56.0;
    final double _triangleSize = triangleSize ?? 32.0;
    final double _sliderHeight = sliderHeight ?? 28.0;
    final double _sliderThumbRadius = sliderThumbRadius ?? 10.0;
    final double _spinnerSize = spinnerSize ?? 12.0;
    final double _trackHeight = trackHeight ?? 4.0;

    return SizedBox(
      height: _height,
      child: Row(
        children: [
          SizedBox(width: _sideButtonWidth),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${silenceThresholdDb.toStringAsFixed(1)} dB',
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.normal,
                    color: colors.currentValueText.color,
                    shadows: colors.currentValueText.shadowEnabled
                        ? [
                      Shadow(
                        color: colors.currentValueText.shadowColor,
                        blurRadius: colors.currentValueText.shadowBlur > 0
                            ? colors.currentValueText.shadowBlur
                            : 0.1,
                        offset: const Offset(0, 2),
                      )
                    ]
                        : [],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: _sliderHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Левый треугольник с точкой
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onJumpToPrevSilence,
                        child: Center(
                          child: TriangleWithDot(
                            size: _triangleSize,
                            color: colors.controlElements.color,
                            mirrored: false,
                            dotOnRight: false,
                            shadowEnabled: colors.controlElements.shadowEnabled,
                            shadowColor: colors.controlElements.shadowColor,
                            shadowBlur: colors.controlElements.shadowBlur,
                            shadowOffset: const Offset(0, 2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Слайдер по центру
                      Expanded(
                        child: Center(
                          child: _buildSlider(
                            context,
                            thumbRadius: _sliderThumbRadius,
                            spinnerSize: _spinnerSize,
                            trackHeight: _trackHeight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Правый треугольник с точкой
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onJumpToNextSilence,
                        child: Center(
                          child: TriangleWithDot(
                            size: _triangleSize,
                            color: colors.controlElements.color,
                            mirrored: true,
                            dotOnRight: true,
                            shadowEnabled: colors.controlElements.shadowEnabled,
                            shadowColor: colors.controlElements.shadowColor,
                            shadowBlur: colors.controlElements.shadowBlur,
                            shadowOffset: const Offset(0, 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: _sideButtonWidth),
        ],
      ),
    );
  }

  Widget _buildSlider(
      BuildContext context, {
        required double thumbRadius,
        required double spinnerSize,
        required double trackHeight,
      }) {
    final app = context.watch<AppModel>();
    final colors = app.themeColors;
    final isAnalyzing = context.select<AudioToLevelsModel?, bool>(
          (m) => (m?.isAnalyzing ?? false) || ((m?.analyzeProgress ?? 0) > 0),
    );

    const double sliderMin = -70;
    const double sliderMax = 0;
    final double threshold = silenceThresholdDb;

    return LayoutBuilder(
      builder: (context, constraints) {
        const double trackLeft = 8.0;
        const double trackRight = 8.0;

        final double sliderWidth = constraints.maxWidth;
        final double min = sliderMin;
        final double max = sliderMax;
        final double value = threshold.clamp(sliderMin, sliderMax);
        final double t = ((value - min) / (max - min)).clamp(0.0, 1.0);

        // Вычисляем позицию бегунка, чтобы не вылазил за границы
        final double leftEdge = trackLeft;
        final double rightEdge = sliderWidth - trackRight;
        final double thumbCenterX = leftEdge + (rightEdge - leftEdge) * t;

        return Stack(
          alignment: Alignment.centerLeft,
          clipBehavior: Clip.none,
          children: [
            // Сам Slider
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                  begin: 0.0, end: currentPcmLevel.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 200),
              builder: (context, animatedPcm, _) {
                final pcmLevel = animatedPcm.clamp(1e-9, 1.0);
                const sliderMin = -70.0;
                const sliderMax = 0.0;
                final pcmDb = 20 * math.log(pcmLevel) / math.ln10;
                final dBnormalized =
                ((pcmDb - sliderMin) / (sliderMax - sliderMin))
                    .clamp(0.0, 1.0);

                return SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                    overlayShape: SliderComponentShape.noOverlay,
                    showValueIndicator: ShowValueIndicator.never,
                    trackHeight: trackHeight,
                    trackShape: DoubleShadowTrackShape(
                      active: colors.sliderActiveSegment,
                      inactive: colors.sliderInactiveSegment,
                      pcmProgress: dBnormalized,
                      pcmColor: colors.sliderActiveSegment,
                      pcmHeight: trackHeight * 2,
                    ),
                    thumbShape: ThemedThumbShape(
                      color: colors.controlElements.color,
                      shadowColor: colors.controlElements.shadowColor,
                      shadowBlur: colors.controlElements.shadowBlur,
                      shadowEnabled: colors.controlElements.shadowEnabled,
                      size: thumbRadius * 2,
                    ),
                  ),
                  child: Slider(
                    value: threshold.clamp(sliderMin, sliderMax),
                    min: sliderMin,
                    max: sliderMax,
                    divisions: 70,
                    onChanged: onThresholdChanged,
                    onChangeEnd: (v) async {
                      final appModel = context.read<AppModel>();
                      appModel.persistentState.silenceThreshold = v;
                      await appModel.persistentState.save();
                      onThresholdChangeEnd();
                    },
                  ),
                );
              },
            ),

            // Спиннер поверх бегунка
            if (isAnalyzing)
              Positioned(
                left: thumbCenterX - spinnerSize / 2,
                top: (constraints.maxHeight - spinnerSize) / 2,
                child: IgnorePointer(
                  child: _ArcSpinner(
                    size: spinnerSize,
                    strokeWidth: 2,
                    color: colors.buttonIconText.color,
                    shadowEnabled: colors.buttonIconText.shadowEnabled,
                    shadowColor: colors.buttonIconText.shadowColor,
                    shadowBlur: colors.buttonIconText.shadowBlur > 0
                        ? colors.buttonIconText.shadowBlur
                        : 0.1,
                    shadowOffset: const Offset(0, 2),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
// Теневой контур под спиннер: тень — это размазанный штрих по окружности
class _SpinnerStrokeShadowPainter extends CustomPainter {
  final Color color;
  final double blur;
  final bool enabled;
  final double strokeWidth;
  final Offset offset;

  const _SpinnerStrokeShadowPainter({
    required this.color,
    required this.blur,
    required this.enabled,
    required this.strokeWidth,
    this.offset = const Offset(0, 2),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!enabled) return;

    // смещаем вниз, как у остальных теней
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width / 2) - strokeWidth / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    // Рисуем именно КОНТУР (полое кольцо), а не заливку:
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      // можно сделать полную окружность — так точно совпадёт с формой индикатора
      2 * math.pi,
      // если захочешь тень только под «дугой», скажи — дам кастомный спиннер
      false,
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpinnerStrokeShadowPainter old) {
    return old.color != color ||
        old.blur != blur ||
        old.enabled != enabled ||
        old.strokeWidth != strokeWidth ||
        old.offset != offset;
  }
}

class TriangleWithDot extends StatelessWidget {
  final double size;
  final Color color;
  final bool mirrored;
  final bool dotOnRight;
  final bool shadowEnabled;
  final Color shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;

  const TriangleWithDot({
    Key? key,
    this.size = 22,
    required this.color,
    this.mirrored = false,
    this.dotOnRight = false,
    this.shadowEnabled = false,
    this.shadowColor = Colors.black,
    this.shadowBlur = 4,
    this.shadowOffset = const Offset(0, 2),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TriangleWithDotPainter(
          color: color,
          mirrored: mirrored,
          dotOnRight: dotOnRight,
          shadowEnabled: shadowEnabled,
          shadowColor: shadowColor,
          shadowBlur: shadowBlur,
          shadowOffset: shadowOffset,
        ),
      ),
    );
  }
}

class _TriangleWithDotPainter extends CustomPainter {
  final Color color;
  final bool mirrored;
  final bool dotOnRight;
  final bool shadowEnabled;
  final Color shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;

  _TriangleWithDotPainter({
    required this.color,
    required this.mirrored,
    required this.dotOnRight,
    required this.shadowEnabled,
    required this.shadowColor,
    required this.shadowBlur,
    required this.shadowOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double triSize = size.width * 0.58;
    final double centerY = size.height / 2;

    Path triangle = Path();

    triangle.moveTo(size.width * (mirrored ? 0.72 : 0.28), centerY);
    triangle.lineTo(
        size.width * (mirrored ? 0.32 : 0.68), centerY - triSize / 2);
    triangle.lineTo(
        size.width * (mirrored ? 0.32 : 0.68), centerY + triSize / 2);
    triangle.close();

    // Тень
    if (shadowEnabled && shadowBlur > 0.1) {
      canvas.save();
      canvas.translate(shadowOffset.dx, shadowOffset.dy);
      canvas.drawPath(
        triangle,
        paint
          ..color = shadowColor.withOpacity(0.6)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur),
      );
      canvas.restore();
      paint
        ..color = color
        ..maskFilter = null;
    }

    // Треугольник
    canvas.drawPath(triangle, paint);

    // Маленькая точка
    final double dotRadius = size.width * 0.10;
    final double dotX = dotOnRight ? size.width * 0.90 : size.width * 0.10;
    final double dotY = centerY;

    if (shadowEnabled && shadowBlur > 0.1) {
      canvas.save();
      canvas.translate(shadowOffset.dx, shadowOffset.dy);
      canvas.drawCircle(
        Offset(dotX, dotY),
        dotRadius,
        Paint()
          ..color = shadowColor.withOpacity(0.5)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur),
      );
      canvas.restore();
    }
    canvas.drawCircle(
      Offset(dotX, dotY),
      dotRadius,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _TriangleWithDotPainter oldDelegate) => true;
}

// ========== ArcSpinner (анимированный спиннер) ==========

class _ArcSpinner extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final Color color;

  final bool shadowEnabled;
  final Color shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;

  const _ArcSpinner({
    required this.size,
    required this.strokeWidth,
    required this.color,
    required this.shadowEnabled,
    required this.shadowColor,
    required this.shadowBlur,
    this.shadowOffset = const Offset(0, 2),
  });

  @override
  State<_ArcSpinner> createState() => _ArcSpinnerState();
}

class _ArcSpinnerState extends State<_ArcSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final startAngle = _ctrl.value * 2 * math.pi;
          final sweepAngle = 1.5 * math.pi;

          return CustomPaint(
            painter: _ArcSpinnerPainter(
              color: widget.color,
              strokeWidth: widget.strokeWidth,
              startAngle: startAngle,
              sweepAngle: sweepAngle,
              shadowEnabled: widget.shadowEnabled,
              shadowColor: widget.shadowColor,
              shadowBlur: widget.shadowBlur,
              shadowOffset: widget.shadowOffset,
            ),
          );
        },
      ),
    );
  }
}

class _ArcSpinnerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  final bool shadowEnabled;
  final Color shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;

  _ArcSpinnerPainter({
    required this.color,
    required this.strokeWidth,
    required this.startAngle,
    required this.sweepAngle,
    required this.shadowEnabled,
    required this.shadowColor,
    required this.shadowBlur,
    required this.shadowOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide / 2) - strokeWidth / 2;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    // 1) ТЕНЬ (если активна)
    if (shadowEnabled && shadowBlur >= 0) {
      final shadowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 1.5
        ..strokeCap = StrokeCap.round
        ..color = shadowColor.withOpacity(1.0)
        ..maskFilter = MaskFilter.blur(
            BlurStyle.normal, shadowBlur > 0.2 ? shadowBlur : 0.17);

      canvas.save();
      canvas.translate(shadowOffset.dx, shadowOffset.dy);
      canvas.drawArc(arcRect, startAngle, sweepAngle, false, shadowPaint);
      canvas.restore();
    }

    // 2) ОСНОВНАЯ ДУГА (всегда!)
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawArc(arcRect, startAngle, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _ArcSpinnerPainter old) {
    return old.color != color ||
        old.strokeWidth != strokeWidth ||
        old.startAngle != startAngle ||
        old.sweepAngle != sweepAngle ||
        old.shadowEnabled != shadowEnabled ||
        old.shadowColor != shadowColor ||
        old.shadowBlur != shadowBlur ||
        old.shadowOffset != shadowOffset;
  }
}
