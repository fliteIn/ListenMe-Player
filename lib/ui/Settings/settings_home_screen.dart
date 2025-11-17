import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../models/app_theme_colors.dart';
import '../../widgets/themed_text.dart';
import '../../utils/shadow_utils.dart';
import '../../l10n/app_localizations.dart'; // 👈 локализация
import '../../main.dart';

// Адаптивный горизонтальный паддинг (через флаг isTablet)
double getAdaptiveHorizontalPadding(BuildContext context) {
  final app = Provider.of<AppModel>(context, listen: false);
  return app.isTablet ? 32.0 : 16.0;
}

class SettingsHomeScreen extends StatefulWidget {
  const SettingsHomeScreen({super.key});

  @override
  State<SettingsHomeScreen> createState() => _SettingsHomeScreenState();
}

class _SettingsHomeScreenState extends State<SettingsHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Сохраняем факт, что мы в главном экране настроек
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = context.read<AppModel>();
      app.lastVisitedSettingsScreen = 'Главное меню';
      app.lastVisitedSettingsScreenRoute = '/settings/home';
      app.openSettingsRootNextTime = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final loc = AppLocalizations.of(context)!;
    final theme = app.themeColors;
    final foreground = theme.currentValueText;

    final adaptivePadding = getAdaptiveHorizontalPadding(context);

    app.updateSystemUi(theme);

    return WillPopScope(
      onWillPop: () async {
        lastRouteForAnimation = currentAppRoute.value;
        navigatorKey.currentState?.pushReplacementNamed('/home');
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            //TopMenuBar(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: adaptivePadding),
                children: [
                  const SizedBox(height: 20),
                  _SettingsCategoryTile(
                    title: loc.interfaceLanguage,
                    route: '/settings/language',
                    foreground: foreground,
                  ),
                  _SettingsCategoryTile(
                    title: loc.interface,
                    route: '/settings/interface',
                    foreground: foreground,
                  ),
                  _SettingsCategoryTile(
                    title: loc.playback,
                    route: '/settings/playback',
                    foreground: foreground,
                  ),
                  _SettingsCategoryTile(
                    title: loc.timecode,
                    route: '/settings/timecode',
                    foreground: foreground,
                  ),
                  _SettingsCategoryTile(
                    title: loc.jogAndSeek,
                    route: '/settings/jog',
                    foreground: foreground,
                  ),
                  _SettingsCategoryTile(
                    title: loc.tempFiles, // локализация для "Временные файлы"
                    route: '/settings/tempfiles',
                    foreground: foreground,
                  ),
                  _SettingsCategoryTile(
                    title: loc.equalizer,  // локализация!
                    route: '/settings/equalizer',
                    foreground: foreground,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCategoryTile extends StatelessWidget {
  final String title;
  final String route;
  final ThemedColor foreground;

  const _SettingsCategoryTile({
    required this.title,
    required this.route,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: buildShadowedText(
        context,
        title,
        fontSize: 18,
        fontWeight: FontWeight.normal,
        textAlign: TextAlign.start,
      ),
      trailing: buildShadowedIcon(
        Icons.chevron_right,
        foreground,
      ),
      onTap: () {
        final app = context.read<AppModel>();

        app.lastVisitedSettingsScreen = title;
        app.lastVisitedSettingsScreenRoute = route;
        app.openSettingsRootNextTime = false;

        lastRouteForAnimation = settingsRoot; // обязательно '/settings', а не '/settings/home'
        Navigator.pushNamed(context, route);
      },
    );
  }
}
