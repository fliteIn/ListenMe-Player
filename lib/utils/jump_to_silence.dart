import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// Прыжок к предыдущей тишине (маркеру) с учетом защитного интервала
void jumpToPrevSilence({
  required AudioPlayer player,
  required Duration position,
  required List<Duration> silenceMarkers,
  required Duration minBound,
  Duration tolerance = const Duration(milliseconds: 500),
}) {
  final prev = silenceMarkers
      .where((d) => d < position - tolerance && d >= minBound)
      .toList();
  if (prev.isNotEmpty) {
    player.seek(prev.last);
  } else {
    player.seek(minBound); // упираемся в левый маркер
  }
}

void jumpToNextSilence({
  required AudioPlayer player,
  required Duration position,
  required List<Duration> silenceMarkers,
  required Duration maxBound,
  Duration tolerance = const Duration(milliseconds: 200),
}) {
  // Если текущее положение уже близко к правому краю — ничего не делаем
  if ((maxBound - position).abs() < tolerance) return;

  final next = silenceMarkers
      .where((s) => s > position && s <= maxBound)
      .toList();

  final target = next.isNotEmpty ? next.first : maxBound;

  player.seek(target);
}



/// Виджет кнопки прыжка вперед (вверх)
class JumpToNextSilenceButton extends StatelessWidget {
  final AudioPlayer player;
  final Duration position;
  final List<Duration> silenceMarkers;
  final double width;
  final double spacing;
  final Duration maxBound;


  const JumpToNextSilenceButton({
    super.key,
    required this.player,
    required this.position,
    required this.silenceMarkers,
    required this.width,
    required this.spacing,
    required this.maxBound,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        jumpToNextSilence(
          player: player,
          position: position,
          silenceMarkers: silenceMarkers,
          maxBound: maxBound,
        );

      },
      child: Container(
        width: width,
        height: 40,
        margin: EdgeInsets.only(bottom: spacing / 2),
        decoration: BoxDecoration(
          color: Colors.indigo.withOpacity(0.15),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: const Icon(Icons.keyboard_arrow_up, color: Colors.indigo),
      ),
    );
  }
}

/// Виджет кнопки прыжка назад (вниз)
class JumpToPrevSilenceButton extends StatelessWidget {
  final AudioPlayer player;
  final Duration position;
  final List<Duration> silenceMarkers;
  final double width;
  final double spacing;
  final Duration minBound;


  const JumpToPrevSilenceButton({
    super.key,
    required this.player,
    required this.position,
    required this.silenceMarkers,
    required this.width,
    required this.spacing,
    required this.minBound,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        jumpToPrevSilence(
          player: player,
          position: position,
          silenceMarkers: silenceMarkers,
          minBound: minBound,
        );

      },
      child: Container(
        width: width,
        height: 40,
        margin: EdgeInsets.only(top: spacing / 2),
        decoration: BoxDecoration(
          color: Colors.indigo.withOpacity(0.15),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: const Icon(Icons.keyboard_arrow_down, color: Colors.indigo),
      ),
    );
  }
}
