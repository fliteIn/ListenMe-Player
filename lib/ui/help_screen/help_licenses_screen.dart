import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../models/app_theme_colors.dart';
import '../../widgets/themed_text.dart';
import '../../utils/shadow_utils.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show LicenseEntry, LicenseParagraph, LicenseRegistry;
import 'license_detail_screen.dart';
import 'help_licenses_page_route.dart';

// --- Адаптивный горизонтальный паддинг ---
double getAdaptiveHorizontalPadding(BuildContext context) {
  final app = Provider.of<AppModel>(context, listen: false);
  return app.isTablet ? 64.0 : 16.0;
}

class HelpLicensesScreen extends StatefulWidget {
  const HelpLicensesScreen({super.key});

  @override
  State<HelpLicensesScreen> createState() => _HelpLicensesScreenState();
}

class _HelpLicensesScreenState extends State<HelpLicensesScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    // Запоминаем этот экран как последнее help-подменю
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = context.read<AppModel>();
      app.lastVisitedHelpScreenRoute = '/help/licenses';
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<AppModel>().themeColors;
    final theme = context.watch<AppModel>().themeColors;
    final app = context.watch<AppModel>();
    app.updateSystemUi(theme);

    final loc = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final adaptivePadding = getAdaptiveHorizontalPadding(context); // <-- добавили

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Список + полоса прокрутки
                ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor: MaterialStateProperty.all(theme.controlElements.color),
                    thickness: MaterialStateProperty.all(8),
                    radius: const Radius.circular(8),
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    interactive: true,
                    child: FutureBuilder<List<LicenseEntry>>(
                      future: LicenseRegistry.licenses.toList(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final entries = snapshot.data!;
                        final licensesMap = <String, List<LicenseParagraph>>{};
                        for (final entry in entries) {
                          for (final package in entry.packages) {
                            licensesMap[package] = [
                              ...licensesMap[package] ?? [],
                              ...entry.paragraphs,
                            ];
                          }
                        }

                        final packageNames = licensesMap.keys.toList()..sort();

                        return ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.fromLTRB(
                            adaptivePadding, // ← слева
                            16,              // ← сверху как было
                            adaptivePadding, // ← справа
                            80 + bottomPadding, // ← снизу как было
                          ),
                          itemCount: packageNames.length + 2, // заголовок + spacer + элементы
                          itemBuilder: (context, index) {
                            // 0 — заголовок, 1 — отступ после заголовка
                            if (index == 0) {
                              return Center(
                                child: buildShadowedText(
                                  context,
                                  loc.licenses,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                            if (index == 1) {
                              return const SizedBox(height: 16);
                            }

                            final pkgIndex = index - 2;
                            final package = packageNames[pkgIndex];

                            return ListTile(
                              contentPadding: EdgeInsets.zero, // паддинг уже есть у ListView
                              title: buildShadowedText(
                                context,
                                package,
                                fontSize: 16,
                                textAlign: TextAlign.start, // <-- вот это
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: colors.controlElements.color,
                              ),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  '/help/licenses/detail',
                                  arguments: {
                                    'package': package,
                                    'paragraphs': licensesMap[package]!,
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Кнопки вверх/вниз
                Positioned(
                  bottom: 16 + bottomPadding,
                  right: 18,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Вверх
                      GestureDetector(
                        onTap: () {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.controlElements.color,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: theme.controlElements.shadowEnabled
                                ? [
                              BoxShadow(
                                color: theme.controlElements.shadowColor,
                                blurRadius: theme.controlElements.shadowBlur,
                                offset: const Offset(0, 2),
                              ),
                            ]
                                : [],
                          ),
                          child: Icon(Icons.arrow_upward, color: theme.buttonIconText.color, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Вниз
                      GestureDetector(
                        onTap: () async {
                          for (int i = 0; i < 4; i++) {
                            if (!_scrollController.hasClients) break;
                            await _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                            await Future.delayed(const Duration(milliseconds: 70));
                          }
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.controlElements.color,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: theme.controlElements.shadowEnabled
                                ? [
                              BoxShadow(
                                color: theme.controlElements.shadowColor,
                                blurRadius: theme.controlElements.shadowBlur,
                                offset: const Offset(0, 2),
                              ),
                            ]
                                : [],
                          ),
                          child: Icon(Icons.arrow_downward, color: theme.buttonIconText.color, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
