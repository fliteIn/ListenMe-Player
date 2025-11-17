import 'package:flutter/material.dart';
import '../models/app_theme_colors.dart';

Text buildShadowedTextSimple(
    String text,
    ThemedColor themed, {
      double fontSize = 14,
      FontWeight fontWeight = FontWeight.normal,
    }) {
  return Text(
    text,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: themed.color,
      shadows: themed.shadowEnabled
          ? [
        Shadow(
          color: themed.shadowColor,
          blurRadius: themed.shadowBlur > 0 ? themed.shadowBlur : 0.1,
          offset: const Offset(0, 2),
        )
      ]
          : [],
    ),
  );
}

Widget buildShadowedIcon(
    IconData icon,
    ThemedColor themed, {
      double size = 24,
    }) {
  return Icon(
    icon,
    size: size,
    color: themed.color,
    shadows: themed.shadowEnabled
        ? [
      Shadow(
        color: themed.shadowColor,
        blurRadius: themed.shadowBlur > 0 ? themed.shadowBlur : 0.1,
        offset: const Offset(0, 2),
      )
    ]
        : [],
  );
}
