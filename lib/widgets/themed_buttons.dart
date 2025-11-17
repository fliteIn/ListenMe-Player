import 'package:flutter/material.dart';
import '../models/app_theme_colors.dart';

BoxDecoration themedBoxDecoration(ThemedColor themedColor) {
  final blur = themedColor.shadowEnabled
      ? (themedColor.shadowBlur > 0 ? themedColor.shadowBlur : 0.1)
      : 0.0;

  return BoxDecoration(
    color: themedColor.color,
    borderRadius: BorderRadius.circular(6),
    boxShadow: themedColor.shadowEnabled
        ? [
      BoxShadow(
        color: themedColor.shadowColor,
        blurRadius: blur,
        offset: const Offset(0, 2),
      )
    ]
        : [],
  );
}

TextStyle themedTextStyle(
    ThemedColor themedColor,
    double fontSize, {
      bool bold = false,
      bool withShadow = true,
    }) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    color: themedColor.color,
    shadows: (withShadow && themedColor.shadowEnabled)
        ? [
      Shadow(
        color: themedColor.shadowColor,
        blurRadius:
        themedColor.shadowBlur > 0 ? themedColor.shadowBlur : 0.1,
        offset: const Offset(0, 2),
      )
    ]
        : [],
  );
}

class ThemedButton extends StatelessWidget {
  final VoidCallback onTap;
  final ThemedColor background;
  final ThemedColor foreground;
  final double width;
  final double height;
  final String? text;
  final Widget? child;

  const ThemedButton({
    super.key,
    required this.onTap,
    required this.background,
    required this.foreground,
    this.width = 200,
    this.height = 40,
    this.text,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: background.shadowEnabled
              ? [
            BoxShadow(
              color: background.shadowColor,
              blurRadius: background.shadowBlur,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: child ??
            Text(
              text ?? '',
              style: TextStyle(
                color: foreground.color,
                fontWeight: FontWeight.bold,
                shadows: foreground.shadowEnabled
                    ? [
                  Shadow(
                    color: foreground.shadowColor,
                    blurRadius: foreground.shadowBlur,
                    offset: const Offset(0, 1),
                  )
                ]
                    : [],
              ),
            ),
      ),
    );
  }
}
