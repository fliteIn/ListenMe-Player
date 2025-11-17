import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import '../widgets/icon_with_shadow.dart';

class JogWheel extends StatefulWidget {
  final bool staticMode;
  final Duration position;
  final Duration duration;
  final Duration? markerA;
  final Duration? markerB;
  final bool playBetweenMarkers;
  final bool isPlaying;
  final void Function(Duration newPosition) onKnobPanEnd;
  final void Function(Duration newPosition)? onKnobPanUpdate;
  final VoidCallback onPlayPauseToggle;
  final VoidCallback? onKnobTouchStart;
  final VoidCallback? onKnobTouchEnd;
  final VoidCallback? onBlockScroll;
  final VoidCallback? onUnblockScroll;

  // Для адаптивности:
  final double? size; // <--- Добавляем
  final double? jogSize;
  final double? knobSize;
  final double? innerButtonSize;

  const JogWheel({
    this.staticMode = false,
    super.key,
    required this.position,
    required this.duration,
    this.markerA,
    this.markerB,
    this.playBetweenMarkers = false,
    required this.isPlaying,
    required this.onKnobPanEnd,
    required this.onKnobPanUpdate,
    required this.onPlayPauseToggle,
    this.onKnobTouchStart,
    this.onKnobTouchEnd,
    this.onBlockScroll,
    this.onUnblockScroll,
    this.size, // <---- new!
    this.jogSize,
    this.knobSize,
    this.innerButtonSize,
  });

  @override
  State<JogWheel> createState() => _JogWheelState();
}

