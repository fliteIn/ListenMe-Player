import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'ui/home.dart';
import 'ui/manual_playlist_screen.dart';
import 'ui/folder_playlist_screen.dart';

import 'ui/Settings/settings_home_screen.dart';

import 'models/app_model.dart';
import 'widgets/open_files_button.dart';
import 'widgets/top_menu_bar.dart';
import 'models/playlist_model.dart';
import 'models/playback_model.dart';
import 'models/purchase_model.dart';
import 'models/audio_to_levels_model.dart';
import 'ui/Settings/color_settings_screen.dart';
import 'ui/Settings/jog_settings_screen.dart';
import 'ui/Settings/playback_settings_screen.dart';
import 'ui/Settings/time_display_settings_screen.dart';
import 'ui/Settings/language_settings_screen.dart';
import 'ui/Settings/temp_files_settings_screen.dart';
import 'ui/Settings/equalizer_screen.dart';
import 'ui/help_screen/help_home_screen.dart';
import 'ui/help_screen/help_about_app_screen.dart';
import 'ui/help_screen/help_widgets_screen.dart';
import 'ui/help_screen/help_manual_playlist_screen.dart';
import 'ui/help_screen/help_licenses_screen.dart';
import 'ui/add_files_to_playlist_screen.dart';
import 'ui/help_screen/help_remove_ads_screen.dart'; // Импорт нового экрана

import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:audio_service/audio_service.dart';
import 'utils/my_audio_handler.dart';
import 'dart:io';
import 'dart:ui';

import '../utils/global_keys.dart';
import 'package:flutter/services.dart';
import 'ui/help_screen/welcome_screen.dart';
import 'ui/help_screen/license_detail_screen.dart';


import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'widgets/my_interstitial_ad.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // создаётся через FlutterFire CLI
import 'utils/app_analytics.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';



enum AppTransitionType {
  slide,
  fade,
  scale,
  none,
}

String? lastRouteForAnimation;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
String? currentMainRoute = '/home';
String? lastRoute;
final ValueNotifier<String> currentAppRoute = ValueNotifier<String>('/home');
final MyRouteObserver myRouteObserver = MyRouteObserver();

void navigateToMain(BuildContext context, String routeName) {
  // Вместо currentMainRoute используем фактический route
  final prev = currentAppRoute.value ?? currentMainRoute ?? '/home';
  lastRouteForAnimation = prev;
  //debugPrint('NAVIGATE: from $prev to $routeName');
  currentMainRoute = routeName;
  navigatorKey.currentState
      ?.pushNamedAndRemoveUntil(routeName, (route) => false);
}

void navigateReplace(BuildContext context, String routeName) {
  // lastRouteForAnimation ДОЛЖНА быть уже установлена до вызова этой функции!
  navigatorKey.currentState?.pushReplacementNamed(routeName);
  // debugPrint('NAVIGATE REPLACE: to $routeName');
}

// --- КОНСТАНТЫ ПОДМЕНЮ ---
final settingsRoot = '/settings';
final helpRoot = '/help';
final playlistSubroutes = <String>[
  '/playlist/add_files',
  // сюда добавляй новые подменю плейлиста если появятся
];
final settingsSubroutes = <String>[
  '/settings/language',
  '/settings/interface',
  '/settings/playback',
  '/settings/jog',
  '/settings/timecode',
  '/settings/widget-order',
  '/settings/tempfiles',
  '/settings/equalizer',

];
final helpSubroutes = <String>[
  '/help/about',
  '/help/licenses',
  '/help/licenses/detail',
  '/help/widgets',
  '/help/playlist',
  '/help/remove_ads',
  '/help/welcome',
];
final mainRoutes = <String>[
  '/home',
  '/playlist',
  '/folder_playlist',
  '/settings',
  '/help',
];

String normalizeMainRoute(String? route) {
  if (route == null) return '/home';
  if (route.startsWith('/settings')) return '/settings';
  if (route.startsWith('/help')) return '/help';
  if (route.startsWith('/folder_playlist')) return '/folder_playlist';
  if (route.startsWith('/playlist')) return '/playlist';
  if (route.startsWith('/home')) return '/home';
  return route;
}

