import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import '../widgets/playback_mode_button.dart';
import '../models/app_theme_colors.dart';
import '../widgets/icon_with_shadow.dart';
import '../main.dart';
import 'my_interstitial_ad.dart';
import '../models/purchase_model.dart';

class TopMenuBarUpperRow extends StatelessWidget {
  final String currentRoute;
  final AppThemeColors theme;
  final bool forceShowAllControls;
  final bool previewMode;
  final bool showBackground; // <--- вот ключевой флаг!

  const TopMenuBarUpperRow({
    super.key,
    required this.currentRoute,
    required this.theme,
    this.forceShowAllControls = false,
    this.previewMode = false,
    this.showBackground = false, // <-- по умолчанию фон не рисуем!
  });

  @override
  Widget build(BuildContext context) {
    final isSettingsSubmenu = currentRoute.startsWith('/settings') &&
        currentRoute != '/settings' &&
        currentRoute != '/settings/home';
    final isHelpSubmenu =
        currentRoute.startsWith('/help') && currentRoute != '/help';
    final isPlaylistSubmenu =
        currentRoute.startsWith('/playlist/') && currentRoute != '/playlist';

    final adsDisabled = context.watch<PurchaseModel>().adsDisabled;

    return Container(
      height: 56,
      decoration: showBackground
          ? BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.topBarUpperStart,
            theme.topBarUpperEnd,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      )
          : null,
      child: Stack(
        children: [
          // Центр — навигационные иконки (ровно по центру)
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IgnorePointer(
                  ignoring: previewMode,
                  child: buildTopBarButtonsWithKey(
                    context,
                    currentRoute,
                    forceShowAllControls: forceShowAllControls,
                    adsDisabled: adsDisabled,
                  ),
                ),
              ],
            ),
          ),

          // Левый край — стрелка или логотип (прижат к краю)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 2.5),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Builder(
                  builder: (context) {
                    if (isSettingsSubmenu) {
                      return IconButton(
                        icon: IconWithShadow(
                          icon: Icons.arrow_back,
                          color: theme.navIconActive.color,
                          shadowColor: theme.navIconActive.shadowColor,
                          shadowBlur: theme.navIconActive.shadowBlur,
                          shadowEnabled: theme.navIconActive.shadowEnabled,
                        ),
                        onPressed: previewMode
                            ? null
                            : () {
                          final app = context.read<AppModel>();
                          final lastSettingsSubroute =
                              app.lastVisitedSettingsScreenRoute ?? '/settings/home';
                          final currentRouteName =
                              ModalRoute.of(context)?.settings.name ?? currentRoute;

                          if (currentRouteName.startsWith('/settings') &&
                              currentRouteName != '/settings/home') {
                            lastRouteForAnimation = currentRouteName;
                            navigatorKey.currentState?.pushReplacementNamed('/settings/home');
                            app.lastVisitedSettingsScreenRoute = '/settings/home';
                            return;
                          }
                          if (currentRouteName == '/settings/home') {
                            return;
                          }
                          lastRouteForAnimation = currentRouteName;
                          navigatorKey.currentState
                              ?.pushReplacementNamed(lastSettingsSubroute);
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                      );
                    } else if (isHelpSubmenu) {
                      return IconButton(
                        icon: IconWithShadow(
                          icon: Icons.arrow_back,
                          color: theme.navIconActive.color,
                          shadowColor: theme.navIconActive.shadowColor,
                          shadowBlur: theme.navIconActive.shadowBlur,
                          shadowEnabled: theme.navIconActive.shadowEnabled,
                        ),
                        onPressed: previewMode
                            ? null
                            : () {
                          final app = context.read<AppModel>();
                          final currentRouteName = ModalRoute.of(context)?.settings.name ?? currentRoute;
                          if (currentRouteName == '/help/licenses/detail') {
                            if (navigatorKey.currentState?.canPop() ?? false) {
                              navigatorKey.currentState?.pop();
                            } else {
                              navigatorKey.currentState?.pushNamed('/help/licenses');
                            }
                            return;
                          }
                          final lastHelpSubroute = app.lastVisitedHelpScreenRoute ?? '/help';
                          if (currentRouteName.startsWith('/help') && currentRouteName != '/help') {
                            lastRouteForAnimation = currentRouteName;
                            navigatorKey.currentState?.pushReplacementNamed('/help');
                            app.lastVisitedHelpScreenRoute = '/help';
                            return;
                          }
                          if (currentRouteName == '/help') {
                            return;
                          }
                          lastRouteForAnimation = currentRouteName;
                          navigatorKey.currentState?.pushReplacementNamed(lastHelpSubroute);
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                      );
                    } else if (currentRoute == '/playlist/add_files') {
                      return IconButton(
                        icon: IconWithShadow(
                          icon: Icons.arrow_back,
                          color: theme.navIconActive.color,
                          shadowColor: theme.navIconActive.shadowColor,
                          shadowBlur: theme.navIconActive.shadowBlur,
                          shadowEnabled: theme.navIconActive.shadowEnabled,
                        ),
                        onPressed: previewMode
                            ? null
                            : () {
                          if (navigatorKey.currentState?.canPop() ?? false) {
                            navigatorKey.currentState?.pop();
                          }
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                      );
                    } else if (isPlaylistSubmenu) {
                      return IconButton(
                        icon: IconWithShadow(
                          icon: Icons.arrow_back,
                          color: theme.navIconActive.color,
                          shadowColor: theme.navIconActive.shadowColor,
                          shadowBlur: theme.navIconActive.shadowBlur,
                          shadowEnabled: theme.navIconActive.shadowEnabled,
                        ),
                        onPressed: previewMode
                            ? null
                            : () {
                          final currentRouteName =
                              ModalRoute.of(context)?.settings.name ?? currentRoute;
                          // ... навигация назад, как было ...
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                      );
                    } else {
                      // Логотип для главных экранов и корня настроек/помощи
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/logo_active_part.png',
                              color: theme.navIconActive.color,
                              colorBlendMode: BlendMode.srcIn,
                            ),
                            Image.asset(
                              'assets/logo_inactive_part.png',
                              color: theme.navIconInactive.color,
                              colorBlendMode: BlendMode.srcIn,
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),

          // Правый край — ручка (или невидимая заглушка, всегда занимает место!)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 48,
              height: 48,
              child: _EditorModeButton(
                visible: (currentRoute == '/home'), // или твоя логика!
                forceShowAllControls: forceShowAllControls,
              ),
            ),
          ),
        ],
      )
,
    );
  }
}


