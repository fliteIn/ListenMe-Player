import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../models/purchase_model.dart';
import '../../widgets/themed_buttons.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/themed_text.dart';
import '../../utils/shadow_utils.dart';

class RemoveAdsScreen extends StatefulWidget {
  const RemoveAdsScreen({super.key});

  @override
  State<RemoveAdsScreen> createState() => _RemoveAdsScreenState();
}

class _RemoveAdsScreenState extends State<RemoveAdsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = context.read<AppModel>();
      app.lastVisitedHelpScreenRoute = '/help/remove_ads';
      // Прокидываем контекст для PurchaseModel (чтобы показывать SnackBar из модели)
      context.read<PurchaseModel>().setContext(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final theme = app.themeColors;
    final loc = AppLocalizations.of(context)!;
    final purchase = context.watch<PurchaseModel>();
    final adsDisabled = purchase.adsDisabled;

    app.updateSystemUi(theme);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        bottom: true,
        child: Stack(
          children: [
            // Если реклама не отключена — показываем заголовок, описание и кнопки
            if (!adsDisabled) ...[
              // Верхний контент: заголовок + описание
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildShadowedText(
                          context,
                          loc.iapRemoveAdsTitle,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        buildShadowedText(
                          context,
                          loc.iapRemoveAdsDescription,
                          fontSize: 16,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Кнопки по центру
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ThemedButton(
                      child: buildShadowedTextSimple(
                        loc.iapRemoveAdsButton("9,99 €"),
                        theme.buttonIconText,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                      onTap: () async {
                        await purchase.buyRemoveAds();
                      },
                      background: theme.controlElements,
                      foreground: theme.buttonIconText,
                      width: 300,
                      height: 44,
                    ),
                    const SizedBox(height: 16),
                    ThemedButton(
                      child: buildShadowedTextSimple(
                        loc.iapRestorePurchaseButton,
                        theme.buttonIconText,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                      onTap: () async {
                        // Здесь делаем то же самое, что и в кнопке “Купить”
                        await purchase.restorePurchases();

                      },
                      background: theme.controlElements,
                      foreground: theme.buttonIconText,
                      width: 240,
                      height: 36,
                    ),
                  ],
                ),
              ),
            ],
            // Если реклама отключена — только благодарность в центре
            if (adsDisabled) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: buildShadowedText(
                    context,
                    loc.iapAdsRemovedMessage,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // ======= КНОПКА ВКЛЮЧИТЬ РЕКЛАМУ ==========
              /*Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 180),
                    ThemedButton(
                      child: buildShadowedTextSimple(
                        "Включить рекламу (тест)", // Лучше добавить локализацию
                        theme.buttonIconText,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      onTap: () async {
                        await context.read<PurchaseModel>().enableAds();
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Реклама снова включена (тестовый режим).")),
                        );
                      },
                      background: theme.controlElements,
                      foreground: theme.buttonIconText,
                      width: 240,
                      height: 36,
                    ),
                  ],
                ),
              ),*/
            ],
          ],
        ),
      ),
    );
  }
}
