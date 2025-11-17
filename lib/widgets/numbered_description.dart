import 'package:flutter/material.dart';
import '../models/app_theme_colors.dart';
import '../widgets/themed_text.dart';

/// Универсальный кружок с тенью от фона и текста
Widget buildThemedCircle({
  required String text,
  required ThemedColor background,
  required ThemedColor foreground,
  double size = 20,
  double fontSize = 12,
}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: background.color,
      boxShadow: background.shadowEnabled
          ? [
        BoxShadow(
          color: background.shadowColor,
          blurRadius: background.shadowBlur,
          offset: const Offset(0, 2),
        )
      ]
          : [],
    ),
    child: Center(
      child: Text(
        text,
        style: TextStyle(
          color: foreground.color,
          fontSize: fontSize,
          shadows: foreground.shadowEnabled
              ? [
            Shadow(
              color: foreground.shadowColor,
              blurRadius: foreground.shadowBlur,
              offset: const Offset(0, 2),
            )
          ]
              : [],
        ),
      ),
    ),
  );
}

Widget numberCircle(String number, AppThemeColors theme) {
  return buildThemedCircle(
    text: number,
    background: theme.controlElements,
    foreground: theme.buttonIconText,
    size: 20,
    fontSize: 12,
  );
}

Widget numberedDescription(
    BuildContext context,
    String number,
    String text,
    AppThemeColors theme,
    ) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildThemedCircle(
          text: number,
          background: theme.controlElements,
          foreground: theme.buttonIconText,
          size: 20,
          fontSize: 12,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: buildShadowedText(
            context,
            text,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    ),
  );
}