late MyInterstitialAd interstitialAd;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final purchaseModel = PurchaseModel();
  final app = AppModel();
  await app.clearTempCache();
  app.setPurchaseModel(purchaseModel);

  // ⚡ РЕКЛАМА — только если не отключена
  if (!purchaseModel.adsDisabled) {
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: ['7871B049C4FDB45FF4CEA15492E45EAC'],
      ),
    );
    await MobileAds.instance.initialize();

    interstitialAd = MyInterstitialAd()..loadAd();
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(app),
    config: AudioServiceConfig(
      //androidNotificationIcon: 'ic_audio_notification',
      androidNotificationChannelId: 'com.listenme.app.channel.audio',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: false,
    ),
  );
  app.audioHandler = audioHandler;

  await app.initialize();
  await app.checkWelcomeFlag();

  WidgetsBinding.instance.addObserver(AppLifecycleHandler(app));
  app.playlist.initReceiveSharing();

  await app.setInitialLocaleIfNeeded();

  runApp(
    ChangeNotifierProvider<AppModel>.value(
      value: app,
      child: MyAppRoot(
        app: app,
        purchaseModel: purchaseModel, // 👈 Обязательно прокинь сюда!

      ),
    ),
  );
}



class MyAppRoot extends StatelessWidget {
  final AppModel app;
  final PurchaseModel purchaseModel;

  const MyAppRoot({
    super.key,
    required this.app,
    required this.purchaseModel,
  });

  @override
  Widget build(BuildContext context) {

    app.updateIsTablet(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppModel>.value(value: app),
        ChangeNotifierProvider<PlaybackModel>.value(value: app.playbackModel),
        ChangeNotifierProvider<PlaylistModel>.value(value: app.playlist),
        ChangeNotifierProvider<AudioToLevelsModel>.value(value: app.audio_to_levels),
        ChangeNotifierProvider.value(value: purchaseModel),
      ],
      child: MyApp(app: app),
    );
  }
}

class OpenFileRouteScreen extends StatelessWidget {
  const OpenFileRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Открыть файл')),
      body: Center(
        child: OpenFilesButton(
          audioState: app.playlist,
          onTrackSelected: app.playlist.onManualTrackSelected,
          autoPlay: true,
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Здесь будет экран "$title"')),
    );
  }
}

class MyApp extends StatelessWidget {
  final AppModel app;
  final PageStorageBucket _bucket = PageStorageBucket();

