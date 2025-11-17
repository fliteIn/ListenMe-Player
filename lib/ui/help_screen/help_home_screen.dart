import 'package:flutter/material.dart';
import 'help_licenses_screen.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../models/app_theme_colors.dart';
import '../../models/purchase_model.dart';
import '../../widgets/themed_text.dart';
import '../../utils/shadow_utils.dart';
import '../../l10n/app_localizations.dart';
import 'help_widgets_screen.dart';
import 'help_manual_playlist_screen.dart';
import 'help_about_app_screen.dart';
import 'welcome_screen.dart';
import 'help_remove_ads_screen.dart';
import '../../main.dart';

// --- Адаптивный паддинг, такой же как в настройках ---
double getAdaptiveHorizontalPadding(BuildContext context) {
  final app = Provider.of<AppModel>(context, listen: false);
  return app.isTablet ? 32.0 : 16.0;
}

class HelpHomeScreen extends StatefulWidget {
  const HelpHomeScreen({super.key});

  @override
  State<HelpHomeScreen> createState() => _HelpHomeScreenState();
}

class _HelpHomeScreenState extends State<HelpHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = context.read<AppModel>();
      app.lastVisitedHelpScreenRoute = '/help';
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final theme = app.themeColors;
    final loc = AppLocalizations.of(context)!;
    final foreground = theme.currentValueText;

    final purchase = context.watch<PurchaseModel>();
    final adsDisabled = purchase.adsDisabled;

    app.updateSystemUi(theme);

    final adaptivePadding = getAdaptiveHorizontalPadding(context);

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
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: adaptivePadding),
                children: [
                  const SizedBox(height: 20), // <-- вот добавленный отступ
                  _HelpCategoryTile(
                    title: loc.showWelcomeScreen,
                    screen: const WelcomeScreen(
                      requireConfirmation: false,
                      showLanguageSelector: false,
                      helpStyle: true,
                    ),
                    route: '/help/welcome',
                    foreground: foreground,
                  ),
                  _HelpCategoryTile(
                    title: loc.widgets,
                    screen: const HelpWidgetsScreen(),
                    route: '/help/widgets',
                    foreground: foreground,
                  ),
                  _HelpCategoryTile(
                    title: loc.playlistHelpTitle,
                    screen: const HelpManualPlaylistScreen(),
                    route: '/help/playlist',
                    foreground: foreground,
                  ),
                  _HelpCategoryTile(
                    title: loc.licenses,
                    screen: const HelpLicensesScreen(),
                    route: '/help/licenses',
                    foreground: foreground,
                  ),
                  if (!adsDisabled)
                    _HelpCategoryTile(
                      title: loc.iapRemoveAdsTitle, // строка из локализации
                      screen: const RemoveAdsScreen(), // твой экран
                      route: '/help/remove_ads', // уникальный роут
                      foreground: foreground,
                    ),
                  _HelpCategoryTile(
                    title: loc.aboutApp,
                    screen: const AboutAppScreen(),
                    route: '/help/about',
                    foreground: foreground,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpCategoryTile extends StatelessWidget {
  final String title;
  final Widget screen;
  final String route;
  final ThemedColor foreground;

  const _HelpCategoryTile({
    required this.title,
    required this.screen,
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
        app.lastVisitedHelpScreenRoute = route;
        lastRouteForAnimation = '/help';
        Navigator.pushNamed(context, route);
      },
    );
  }
}
