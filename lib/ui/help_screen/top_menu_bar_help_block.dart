import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../models/app_theme_colors.dart';
import '../../widgets/numbered_description.dart';
import '../../widgets/top_menu_bar.dart'; // твой TopMenuBarUpperRow!
import '../../l10n/app_localizations.dart';
import '../../widgets/themed_text.dart';
import '../../widgets/gradient_divider.dart';

class TopMenuBarHelpBlock extends StatelessWidget {
  const TopMenuBarHelpBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = context.watch<AppModel>().themeColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок
        Center(
          child: buildShadowedText(
            context,
            loc.helpTopBarTitle,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 12),

        // Панель — без отступов!
        IgnorePointer(
          child: TopMenuBarUpperRow(
            currentRoute: '/home',
            theme: theme,
            forceShowAllControls: true,
            previewMode: true,
            showBackground: true,
          ),
        ),

        // Кружки ровно под каждым элементом панели
        SizedBox(
          height: 32,
          child: Stack(
            children: [
              // Кружок 1 — строго у левого края (под логотип/стрелку)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: SizedBox(
                  width: 48,
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
              ),
              // Кружок 7 — строго у правого края (под ручку)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: SizedBox(
                  width: 48,
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
              ),
              // Центральные кружки — под иконками (ровно по центру)
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    return SizedBox(
                      width: 48,
                      child: Center(
                        child: buildThemedCircle(
                          text: '${i + 2}',
                          background: theme.controlElements,
                          foreground: theme.buttonIconText,
                          size: 20,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        // --- ОТСТУП после кружков ---
        const SizedBox(height: 16),
        GradientDivider(),
        const SizedBox(height: 16),
        // Описания с отступами
        ...List.generate(7, (i) {
          final labels = [
            loc.helpTopBarLogoBack,
            loc.helpTopBarHome,
            loc.helpTopBarFolderPlaylist,
            loc.helpTopBarManualPlaylist,
            loc.helpTopBarSettings,
            loc.helpTopBarHelp,
            loc.helpTopBarEdit,
          ];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: numberedDescription(context, '${i + 1}', labels[i], theme),
          );
        }),

        // Длинное описание
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: buildShadowedText(
            context,
            loc.helpTopBarDescription,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(height: 16),
        GradientDivider(),
        const SizedBox(height: 16),
      ],
    );
  }
}