class _TopBarButtonsInner extends StatelessWidget {
  final String? currentRoute;
  final bool forceShowAllControls;
  final bool adsDisabled;


  const _TopBarButtonsInner({
    Key? key,
    required this.currentRoute,
    this.forceShowAllControls = false,
    required this.adsDisabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('_TopBarButtonsInner.build currentRoute: $currentRoute');

    // Цвета и тема из модели приложения
    final colors = context.watch<AppModel>().themeColors;

    // Кнопки верхнего ряда главного меню (основные экраны)
    final isHome = (currentRoute ?? '') == '/home';

    List<Widget> buttons = [
      _button(context, '/home', Icons.home, colors),
      _button(context, '/folder_playlist', Icons.folder_open, colors),
      _button(context, '/playlist', Icons.queue_music, colors),
      _button(context, '/settings', Icons.settings, colors),
      _button(context, '/help', Icons.help_outline, colors),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: buttons,
    );
  }


  // Кнопка главного меню (логика активной/неактивной, переходов, цветов)
  Widget _button(BuildContext context, String routeName, IconData iconData,
      AppThemeColors colors) {
    // Определяем активность (подсвеченность) кнопки
    final bool isActive = forceShowAllControls ||
        (routeName == '/settings'
            ? ((currentRoute ?? '').startsWith('/settings'))
            : (routeName == '/help'
                ? ((currentRoute ?? '').startsWith('/help'))
                : (routeName == '/playlist'
                    ? ((currentRoute ?? '').startsWith('/playlist'))
                    : (routeName == '/folder_playlist'
                        ? ((currentRoute ?? '').startsWith('/folder_playlist'))
                        : (currentRoute == routeName)))));

    final themed = isActive ? colors.navIconActive : colors.navIconInactive;

    VoidCallback? onTap;
    if (!forceShowAllControls) {
      final current = currentRoute ?? '';

      if (routeName == '/home' ||
          routeName == '/playlist' ||
          routeName == '/folder_playlist') {
        if (current == routeName) {
          onTap = null; // Уже на этом экране — ничего не делаем
        } else {
          onTap = () {
            debugPrint(
                '[TopMenuBar][_button] onTap: current=$current, routeName=$routeName');

            final adsDisabled = context.read<PurchaseModel>().adsDisabled;


            // 👇 показываем рекламу только если она включена
            final app = context.read<AppModel>();
            final isPlaying = app.isPlaying; // или app.isPlaying, если есть такое поле

// 👇 показываем рекламу только если она включена и не идёт воспроизведение
            if (!adsDisabled && !isPlaying) {
              interstitialAd.maybeShowAd(adsDisabled: adsDisabled);
            }


            debugPrint(
                '[TopMenuBar] Main tab pressed: from $current to $routeName');
            navigateToMain(context, routeName);
          };
        }
      }


      // Логика перехода для кнопки "настройки"
      else if (routeName == '/settings') {
        final currentRouteName = currentAppRoute.value;

        if (currentRouteName == '/settings/home') {
          onTap = null; // Уже в корне настроек — ничего не делаем
        } else {
          onTap = () {
            final app = context.read<AppModel>();
            final lastSettingsSubroute =
                app.lastVisitedSettingsScreenRoute ?? '/settings/home';

            debugPrint(
                '[TopMenuBar] SETTINGS RETURN: lastRouteForAnimation=$lastRouteForAnimation, currentRouteName=$currentRouteName');

            if (currentRouteName.startsWith('/settings')) {
              lastRouteForAnimation = currentRouteName;
              navigatorKey.currentState?.pushReplacementNamed('/settings/home');
            } else {
              lastRouteForAnimation = currentRouteName;
              navigatorKey.currentState
                  ?.pushReplacementNamed(lastSettingsSubroute);
            }
          };
        }
      }

      // Логика перехода для кнопки "помощь"
      else if (routeName == '/help') {
        onTap = () {
          final app = context.read<AppModel>();
          final lastHelpSubroute = app.lastVisitedHelpScreenRoute ?? '/help';
          final currentRouteName = currentAppRoute.value;

          // Если уже в help-подменю И НЕ в корне — при повторном нажатии ведём в корень
          if (currentRouteName.startsWith('/help') && currentRouteName != '/help') {
            // Второй раз — возврат в корень
            lastRouteForAnimation = currentRouteName;
            navigatorKey.currentState?.pushReplacementNamed('/help');
            // и ОБЯЗАТЕЛЬНО обновляем lastVisitedHelpScreenRoute на '/help'
            app.lastVisitedHelpScreenRoute = '/help';
            return;
          }

          // Если уже в корне — ничего не делаем
          if (currentRouteName == '/help') {
            return;
          }

          // В остальных случаях — переход в последнее подменю
          lastRouteForAnimation = currentRouteName;
          navigatorKey.currentState?.pushReplacementNamed(lastHelpSubroute);
        };
      }



      // Прочие (будущие) кнопки
      else {
        if (current == routeName) {
          onTap = null;
        } else {
          onTap = () {
            debugPrint(
                '[TopMenuBar][_button] onTap: current=$current, routeName=$routeName');
            debugPrint('[TopMenuBar] (other) from $current to $routeName');
            lastRouteForAnimation = current;
            navigatorKey.currentState?.pushNamed(routeName);
          };
        }
      }
    }

    // Ключи для горячей перерисовки при смене темы/стиля
    final btnKey = ValueKey(
        'btn_${routeName}_${themed.color.value}_${themed.shadowEnabled}_${themed.shadowColor.value}_${themed.shadowBlur}');
    final iconKey = ValueKey(
        'icn_${routeName}_${themed.color.value}_${themed.shadowEnabled}_${themed.shadowColor.value}_${themed.shadowBlur}');

    return GestureDetector(
      key: btnKey,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(12),
        // <--- Важно, чтобы у всех одинаково!
        child: KeyedSubtree(
          key: iconKey,
          child: IconWithShadow(
            icon: iconData,
            size: 24,
            // <-- ВАЖНО! (или твой дефолт)
            color: themed.color,
            shadowColor: themed.shadowColor,
            shadowBlur: themed.shadowBlur,
            shadowEnabled: themed.shadowEnabled,
          ),
        ),
      ),
    );
  }
}

