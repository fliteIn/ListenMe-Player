import 'package:flutter/material.dart';

class IconWithShadow extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;
  final bool shadowEnabled;

  const IconWithShadow({
    Key? key,
    required this.icon,
    this.size = 24.0,
    required this.color,
    required this.shadowColor,
    required this.shadowBlur,
    this.shadowOffset = const Offset(0, 2),
    this.shadowEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Магия с уникализацией blur
    const double minBlur = 0.0;
    const double maxBlur = 32.0;
    final int colorMagic = shadowColor.value % 97;
    final double magicDelta = colorMagic * 0.05; // Рабочее значение
    final double patchedBlur = (shadowBlur <= minBlur + 0.05)
        ? shadowBlur + magicDelta
        : (shadowBlur >= maxBlur - 0.05)
        ? shadowBlur - magicDelta
        : shadowBlur + magicDelta;

    return Icon(
      icon,
      size: size,
      color: color,
      shadows: shadowEnabled
          ? [
        Shadow(
          color: shadowColor,
          blurRadius: patchedBlur,
          offset: shadowOffset,
        ),
      ]
          : [],
    );
  }
}
