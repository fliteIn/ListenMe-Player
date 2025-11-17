import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../widgets/top_menu_bar.dart';
import '../../widgets/themed_text.dart';
import '../../l10n/app_localizations.dart';

// Адаптивный горизонтальный паддинг
double getAdaptiveHorizontalPadding(BuildContext context) {
  final app = Provider.of<AppModel>(context, listen: false);
  return app.isTablet ? 32.0 : 32.0;
}

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final app = context.read<AppModel>();
    final routeName = ModalRoute.of(context)?.settings.name;
    debugPrint('[LanguageSettingsScreen] ModalRoute: ${ModalRoute.of(context)?.settings.name}');
    print('✅ LanguageSettingsScreen — didChangeDependencies: $routeName');

    if (routeName != null && routeName.startsWith('/settings/')) {
      app.lastVisitedSettingsScreenRoute = routeName;
      app.openSettingsRootNextTime = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final theme = app.themeColors;
    final currentLocale = app.localeCode;
    final loc = AppLocalizations.of(context)!;

    final adaptivePadding = getAdaptiveHorizontalPadding(context);

    void setLocale(String? code) {
      if (code != null) {
        app.setLocale(code);
      }
    }

    app.updateSystemUi(theme);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          //TopMenuBar(),

          Padding(
            padding: EdgeInsets.fromLTRB(adaptivePadding, 32, adaptivePadding, 0),
            child: Align(
              alignment: Alignment.center,
              child: buildShadowedText(
                context,
                loc.interfaceLanguage,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.left,
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: adaptivePadding, vertical: 16),
              children: [
                _buildRadioTile(context, 'English (US)', 'en', currentLocale),
                _buildRadioTile(context, 'Deutsch', 'de', currentLocale),
                _buildRadioTile(context, 'Русский', 'ru', currentLocale),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile(BuildContext context, String title, String value, String groupValue) {
    final app = context.watch<AppModel>();
    final theme = app.themeColors;

    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero, // Чтобы не было лишних внутренних отступов
      title: buildShadowedText(context, title, fontSize: 16, textAlign: TextAlign.left),
      value: value,
      groupValue: groupValue,
      onChanged: (code) => app.setLocale(code!),
      activeColor: theme.currentValueText.color,
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return theme.currentValueText.color;
        } else {
          return theme.currentValueText.color.withOpacity(0.6);
        }
      }),
    );
  }
}