  MyApp({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
      builder: (context, appModel, _) {
        return PageStorage(
          bucket: _bucket,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            navigatorObservers: [myRouteObserver],
            scaffoldMessengerKey: scaffoldMessengerKey,
            title: 'ListenMe Player',
            debugShowCheckedModeBanner: false,
            locale: Locale(appModel.localeCode),
            supportedLocales: const [
              Locale('en'),
              Locale('de'),
              Locale('ru'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.blue,
              scaffoldBackgroundColor: Colors.black, // для темной темы
              canvasColor: Colors.black,
            ),
            initialRoute: app.needShowWelcome.value ? '/welcome' : '/home',
            onGenerateRoute: (settings) {
              WidgetBuilder builder;

              // --- ЛОГИ ДЛЯ ОТЛАДКИ ---
              final prevRoute =
                  lastRouteForAnimation ?? myRouteObserver.lastRoute;
              // debugPrint('onGenerateRoute: prevRoute=$prevRoute, next=${settings.name}, settingsRoot=$settingsRoot');
              // debugPrint('prevRoute from lastRouteForAnimation: $lastRouteForAnimation');
              //debugPrint('prevRoute from RouteObserver: ${myRouteObserver.lastRoute}');

              // --- Switch-case по routes ---
              switch (settings.name) {
                case '/welcome':
                  builder = (_) => WelcomeScreen(
                        requireConfirmation: true,
                        showLanguageSelector: true,
                        helpStyle: false,
                      );
                  break;

                case '/':
                  builder = (_) => HomeScreen();
                  break;
                case '/home':
                  builder = (_) => HomeScreen();
                  break;

                case '/playlist':
                  builder = (context) {
                    final app = Provider.of<AppModel>(context, listen: false);
                    return PlaylistScreen(
                      audioState: app.playlist,
                      onTrackDeleted: app.playlist.stopIfPlayingDeletedTrack,
                      onTrackSelected: (index) => app.playManualTrack(index),
                    );
                  };
                  break;
                case '/playlist/add_files':
                  builder = (_) => AddFilesToPlaylistScreen();
                  break;
                case '/folder_playlist':
                  builder = (context) {
                    final app = Provider.of<AppModel>(context, listen: false);
                    return FolderPlaylistScreen(
                      audioState: app.playlist,
                      onTrackSelected: (index) => app.playFolderTrack(index),
                    );
                  };
                  break;
                case '/settings/language':
                  builder = (_) => LanguageSettingsScreen();
                  break;
                case '/settings/home':
                  builder = (_) => SettingsHomeScreen();
                  break;
                case '/settings/playback':
                  builder = (_) => PlaybackSettingsScreen();
                  break;
                case '/settings/jog':
                  builder = (_) => JogSettingsScreen();
                  break;
                case '/settings/interface':
                  builder = (_) => ColorSettingsScreen();
                  break;
                case '/settings/timecode':
                  builder = (_) => TimeDisplaySettingsScreen();
                  break;
                case '/settings/tempfiles':
                  builder = (_) => TempFilesSettingsScreen();
                  break;
                case '/settings/equalizer':
                  builder = (_) => EqualizerScreen();
                  break;
                case '/help':
                  builder = (_) => HelpHomeScreen();
                  break;
                case '/help/about':
                  builder = (_) => AboutAppScreen();
                  break;
                case '/help/licenses':
                  builder = (_) => HelpLicensesScreen();
                  break;
                case '/help/licenses/detail':
                  final args = settings.arguments
                      as Map<String, dynamic>?; // или твоя структура
                  builder = (_) => LicenseDetailScreen(
                        package: args?['package'],
                        paragraphs: args?['paragraphs'],
                      );
                  break;
                case '/help/widgets':
                  builder = (_) => HelpWidgetsScreen();
                  break;
                case '/help/playlist':
                  builder = (_) => HelpManualPlaylistScreen();
                  break;
                case '/help/remove_ads':
                  builder = (_) => RemoveAdsScreen();
                  break;
                case '/help/welcome':
                  builder = (_) => const WelcomeScreen(
                        requireConfirmation: false,
                        showLanguageSelector: false,
                        helpStyle: true,
                      );
                  break;
                default:
                  builder = (_) => HomeScreen();
              }

              // --- Направление свайпа ---
              Offset begin = const Offset(1.0, 0.0);

              String normalizeMainRoute(String? route) {
                if (route == null) return '/home';
                if (route.startsWith('/settings')) return '/settings';
                if (route.startsWith('/help')) return '/help';
                if (route.startsWith('/folder_playlist'))
                  return '/folder_playlist';
                if (route.startsWith('/playlist')) return '/playlist';
                if (route.startsWith('/home')) return '/home';
                return route;
              }

              final prevMain = normalizeMainRoute(prevRoute ?? '');
              final nextMain = normalizeMainRoute(settings.name ?? '');

              // 1. Спец. обработка: settings → playlist/folder_playlist — свайп вправо!
              if (prevMain == '/settings' &&
                  (nextMain == '/playlist' || nextMain == '/folder_playlist')) {
                begin = const Offset(-1.0, 0.0);
                // debugPrint('settings → playlist/folder_playlist: swipe RIGHT');
              }
              // 2. playlist/folder_playlist → settings — свайп влево!
              else if ((prevMain == '/playlist' ||
                      prevMain == '/folder_playlist') &&
                  nextMain == '/settings') {
                begin = const Offset(1.0, 0.0);
                // debugPrint('playlist/folder_playlist → settings: swipe LEFT');
              }
              // --- Явный кейс: c любого экрана /playlist или /playlist/... на /folder_playlist — свайп вправо
              else if (prevRoute != null &&
                  prevRoute.startsWith('/playlist') &&
                  nextMain == '/folder_playlist') {
                begin = const Offset(-1.0, 0.0); // свайп вправо
                // debugPrint('/playlist or subroute → /folder_playlist: swipe RIGHT');
              }
              // --- Явный кейс: c /folder_playlist на /playlist или его подменю — свайп влево
              else if (prevMain == '/folder_playlist' &&
                  (nextMain == '/playlist' ||
                      (settings.name?.startsWith('/playlist') ?? false))) {
                begin = const Offset(1.0, 0.0); // свайп влево
                // debugPrint('/folder_playlist → /playlist or subroute: swipe LEFT');
              }
              // --- Вертикальные свайпы для подменю плейлиста ---
              else if (prevRoute == '/playlist' &&
                  playlistSubroutes.contains(settings.name)) {
                begin = const Offset(0.0, 1.0); // снизу вверх
                //   debugPrint('playlist → subroute: swipe UP');
              } else if (playlistSubroutes.contains(prevRoute) &&
                  settings.name == '/playlist') {
                begin = const Offset(0.0, -1.0); // сверху вниз
                //   debugPrint('playlistSubroute → root: swipe DOWN');
              } else if (playlistSubroutes.contains(prevRoute) &&
                  playlistSubroutes.contains(settings.name)) {
                begin = const Offset(0.0, 1.0); // снизу вверх (между подменю)
                //   debugPrint('playlistSubroute → subroute: swipe UP');
              }
              // 3. Вертикальные свайпы для settings
              else if ((prevRoute == settingsRoot ||
                      prevRoute == '/settings' ||
                      prevRoute == '/settings/home') &&
                  settingsSubroutes.contains(settings.name)) {
                begin = const Offset(0.0, 1.0); // снизу вверх
                //     debugPrint('settingsRoot/home → subroute: swipe UP');
              } else if ((settings.name == settingsRoot ||
                      settings.name == '/settings' ||
                      settings.name == '/settings/home') &&
                  (settingsSubroutes.contains(prevRoute) ||
                      settingsSubroutes.contains(lastRouteForAnimation))) {
                begin = const Offset(0.0, -1.0); // сверху вниз
                //    debugPrint('settingsSubroute → root/home: swipe DOWN');
              } else if (settingsSubroutes.contains(prevRoute) &&
                  settingsSubroutes.contains(settings.name)) {
                begin = const Offset(0.0, 1.0); // снизу вверх
                //     debugPrint('settingsSubroute → subroute: swipe UP');
              }
              // 4. Вертикальные свайпы для help
              else if ((prevRoute == helpRoot || prevRoute == '/help') &&
                  helpSubroutes.contains(settings.name)) {
                begin = const Offset(0.0, 1.0); // снизу вверх
                //    debugPrint('helpRoot → subroute: swipe UP');
              } else if ((settings.name == helpRoot ||
                      settings.name == '/help') &&
                  (helpSubroutes.contains(prevRoute) ||
                      helpSubroutes.contains(lastRouteForAnimation))) {
                begin = const Offset(0.0, -1.0); // сверху вниз
                //   debugPrint('helpSubroute → root: swipe DOWN');
              } else if (helpSubroutes.contains(prevRoute) &&
                  helpSubroutes.contains(settings.name)) {
                begin = const Offset(0.0, 1.0); // снизу вверх
                //   debugPrint('helpSubroute → subroute: swipe UP');
              }
              // 5. Горизонтальные свайпы между главными экранами
              else if (mainRoutes.contains(prevMain) &&
                  mainRoutes.contains(nextMain)) {
                int prevIndex = mainRoutes.indexOf(prevMain);
                int nextIndex = mainRoutes.indexOf(nextMain);
                if (nextIndex < prevIndex) {
                  begin = const Offset(-1.0, 0.0); // справа налево (вправо)
                  //     debugPrint('mainRoutes (normalized): swipe RIGHT');
                } else if (nextIndex > prevIndex) {
                  begin = const Offset(1.0, 0.0); // слева направо (влево)
                  //    debugPrint('mainRoutes (normalized): swipe LEFT');
                }
              }
              // 6. Между подменю settings → другой главный экран
              else if (settingsSubroutes.contains(prevRoute) &&
                  mainRoutes.contains(nextMain)) {
                int settingsIndex = mainRoutes.indexOf(settingsRoot);
                int nextIndex = mainRoutes.indexOf(nextMain);
                if (nextIndex < settingsIndex) {
                  begin = const Offset(-1.0, 0.0);
                  //    debugPrint('settingsSubroute → mainRoute: swipe RIGHT');
                } else if (nextIndex > settingsIndex) {
                  begin = const Offset(1.0, 0.0);
                  //    debugPrint('settingsSubroute → mainRoute: swipe LEFT');
                }
              }

              //  debugPrint('Chosen slide direction: $begin');

              // -- Теперь сбрасываем lastRouteForAnimation! --
              lastRouteForAnimation = null;
              final transitionType = app.themeColors.transitionType;

              return PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    builder(context),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  switch (transitionType) {
                    case AppTransitionType.slide:
                      if (begin == Offset.zero) return child;
                      final tween = Tween(begin: begin, end: Offset.zero)
                          .chain(CurveTween(curve: Curves.ease));
                      final offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    case AppTransitionType.fade:
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    case AppTransitionType.scale:
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );

                    case AppTransitionType.none:
                    default:
                      return child;
                  }
                },
                transitionDuration: transitionType == AppTransitionType.none
                    ? Duration.zero
                    : Duration(milliseconds: 300),
                settings: settings,
              );
            },

            /// 👇 Добавляем глобальный фон (глобальный builder)

            builder: (context, child) {
              final app = Provider.of<AppModel>(context, listen: false);
              final theme = app.themeColors;

              return ValueListenableBuilder<String>(
                valueListenable: currentAppRoute,
                builder: (context, currentRoute, _) {
                  // Проверяем — если на welcome, не показываем TopBar
                  final showTopBar = currentRoute != '/welcome';

                  return Stack(
                    children: [
                      // Фон и фонкартинка как было
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.backgroundStart,
                              theme.backgroundEnd,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      if (theme.useBackgroundImage &&
                          theme.backgroundImagePath != null)
                        Positioned.fill(
                          child: Opacity(
                            opacity: theme.backgroundImageOpacity ?? 1.0,
                            child: Builder(
                              builder: (context) {
                                final path = theme.backgroundImagePath;
                                if (path == null) return const SizedBox();

                                ImageProvider? image;

                                if (path.startsWith('assets/')) {
                                  image = AssetImage(path);
                                } else {
                                  final file = File(path);
                                  if (file.existsSync()) {
                                    image = FileImage(file);
                                  }
                                }

                                if (image == null) return const SizedBox();

                                return ColorFiltered(
                                  colorFilter: ColorFilter.matrix(
                                      _createColorFilterMatrix(
                                    brightness:
                                        theme.backgroundImageBrightness ?? 1.0,
                                    contrast:
                                        theme.backgroundImageContrast ?? 1.0,
                                  )),
                                  child: Image(
                                    image: image,
                                    fit: theme.backgroundFitFill
                                        ? BoxFit.fill
                                        : theme.backgroundFitCover
                                            ? BoxFit.cover
                                            : BoxFit.none,
                                    alignment: Alignment.topCenter,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      // Контент (с топбаром или без)
                      Column(
                        children: [
                          if (showTopBar)
                            TopMenuBar(currentRoute: currentRoute),
                          Expanded(child: child ?? SizedBox.shrink()),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final List<String?> _routeStack = [];

  String? get lastRoute =>
      _routeStack.length >= 2 ? _routeStack[_routeStack.length - 2] : null;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _routeStack.add(route.settings.name);
      _updateCurrentRoute();
      debugPrint('RouteObserver didPush: stack = $_routeStack');
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // ⚠️ Удаляем только если route был PageRoute (то есть был добавлен)
    if (route is PageRoute) {
      if (_routeStack.isNotEmpty) _routeStack.removeLast();
      _updateCurrentRoute();
      debugPrint('RouteObserver didPop: stack = $_routeStack');
    } else {
      // Если это не PageRoute (например, DropdownRoute/DialogRoute) — игнорируем!
      debugPrint(
          'RouteObserver didPop: (non-PageRoute, overlay) stack = $_routeStack');
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute is PageRoute) {
      if (_routeStack.isNotEmpty) _routeStack.removeLast();
    }
    if (newRoute is PageRoute) {
      _routeStack.add(newRoute.settings.name);
    }
    _updateCurrentRoute();
    debugPrint('RouteObserver didReplace: stack = $_routeStack');
  }

  void _updateCurrentRoute() {
    String current =
        _routeStack.isNotEmpty ? (_routeStack.last ?? '/home') : '/home';
    // Авто-подмена '/' на '/home'
    if (current == '/' || current == null || current.isEmpty) current = '/home';

    debugPrint('[RouteObserver] currentAppRoute: $current');
    if (currentAppRoute.value != current) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (currentAppRoute.value != current) {
          currentAppRoute.value = current;
        }
      });
    }
    AppAnalytics.logScreenView(current);
  }
}

List<double> _createColorFilterMatrix({
  double brightness = 1.0,
  double contrast = 1.0,
}) {
  final c = contrast;
  final b = (brightness - 1.0) * 255;

  return [
    c,
    0,
    0,
    0,
    b,
    0,
    c,
    0,
    0,
    b,
    0,
    0,
    c,
    0,
    b,
    0,
    0,
    0,
    1,
    0,
  ];
}

// Обсервер для слежения за жизненным циклом приложения
class AppLifecycleHandler extends WidgetsBindingObserver {
  final AppModel app;

  AppLifecycleHandler(this.app);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      // Приложение реально завершилось (например, смахнули)
      app.player.stop(); // или app.audioHandler.stop();
    }
  }
}