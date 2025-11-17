import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../models/app_theme_colors.dart';
import '../../widgets/playback_standard.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/themed_text.dart';
import '../../widgets/numbered_description.dart';
import '../../widgets/gradient_divider.dart';

class PlaybackStandardHelpBlock extends StatelessWidget {
  const PlaybackStandardHelpBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final app = context.watch<AppModel>();
    final theme = app.themeColors;

    // Подписи к кнопкам
    final labels = [
      loc.helpPlaybackPrevTrack,
      loc.helpPlaybackJumpBack5,
      loc.helpPlaybackPlayPause,
      loc.helpPlaybackJumpForward5,
      loc.helpPlaybackNextTrack,
    ];

    // Ширины и отступы из оригинального PlaybackStandard
    const double prevWidth = 36.0;
    const double rewindWidth = 36.0;
    const double playWidth = 42.0;
    const double forwardWidth = 36.0;
    const double nextWidth = 36.0;
    const double bigSpacing = 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок по центру
        Center(
          child: buildShadowedText(
            context,
            loc.helpPlaybackStandardTitle,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),

        // Сам PlaybackStandard (растянутый)
        IgnorePointer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: PlaybackStandard(app: app),
          ),
        ),
        const SizedBox(height: 8),

        // Кружочки строго под иконками (с теми же размерами и отступами, что и в PlaybackStandard)
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
              // Rewind
              SizedBox(
                width: rewindWidth,
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
              const SizedBox(width: bigSpacing),
              // Play/Pause
              SizedBox(
                width: playWidth,
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
              // Forward
              SizedBox(
                width: forwardWidth,
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
              // Next
              SizedBox(
                width: nextWidth,
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
            loc.helpPlaybackStandardDescription,
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
