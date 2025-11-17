import 'package:flutter/material.dart';
import '../models/app_theme_colors.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';

class ThemedShadowText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final BuildContext context;

  const ThemedShadowText({
    super.key,
    required this.context,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final themed = Theme.of(this.context).extension<AppThemeColors>()?.currentValueText;

    final shadowColor = themed?.shadowColor ?? Colors.transparent;
    final shadowBlur = themed?.shadowBlur ?? 0.0;

    return Text(
      text,
      style: style.copyWith(shadows: [
        Shadow(
          color: shadowColor,
          blurRadius: shadowBlur,
          offset: const Offset(0, 2),
        ),
      ]),
      textAlign: textAlign,
    );
  }
}


Widget buildShadowedText(
    BuildContext context,
    String text, {
      double fontSize = 16,
      FontWeight fontWeight = FontWeight.normal,
      TextAlign textAlign = TextAlign.center,
      TextOverflow? overflow,
      int? maxLines,
    }) {
  final themeColors = context.watch<AppModel>().themeColors;
  final themed = themeColors.currentValueText;

  return Text(
    text,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: themed.color,
      shadows: themed.shadowEnabled
          ? [
        Shadow(
          offset: const Offset(0, 2),
          blurRadius: themed.shadowBlur,
          color: themed.shadowColor,
        ),
      ]
          : null,
    ),
  );
}

