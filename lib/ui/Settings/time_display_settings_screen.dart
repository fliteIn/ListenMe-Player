import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_model.dart';
import '../../../enums/enums.dart';
import '../../../widgets/top_menu_bar.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/themed_text.dart';

// Адаптивный горизонтальный паддинг через AppModel
double getAdaptiveHorizontalPadding(BuildContext context) {
  final app = Provider.of<AppModel>(context, listen: false);
  return app.isTablet ? 64.0 : 32.0;
}

class TimeDisplaySettingsScreen extends StatelessWidget {
  const TimeDisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final theme = app.themeColors;
    final currentText = theme.currentValueText;
    final loc = AppLocalizations.of(context)!;

    final adaptivePadding = getAdaptiveHorizontalPadding(context);

    app.updateSystemUi(theme);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          //TopMenuBar(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: adaptivePadding,
                vertical: 24,
              ),
              children: [
                // Первый блок: выбор формата времени
                buildSectionTitle(context, loc.timeFormatTitle),
                const SizedBox(height: 10),
                ...[
                  [TimeDisplayStyle.mmss, loc.timeFormatMmss],
                  [TimeDisplayStyle.mmss2digitMillis, loc.timeFormatMmss2digitMillis],
                  [TimeDisplayStyle.mmss3digitMillis, loc.timeFormatMmss3digitMillis],
                ].map((entry) {
                  return RadioListTile<TimeDisplayStyle>(

                    contentPadding: EdgeInsets.zero, // Важно для ровных отступов!
                    title: buildShadowedText(
                      context,
                      entry[1] as String,
                      fontSize: 16,
                      textAlign: TextAlign.left,
                    ),
                    value: entry[0] as TimeDisplayStyle,
                    groupValue: app.timeDisplayStyle,
                    onChanged: (value) {
                      if (value != null) app.setTimeDisplayStyle(value);
                    },
                    activeColor: currentText.color,
                    fillColor: MaterialStateProperty.resolveWith((states) {
                      return currentText.color.withOpacity(
                        states.contains(MaterialState.selected) ? 1.0 : 0.6,
                      );
                    }),
                  );
                }),

                const SizedBox(height: 16),
                buildSectionHint(context, loc.autoHoursHint),

                // Второй блок: выбор второго типа времени
                const SizedBox(height: 24),
                buildSectionTitle(context, loc.secondaryTimeTypeTitle),
                const SizedBox(height: 10),
                ...[
                  [SecondaryTimeType.remaining, loc.secondaryTimeTypeRemaining],
                  [SecondaryTimeType.totalDuration, loc.secondaryTimeTypeTotalDuration],
                ].map((entry) {
                  return RadioListTile<SecondaryTimeType>(
                    contentPadding: EdgeInsets.zero,
                    title: buildShadowedText(
                      context,
                      entry[1] as String,
                      fontSize: 16,
                      textAlign: TextAlign.left,
                    ),
                    value: entry[0] as SecondaryTimeType,
                    groupValue: app.secondaryTimeType,
                    onChanged: (value) {
                      if (value != null) app.setSecondaryTimeType(value);
                    },
                    activeColor: currentText.color,
                    fillColor: MaterialStateProperty.resolveWith((states) {
                      return currentText.color.withOpacity(
                        states.contains(MaterialState.selected) ? 1.0 : 0.6,
                      );
                    }),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.center,
      child: buildShadowedText(
        context,
        title,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildSectionHint(BuildContext context, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Align(
        alignment: Alignment.center,
        child: buildShadowedText(
          context,
          hint,
          textAlign: TextAlign.center,
          fontSize: 12,
        ),
      ),
    );
  }
}
