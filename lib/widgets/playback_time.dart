import 'package:flutter/material.dart';
import '../enums/enums.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import '../models/app_theme_colors.dart';

class PlaybackTime extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final TimeDisplayStyle style;
  final SecondaryTimeType secondaryTimeType;
  final double? fontSize;
  final double? height;
  final double? sideButtonWidth; // <-- новый параметр!

  const PlaybackTime({
    Key? key,
    required this.position,
    required this.duration,
    this.style = TimeDisplayStyle.mmss,
    this.secondaryTimeType = SecondaryTimeType.remaining,
    this.fontSize,
    this.height,
    this.sideButtonWidth, // <-- новый параметр!
  }) : super(key: key);

  String _format(Duration d, TimeDisplayStyle style) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final millis = d.inMilliseconds.remainder(1000);

    String prefix = hours > 0 ? '${hours.toString().padLeft(2, '0')}:' : '';

    switch (style) {
      case TimeDisplayStyle.mmss:
        return '$prefix$minutes:$seconds';
      case TimeDisplayStyle.mmss2digitMillis:
        final twoDigits = (millis ~/ 10).toString().padLeft(2, '0');
        return '$prefix$minutes:$seconds:$twoDigits';
      case TimeDisplayStyle.mmss3digitMillis:
        final threeDigits = millis.toString().padLeft(3, '0');
        return '$prefix$minutes:$seconds:$threeDigits';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themed = context.watch<AppModel>().themeColors.currentValueText;
    final remaining = duration - position;
    final double _sideButtonWidth = sideButtonWidth ?? 58.0;

    return SizedBox(
      height: height ?? 20,
      child: Row(
        children: [
          SizedBox(width: _sideButtonWidth), // Левая фейковая кнопка (адаптивно)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildShadowedText(
                  _format(position, style),
                  themed,
                  fontSize,
                ),
                _buildShadowedText(
                  secondaryTimeType == SecondaryTimeType.remaining
                      ? '-${_format(remaining, style)}'
                      : _format(duration, style),
                  themed,
                  fontSize,
                ),
              ],
            ),
          ),
          SizedBox(width: _sideButtonWidth), // Правая фейковая кнопка (адаптивно)
        ],
      ),
    );
  }

  Widget _buildShadowedText(String text, ThemedColor themed, double? fontSize) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 14,
        color: themed.color,
        shadows: themed.shadowEnabled
            ? [
          Shadow(
            color: themed.shadowColor,
            blurRadius: themed.shadowBlur,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
    );
  }
}