class _JogWheelState extends State<JogWheel>
    with SingleTickerProviderStateMixin {
  // Используем константы для стандартных размеров, но если заданы через параметры — используем их!
  late double jogSize;
  late double knobSize;
  late double innerButtonSize;

  bool _knobTouched = false;

  double? _startAngle;
  double? _previousAngle;
  double _accumulatedAngle = 0;
  Duration? _startPosition;

  late final Ticker _ticker;

  Duration _lastRawPosition = Duration.zero;
  Duration _smoothedPosition = Duration.zero;
  Duration _lastTickTime = Duration.zero;

  late int _rotationMs;
  Duration _lastPaintedPosition = Duration.zero;

  Duration _lastUiUpdateTime = Duration.zero;

  bool _shouldRepaint() {
    final newAngle = 2 * pi * (_smoothedPosition.inMilliseconds / _rotationMs);
    final oldAngle =
        2 * pi * (_lastPaintedPosition.inMilliseconds / _rotationMs);
    const threshold = 0.0087; // ~0.5 deg

    if ((newAngle - oldAngle).abs() > threshold) {
      _lastPaintedPosition = _smoothedPosition;
      return true;
    }
    return false;
  }

  Duration get _minBound =>
      widget.playBetweenMarkers &&
          widget.markerA != null &&
          widget.markerB != null
      ? (widget.markerA!.compareTo(widget.markerB!) < 0
            ? widget.markerA!
            : widget.markerB!)
      : Duration.zero;

  Duration get _maxBound =>
      widget.playBetweenMarkers &&
          widget.markerA != null &&
          widget.markerB != null
      ? (widget.markerA!.compareTo(widget.markerB!) > 0
            ? widget.markerA!
            : widget.markerB!)
      : widget.duration;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppModel>();
    _rotationMs = Duration(
      seconds: app.jogResolutionSecondsPerRevolution,
    ).inMilliseconds;
    // Приоритет: size > jogSize > default
    jogSize = widget.size ?? widget.jogSize ?? 140;
    knobSize = widget.knobSize ?? 20;
    innerButtonSize = widget.innerButtonSize ?? 54;

    if (!widget.staticMode) {
      _ticker = Ticker(_onTick)..start();
    }
  }

  @override
  void dispose() {
    if (!widget.staticMode) {
      _ticker.dispose();
    }
    super.dispose();
  }

  Duration _calculatePreviewPosition() {
    final app = context.read<AppModel>();
    final rotationMs = Duration(
      seconds: app.jogResolutionSecondsPerRevolution,
    ).inMilliseconds;

    final deltaMs = (_accumulatedAngle / (2 * pi) * rotationMs).round();
    final startMs = _startPosition?.inMilliseconds ?? 0;
    final previewMs = (startMs + deltaMs).clamp(
      _minBound.inMilliseconds,
      _maxBound.inMilliseconds,
    );

    return Duration(milliseconds: previewMs);
  }

  void _onTick(Duration elapsed) {
    if (_knobTouched) return;

    final app = context.read<AppModel>();
    final raw = app.positionVN.value;

    // Фикс: учитываем текущую скорость воспроизведения
    final speed = app.player.speed;

    if (raw != _lastRawPosition) {
      _lastRawPosition = raw;
      _smoothedPosition = raw;
    }

    if (widget.isPlaying) {
      final dt = elapsed - _lastTickTime;
      _smoothedPosition += Duration(
        microseconds: (dt.inMicroseconds * speed).round(),
      );
    } else {
      _smoothedPosition = _lastRawPosition;
    }

    const minFrameInterval = Duration(milliseconds: 33);

    if ((elapsed - _lastUiUpdateTime) >= minFrameInterval && _shouldRepaint()) {
      _lastUiUpdateTime = elapsed;
      setState(() {});
    }

    _lastTickTime = elapsed;
  }

  void _handlePanStart(DragStartDetails details) {
    _knobTouched = true;
    widget.onKnobTouchStart?.call();

    final app = context.read<AppModel>();
    app.knobTouchVN.value++;

    final box = context.findRenderObject() as RenderBox;
    final local = box.globalToLocal(details.globalPosition);
    final size = box.size;
    final center = Offset(size.width / 2, size.height / 2);
    final angle = atan2(local.dy - center.dy, local.dx - center.dx);

    _startAngle = angle;
    _previousAngle = angle;
    _accumulatedAngle = 0;
    _startPosition = context.read<AppModel>().positionVN.value;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_knobTouched ||
        _startAngle == null ||
        _startPosition == null ||
        _previousAngle == null)
      return;

    final box = context.findRenderObject() as RenderBox;
    final local = box.globalToLocal(details.globalPosition);
    final size = box.size;
    final center = Offset(size.width / 2, size.height / 2);
    final currentAngle = atan2(local.dy - center.dy, local.dx - center.dx);

    double delta = currentAngle - _previousAngle!;
    if (delta > pi) delta -= 2 * pi;
    if (delta < -pi) delta += 2 * pi;

    _accumulatedAngle += delta;
    _previousAngle = currentAngle;

    final rotationMs = Duration(
      seconds: context.read<AppModel>().jogResolutionSecondsPerRevolution,
    ).inMilliseconds;
    final deltaMs = (_accumulatedAngle / (2 * pi) * rotationMs).round();
    final tentativeMs = _startPosition!.inMilliseconds + deltaMs;

    if (tentativeMs < _minBound.inMilliseconds ||
        tentativeMs > _maxBound.inMilliseconds)
      return;

    final clampedMs = tentativeMs.clamp(
      _minBound.inMilliseconds,
      _maxBound.inMilliseconds,
    );
    final newPosition = Duration(milliseconds: clampedMs);

    context.read<AppModel>().seekThrottled(newPosition);
    setState(() {});
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_knobTouched) {
      final newPosition = _calculatePreviewPosition();
      widget.onKnobPanEnd(newPosition);

      _lastRawPosition = newPosition;
      _smoothedPosition = newPosition;
    }

    _knobTouched = false;
    widget.onKnobTouchEnd?.call();
    _startAngle = null;
    _startPosition = null;
    _previousAngle = null;
    _accumulatedAngle = 0;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppModel>();

    final colors = app.themeColors;
    final jogShadow = colors.jogBackgroundShadow;
    final knobShadow = colors.controlElements;

    final int rotationMs = Duration(
      seconds: app.jogResolutionSecondsPerRevolution,
    ).inMilliseconds;

    final position = widget.staticMode
        ? widget.position
        : (_knobTouched ? _calculatePreviewPosition() : _smoothedPosition);
    final angle = 2 * pi * (position.inMilliseconds / rotationMs) - pi / 2;

    final knobRadius = jogSize / 2 - knobSize / 2 - 10;
    final knobOffset = Offset(
      knobRadius * cos(angle) - 15,
      knobRadius * sin(angle) - 15,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        SizedBox(
          width: jogSize,
          height: jogSize,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Тень джога
              Container(
                width: jogSize,
                height: jogSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  boxShadow: jogShadow.shadowEnabled
                      ? [
                          BoxShadow(
                            color: jogShadow.shadowColor,
                            blurRadius: jogShadow.shadowBlur,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
              ),
              // Градиент джога
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      colors.jogBackgroundStart,
                      colors.jogBackgroundEnd,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: Container(
                  width: jogSize,
                  height: jogSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
              // Кноб
              Positioned(
                left: jogSize / 2 - knobSize / 2 + knobOffset.dx,
                top: jogSize / 2 - knobSize / 2 + knobOffset.dy,
                child: RawGestureDetector(
                  gestures: {
                    _AlwaysWinPanGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          _AlwaysWinPanGestureRecognizer
                        >(() => _AlwaysWinPanGestureRecognizer(), (instance) {
                          instance
                            ..onStart = _handlePanStart
                            ..onUpdate = _handlePanUpdate
                            ..onEnd = _handlePanEnd;
                        }),
                  },
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: knobSize + 30,
                    height: knobSize + 30,
                    child: Center(
                      child: Container(
                        width: knobSize,
                        height: knobSize,
                        decoration: BoxDecoration(
                          color: knobShadow.color,
                          shape: BoxShape.circle,
                          boxShadow: knobShadow.shadowEnabled
                              ? [
                                  BoxShadow(
                                    color: knobShadow.shadowColor,
                                    blurRadius: knobShadow.shadowBlur,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Центральная кнопка Play/Pause
              Stack(
                alignment: Alignment.center,
                children: [
                  // Тень
                  IgnorePointer(
                    child: Transform.translate(
                      offset: Offset(0.0, 2.0),
                      child: Transform.rotate(
                        angle: angle + pi / 2,
                        child: Transform.translate(
                          offset: Offset(0.0, 0.0),
                          child: IconWithShadow(
                            icon: widget.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            size: innerButtonSize,
                            color: Colors.transparent,
                            shadowColor: knobShadow.shadowColor,
                            shadowBlur: knobShadow.shadowBlur > 0
                                ? knobShadow.shadowBlur
                                : 0.01,
                            shadowEnabled: knobShadow.shadowEnabled,
                            shadowOffset: Offset.zero,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Кнопка
                  Transform.rotate(
                    angle: angle + pi / 2,
                    child: Transform.translate(
                      offset: Offset(0.0, 0.0),
                      child: smallIconButton(
                        icon: widget.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        iconSize: innerButtonSize,
                        buttonSize: innerButtonSize,
                        onPressed: widget.onPlayPauseToggle,
                        applyShadow: false,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget smallIconButton({
    required IconData icon,
    required double iconSize,
    required VoidCallback? onPressed,
    double buttonSize = 36,
    bool applyShadow = true,
  }) {
    final themed = context.watch<AppModel>().themeColors.controlElements;
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: IconButton(
        icon: IconWithShadow(
          icon: icon,
          size: iconSize,
          color: themed.color,
          shadowColor: themed.shadowColor,
          shadowBlur: themed.shadowBlur,
          shadowEnabled: applyShadow && themed.shadowEnabled,
        ),
        onPressed: onPressed,
        splashRadius: buttonSize / 2,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}

class _AlwaysWinPanGestureRecognizer extends PanGestureRecognizer {
  _AlwaysWinPanGestureRecognizer() {
    team = GestureArenaTeam();
  }

  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}
