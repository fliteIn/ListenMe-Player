import 'package:flutter/material.dart';
import '../models/app_theme_colors.dart';

class ThemedSymbolButton extends StatelessWidget {
  final String symbol;
  final VoidCallback onTap;
  final ThemedColor background;
  final ThemedColor foreground;
  final double? size;
  final double? fontSize;

  const ThemedSymbolButton({
    super.key,
    required this.symbol,
    required this.onTap,
    required this.background,
    required this.foreground,
    this.size,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? 32.0;
    final symbolFontSize = fontSize ?? (buttonSize * 0.72);

    final style = TextStyle(
      fontSize: symbolFontSize,  // ← теперь можно задать явно!
      fontWeight: FontWeight.bold,
      color: foreground.color,
      shadows: foreground.shadowEnabled
          ? [
        Shadow(
          color: foreground.shadowColor,
          blurRadius: foreground.shadowBlur > 0
              ? foreground.shadowBlur
              : 0.1,
          offset: const Offset(0, 2),
        )
      ]
          : [],
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: background.color,
          borderRadius: BorderRadius.circular(buttonSize * 0.27),
          boxShadow: background.shadowEnabled
              ? [
            BoxShadow(
              color: background.shadowColor,
              blurRadius: background.shadowBlur > 0
                  ? background.shadowBlur
                  : 0.1,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: CustomPaint(
          painter: _SymbolPainter(symbol: symbol, style: style),
        ),
      ),
    );
  }
}

class _SymbolPainter extends CustomPainter {
  final String symbol;
  final TextStyle style;
  final TextDirection textDirection;

  _SymbolPainter({
    required this.symbol,
    required this.style,
    this.textDirection = TextDirection.ltr,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(text: symbol, style: style),
      textDirection: textDirection,
    )..layout();

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
