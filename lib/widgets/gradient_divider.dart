import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';

class GradientDivider extends StatelessWidget {
  /// Процент ширины (0.0 — 0%, 1.0 — 100%)
  final double widthPercent;

  const GradientDivider({
    super.key,
    this.widthPercent = 0.75, // по умолчанию на всю ширину
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final colors = app.themeColors;
    final shadow = colors.gradientDividerShadow;

    return LayoutBuilder(
      builder: (context, constraints) {
        // constraints.maxWidth — ширина доступного пространства
        final width = constraints.maxWidth * widthPercent;

        return Center(
          child: SizedBox(
            width: width,
            child: Container(
              height: 1.5,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    colors.gradientDividerStart,
                    colors.gradientDividerEnd,
                    colors.gradientDividerStart,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                boxShadow: shadow.shadowEnabled
                    ? [
                  BoxShadow(
                    color: shadow.shadowColor,
                    blurRadius: shadow.shadowBlur,
                    offset: const Offset(0, 2),
                  )
                ]
                    : [],
              ),
            ),
          ),
        );
      },
    );
  }
}
