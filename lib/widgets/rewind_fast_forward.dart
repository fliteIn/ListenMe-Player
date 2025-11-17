import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import '../models/app_theme_colors.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import '../widgets/icon_with_shadow.dart';

enum ButtonSide { left, right }

class CurvedRewindButton extends StatefulWidget {
  final ButtonSide side;
  final double size;
  final double rewindButtonWidth;
  final double trackSwitchWidth;
  final double gap;
  final double? iconSize; // ← ДОБАВЬ
  final double? trackSwitchIconSize; // ← ДОБАВЬ для боковой кнопки
  final void Function(Offset localPosition, double height) onPanStart;
  final void Function(Offset localPosition, double height) onPanUpdate;
  final VoidCallback onPanEnd;
  final VoidCallback? onTrackSwitch;

  const CurvedRewindButton({
    super.key,
    required this.side,
    required this.size,
    required this.rewindButtonWidth,
    required this.trackSwitchWidth,
    required this.gap,
    this.iconSize, // ← ДОБАВЬ
    this.trackSwitchIconSize, // ← ДОБАВЬ
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    this.onTrackSwitch,
  });

  @override
  State<CurvedRewindButton> createState() => _CurvedRewindButtonState();
}

class _CurvedRewindButtonState extends State<CurvedRewindButton> {
  Timer? _seekDelayTimer;
  bool _canStartSeek = false;

