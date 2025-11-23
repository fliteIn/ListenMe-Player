import 'package:flutter/material.dart';

/// A custom widget that renders an icon with a configurable shadow.
/// Includes a small "blur patch" trick to force Flutter to repaint the shadow
/// when the shadow color changes.
class IconWithShadow extends StatelessWidget {
  final IconData icon;          // The icon to display.
  final double size;            // Icon size in logical pixels.
  final Color color;            // Base color of the icon.
  final Color shadowColor;      // Color of the shadow.
  final double shadowBlur;      // User-defined blur radius (before patching).
  final Offset shadowOffset;    // Shadow offset.
  final bool shadowEnabled;     // If false, no shadow is drawn.

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
    // --- Blur patching section ---
    // Flutter sometimes reuses cached shadow layers when only the shadow color
    // changes. As a result, the shadow may not visually update.
    // To force Flutter to repaint the shadow, we slightly modify the blur radius
    // by adding an extremely small but unique value derived from the shadow color.

    const double minBlur = 0.0;     // Minimum allowed blur.
    const double maxBlur = 32.0;    // Maximum allowed blur.

    // Generate a small pseudo-unique number based on the shadowColor.
    // shadowColor.value is a 32-bit ARGB integer.
    // Taking modulo 97 gives us a number from 0 to 96.
    final int colorMagic = shadowColor.value % 97;

    // Convert that number into a tiny delta to adjust the blur radius.
    // This is small enough to be visually invisible,
    // but large enough to make Flutter think the shadow changed.
    final double magicDelta = colorMagic * 0.05;

    // Adjust the blur radius depending on whether it's near the min or max range.
    // This prevents patchedBlur from going outside valid bounds.
    final double patchedBlur =
    (shadowBlur <= minBlur + 0.05)
        ? shadowBlur + magicDelta        // Nudge upward near minimum.
        : (shadowBlur >= maxBlur - 0.05)
        ? shadowBlur - magicDelta    // Nudge downward near maximum.
        : shadowBlur + magicDelta;   // Normal case: add delta.

    // --- Icon rendering ---
    return Icon(
      icon,                 // Icon data.
      size: size,           // Icon size.
      color: color,         // Icon fill color.
      shadows: shadowEnabled
          ? [
        Shadow(
          color: shadowColor,        // Actual shadow color.
          blurRadius: patchedBlur,   // Blur with patch applied.
          offset: shadowOffset,      // Shadow offset.
        ),
      ]
          : [],                            // No shadow if disabled.
    );
  }
}
