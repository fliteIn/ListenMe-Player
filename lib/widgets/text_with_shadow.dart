import 'package:flutter/material.dart';

class TextWithShadow extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final Color shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;
  final bool shadowEnabled;
  final FontWeight fontWeight;
  final FontStyle fontStyle;

  final TextAlign? textAlign;
  final int? maxLines;

  const TextWithShadow({
    Key? key,
    required this.text,
    this.fontSize = 18,
    required this.color,
    required this.shadowColor,
    required this.shadowBlur,
    this.shadowOffset = const Offset(0, 2),
    this.shadowEnabled = true,
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
    this.textAlign,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Магия: "уникализируем" blur так же, как в IconWithShadow
    const double minBlur = 0.0;
    const double maxBlur = 32.0;
    final int colorMagic = shadowColor.value % 97;
    final double magicDelta = colorMagic * 0.05;
    final double patchedBlur = (shadowBlur <= minBlur + 0.05)
        ? shadowBlur + magicDelta
        : (shadowBlur >= maxBlur - 0.05)
        ? shadowBlur - magicDelta
        : shadowBlur + magicDelta;

    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        shadows: shadowEnabled
            ? [
          Shadow(
            color: shadowColor,
            blurRadius: patchedBlur,
            offset: shadowOffset,
          ),
        ]
            : [],
      ),
    );
  }
}
