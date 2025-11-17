import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/app_model.dart';
import '../../widgets/themed_buttons.dart';
import '../../widgets/themed_text.dart';
import '../../utils/shadow_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../home.dart';
import 'package:url_launcher/url_launcher.dart';

extension LocalizationExt on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}

enum WelcomeStep { language, intro, legal }

class WelcomeScreen extends StatefulWidget {
  final bool requireConfirmation;
  final bool showLanguageSelector;
  final bool helpStyle;

  const WelcomeScreen({
    Key? key,
    this.requireConfirmation = true,
    this.showLanguageSelector = true,
    this.helpStyle = false,
  }) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  WelcomeStep step = WelcomeStep.language;

  @override
  void initState() {
    super.initState();
    if (widget.helpStyle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final app = context.read<AppModel>();
        app.lastVisitedHelpScreenRoute = '/help/welcome';
      });
    }
  }

  Future<void> _finish(BuildContext context) async {
    if (widget.requireConfirmation) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenWelcome', true);
    }
    final app = Provider.of<AppModel>(context, listen: false);
    app.needShowWelcome.value = false;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppModel>(context);
    final theme = app.themeColors;
    final currentLocale = app.localeCode;
    final loc = AppLocalizations.of(context)!;

    void setLocale(String? code) {
      if (code != null) app.setLocale(code);
    }

    app.updateSystemUi(theme);

    if (widget.helpStyle) {
      // --- help-экран ---
      final bottomPadding = MediaQuery.of(context).padding.bottom;
      final double sidePadding = app.isTablet ? 64.0 : 20.0; // Адаптивно!
      return WillPopScope(
        onWillPop: () async {
          lastRouteForAnimation = currentAppRoute.value;
          navigatorKey.currentState?.pushReplacementNamed('/help');
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      sidePadding,
                      24,
                      sidePadding,
                      24 + bottomPadding,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: buildShadowedText(
                            context,
                            loc.welcomeTitle, // Заголовок приветствия
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        buildShadowedText(
                          context,
                          '• ${loc.welcomeDescription}',
                          fontSize: 16,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 24),

                        buildShadowedText(
                          context,
                          loc.welcomeBackgroundImagesIntro,
                          fontSize: 14,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 16),

                        buildShadowedText(
                          context,
                          "- Selina Farzaei",
                          fontSize: 13,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        buildShadowedText(
                          context,
                          "- Matt Gross",
                          fontSize: 13,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        buildShadowedText(
                          context,
                          "- Kiwihug",
                          fontSize: 13,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        buildShadowedText(
                          context,
                          "- Gor Davtyan",
                          fontSize: 13,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 24),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: buildShadowedText(
                                context,
                                loc.welcomePolicyTitle, // "Правовая информация"
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                            buildShadowedText(
                              context,
                              '• ${loc.welcomeLegalSummary1}',
                              fontSize: 14,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 12),
                            buildShadowedText(
                              context,
                              '• ${loc.welcomeLegalSummary2}',
                              fontSize: 14,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 12),
                            buildShadowedText(
                              context,
                              '• ${loc.welcomeLegalSummary3}',
                              fontSize: 14,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 12),
                            buildShadowedText(
                              context,
                              '• ${loc.welcomeLegalSummary4}',
                              fontSize: 14,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: () async {
                                final url = Uri.parse(
                                  'https://flitein.github.io/ListenMe-Player/Privacy.html',
                                );
                                try {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } catch (e) {
                                  print('Ошибка открытия ссылки: $e');
                                }
                              },
                              child: Center(
                                child: Text(
                                  loc.welcomeLegalDetails,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationColor: theme.widgetIconText.color,
                                    color: theme.widgetIconText.color,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // --- основной welcome ---
    return WillPopScope(
      onWillPop: () async => false, // блокируем системную кнопку «Назад»
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.backgroundStart.withOpacity(1.0),
                theme.backgroundEnd.withOpacity(1.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: _buildStepContent(
                          context: context,
                          step: step,
                          theme: theme,
                          currentLocale: currentLocale,
                          setLocale: setLocale,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (step != WelcomeStep.language) ...[
                        ThemedButton(
                          child: buildShadowedTextSimple(
                            loc.buttonBack,
                            theme.buttonIconText,
                          ),
                          onTap: () {
                            setState(() {
                              if (step == WelcomeStep.intro) {
                                step = WelcomeStep.language;
                              } else if (step == WelcomeStep.legal) {
                                step = WelcomeStep.intro;
                              }
                            });
                          },
                          background: theme.controlElements,
                          foreground: theme.buttonIconText,
                          width: 130,
                        ),
                        const SizedBox(width: 20),
                      ],
                      ThemedButton(
                        child: buildShadowedTextSimple(
                          step == WelcomeStep.legal
                              ? loc.buttonAgree
                              : loc.buttonNext,
                          theme.buttonIconText,
                        ),
                        onTap: () {
                          if (step == WelcomeStep.language) {
                            setState(() => step = WelcomeStep.intro);
                          } else if (step == WelcomeStep.intro) {
                            setState(() => step = WelcomeStep.legal);
                          } else {
                            _finish(context);
                          }
                        },
                        background: theme.controlElements,
                        foreground: theme.buttonIconText,
                        width: step == WelcomeStep.language ? 280 : 130,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent({
    required BuildContext context,
    required WelcomeStep step,
    required dynamic theme,
    required String currentLocale,
    required void Function(String? code) setLocale,
  }) {
    final loc = context.loc;

    switch (step) {
      case WelcomeStep.language:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showLanguageSelector) ...[
              Center(
                child: buildShadowedText(
                  context,
                  loc.interfaceLanguage,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 300,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    alignment: Alignment.center,
                    dropdownColor: theme.backgroundStart.withOpacity(0.95),
                    value: currentLocale,
                    onChanged: setLocale,
                    items: [
                      DropdownMenuItem(
                        value: 'ru',
                        child: Center(
                          child: buildShadowedText(context, 'Русский'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Center(
                          child: buildShadowedText(context, 'English'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'de',
                        child: Center(
                          child: buildShadowedText(context, 'Deutsch'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );

      case WelcomeStep.intro:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: buildShadowedText(
                context,
                loc.welcomeTitle,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            buildShadowedText(
              context,
              loc.welcomeDescription,
              fontSize: 16,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
          ],
        );

      case WelcomeStep.legal:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: buildShadowedText(
                context,
                loc.welcomePolicyTitle, // "Правовая информация"
                fontSize: 18,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            buildShadowedText(
              context,
              '• ${loc.welcomeLegalSummary1}',
              fontSize: 14,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            buildShadowedText(
              context,
              '• ${loc.welcomeLegalSummary2}',
              fontSize: 14,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            buildShadowedText(
              context,
              '• ${loc.welcomeLegalSummary3}',
              fontSize: 14,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            buildShadowedText(
              context,
              '• ${loc.welcomeLegalSummary4}',
              fontSize: 14,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 24),
            if (!widget.helpStyle) ...[
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse(
                    'https://flitein.github.io/ListenMe-Player/Privacy.html',
                  );
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    print('Ошибка открытия ссылки: $e');
                  }
                },

                child: Center(
                  child: Text(
                    loc.welcomeLegalDetails,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: theme.widgetIconText.color,
                      color: theme.widgetIconText.color,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: Text(
                  loc.welcomeLegalAgreeNotice,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.widgetIconText.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        );
    }
  }
}
