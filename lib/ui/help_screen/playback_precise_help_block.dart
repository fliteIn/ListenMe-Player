import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../models/app_theme_colors.dart';
import '../../widgets/playback_precise.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/themed_text.dart';
import '../../widgets/numbered_description.dart';
import '../../widgets/gradient_divider.dart';

class PlaybackPreciseHelpBlock extends StatelessWidget {
  const PlaybackPreciseHelpBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final app = context.watch<AppModel>();
    final theme = app.themeColors;

    // Подписи к кнопкам (нумерация — как у тебя в иконках)
    final labels = [
      loc.helpPlaybackPrevTrack,
      loc.helpPlaybackRewind,
      loc.helpPlaybackJumpBack5,
      loc.helpPlaybackPlayPause,
      loc.helpPlaybackJumpForward5,
      loc.helpPlaybackFastForward,
      loc.helpPlaybackNextTrack,
    ];

    // Ширины и отступы точно по PlaybackPrecise
    const double prevWidth = 36.0;
    const double smoothRewindWidth = 36.0;
    const double rewind5Width = 36.0;
    const double playWidth = 42.0;
    const double forward5Width = 36.0;
    const double smoothForwardWidth = 36.0;
    const double nextWidth = 36.0;
    const double bigSpacing = 12.0;
    const double smallSpacing = 0.0; // spacing

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок по центру
        Center(
          child: buildShadowedText(
            context,
            loc.helpPlaybackPreciseTitle,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),

        // Сам PlaybackPrecise (растянутый)
        IgnorePointer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: PlaybackPrecise(app: app),
          ),
        ),
        const SizedBox(height: 8),

        // Кружки строго под иконками
        SizedBox(
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prev
              SizedBox(
                width: prevWidth,
                child: Center(
                  child: buildThemedCircle(
                    text: '1',
                    background: theme.controlElements,
                    foreground: theme.buttonIconText,
                    size: 20,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: bigSpacing),
              // Smooth rewind (удержание назад)
              SizedBox(
                width: smoothRewindWidth,
                child: Center(
                  child: buildThemedCircle(
                    text: '2',
                    background: theme.controlElements,
                    foreground: theme.buttonIconText,
                    size: 20,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: smallSpacing),
              // Rewind 5
              SizedBox(
                width: rewind5Width,
                child: Center(
                  child: buildThemedCircle(
                    text: '3',
                    background: theme.controlElements,
                    foreground: theme.buttonIconText,
                    size: 20,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: bigSpacing),
              // Play/Pause
              SizedBox(
                width: playWidth,
                child: Center(
                  child: buildThemedCircle(
                    text: '4',
                    background: theme.controlElements,
                    foreground: theme.buttonIconText,
                    size: 20,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: bigSpacing),
              // Forward 5
              SizedBox(
                width: forward5Width,
                child: Center(
                  child: buildThemedCircle(
                    text: '5',
                    background: theme.controlElements,
                    foreground: theme.buttonIconText,
                    size: 20,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: smallSpacing),
              // Smooth forward (удержание вперед)
              SizedBox(
                width: smoothForwardWidth,
                child: Center(
                  child: buildThemedCircle(
                    text: '6',
                    background: theme.controlElements,
                    foreground: theme.buttonIconText,
                    size: 20,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: bigSpacing),
              // Next
              SizedBox(
                width: nextWidth,
                child: Center(
                  child: buildThemedCircle(
                    text: '7',
                    background: theme.controlElements,
                    foreground: theme.buttonIconText,
                    size: 20,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Градиентный разделитель
        const GradientDivider(),
        const SizedBox(height: 16),

        // Описания к каждой кнопке с паддингом
        ...List.generate(labels.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: numberedDescription(context, '${i + 1}', labels[i], theme),
          );
        }),

        const SizedBox(height: 12),

        // Длинное описание (если оно есть), с паддингом
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: buildShadowedText(
            context,
            loc.helpPlaybackPreciseDescription,
            textAlign: TextAlign.left,
          ),
        ),

        const SizedBox(height: 24),
        const GradientDivider(),
        const SizedBox(height: 24),
      ],
    );
  }
}