class _DebugTopBarWrapper extends StatefulWidget {
  final Widget child;

  const _DebugTopBarWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<_DebugTopBarWrapper> createState() => _DebugTopBarWrapperState();
}

class _DebugTopBarWrapperState extends State<_DebugTopBarWrapper> {
  @override
  void initState() {
    super.initState();
    //debugPrint('🟢 _DebugTopBarWrapper initState! key=${widget.key}');
  }

  @override
  void dispose() {
    //debugPrint('🔴 _DebugTopBarWrapper dispose! key=${widget.key}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

Widget buildTopBarButtonsWithKey(
    BuildContext context,
    String? currentRoute, {
      bool forceShowAllControls = false,
      bool? adsDisabled, // <- добавляем опциональный параметр для совместимости
    }) {
  final colors = context.watch<AppModel>().themeColors;
  final navA = colors.navIconActive;
  final navI = colors.navIconInactive;

  // Получаем adsDisabled из Provider, если не передан явно (старые вызовы)
  final _adsDisabled = adsDisabled ?? context.watch<PurchaseModel>().adsDisabled;

  final key = ValueKey(
    '${navA.color.value}_${navA.shadowEnabled}_${navA.shadowColor.value}_${navA.shadowBlur}_'
        '${navI.color.value}_${navI.shadowEnabled}_${navI.shadowColor.value}_${navI.shadowBlur}_'
        '${_adsDisabled ? 1 : 0}', // В ключ можно добавить этот флаг для перестроения
  );

  return _TopBarButtonsInner(
    key: key,
    currentRoute: currentRoute,
    forceShowAllControls: forceShowAllControls,
    adsDisabled: _adsDisabled, // <-- новый аргумент!
  );
}


class TopMenuBar extends StatelessWidget {
  final String? currentRoute;
  final bool forceShowLower;
  final bool forceShowAllControls;

  const TopMenuBar({
    super.key,
    this.currentRoute,
    this.forceShowLower = false,
    this.forceShowAllControls = false,
  });

  @override
  Widget build(BuildContext context) {
    double topSafePadding = MediaQuery.of(context).padding.top;
    const double kMinTopPadding = 24;
    double topPadding =
    topSafePadding > kMinTopPadding ? topSafePadding : kMinTopPadding;

    return Consumer<AppModel>(
      builder: (context, app, _) {
        final colors = app.themeColors;
        final upperShadow = colors.topBarUpperShadow;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.topBarUpperStart, colors.topBarUpperEnd],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: upperShadow.shadowEnabled
                ? [
              BoxShadow(
                color: upperShadow.shadowColor,
                blurRadius: upperShadow.shadowBlur,
                offset: const Offset(0, 2),
              )
            ]
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: TopMenuBarUpperRow(
              currentRoute: currentRoute ?? '/home',
              theme: colors,
              forceShowAllControls: forceShowAllControls,
              previewMode: false,
              showBackground: false, // <--- ВАЖНО! (фон не нужен, он уже выше)
            ),
          ),
        );
      },
    );
  }
}

class _EditorModeButton extends StatelessWidget {
  final bool visible;
  final bool forceShowAllControls;

  const _EditorModeButton({
    this.visible = false,
    this.forceShowAllControls = false, // <--- добавь
  });

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppModel>(context, listen: false);
    final isEditing = app.editMode;
    final theme = app.themeColors;
    final themed = (forceShowAllControls || isEditing)
        ? theme.navIconActive
        : theme.navIconInactive;


    return Opacity(
      opacity: visible ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !visible,
        child: GestureDetector(
          onTap: () {
            app.setEditMode(!isEditing);
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: IconWithShadow(
              icon: isEditing ? Icons.check : Icons.edit,
              size: 24,
              color: themed.color,
              shadowColor: themed.shadowColor,
              shadowBlur: themed.shadowBlur,
              shadowEnabled: themed.shadowEnabled,
            ),
          ),
        ),
      ),
    );
  }
}