  @override
  void dispose() {
    _seekDelayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final colors = app.themeColors;
    final shadow = colors.jogBackgroundShadow;
    final iconShadow = colors.widgetIconText;

    // Параметры для узкой кнопки и зазора
    final rewindButtonWidth = widget.rewindButtonWidth;
    final trackSwitchWidth = widget.trackSwitchWidth;
    final gap = widget.gap;

    final double iconSize = widget.iconSize ?? 20.0;
    final double trackSwitchIconSize = widget.trackSwitchIconSize ?? 26.0;


    final isPlaylistEmpty = app.currentPlaylist.isEmpty ||
        app.currentIndex == null ||
        app.currentIndex! < 0 ||
        app.currentIndex! >= app.currentPlaylist.length;


    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        SizedBox(
          width: rewindButtonWidth + trackSwitchWidth + gap,
          height: widget.size,
          child: Stack(
            children: [
              // --- Боковая кнопка ---
              Align(
                alignment: widget.side == ButtonSide.left
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: _TrackSwitchSmallButton(
                  side: widget.side,
                  height: widget.size,
                  onPressed: widget.onTrackSwitch,
                  width: trackSwitchWidth,
                  gap: gap,
                  iconSize: trackSwitchIconSize,
                  isPlaylistEmpty: isPlaylistEmpty,
                ),
              ),
              // --- Основная кривая кнопка ---
              Positioned(
                left:
                    widget.side == ButtonSide.left ? trackSwitchWidth + gap : 0,
                right: widget.side == ButtonSide.right
                    ? trackSwitchWidth + gap
                    : 0,
                top: 0,
                bottom: 0,
                child: SizedBox(
                  width: rewindButtonWidth,
                  height: widget.size,
                  child: Stack(
                      children: [
                        // 🟤 1. Тень под кнопкой
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _ButtonShadowPainter(widget.side, shadow),
                          ),
                        ),

                        // 🟦 2. Внешний наложенный край (наружу от джога)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _OuterEdgeOverlayPainter(side: widget.side),
                            ),
                          ),
                        ),

                        // 🟢 3. Основная кнопка (с вырезом)
                        ClipPath(
                          clipper: _CurvedClipper(side: widget.side),
                          child: Material(
                            color: Colors.transparent,
                            child: Ink(
                              width: rewindButtonWidth,
                              height: widget.size,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    colors.jogBackgroundStart,
                                    colors.jogBackgroundEnd,
                                  ],
                                ),
                              ),
                              child: InkWell(
                                borderRadius: widget.side == ButtonSide.left
                                    ? const BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                )
                                    : const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                onTapDown: isPlaylistEmpty ? null : (details) {
                                  final box = context.findRenderObject() as RenderBox;
                                  final local = box.globalToLocal(details.globalPosition);
                                  app.playbackModel.handleSeekStart();
                                  widget.onPanStart(local, widget.size);
                                },
                                onTapUp: isPlaylistEmpty ? null : (details) {
                                  final clamped = app.clampToMarkers(app.positionVN.value);
                                  app.player.seek(clamped);
                                  app.positionVN.value = clamped;
                                  app.playbackModel.handleSeekEnd();
                                  widget.onPanEnd();
                                },
                                onTapCancel: isPlaylistEmpty ? null : () {
                                  final clamped = app.clampToMarkers(app.positionVN.value);
                                  app.player.seek(clamped);
                                  app.positionVN.value = clamped;
                                  app.playbackModel.handleSeekEnd();
                                  widget.onPanEnd();
                                },
                                splashFactory: InkRipple.splashFactory,
                                child: Stack(
                                  children: [
                                    // 🟣 Внутренний белый треугольник
                                    Positioned.fill(
                                      child: TriangleGradientOverlay(
                                        jogStartColor: colors.jogBackgroundStart,
                                      ),
                                    ),
                                    // 🔘 Иконки перемотки
                                    Column(
                                      children: [
                                        const SizedBox(height: 10),
                                        Center(
                                          child: Transform.translate(
                                            offset: widget.side == ButtonSide.left
                                                ? const Offset(0.0, 0)
                                                : const Offset(0.0, 0),
                                            child: SizedBox(
                                              width: 35,
                                              height: 20,
                                              child: Stack(
                                                children: [
                                                  // Первая иконка
                                                  Positioned(
                                                    left: 0,
                                                    child: IconWithShadow(
                                                      icon: widget.side == ButtonSide.left
                                                          ? Icons.fast_rewind
                                                          : Icons.fast_forward,
                                                      size: iconSize,
                                                      color: iconShadow.color,
                                                      shadowColor: iconShadow.shadowColor,
                                                      shadowBlur: iconShadow.shadowBlur,
                                                      shadowEnabled: iconShadow.shadowEnabled,
                                                    ),
                                                  ),
                                                  // Вторая иконка
                                                  Positioned(
                                                    left: 15,
                                                    child: IconWithShadow(
                                                      icon: widget.side == ButtonSide.left
                                                          ? Icons.fast_rewind
                                                          : Icons.fast_forward,
                                                      size: iconSize,
                                                      color: iconShadow.color,
                                                      shadowColor: iconShadow.shadowColor,
                                                      shadowBlur: iconShadow.shadowBlur,
                                                      shadowEnabled: iconShadow.shadowEnabled,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Center(
                                          child: IconWithShadow(
                                            icon: widget.side == ButtonSide.left
                                                ? Icons.fast_rewind
                                                : Icons.fast_forward,
                                            size: iconSize,
                                            color: iconShadow.color,
                                            shadowColor: iconShadow.shadowColor,
                                            shadowBlur: iconShadow.shadowBlur,
                                            shadowEnabled: iconShadow.shadowEnabled,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 🟠 4. Внутренний край (прямоугольная полоска во всю высоту)
                        if (widget.side == ButtonSide.left)
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: CustomPaint(
                              size: Size(5, widget.size),
                              painter: _RectEdgeOverlayPainter(
                                side: ButtonSide.left,
                                shadow: shadow,
                              ),
                            ),
                          )
                        else
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: CustomPaint(
                              size: Size(5, widget.size),
                              painter: _RectEdgeOverlayPainter(
                                side: ButtonSide.right,
                                shadow: shadow,
                              ),
                            ),
                          ),

                        // 🟡 5. GestureDetector (обработка удержания)
                        Positioned.fill(
                          child: Builder(
                            builder: (context) {
                              final GestureArenaTeam team = GestureArenaTeam();
                              final app = context.read<AppModel>();

                              return RawGestureDetector(
                                behavior: HitTestBehavior.opaque,
                                gestures: {
                                  _AlwaysWinVerticalDragRecognizer:
                                  GestureRecognizerFactoryWithHandlers<
                                      _AlwaysWinVerticalDragRecognizer>(
                                        () => _AlwaysWinVerticalDragRecognizer()
                                      ..team = team
                                      ..dragStartBehavior = DragStartBehavior.down,
                                        (instance) {
                                      instance
                                        ..onDown = isPlaylistEmpty ? null : (details) {
                                          if (app.isSeeking) return;
                                          final box =
                                          context.findRenderObject() as RenderBox;
                                          final local =
                                          box.globalToLocal(details.globalPosition);
                                          app.playbackModel.handleSeekStart();
                                          widget.onPanStart(local, widget.size);
                                        }
                                        ..onUpdate = isPlaylistEmpty ? null : (details) {
                                          final box =
                                          context.findRenderObject() as RenderBox;
                                          final local =
                                          box.globalToLocal(details.globalPosition);
                                          widget.onPanUpdate(local, widget.size);
                                        }
                                        ..onEnd = isPlaylistEmpty ? null : (_) {
                                          final clamped =
                                          app.clampToMarkers(app.positionVN.value);
                                          app.player.seek(clamped);
                                          app.positionVN.value = clamped;
                                          app.playbackModel.handleSeekEnd();
                                          widget.onPanEnd();
                                        }
                                        ..onCancel = isPlaylistEmpty ? null : () {
                                          final clamped =
                                          app.clampToMarkers(app.positionVN.value);
                                          app.player.seek(clamped);
                                          app.positionVN.value = clamped;
                                          app.playbackModel.handleSeekEnd();
                                          widget.onPanEnd();
                                        };
                                    },
                                  ),
                                },
                              );
                            },
                          ),
                        ),
                      ],

                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _TrackSwitchSmallButton extends StatelessWidget {
  final ButtonSide side;
  final double height;
  final VoidCallback? onPressed;
  final double width;
  final double gap;
  final double? iconSize; // ← ДОБАВЬ
  final bool isPlaylistEmpty;

  const _TrackSwitchSmallButton({
    Key? key,
    required this.side,
    required this.height,
    required this.onPressed,
    required this.width,
    required this.gap,
    this.iconSize,
    required this.isPlaylistEmpty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final colors = app.themeColors;
    final shadow = colors.jogBackgroundShadow;
    final iconShadow = colors.widgetIconText;
    final overlaySide = side == ButtonSide.left ? ButtonSide.right : ButtonSide.left;


    final isPlaylistEmpty = app.currentPlaylist.isEmpty ||
        app.currentIndex == null ||
        app.currentIndex! < 0 ||
        app.currentIndex! >= app.currentPlaylist.length;


    return Container(
      margin: side == ButtonSide.left
          ? EdgeInsets.only(right: gap)
          : EdgeInsets.only(left: gap),
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Тень кнопки
          Positioned.fill(
            child: CustomPaint(
              painter: _TrackSwitchButtonShadowPainter(side, shadow),
            ),
          ),

          // 2. Основное тело кнопки
          ClipRRect(
            borderRadius: side == ButtonSide.left
                ? const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
            child: Material(
              color: Colors.transparent,
              child: Ink(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.jogBackgroundStart,
                      colors.jogBackgroundEnd,
                    ],
                  ),
                ),
                child: InkWell(
                  borderRadius: side == ButtonSide.left
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                        )
                      : const BorderRadius.only(
                          topRight: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                  onTap: isPlaylistEmpty ? null : onPressed,
                  child: Transform.translate(
                    offset: side == ButtonSide.left
                        ? const Offset(2.0, 0) // Смещаем вправо
                        : const Offset(-3.0, 0), // Смещаем влево
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 4),
                        _buildLines(colors.jogBackgroundStart),
                        const SizedBox(height: 10),
                        IconWithShadow(
                          icon: side == ButtonSide.left
                              ? Icons.skip_previous
                              : Icons.skip_next,
                          size: iconSize ?? 26.0, // теперь адаптивно
                          color: iconShadow.color,
                          shadowColor: iconShadow.shadowColor,
                          shadowBlur: iconShadow.shadowBlur,
                          shadowEnabled: iconShadow.shadowEnabled,
                        ),
                        const SizedBox(height: 10),
                        _buildLines(colors.jogBackgroundStart),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),

                ),
              ),
            ),
          ),

          // 3. Полупрозрачная накладка — теперь с тем же цветом, что и у кнопок перемотки!


    Positioned.fill(
    child: IgnorePointer(
    child: CustomPaint(
    painter: _InnerEdgeOverlayPainter(
    side: overlaySide,
    shadow: colors.jogBackgroundShadow,
    ),
    ),
    ),
    ),

        ],
      ),
    );
  }

  Widget _buildLines(Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(1, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            width: 2,
            height: 16,
            decoration: BoxDecoration(
              color: color.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 1),
                  blurRadius: 1,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  offset: const Offset(0, -1),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Тень боковой кнопки через CustomPaint (аналогично основной)
class _TrackSwitchButtonShadowPainter extends CustomPainter {
  final ButtonSide side;
  final ThemedColor shadow;

  _TrackSwitchButtonShadowPainter(this.side, this.shadow);

  @override
  void paint(Canvas canvas, Size size) {
    if (!shadow.shadowEnabled) return;
    final radius = 14.0;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 0, size.width, size.height),
          topLeft:
              side == ButtonSide.left ? Radius.circular(radius) : Radius.zero,
          bottomLeft:
              side == ButtonSide.left ? Radius.circular(radius) : Radius.zero,
          topRight:
              side == ButtonSide.right ? Radius.circular(radius) : Radius.zero,
          bottomRight:
              side == ButtonSide.right ? Radius.circular(radius) : Radius.zero,
        ),
      );
    final paint = Paint()
      ..color = shadow.shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.shadowBlur)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(0, 2); // смещение вниз на 2px (как у основной!)
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TriangleGradientOverlay extends StatelessWidget {
  final Color jogStartColor;

  const TriangleGradientOverlay({
    super.key,
    required this.jogStartColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EmbossedTrianglePainter(jogStartColor),
    );
  }
}

class _EmbossedTrianglePainter extends CustomPainter {
  final Color jogStartColor;

  _EmbossedTrianglePainter(this.jogStartColor);

  @override
  void paint(Canvas canvas, Size size) {
    final triangleHeight = size.height * 0.5;
    final triangleWidth = size.width * 0.25;
    final centerX = size.width / 2;
    final topY = (size.height - triangleHeight) / 2;
    final bottomY = topY + triangleHeight;

    final path = Path()
      ..moveTo(centerX, bottomY)
      ..lineTo(centerX - triangleWidth / 2, topY)
      ..lineTo(centerX + triangleWidth / 2, topY)
      ..close();

    // 🟫 Внутренняя заливка
    final fillPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // ⚫ Левая нижняя грань (тень)
    final shadowPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    final shadowPath = Path()
      ..moveTo(centerX - triangleWidth / 2, topY)
      ..lineTo(centerX, bottomY);
    canvas.drawPath(shadowPath, shadowPaint);

    // ⚪ Правая нижняя грань (блик)
    final highlightPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    final highlightPath = Path()
      ..moveTo(centerX + triangleWidth / 2, topY)
      ..lineTo(centerX, bottomY);
    canvas.drawPath(highlightPath, highlightPaint);

    // 🟤 Верхняя горизонтальная грань (тень от света сверху)
    final topEdgePaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final topEdgePath = Path()
      ..moveTo(centerX - triangleWidth / 2, topY)
      ..lineTo(centerX + triangleWidth / 2, topY);
    canvas.drawPath(topEdgePath, topEdgePaint);
  }

  @override
  bool shouldRepaint(covariant _EmbossedTrianglePainter oldDelegate) =>
      oldDelegate.jogStartColor != jogStartColor;
}


class _CurvedClipper extends CustomClipper<Path> {
  final ButtonSide side;

  _CurvedClipper({required this.side});

  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    final jogRadius = height / 2;
    final cutoutRadius = jogRadius;
    final cutoutHeight = height * 0.5;
    final cutoutTop = (height - cutoutHeight) / 2;
    final cutoutBottom = cutoutTop + cutoutHeight;

    // Скругления только с внешней стороны
    final externalRadius = 10.0;
    final internalRadius = 0.0;

    if (side == ButtonSide.left) {
      // Левая кнопка: радиус только topRight/bottomRight (внешние)
      path.moveTo(0, 0);
      path.lineTo(width - externalRadius, 0);
      path.arcToPoint(Offset(width, externalRadius),
          radius: Radius.circular(externalRadius), clockwise: true);
      path.lineTo(width, cutoutTop);
      path.arcToPoint(Offset(width, cutoutBottom),
          radius: Radius.circular(cutoutRadius), clockwise: false);
      path.lineTo(width, height - externalRadius);
      path.arcToPoint(Offset(width - externalRadius, height),
          radius: Radius.circular(externalRadius), clockwise: true);
      path.lineTo(0, height);
      // Внутренние углы прямые (internalRadius = 0)
      path.close();
    } else {
      // Правая кнопка: радиус только topLeft/bottomLeft (внешние)
      path.moveTo(width, 0);
      path.lineTo(externalRadius, 0);
      path.arcToPoint(Offset(0, externalRadius),
          radius: Radius.circular(externalRadius), clockwise: false);
      path.lineTo(0, cutoutTop);
      path.arcToPoint(Offset(0, cutoutBottom),
          radius: Radius.circular(cutoutRadius), clockwise: true);
      path.lineTo(0, height - externalRadius);
      path.arcToPoint(Offset(externalRadius, height),
          radius: Radius.circular(externalRadius), clockwise: false);
      path.lineTo(width, height);
      // Внутренние углы прямые (internalRadius = 0)
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ButtonShadowPainter extends CustomPainter {
  final ButtonSide side;
  final ThemedColor shadow;

  _ButtonShadowPainter(this.side, this.shadow);

  @override
  void paint(Canvas canvas, Size size) {
    if (!shadow.shadowEnabled) return;

    final path = _CurvedClipper(side: side).getClip(size);
    final paint = Paint()
      ..color = shadow.shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.shadowBlur)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(0, 2); // смещение вниз на 2px
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AlwaysWinVerticalDragRecognizer extends VerticalDragGestureRecognizer {
  _AlwaysWinVerticalDragRecognizer({Object? debugOwner})
      : super(debugOwner: debugOwner);

  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}

/// Внешняя тень с "скошенным" эффектом на наружном краю кнопки
class _OuterEdgeOverlayPainter extends CustomPainter {
  final ButtonSide side;

  _OuterEdgeOverlayPainter({required this.side});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = 14.0;
    final stripWidth = 5.0;

    // Внешняя форма кнопки (с тем же скруглением, что и в Ink)
    final outerRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: side == ButtonSide.left ? Radius.circular(radius) : Radius.zero,
      bottomLeft:
          side == ButtonSide.left ? Radius.circular(radius) : Radius.zero,
      topRight:
          side == ButtonSide.right ? Radius.circular(radius) : Radius.zero,
      bottomRight:
          side == ButtonSide.right ? Radius.circular(radius) : Radius.zero,
    );
    final outerPath = Path()..addRRect(outerRRect);

    // Внутренняя обрезка, чтобы оставить только край шириной stripWidth
    final innerRect = side == ButtonSide.left
        ? Rect.fromLTWH(stripWidth, 0, size.width - stripWidth, size.height)
        : Rect.fromLTWH(0, 0, size.width - stripWidth, size.height);

    final innerPath = Path()..addRect(innerRect);

    // Разница между внешней и внутренней формой
    final edgePath =
        Path.combine(PathOperation.difference, outerPath, innerPath);

    final paint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    canvas.drawPath(edgePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InnerEdgeOverlayPainter extends CustomPainter {
  final ButtonSide side;
  final ThemedColor shadow;

  _InnerEdgeOverlayPainter({
    required this.side,
    required this.shadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 10.0;
    const stripWidth = 5.0;
    const verticalInset = 2.0; // Добавляем инсет сверху и снизу!

    final outerRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        0,
        verticalInset, // <-- Инсет сверху
        size.width,
        size.height - verticalInset * 2, // <-- Инсет снизу
      ),
      topRight: side == ButtonSide.left ? Radius.circular(radius) : Radius.zero,
      bottomRight: side == ButtonSide.left ? Radius.circular(radius) : Radius.zero,
      topLeft: side == ButtonSide.right ? Radius.circular(radius) : Radius.zero,
      bottomLeft: side == ButtonSide.right ? Radius.circular(radius) : Radius.zero,
    );

    final outerPath = Path()..addRRect(outerRRect);

    final innerRect = side == ButtonSide.left
        ? Rect.fromLTWH(
      0,
      verticalInset, // <-- Инсет сверху
      size.width - stripWidth,
      size.height - verticalInset * 2, // <-- Инсет снизу
    )
        : Rect.fromLTWH(
      stripWidth,
      verticalInset, // <-- Инсет сверху
      size.width - stripWidth,
      size.height - verticalInset * 2, // <-- Инсет снизу
    );

    final innerPath = Path()..addRect(innerRect);

    final edgePath = Path.combine(PathOperation.difference, outerPath, innerPath);

    final paint = Paint()
      ..color = shadow.shadowColor.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    canvas.drawPath(edgePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RectEdgeOverlayPainter extends CustomPainter {
  final ButtonSide side;
  final ThemedColor shadow;

  const _RectEdgeOverlayPainter({required this.side, required this.shadow});

  @override
  void paint(Canvas canvas, Size size) {
    const stripWidth = 5.0;
    final paint = Paint()
      ..color = shadow.shadowColor.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final rect = side == ButtonSide.left
        ? Rect.fromLTWH(0, 0, stripWidth, size.height)
        : Rect.fromLTWH(size.width - stripWidth, 0, stripWidth, size.height);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

