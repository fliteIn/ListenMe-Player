import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/widgets.dart';

import 'dart:ui';
import 'audio_to_levels_model.dart';
import 'playlist_model.dart';
import 'playback_model.dart';
import 'purchase_model.dart';
import 'display_widget_config.dart';
import '../enums/enums.dart';
import '../models/app_theme_colors.dart';
import '../utils/theme_presets.dart';
import '../l10n/app_localizations.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import '../services/audio_player_repository.dart';
import '../utils/temp_audio_files_utils.dart';
import '../utils/my_audio_handler.dart';
import '../utils/global_keys.dart';
import 'package:rxdart/rxdart.dart';
import 'app_persistent_state.dart';
import '../main.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../utils/app_analytics.dart';
import '../utils/saf.dart';
import 'package:hive/hive.dart';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../utils/saf.dart';

String safeKey(String uriOrPath) => md5.convert(utf8.encode(uriOrPath)).toString();

const Map<PlayerSection, double> sectionHeightsPhone = {
  PlayerSection.homeBottomControls: 50,
  PlayerSection.trackTitle: 58,
  PlayerSection.progressSlider: 102,
  PlayerSection.jogWheel: 150,
  PlayerSection.playback: 50,
  PlayerSection.speedSlider: 50,
  PlayerSection.silenceControlBar: 50,
  PlayerSection.gradientDivider: 25,
};

const Map<PlayerSection, double> sectionHeightsTablet = {
  PlayerSection.homeBottomControls: 70,
  PlayerSection.trackTitle: 81.2,
  PlayerSection.progressSlider: 153,
  PlayerSection.jogWheel: 204,
  PlayerSection.playback: 70,
  PlayerSection.speedSlider: 70,
  PlayerSection.silenceControlBar: 70,
  PlayerSection.gradientDivider: 35,
};




class SectionSlot {
  final String id;              // уникальный id (например, uuid)
  final PlayerSection type;
  bool active;
  double positionY;

  SectionSlot({
    required this.id,
    required this.type,
    this.active = true,
    this.positionY = 0.0,
  });
}



class AppModel extends ChangeNotifier {


  AppModel() {
    print('🟢 AppModel создан с цветами: $themeColors');
    _playbackMode = PlaybackMode.playlistLoop;

    playbackModel = PlaybackModel();
    playlist = PlaylistModel();
    audio_to_levels = AudioToLevelsModel();

    // 1) сначала "связываем" модели с AppModel
    playbackModel.setAppModel(this);
    playlist.setAppModel(this);
    audio_to_levels.setAppModel(this);

    _initAudioSession();
    loadBackgroundImageSettings();
    _loadOrCreateDeviceId();
    startAnalyticsPolling();
  }

  PurchaseModel? purchaseModel;

  void setPurchaseModel(PurchaseModel model) {
    purchaseModel = model;
  }


  void updateIsTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    isTablet = shortestSide >= 600;
  }


  List<SectionSlot> getDefaultSectionSlots() {
    // Если нужен доступ к purchaseModel, учти это!
    final adsDisabled = purchaseModel?.adsDisabled ?? false;




    if (isTablet) {
      // ----- Планшет: увеличенные значения -----
      return [
        SectionSlot(id: 'homeBottomControls', type: PlayerSection.homeBottomControls, positionY: 50.0, active: true),
        SectionSlot(id: 'trackTitle', type: PlayerSection.trackTitle, positionY: 170.0, active: true),
        SectionSlot(id: 'progressSlider', type: PlayerSection.progressSlider, positionY: 252.0, active: true),

        SectionSlot(id: 'silenceControlBar', type: PlayerSection.silenceControlBar, positionY: 445.0, active: true),
        SectionSlot(id: 'gradientDivider_1', type: PlayerSection.gradientDivider, positionY: 515.0, active: true),

        SectionSlot(id: 'playback', type: PlayerSection.playback, positionY: 550.0, active: true),
        SectionSlot(id: 'gradientDivider_2', type: PlayerSection.gradientDivider, positionY: 620.0, active: true),
        SectionSlot(id: 'jogWheel', type: PlayerSection.jogWheel, positionY: 655.0, active: true),
        SectionSlot(id: 'gradientDivider_3', type: PlayerSection.gradientDivider, positionY: 859.0, active: true),
        SectionSlot(id: 'speedSlider', type: PlayerSection.speedSlider, positionY: 894.0, active: adsDisabled),
      ];
    } else {
      // ----- Смартфон: твои значения -----
      return [
        SectionSlot(id: 'homeBottomControls', type: PlayerSection.homeBottomControls, positionY: 0.0, active: true),
        SectionSlot(id: 'trackTitle', type: PlayerSection.trackTitle, positionY: 50.0, active: true),
        SectionSlot(id: 'progressSlider', type: PlayerSection.progressSlider, positionY: 108.0, active: true),

        SectionSlot(id: 'silenceControlBar', type: PlayerSection.silenceControlBar, positionY: 225.0, active: true),
        SectionSlot(id: 'gradientDivider_1', type: PlayerSection.gradientDivider, positionY: 275.0, active: true),

        SectionSlot(id: 'playback', type: PlayerSection.playback, positionY: 300.0, active: true),
        SectionSlot(id: 'gradientDivider_2', type: PlayerSection.gradientDivider, positionY: 350.0, active: true),
        SectionSlot(id: 'jogWheel', type: PlayerSection.jogWheel, positionY: 375.0, active: true),
        SectionSlot(id: 'gradientDivider_3', type: PlayerSection.gradientDivider, positionY: 525.0, active: true),
        SectionSlot(id: 'speedSlider', type: PlayerSection.speedSlider, positionY: 550.0, active: adsDisabled),
      ];
    }
  }



  bool isTablet = false;


  AppThemeColors _themeColors = AppThemeColors.standard();
  AppThemeColors _savedThemeColors = AppThemeColors.standard();
  bool _initialized = false;

  late final AudioHandler audioHandler;

  final player = AudioPlayerRepository().player;

  late final AudioToLevelsModel audio_to_levels;
  late final PlaybackModel playbackModel;
  late final PlaylistModel playlist;



  List<String> folderPlaylist = [];
  bool usingFolderPlaylist = false;

  PlaylistSource currentPlaylistSource = PlaylistSource.manual;

  List<String> get currentPlaylist {
    return currentPlaylistSource == PlaylistSource.folder
        ? folderPlaylist
        : playlist.trackPaths;
  }




  static const String _trackPathsKey = 'track_paths';

  String? _backgroundImagePath;
  String? lastVisitedSettingsScreen;
  String lastVisitedSettingsScreenRoute = '/settings/home';
  double? colorSettingsScrollOffset;

  String? lastVisitedHelpScreenRoute;
  double? helpWidgetsScrollOffset;




  PlaylistSource? lastLoadedPlaylistSource; // что реально загружено в player.sequence

  List<String> widgetOrderIds = [
    'trackTitle',
    'positionGroup',
    'playbackButtons',
    'jog',
    'speedSlider',
    'silenceBar',
  ];

  final ValueNotifier<Duration> positionVN = ValueNotifier(Duration.zero);
  final ValueNotifier<bool>     isPlayingVN = ValueNotifier(false);
  final ValueNotifier<double>   currentPcmLevelVN = ValueNotifier(0.0);

  Timer? _positionTimer;

  Timer? savePositionTimer;
  Duration? _lastSavedPosition;
  static const int _savePositionDebounceMs = 2000;

  late final AppPersistentState persistentState;

  final List<AppThemeColors> _undoStack = [];
  final List<AppThemeColors> _redoStack = [];



  List<SectionSlot> sectionSlots = [];

  void removeSectionById(String id) {
    final index = sectionSlots.indexWhere((s) => s.id == id);
    if (index == -1) return;
    final slot = sectionSlots[index];
    if (slot.type == PlayerSection.gradientDivider) {
      sectionSlots.removeAt(index);
    } else {
      slot.active = false;
      slot.positionY = 0;
    }
    saveSectionSlots(sectionSlots); // <<<<< Сохраняем!
    notifyListeners();
    print('--- AFTER REMOVE ---');
    print(sectionSlots.map((s) => '${s.id} | ${s.type} | ${s.active} | y=${s.positionY}').join('\n'));
  }








  int? _lastExplicitTrackSwitch;

  int? get lastExplicitTrackSwitch => _lastExplicitTrackSwitch;
  set lastExplicitTrackSwitch(int? value) {
    _lastExplicitTrackSwitch = value;
  }

  // Если хотите — можно сделать метод для сброса
  void clearExplicitTrackSwitch() {
    _lastExplicitTrackSwitch = null;
  }

  Timer? _positionSaveTimer;

  // Внутри AppModel:





  final ValueNotifier<bool> needShowWelcome = ValueNotifier(true); // ДОЛЖНО быть true по умолчанию

  Future<void> checkWelcomeFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('hasSeenWelcome') ?? false;
    //final seen = false;
    needShowWelcome.value = !seen;
  }

  Future<void> setWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWelcome', true);
    needShowWelcome.value = false;
  }



  Duration clampToMarkers(Duration position) {
    if (playBetweenMarkers && markerA != markerB) {
      final left = markerA < markerB ? markerA : markerB;
      final right = markerA > markerB ? markerA : markerB;
      if (position < left) return left;
      if (position > right) return right;
    }
    return position;
  }


  void setCurrentPlaylistSource(PlaylistSource source) {
    currentPlaylistSource = source;
    persistentState.playlistSource = source.name;
    persistentState.save();
    isPlayingVN.value = player.playing;
    notifyListeners();
  }

  Future<void> loadOrInitSectionSlots() async {
    final loaded = await loadSectionSlots();
    sectionSlots = loaded;

    // Если по какой-то причине список слотов пустой — применяем заводские
    if (sectionSlots.isEmpty) {
      sectionSlots = getDefaultSectionSlots();
    }

    notifyListeners();
  }

  Future<void> saveSectionSlots(List<SectionSlot> slots) async {
    final prefs = await SharedPreferences.getInstance();
    final strings = slots.map((s) =>
    '${s.id}|${s.type}|${s.positionY}|${s.active}'
    ).toList();
    await prefs.setStringList('section_slots', strings);
    print('Saved section_slots: $strings');
  }

  Future<List<SectionSlot>> loadSectionSlots() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('section_slots');
    print('Loaded section_slots: $list');
    if (list == null) return getDefaultSectionSlots();
    return list.map((s) {
      final parts = s.split('|');
      return SectionSlot(
        id: parts[0],
        type: PlayerSection.values.firstWhere((e) => e.toString() == parts[1]),
        positionY: double.tryParse(parts[2]) ?? 0.0,
        active: parts[3] == 'true',
      );
    }).toList();
  }

  void restoreSection(String id, [double? positionY]) {
    final index = sectionSlots.indexWhere((s) => s.id == id);
    if (index != -1) {
      sectionSlots[index].active = true;
      if (positionY != null) sectionSlots[index].positionY = positionY;
      saveSectionSlots(sectionSlots);
      notifyListeners();
    }
  }



  List<SectionSlot> get activeSlots => sectionSlots.where((s) => s.active).toList();
  List<SectionSlot> get inactiveSlots => sectionSlots.where((s) => !s.active).toList();


  List<PlayerSection> get allSections => PlayerSection.values;



  void addSection(PlayerSection section, int index, {double positionY = 0.0}) {
    if (section == PlayerSection.gradientDivider) {
      sectionSlots.add(
        SectionSlot(
          id: Uuid().v4(),
          type: PlayerSection.gradientDivider,
          active: true,
          positionY: positionY,
        ),
      );
    } else {
      // стандартная логика (для других секций)
      SectionSlot? slot;
      try {
        slot = sectionSlots.firstWhere((s) => s.type == section);
      } catch (_) {
        slot = null;
      }
      if (slot != null) {
        slot.active = true;
        slot.positionY = positionY;
      }
    }
    saveSectionSlots(sectionSlots);
    notifyListeners();
  }




  void setSectionActive(PlayerSection section, bool value) {
    final index = sectionSlots.indexWhere((s) => s.type == section);
    if (index != -1) {
      print('🔴 setSectionActive: $section → $value');
      sectionSlots[index].active = value;
      saveSectionSlots(sectionSlots);
      notifyListeners();
      print('🔔 notifyListeners после удаления');
    }
  }


  @override
  void notifyListeners() {

    super.notifyListeners();
  }

  void toggleSlotActive(int index) {
    sectionSlots[index].active = !sectionSlots[index].active;
    saveSectionSlots(sectionSlots);
    notifyListeners();
  }

  void moveSlot(int fromIndex, int toIndex) {
    final slot = sectionSlots.removeAt(fromIndex);
    sectionSlots.insert(toIndex, slot);
    saveSectionSlots(sectionSlots); // Сохраняем!
    notifyListeners();
  }




  bool _editMode = false;
  bool get editMode => _editMode;

  void setEditMode(bool value) {
    if (_editMode != value) {
      _editMode = value;
      notifyListeners();
    }
  }

  void updateSystemUi(AppThemeColors theme) {
    // Используй нужные цвета из theme
    final Color bgColor = theme.backgroundStart; // например

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // Прозрачный статусбар (фон будет виден!)
        statusBarColor: Colors.transparent,
        // Светлый/тёмный цвет иконок
        statusBarIconBrightness: ThemeData.estimateBrightnessForColor(bgColor) == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,

        systemNavigationBarIconBrightness: Brightness.light,
        /*
          systemNavigationBarIconBrightness: ThemeData.estimateBrightnessForColor(bgColor) == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
*/
        // Для прозрачного навбара:

        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  void undoThemeChange() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(_themeColors);
      _themeColors = _undoStack.removeLast();
      notifyListeners();
      try {
        WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      } catch (_) {}
    }
  }

  void redoThemeChange() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(_themeColors);
      _themeColors = _redoStack.removeLast();
      notifyListeners();
      try {
        WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      } catch (_) {}
    }
  }


  set position(Duration v) {
    positionVN.value = v;

    _lastSavedPosition = v;
    savePositionTimer?.cancel();
    savePositionTimer = Timer(
      const Duration(milliseconds: _savePositionDebounceMs),
          () => saveCurrentTrackPosition(),
    );
  }

  Future<void> saveCurrentTrackPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final trackId = originalTrackPath ?? currentTrackPath ?? 'unknown';
    final position = player.position; // Получаем актуальную позицию
    await prefs.setInt('track_position_$trackId', position.inMilliseconds);
    //print('[SAVE_POSITION] Saved $position for $trackId');
  }


  Future<Duration?> loadTrackPosition(String trackId) async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt('track_position_$trackId');
    if (ms != null && ms > 0) return Duration(milliseconds: ms);
    return null;
  }



  Timer? _seekThrottleTimer;
  Duration? _lastThrottledPosition;

  void seekThrottled(Duration position) {
    // Запретить перемотку, если нет треков или индекс невалидный
    final list = currentPlaylist;
    final ix = currentIndex;
    if (list.isEmpty || ix == null || ix < 0 || ix >= list.length) return;

    _lastThrottledPosition = clampToMarkers(position);

    if (_seekThrottleTimer != null && _seekThrottleTimer!.isActive) return;

    _seekThrottleTimer = Timer(const Duration(milliseconds: 80), () async {
      if (_lastThrottledPosition != null) {
        manualSeekInProgress = true;
        await player.seek(_lastThrottledPosition!);
        positionVN.value = _lastThrottledPosition!;
        manualSeekInProgress = false;
      }
    });
  }



  Duration get position => positionVN.value;
  //set position(Duration v) { positionVN.value = v; } // без notifyListeners()

  bool get isPlaying => isPlayingVN.value;
  set isPlaying(bool v) { isPlayingVN.value = v; }   // без notifyListeners()

  double get currentPcmLevel => currentPcmLevelVN.value;
  set currentPcmLevel(double v) {
    if (currentPcmLevelVN.value != v) currentPcmLevelVN.value = v;
  } // без notifyListeners()

  Duration? _lastReportedPosition;

  bool _segmentEndHandled = false;

  void startPositionPolling() {
    //print('🟡 [POLLING] startPositionPolling CALLED! (hashCode: $hashCode, DateTime: ${DateTime.now()})');

    // Отмена предыдущей подписки, если была
    _positionSub?.cancel();
    //print('🟡 [POLLING] Старая подписка _positionSub отменена');

    _positionSub = player.positionStream
        .sampleTime(const Duration(milliseconds: 33))
        .listen((pos) async {
      //print('[POLLING] positionStream: $pos');
      // Лог по позиции
      final left = markerA < markerB ? markerA : markerB;
      final right = markerA > markerB ? markerA : markerB;

      //print('🟢 [POS] $pos | markerA: $markerA | markerB: $markerB | left: $left | right: $right | playBetweenMarkers: $playBetweenMarkers | _segmentEndHandled: $_segmentEndHandled');
      //print('🟢 [VN] positionVN.value = $pos | old: ${positionVN.value}');

      position = pos;
      positionVN.value = pos;

      // Только если активен playBetweenMarkers
      if (playBetweenMarkers && markerA != markerB) {
        final left = markerA < markerB ? markerA : markerB;
        final right = markerA > markerB ? markerA : markerB;

        //print('🟡 [MARKER] CHECK: pos=$pos, right=$right, _segmentEndHandled=$_segmentEndHandled, pos>=right=${pos >= right}');

        if (!_segmentEndHandled && pos >= right) {
          //print('🔴 [MARKER PAUSE] pos=$pos, right=$right — вызываем остановку');
          _segmentEndHandled = true;
          await playbackModel.handleTrackOrSegmentEnd();
        } else if (_segmentEndHandled && pos < right) {
          //print('🟢 [MARKER RESET] pos=$pos < right=$right, сброс _segmentEndHandled');
          _segmentEndHandled = false;
        }
      }
      // Для обычных режимов не вызываем handleTrackOrSegmentEnd!
    });

    //print('🟡 [POLLING] → SUBSCRIBED to player.positionStream');

    _positionSaveTimer?.cancel();
    //print('🟡 [POLLING] positionSaveTimer СТОП');
    _positionSaveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      final currentPos = positionVN.value;
      if (currentPos != null && currentTrackPath != null) {
        //print('🟢 [POLLING][SAVE_POSITION] $currentPos for $currentTrackPath');
        _lastSavedPosition = currentPos;
        saveCurrentTrackPosition();
      }
    });
    //print('🟡 [POLLING] positionSaveTimer ЗАПУЩЕН');
  }





  void stopPositionPolling() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }


  Future<void> playManualTrack(int index) async {
    print('\n==============================');
    print('[APP] 📥 playManualTrack($index)');

    // 0) Валидация индекса
    final list = currentPlaylist; // это всегда актуальный список!
    if (index < 0 || index >= list.length) {
      debugPrint('❌ Неверный индекс: $index (доступно: ${list.length})');
      print('==============================\n');
      return;
    }

    // 1) Переключаем источник, если надо
    final needSwitch = currentPlaylistSource != PlaylistSource.manual;
    if (needSwitch) {
      setCurrentPlaylistSource(PlaylistSource.manual);
      lastLoadedPlaylistSource = null; // только если это реально нужно у тебя!
      print('[APP] 🟢 Источник переключён: manual');
    }

    // 2) Просто вызываем playTrackAt для этого индекса (он сам сделает setAudioSource)
    try {
      await playbackModel.playTrackAt(index, autoplay: true);
      currentIndex = index;
      print('[APP] ▶️ Запуск трека index=$index');
    } catch (e) {
      debugPrint('❌ Ошибка при запуске трека $index: $e');
    }

    print('[APP] ✅ playManualTrack завершён');
    print('==============================\n');
  }


  Future<void> playFolderTrack(int index, {bool autoplay = false}) async {
    print('\n==============================');
    print('[APP] 📥 playFolderTrack($index)');

    // !!! Не инициализируй плеер повторно, если не менялся источник !!!
    if (currentPlaylistSource == PlaylistSource.folder &&
        lastLoadedPlaylistSource == PlaylistSource.folder &&
        isPlayerInitialized) {
      print('[APP] 📁 Источник folder уже инициализирован, пропускаю initializePlayer');
    } else {
      setCurrentPlaylistSource(PlaylistSource.folder);
      lastLoadedPlaylistSource = null;
      print('[APP] 📁 Источник установлен: folder');
      await initializePlayer();
    }

    // Просто проигрываем нужный трек
    await playbackModel.playTrackAt(index, autoplay: autoplay);

    // Фоновый анализ
    final trackPath = currentPlaylist[index];
    Future.microtask(() async {
      if (showSilenceControlBar) {
        await audio_to_levels.analyzeTrack(full: true, force: true);
      }
    });

    print('[APP] ✅ playFolderTrack завершён');
    print('==============================\n');
  }



  bool _streamsConnected = false; // Добавь в AppModel, если ещё не было

  void restoreFromPersistentState() async {

    _silenceThresholdDb = persistentState.silenceThreshold;
    currentIndex = persistentState.currentIndex;  // 🟢 восстановление индекса
    currentTrackPath = persistentState.currentTrackPath;
    originalTrackPath = persistentState.currentTrackPath;

    changeSpeed(persistentState.playbackSpeed);
    markerA = Duration(milliseconds: persistentState.markerA ?? 0);
    markerB = Duration(milliseconds: persistentState.markerB ?? 0);
    _showPlaybackButtons = persistentState.showPlaybackButtons;
    _showJogAndSeekButtons = persistentState.showJogAndSeekButtons;
    _showSpeedSlider = persistentState.showSpeedSlider;
    _showSilenceControlBar = persistentState.showSilenceControlBar;

    _playbackMode = PlaybackMode.values.firstWhere(
          (e) => e.name == (persistentState.playbackMode ?? 'playlistLoop'),
      orElse: () => PlaybackMode.playlistLoop,
    );

    _lastSegmentPlaybackMode = PlaybackMode.values.firstWhere(
          (e) => e.name == (persistentState.lastSegmentPlaybackMode ?? 'singleLoop'),
      orElse: () => PlaybackMode.singleLoop,
    );

    _showMarkers = persistentState.showMarkers;
    _playBetweenMarkers = persistentState.playBetweenMarkers;

    currentPlaylistSource = PlaylistSource.values.firstWhere(
          (e) => e.name == (persistentState.playlistSource ?? 'manual'),
      orElse: () => PlaylistSource.manual,
    );



    _localeCode = persistentState.localeCode;



    playbackButtonStyle = PlaybackButtonStyle.values.firstWhere(
          (e) => e.name == (persistentState.playbackButtonStyle ?? 'precise'),
      orElse: () => PlaybackButtonStyle.precise,
    );

    minSpeed = persistentState.minSpeed;
    maxSpeed = persistentState.maxSpeed;

    timeDisplayStyle = TimeDisplayStyle.values.firstWhere(
          (e) => e.name == (persistentState.timeDisplayStyle ?? 'mmss'),
      orElse: () => TimeDisplayStyle.mmss,
    );
    secondaryTimeType = SecondaryTimeType.values.firstWhere(
          (e) => e.name == (persistentState.secondaryTimeType ?? 'remaining'),
      orElse: () => SecondaryTimeType.remaining,
    );


    jogResolutionSecondsPerRevolution = persistentState.jogResolutionSecondsPerRevolution;
    minJogSkipSpeedMsPerSec = persistentState.minJogSkipSpeedMsPerSec;
    maxJogSkipSpeedMsPerSec = persistentState.maxJogSkipSpeedMsPerSec;

    cacheRetentionDays = persistentState.cacheRetentionDays ?? 7;
    cacheMaxSizeMb = persistentState.cacheMaxSizeMb ?? 1024;


    print('[RESTORE] Восстановлен index=$currentIndex, path=$currentTrackPath'); // 🟢 лог
    notifyListeners();
  }



  bool _restoredOnce = false;

  bool get restoredOnce => _restoredOnce;

  bool _isCompletionProcessing = false;


  Future<void> initializePlayer() async {
    print('\n[🟦INIT] initializePlayer() START');
    print('[🟦INIT] persistentState.currentIndex = ${persistentState.currentIndex}');
    print('[🟦INIT] persistentState.currentTrackPath = ${persistentState.currentTrackPath}');
    print('[🟦INIT] currentIndex (start) = $currentIndex');

    // 1. Отмена старых подписок и polling
    _positionSub?.cancel();
    _playingSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _indexSub?.cancel();
    _streamsConnected = false;

    // 2. Проверка индекса трека и восстановление по пути
    if (currentPlaylist.isNotEmpty) {
      if (currentIndex == null || currentIndex! < 0 || currentIndex! >= currentPlaylist.length) {
        // Попытка восстановить индекс по сохранённому пути
        final persistedPath = persistentState.currentTrackPath;
        if (persistedPath != null) {
          final found = currentPlaylist.indexOf(persistedPath);
          if (found != -1) {
            currentIndex = found;
            print('[🟦INIT] 🔎 Восстановил индекс по пути: $found');
          } else {
            print('[🟦INIT] ❌ Индекс невалиден и путь не найден — сбрасываю на 0');
            currentIndex = 0;
          }
        } else {
          print('[🟦INIT] ❌ Индекс невалиден — сбрасываю на 0');
          currentIndex = 0;
        }
      } else {
        print('[🟦INIT] ✅ Используем восстановленный индекс: $currentIndex');
      }
    } else {
      currentIndex = null;
    }

    print('[🟦INIT] lastLoadedPlaylistSource=$lastLoadedPlaylistSource, currentPlaylistSource=$currentPlaylistSource');
    final playlistChanged = lastLoadedPlaylistSource != currentPlaylistSource;
    print('[🟦INIT] playlistChanged = $playlistChanged');

    final wasPlaying = player.playing;
    print('[🟦INIT] wasPlaying=$wasPlaying, isPlayerInitialized=$isPlayerInitialized');

    if (isPlayerInitialized && playlistChanged) {
      print('[🟦INIT] ⚒ Источник изменился — сбрасываем плеер');
      try {
        await player.stop();
      } catch (e) {
        print('[🟦INIT] ⚠️ Ошибка при сбросе источника: $e');
      }
      isPlayerInitialized = false;
    }

    final cp = currentPlaylist;
    print('[🟦INIT] currentPlaylist = $cp');

    if (cp.isEmpty) {
      print('[🟦INIT] ❌ Плейлист пуст — инициализация невозможна');
      print('[🟦INIT] END\n');
      return;
    }

    final ix = currentIndex;
    if (ix == null || ix < 0 || ix >= cp.length) {
      print('[INIT] Нет валидного текущего трека — НЕ будем ничего грузить!');
      print('[INIT] END\n');
      return;
    }

    final path = cp[ix]; // path всегда оригинальный URI

    // 🟡 SAF-совместимость — временный путь только для just_audio!
    String playablePath = path;
    if (playablePath.startsWith('content://')) {
      print('[🟦INIT] SAF detected: $playablePath');
      try {
        final temp = await SAF.copySafUriToTempFile(playablePath);
        if (temp != null) {
          playablePath = temp;
          print('[🟦INIT] Copied SAF file to temp: $playablePath');
        } else {
          print('[🟦INIT] ❌ Failed to copy SAF file');
          return;
        }
      } catch (e) {
        print('[🟦INIT] ❌ Exception during SAF copy: $e');
        return;
      }
    }

    final uri = Uri.file(playablePath);

    print('[🟦INIT] >>> Входим в TRY-блок...');
    print('[🟦INIT] ▶️ Готовимся загружать index=$ix, path=$playablePath');

    try {
      Duration initialPos = Duration.zero;
      try {
        // Позиция восстанавливается по оригинальному пути!
        final saved = await loadTrackPosition(path);
        if (saved != null && saved > Duration.zero) {
          initialPos = saved;
        }
      } catch (e) {
        print('[🟦INIT] ⚠️ Не удалось прочитать сохранённую позицию: $e');
      }

      _lastExplicitTrackSwitch = ix;

      print('[🟦INIT] ▶️ setAudioSource (initialPosition=$initialPos)');
      await player.setAudioSource(
        AudioSource.uri(uri),
        preload: true,
        initialPosition: initialPos,
      );

      if (Platform.isAndroid) {
        final sessionId = player.androidAudioSessionId;
        if (sessionId != null) {
          await reapplyEqualizerFromPrefs(sessionId);
        }
      }

      // 🆕 Устанавливаем режим loopMode в off
      await player.setLoopMode(LoopMode.off);

      startPositionPolling(); // <- только polling для позиции

      isPlayerInitialized = true;

      // 🟢 Правильная строка: только оригинальный URI!
      currentTrackPath = path; // Сохраняем только URI (content://...), не temp!
      // Если есть originalTrackPath — удали/не используй его.
      currentIndex = ix;
      lastLoadedPlaylistSource = currentPlaylistSource;
      duration = player.duration ?? duration;
      position = initialPos;
      positionVN.value = initialPos;
      print('[UPDATE] positionVN set to $initialPos');
      print('[🟦INIT] 🎯 Итог: выбран index=$currentIndex, path=$currentTrackPath');
      if (initialPos > Duration.zero) {
        print('[🟦INIT] ⏪ Восстановлена позиция: $initialPos');
      }

      if (wasPlaying) {
        print('[🟦INIT] Восстанавливаем проигрывание...');
        await player.play();
      } else {
        await player.pause();
      }

      // --- СТРИМЫ ---
      if (!_streamsConnected) {
        _streamsConnected = true;
        print('[🟦INIT] Подключаю стримы...');

        _stateSub = player.playerStateStream.listen((state) async {
          print('[LISTEN] playerStateStream: $state');
          print('[PLAYER_STATE] processingState=${state.processingState}, playing=${state.playing}');
          isPlayingVN.value = state.playing;

          if (state.processingState == ProcessingState.completed) {
            if (!_isCompletionProcessing) {
              _isCompletionProcessing = true;
              await playbackModel.handleTrackOrSegmentEnd();
            } else {
              print('[DEBUG][playerStateStream] DOUBLE completed — skipped!');
            }
          } else {
            _isCompletionProcessing = false;
          }

          notifyListeners();
        });

        _durationSub = player.durationStream.listen((d) {
          print('[LISTEN] durationStream: $d');
          if (d != null) {
            duration = d;
            notifyListeners();
          }
        });
      }

      print('[🟦INIT] ✅ Player fully initialized');
    } catch (e, st) {
      print('[🟦INIT] ❌ Error in setAudioSource: $e\n$st');
    }

    print('[🟦INIT] END\n');
  }


  String? _localeCode;

  String get localeCode => _localeCode ?? 'en';



  void setLocale(String code) {
    _localeCode = code;
    persistentState.localeCode = code;
    persistentState.save();
    notifyListeners(); // чтобы интерфейс обновился
  }

  String getSystemLocale() {
    return ui.window.locale.languageCode;
  }

  static const supported = ['ru', 'en', 'de'];

  Future<void> setInitialLocaleIfNeeded() async {
    print('[DEBUG] persistentState.localeCode: ${persistentState.localeCode}');
    if ((persistentState.localeCode ?? '').isNotEmpty) return;
    print('[DEBUG] setInitialLocaleIfNeeded called');
    final systemLang = ui.window.locale.languageCode;
    print('System lang: $systemLang'); // Для отладки!
    final useLang = supported.contains(systemLang) ? systemLang : 'en';
    setLocale(useLang);
  }



  Map<String, double> scrollPositions = {};

  bool openSettingsRootNextTime = false;

  double? lastSettingsScrollOffset;

  double _backgroundImageOpacity = 1.0;
  bool _backgroundImageEnabled = false;



  List<DisplayWidgetConfig> getWidgetOrder(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final allWidgets = {
      'trackTitle':
          DisplayWidgetConfig(id: 'trackTitle', label: loc.widgetTrackTitle),
      'positionGroup': DisplayWidgetConfig(
        id: 'positionGroup',
        label: loc.widgetPositionGroup,
        widgetIds: ['playbackTime', 'markerA', 'progressSlider', 'markerB'],
      ),
      'playbackButtons': DisplayWidgetConfig(
          id: 'playbackButtons', label: loc.widgetPlaybackButtons),
      'jog': DisplayWidgetConfig(id: 'jog', label: loc.widgetJog),
      'speedSlider':
          DisplayWidgetConfig(id: 'speedSlider', label: loc.widgetSpeedSlider),
      'silenceBar':
          DisplayWidgetConfig(id: 'silenceBar', label: loc.widgetSilenceBar),
    };

    return widgetOrderIds.map((id) => allWidgets[id]!).toList();
  }

  String getLocalizedThemeName(BuildContext context, String key) {
    final loc = AppLocalizations.of(context)!;
    switch (key) {
      case ThemeKeys.standard:
        return loc.themeStandard;
      case ThemeKeys.dark:
        return loc.themeDark;
      case ThemeKeys.light:
        return loc.themeLight;
      case ThemeKeys.custom:
        return loc.themeCustom;
      default:
        return key;
    }
  }


  DateTime? _seekStartedAt;

  Future<T> duringSeek<T>(Future<T> Function() op) async {
    manualSeekInProgress = true;
    _seekStartedAt = DateTime.now();
    try {
      return await op();
    } finally {
      manualSeekInProgress = false;
      _seekStartedAt = null;
    }
  }

  bool manualSeekInProgress = false;


  Future<T> withManualSeek<T>(Future<T> Function() action) async {
    if (manualSeekInProgress) {
      debugPrint('[SEEK] overlapping seek detected');
    }
    manualSeekInProgress = true;
    _seekStartedAt = DateTime.now();
    try {
      return await action();
    } finally {
      manualSeekInProgress = false;
      _seekStartedAt = null;
    }
  }


  MediaItem? get currentMediaItem => audioHandler.mediaItem.valueOrNull;






  Future<void> playTrackAt(int index) async {
    await playbackModel.playTrackAt(index);
  }


  void setFolderPlaylist(List<String> paths) {
    folderPlaylist
      ..clear()
      ..addAll(paths);
    usingFolderPlaylist = true;

    // Вместо прямого присваивания:
    setCurrentPlaylistSource(PlaylistSource.folder);

    shuffleOrder.clear();
    shufflePointer = 0;

    notifyListeners();
  }



  void updateBackgroundImageSettings({
    String? imagePath,
    String? displayName, // 👈 добавляем параметр
    bool? useBackgroundImage,
    bool? fitFill,
    bool? fitCover,
    double? brightness,
    double? contrast,
    double? opacity,
  }) {
    updateThemeColorsPartial((c) => c.copyWith(
      backgroundImagePath: imagePath ?? c.backgroundImagePath,
      backgroundImageDisplayName:
      displayName ?? c.backgroundImageDisplayName, // 👈 прокидываем в copyWith
      useBackgroundImage: useBackgroundImage ?? c.useBackgroundImage,
      backgroundFitFill: fitFill ?? c.backgroundFitFill,
      backgroundFitCover: fitCover ?? c.backgroundFitCover,
      backgroundImageBrightness:
      brightness ?? c.backgroundImageBrightness,
      backgroundImageContrast:
      contrast ?? c.backgroundImageContrast,
      backgroundImageOpacity:
      opacity ?? c.backgroundImageOpacity,
    ));
  }


  void applyBackgroundImageSettingsFromTheme(AppThemeColors theme) {
    print('[APPLY] useBackgroundImage = ${theme.useBackgroundImage}');
    print('[APPLY] backgroundFitFill = ${theme.backgroundFitFill}');
    print('[APPLY] backgroundFitCover = ${theme.backgroundFitCover}');

    backgroundImagePath = theme.backgroundImagePath;
    backgroundImageEnabled = theme.useBackgroundImage;
    backgroundImageFillScreen = theme.backgroundFitFill;
    backgroundImageRepeat = theme.backgroundFitCover;
    backgroundImageOpacity = theme.backgroundImageOpacity ?? 1.0;
  }


  void updateBackgroundImageOpacity(double opacity) {
    _themeColors = _themeColors.copyWith(backgroundImageOpacity: opacity);
    backgroundImageOpacity = opacity;
    notifyListeners();
  }


  Future<void> clearTempCache() async {
    final tempDir = await getTemporaryDirectory();

    // Названия системных подпапок в кэше, которые пропускаем
    const skipDirs = <String>[
      'file_picker', // если у тебя есть другие важные — добавь сюда
    ];

    for (final entity in tempDir.listSync()) {
      final path = entity.path;
      final name = path.split(Platform.pathSeparator).last;

      // Пропускаем системные подпапки
      if (skipDirs.contains(name)) continue;

      try {
        if (entity is File) {
          // Удаляем ЛЮБОЙ файл (и wav, и saf_temp, и всё прочее)
          await entity.delete();
          print('🗑 Удалён файл из кэша: $path');
        } else if (entity is Directory) {
          // Удаляем все директории, кроме системных
          await entity.delete(recursive: true);
          print('🗑 Удалена директория из кэша: $path');
        }
      } catch (e) {
        print('⚠️ Не удалось удалить $path: $e');
      }
    }
  }


  Future<void> saveTrackPaths() async {
    print('[PLAYLIST][SAVE] Сохраняю плейлист: $manualPlaylist');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_trackPathsKey, manualPlaylist);
  }

  Future<List<String>> loadTrackPaths() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_trackPathsKey) ?? [];
  }

  bool _wasPlayingBeforeInterruption = false;

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        print('📞 Входящее прерывание: ${event.type}');
        _wasPlayingBeforeInterruption = player.playing;
        if (_wasPlayingBeforeInterruption) {
          player.pause();
        }
      } else {
        print('✅ Прерывание завершено: ${event.type}');
        // Восстанавливаем воспроизведение, только если оно было до прерывания
        if (_wasPlayingBeforeInterruption) {
          player.play();
        }
        // Сбросим флаг на всякий случай
        _wasPlayingBeforeInterruption = false;
      }
    });

    session.becomingNoisyEventStream.listen((_) {
      print('🔇 Наушники отключены — пауза');
      player.pause();
    });
  }


  String extractTitleFromPath(String path) {
    if (path.isEmpty) return '';

    try {
      // Оставляем исходную строку как есть (совместимость «как раньше»)
      String s = path;

      if (s.startsWith('content://')) {
        // Для SAF: раскодируем и вручную находим последний сегмент
        s = Uri.decodeFull(s);

        // Индексы возможных разделителей в SAF-URI
        final i1 = s.lastIndexOf('%2F'); // кодированный '/'
        final i2 = s.lastIndexOf('/');   // обычный '/'
        final i3 = s.lastIndexOf('\\');  // на всякий случай
        final i4 = s.lastIndexOf(':');   // в SAF часто бывает 'primary:Music:Track.mp3'

        // Берём максимально правый разделитель
        int idx = i1;
        if (i2 > idx) idx = i2;
        if (i3 > idx) idx = i3;
        if (i4 > idx) idx = i4;

        if (idx != -1) {
          // Если попали на '%2F', то пропускаем 3 символа, иначе 1
          final skip = (idx == i1) ? 3 : 1;
          s = s.substring(idx + skip);
        }
      } else {
        // Поведение как в твоей исходной версии
        final parts = s.split(RegExp(r'[\\/]'));
        s = parts.isNotEmpty ? parts.last : s;
      }

      // Обрезаем query/fragment, если вдруг есть
      final q = s.indexOf('?');
      if (q != -1) s = s.substring(0, q);
      final h = s.indexOf('#');
      if (h != -1) s = s.substring(0, h);

      // Убираем расширение (как у тебя было)
      final dot = s.lastIndexOf('.');
      if (dot > 0) s = s.substring(0, dot);

      return s;
    } catch (_) {
      // В случае любой ошибки возвращаем как есть (чтобы ничего не «падало»)
      return path;
    }
  }




  Future<void> updateCurrentTrackData(int index, String path, {BuildContext? context}) async {
    /*debugPrint('=== [TRACK] updateCurrentTrackData START ===');
    debugPrint('→ incoming index=$index');
    debugPrint('→ incoming path=$path');
    debugPrint('→ currentIndex=$currentIndex');
    debugPrint('→ originalTrackPath=$originalTrackPath');
    debugPrint('→ currentTrackPath=$currentTrackPath');*/

    // 🛡 Валидация входных данных
    if (index < 0) {
      //debugPrint('❌ [TRACK] Неверный индекс ($index) — отмена update');
      return;
    }
    if (path.isEmpty) {
      //debugPrint('❌ [TRACK] Путь пустой — отмена update');
      return;
    }

    // 🛑 Если это тот же трек — ничего не делаем
    /*if (currentIndex == index && originalTrackPath == path && currentTrackPath != null) {
      debugPrint('⏭ [TRACK] Same track & path detected — skipping update');
      return;
    }*/

    // 🔄 Обновляем состояние
    currentIndex = index;
    originalTrackPath = path;
    currentTrackPath = path;

    // 💾 Сохраняем в persistentState
    try {
      persistentState.currentIndex = index;
      persistentState.currentTrackPath = path;
      await persistentState.save();

      //debugPrint('💾 [PERSIST] Saved to persistentState: '
      //    'index=${persistentState.currentIndex}, '
      //    'path=${persistentState.currentTrackPath}');
    } catch (e, st) {
      debugPrint('⚠️ [PERSIST] Ошибка при сохранении состояния: $e\n$st');
    }

    //debugPrint('✅ [TRACK] State updated: index=$currentIndex');
    //debugPrint('   original=$originalTrackPath');
    //debugPrint('   current=$currentTrackPath');

    // 🎧 Обновляем mediaItem для уведомлений/шторки
    try {
      final duration = player.duration ?? Duration.zero;
      await (audioHandler as MyAudioHandler).setMediaItem(
        title: extractTitleFromPath(path),
        duration: duration,
      );
      //debugPrint('🎧 [MEDIA] MediaItem set: title="${extractTitleFromPath(path)}", duration=$duration');
    } catch (e, st) {
      //debugPrint('⚠️ [MEDIA] Ошибка при установке MediaItem: $e\n$st');
    }

    // 🔍 Анализ аудио (только при активной панели)
    if (showSilenceControlBar) {
     /*
      debugPrint('🔍 [ANALYZE] want=$showSilenceControlBar, '
          'isAnalyzing=${audio_to_levels.isAnalyzing}, '
          'currentAnalyzed=${audio_to_levels.currentAnalyzedOriginalPath}, '
          'originalPath=$path');

      */

      //debugPrint('🚀 [ANALYZE] starting FULL analysis for $path');
      unawaited(audio_to_levels.analyzeTrack(
        full: true, // только анализ, отслеживание PCM стартует ВНУТРИ analyzeTrack
      ));

      // audio_to_levels.startLevelTracking(); <-- ЭТО ЛИШНЕЕ, убери!
      // debugPrint('📊 [PCM] startLevelTracking() called');
    } else {
      //debugPrint('ℹ️ [ANALYZE] showSilenceControlBar=false — analysis not requested');
    }

    // --- Новый блок: реинициализация эквалайзера ---
    if (Platform.isAndroid) {
      await Future.delayed(const Duration(milliseconds: 80));
      final sessionId = player.androidAudioSessionId;
      if (sessionId != null) {
        await reapplyEqualizerFromPrefs(sessionId);
      }
    }



    notifyListeners();
    //debugPrint('🏁 [TRACK] updateCurrentTrackData END');
  }


  Future<void> reapplyEqualizerFromPrefs(int sessionId) async {
    final MethodChannel eqChannel = const MethodChannel('equalizer_channel');
    final prefs = await SharedPreferences.getInstance();

    final enabled = prefs.getBool('equalizer_enabled') ?? false;
    final preset = prefs.getString('equalizer_preset') ?? 'manual';

    await eqChannel.invokeMethod('initEqualizer', {'sessionId': sessionId});
    await eqChannel.invokeMethod('setEnabled', {'enabled': enabled});

    // Применить пресет
    await eqChannel.invokeMethod('setPreset', {'preset': preset});

    // Если manual — восстанавливаем значения полос
    if (preset == 'manual') {
      final bands = await eqChannel.invokeMethod('getBands');
      for (final band in (bands as List)) {
        final bandMap = Map<String, dynamic>.from(band);
        final idx = bandMap['band'];
        final level = prefs.getInt('eq_band_manual_$idx');
        if (level != null) {
          await eqChannel.invokeMethod('setBandLevel', {
            'band': idx,
            'level': level,
          });
        }
      }
    }
  }













  void updateCurrentTrack(int index, String path) {
    currentIndex = index;
    originalTrackPath = path;
    currentTrackPath = path;
    notifyListeners();
  }

  String? rootPath;
  String? currentPath;

  Future<bool> isValidSafUri(String? uri) async {
    if (uri == null || uri.isEmpty) {
      print('[SAF][isValidSafUri] URI пустой');
      return false;
    }
    if (!uri.startsWith('content://')) {
      print('[SAF][isValidSafUri] Обычный путь (не SAF): $uri');
      return true; // обычный путь считаем валидным
    }

    try {
      final hasPermission = await SAF.checkUriPermission(uri);
      print('[SAF][isValidSafUri] checkUriPermission($uri): $hasPermission');
      if (!hasPermission) {
        print('[SAF][isValidSafUri] Нет разрешения на доступ к URI!');
        return false;
      }
      final exists = await SAF.fileExists(uri);
      print('[SAF][isValidSafUri] fileExists($uri): $exists');
      if (!exists) {
        print('[SAF][isValidSafUri] Файл/папка по URI не существует!');
        return false;
      }
      return true;
    } catch (e, st) {
      print('[SAF][isValidSafUri] Exception: $e\n$st');
      return false;
    }
  }


  Future<void> initialize() async {
    if (_initialized) return;

    print('\n============================');
    print('[APP INIT] 🔄 Инициализация приложения...');
    print('============================');

    // 1️⃣ Загружаем состояние
    persistentState = await AppPersistentState.load();
    print('[APP INIT] ✅ persistentState загружен');

    // 2️⃣ Восстанавливаем rootPath/currentPath из prefs
    final prefs = await SharedPreferences.getInstance();
    rootPath = prefs.getString('last_folder_playlist_root');
    currentPath = prefs.getString('last_folder_playlist_current') ?? rootPath;

    // Если prefs пусты — пробуем из persistentState
    if ((rootPath == null || rootPath!.isEmpty) &&
        persistentState.lastUsedFolderPath != null &&
        persistentState.lastUsedFolderPath!.isNotEmpty) {
      rootPath = persistentState.lastUsedFolderPath;
      currentPath = rootPath;
      print('[APP INIT] ⚠️ Восстанавливаем путь из persistentState: $rootPath');
    }

    // 2.1️⃣ Проверяем валидность rootPath
    if (!await isValidSafUri(rootPath)) {
      print('[APP INIT] ❌ rootPath невалиден или нет доступа! Обнуляем...');
      rootPath = null;
      currentPath = null;
      await prefs.remove('last_folder_playlist_root');
      await prefs.remove('last_folder_playlist_current');
    }

    print('[APP INIT] 📂 rootPath: $rootPath');
    print('[APP INIT] 📂 currentPath: $currentPath');

    // 3️⃣ Кэш длительностей, секции и слоты
    try {
      await initDurationsCache();
    } catch (e, st) {
      print('[APP INIT] ⚠️ Ошибка при initDurationsCache: $e\n$st');
    }
    try {
      await loadOrInitSectionSlots();
    } catch (e, st) {
      print('[APP INIT] ⚠️ Ошибка при loadOrInitSectionSlots: $e\n$st');
    }

    // 4️⃣ Загружаем плейлисты
    try {
      await playlist.loadManualPlaylist();
    } catch (e, st) {
      print('[APP INIT] ⚠️ Ошибка при loadManualPlaylist: $e\n$st');
    }
    try {
      await playlist.loadFolderPlaylist();
    } catch (e, st) {
      print('[APP INIT] ⚠️ Ошибка при loadFolderPlaylist: $e\n$st');
    }

    restoreFromPersistentState();
    print('[APP INIT] 🔁 Данные восстановлены из persistentState:');
    print('  currentPlaylistSource: $currentPlaylistSource');
    print('  currentTrackPath: ${persistentState.currentTrackPath}');
    print('  lastUsedFolderPath: ${persistentState.lastUsedFolderPath}');

    // 5️⃣ Восстанавливаем кэш папки если надо
    try {
      await _restoreFolderCacheIfNeeded();
    } catch (e, st) {
      print('[APP INIT] ⚠️ Ошибка при _restoreFolderCacheIfNeeded: $e\n$st');
    }

    // 6️⃣ Выбираем активный плейлист
    try {
      await _initializeActivePlaylist();
    } catch (e, st) {
      print('[APP INIT] ⚠️ Ошибка при _initializeActivePlaylist: $e\n$st');
    }

    // 7️⃣ Тема
    try {
      await loadThemeColors();
      print('[APP INIT] 🎨 Цветовая тема загружена');
    } catch (e, st) {
      print('[APP INIT] ⚠️ Ошибка при loadThemeColors: $e\n$st');
    }

    _initialized = true;
    print('[APP INIT] ✅ Инициализация завершена');
    print('============================\n');
  }




// =========================================================
// 🔧 Подметоды инициализации
// =========================================================



  Future<void> _restoreFolderCacheIfNeeded() async {
    if (folderPlaylist.isNotEmpty ||
        persistentState.lastUsedFolderPath == null ||
        persistentState.lastUsedFolderPath!.isEmpty) {
      print('[APP INIT] ℹ️ Пропуск восстановления кэша — папка уже загружена или путь пуст');
      return;
    }

    final lastUri = persistentState.lastUsedFolderPath!;
    print('[APP INIT] 🗂 Попытка восстановления папочного плейлиста из Hive для: $lastUri');

    try {
      final box = await Hive.openBox('folderCache');
      final cached = box.get(lastUri);

      if (cached == null || cached['entries'] == null) {
        print('[APP INIT] ⚠️ Кэш папки отсутствует для $lastUri');
        return;
      }

      final entries = (cached['entries'] as List)
          .map((e) => e['uri'] as String)
          .where((p) {
        final name = (p.split('/').last).toLowerCase();
        return name.endsWith('.mp3') ||
            name.endsWith('.m4a') ||
            name.endsWith('.wav') ||
            name.endsWith('.flac') ||
            name.endsWith('.aac') ||
            name.endsWith('.ogg') ||
            name.endsWith('.wma');
      })
          .toList();

      if (entries.isEmpty) {
        print('[APP INIT] ⚠️ В кэше нет аудиофайлов');
        return;
      }

      setFolderPlaylist(entries);
      folderPlaylist = entries;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_folder_playlist_root', lastUri);
      await prefs.setString('last_folder_playlist_current', lastUri);
      print('[APP INIT] ✅ Восстановлено ${entries.length} треков из кэша Hive');
    } catch (e, st) {
      print('[APP INIT] ❌ Ошибка при чтении кэша Hive: $e\n$st');
    }
  }

  Future<void> _initializeActivePlaylist() async {
    if (currentPlaylistSource == PlaylistSource.folder) {
      print('[APP INIT] ▶️ Активный источник: FOLDER');
      await _setupPlaylist(folderPlaylist, PlaylistSource.folder);
    } else {
      print('[APP INIT] ▶️ Активный источник: MANUAL');
      await _setupPlaylist(manualPlaylist, PlaylistSource.manual);
    }
  }

  Future<void> _setupPlaylist(List<String> list, PlaylistSource source) async {
    if (list.isEmpty) {
      print('[APP INIT] ⚠️ ${source.name} плейлист пуст — initializePlayer() не вызывается');
      return;
    }

    final ix = list.indexOf(persistentState.currentTrackPath);
    final restoredIndex = (ix != -1) ? ix : 0;

    currentIndex = restoredIndex;
    currentTrackPath = list[restoredIndex];

    persistentState
      ..currentIndex = restoredIndex
      ..currentTrackPath = currentTrackPath ?? ''
      ..playlistSource = source.name;
    await persistentState.save();

    print('[APP INIT] ${source.name}: восстановлен индекс $currentIndex, путь: $currentTrackPath');

    await initializePlayer();
    await updateCurrentTrackData(restoredIndex, currentTrackPath!);
    await audio_to_levels.analyzeTrack(full: true, force: true);
  }








  void reorderWidgetsFrom(List<DisplayWidgetConfig> widgets) {
    widgetOrderIds = widgets.map((w) => w.id).toList();
    notifyListeners();
  }


// В AppModel:
  int navIconThemeEpoch = 0;

  void bumpNavIconThemeEpoch() {
    navIconThemeEpoch++;
    debugPrint('🟠 bumpNavIconThemeEpoch: $navIconThemeEpoch');
    notifyListeners();
  }


  AppThemeColors get themeColors => _themeColors;

  Future<void> loadThemeColors({bool silent = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('selectedThemeKey') ?? 'dark';
    final saved = await loadSavedThemeColors(key);
    _savedThemeColors = saved;
    _themeColors = saved;

    // ✅ Предзагрузка фонового изображения
    if (_themeColors.useBackgroundImage && _themeColors.backgroundImagePath != null) {
      final file = File(_themeColors.backgroundImagePath!);
      if (await file.exists()) {
        final context = WidgetsBinding.instance.renderViewElement;
        if (context != null) {
          await precacheImage(FileImage(file), context);
        }
      }
    }

    if (!silent) {
      notifyListeners();
    }
  }



  void updateThemeColorsPartial(AppThemeColors Function(AppThemeColors) updater) {
    _undoStack.add(_themeColors);
    _redoStack.clear();

    _themeColors = updater(_themeColors);

    // <<< Добавь вызов обновления системных панелей здесь >>>
    updateSystemUi(_themeColors);

    notifyListeners();

    try {
      WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    } catch (_) {}
  }






  Future<void> saveCurrentTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('selectedThemeKey');
    if (key != null) {
      await saveThemeColors(key, _themeColors); // 🟢 сохраняем текущие
      _savedThemeColors = _themeColors;         // 🟢 обновляем "сохранённое"
      print('[SAVE] Тема "$key" сохранена');
    }
  }

  String _selectedThemeKey = 'Dark';


  String get selectedThemeKey => _selectedThemeKey;


  Future<String?> get getSelectedThemeKeyFromPrefs async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedThemeKey');
  }


  /// Откатывает изменения (если пользователь не нажал "Сохранить")
  void revertToSavedThemeColors() {
    _themeColors = _savedThemeColors;
    notifyListeners();
    print('[REVERT] Откат к сохранённой теме');
  }

  void openSettings(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/settings',
      ModalRoute.withName('/home'),
    );
  }


  void saveThemedColor(
    SharedPreferences prefs,
    String key,
    ThemedColor color,
  ) {
    prefs.setInt('$key.color', color.color.value);
    prefs.setBool('$key.shadowEnabled', color.shadowEnabled);
    prefs.setInt('$key.shadowColor', color.shadowColor.value);
    prefs.setDouble('$key.shadowBlur', color.shadowBlur);
  }

  ThemedColor loadThemedColor(
    SharedPreferences prefs,
    String key,
    ThemedColor fallback,
  ) {
    return ThemedColor(
      color: Color(prefs.getInt('$key.color') ?? fallback.color.value),
      shadowEnabled:
          prefs.getBool('$key.shadowEnabled') ?? fallback.shadowEnabled,
      shadowColor:
          Color(prefs.getInt('$key.shadowColor') ?? fallback.shadowColor.value),
      shadowBlur: prefs.getDouble('$key.shadowBlur') ?? fallback.shadowBlur,
    );
  }

  bool get backgroundImageEnabled => _backgroundImageEnabled;

  set backgroundImageEnabled(bool value) {
    if (_backgroundImageEnabled != value) {
      _backgroundImageEnabled = value;
      _saveBool('backgroundImageEnabled', value);
      notifyListeners();
    }
  }

  bool _backgroundImageFillScreen = true;

  bool get backgroundImageFillScreen => _backgroundImageFillScreen;

  set backgroundImageFillScreen(bool value) {
    if (_backgroundImageFillScreen != value) {
      _backgroundImageFillScreen = value;
      _saveBool('backgroundImageFillScreen', value);
      notifyListeners();
    }
  }

  bool _backgroundImageRepeat = false;

  bool get backgroundImageRepeat => _backgroundImageRepeat;

  set backgroundImageRepeat(bool value) {
    if (_backgroundImageRepeat != value) {
      _backgroundImageRepeat = value;
      _saveBool('backgroundImageRepeat', value);
      notifyListeners();
    }
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> loadBackgroundImageSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _backgroundImagePath = prefs.getString('backgroundImagePath');
    _backgroundImageOpacity = prefs.getDouble('backgroundImageOpacity') ?? 1.0;
    _backgroundImageEnabled = prefs.getBool('backgroundImageEnabled') ?? true;
    _backgroundImageFillScreen =
        prefs.getBool('backgroundImageFillScreen') ?? true;
    _backgroundImageRepeat = prefs.getBool('backgroundImageRepeat') ?? false;

    notifyListeners(); // 🔥 Обязательно, чтобы UI обновился
  }

  String? get backgroundImagePath => _backgroundImagePath;

  double get backgroundImageOpacity => _backgroundImageOpacity;

  set backgroundImagePath(String? path) {
    _backgroundImagePath = path;
    notifyListeners();
    _saveBackgroundImagePath();
  }

  set backgroundImageOpacity(double value) {
    _backgroundImageOpacity = value;
    notifyListeners();
    _saveBackgroundImageOpacity();
  }

  Future<void> _saveBackgroundImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    if (_backgroundImagePath != null) {
      await prefs.setString('backgroundImagePath', _backgroundImagePath!);
    } else {
      await prefs.remove('backgroundImagePath');
    }
  }

  Future<void> _saveBackgroundImageOpacity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('backgroundImageOpacity', _backgroundImageOpacity);
  }

  Future<void> saveThemeColors(String themeName, AppThemeColors colors) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('$themeName.transitionType', colors.transitionType.name);

    // ✅ Сохраняем параметры фонового изображения
    prefs.setString('$themeName.backgroundImagePath', colors.backgroundImagePath ?? '');
    prefs.setString('$themeName.backgroundImageDisplayName', colors.backgroundImageDisplayName ?? ''); // 👈 новое
    prefs.setBool('$themeName.useBackgroundImage', colors.useBackgroundImage);
    prefs.setBool('$themeName.backgroundFitFill', colors.backgroundFitFill);
    prefs.setBool('$themeName.backgroundFitCover', colors.backgroundFitCover);
    prefs.setDouble('$themeName.backgroundImageOpacity', colors.backgroundImageOpacity ?? 1.0);

    // ✅ Новое: сохраняем яркость и контраст
    prefs.setDouble('$themeName.backgroundImageBrightness', colors.backgroundImageBrightness ?? 1.0);
    prefs.setDouble('$themeName.backgroundImageContrast', colors.backgroundImageContrast ?? 1.0);

    void save(String key, ThemedColor color) {
      prefs.setInt('$themeName.$key.color', color.color.value);
      prefs.setBool('$themeName.$key.shadowEnabled', color.shadowEnabled);
      prefs.setInt('$themeName.$key.shadowColor', color.shadowColor.value);
      prefs.setDouble('$themeName.$key.shadowBlur', color.shadowBlur);
    }

    save('navIconActive', colors.navIconActive);
    save('navIconInactive', colors.navIconInactive);
    save('displayIconActive', colors.displayIconActive);
    save('displayIconInactive', colors.displayIconInactive);
    save('controlElements', colors.controlElements);
    save('widgetIconText', colors.widgetIconText);
    save('buttonIconText', colors.buttonIconText);
    save('currentValueText', colors.currentValueText);
    save('sliderActiveSegment', colors.sliderActiveSegment);
    save('sliderInactiveSegment', colors.sliderInactiveSegment);
    save('playlistDeleteButton', colors.playlistDeleteButton);
    save('gradientDividerShadow', colors.gradientDividerShadow);
    save('topBarUpperShadow', colors.topBarUpperShadow);
    save('jogBackgroundShadow', colors.jogBackgroundShadow);

    prefs.setInt('$themeName.gradientDividerStart', colors.gradientDividerStart.value);
    prefs.setInt('$themeName.gradientDividerEnd', colors.gradientDividerEnd.value);
    prefs.setInt('$themeName.topBarUpperStart', colors.topBarUpperStart.value);
    prefs.setInt('$themeName.topBarUpperEnd', colors.topBarUpperEnd.value);
    prefs.setInt('$themeName.backgroundStart', colors.backgroundStart.value);
    prefs.setInt('$themeName.backgroundEnd', colors.backgroundEnd.value);
    prefs.setInt('$themeName.jogBackgroundStart', colors.jogBackgroundStart.value);
    prefs.setInt('$themeName.jogBackgroundEnd', colors.jogBackgroundEnd.value);
  }



  Future<AppThemeColors> loadSavedThemeColors(String themeName) async {
    _selectedThemeKey = themeName;
    final prefs = await SharedPreferences.getInstance();
    final base = presetThemesRaw[themeName] ?? AppThemeColors.standard();

    final transitionTypeStr = prefs.getString('$themeName.transitionType');
    final transitionType = transitionTypeStr != null
        ? AppTransitionType.values.firstWhere(
          (e) => e.name == transitionTypeStr,
      orElse: () => base.transitionType,
    )
        : base.transitionType;

    // ✅ используем fallback из base
    final imagePath =
        prefs.getString('$themeName.backgroundImagePath') ?? base.backgroundImagePath;

    /// 👇 новое: отображаемый путь
    final displayName =
        prefs.getString('$themeName.backgroundImageDisplayName') ??
            base.backgroundImageDisplayName;

    final useImage =
        prefs.getBool('$themeName.useBackgroundImage') ?? base.useBackgroundImage;
    final fill =
        prefs.getBool('$themeName.backgroundFitFill') ?? base.backgroundFitFill;
    final cover =
        prefs.getBool('$themeName.backgroundFitCover') ?? base.backgroundFitCover;
    final backgroundImageOpacity = prefs.getDouble('$themeName.backgroundImageOpacity') ??
        base.backgroundImageOpacity ??
        1.0;

    // ✅ новое: загружаем яркость и контраст
    final brightness = prefs.getDouble('$themeName.backgroundImageBrightness') ??
        base.backgroundImageBrightness ??
        1.0;
    final contrast = prefs.getDouble('$themeName.backgroundImageContrast') ??
        base.backgroundImageContrast ??
        1.0;

    Color? getColor(String key) {
      final value = prefs.getInt('$themeName.$key');
      return value != null ? Color(value) : null;
    }

    bool getBool(String key, bool fallback) =>
        prefs.getBool('$themeName.$key') ?? fallback;
    double getDouble(String key, double fallback) =>
        prefs.getDouble('$themeName.$key') ?? fallback;

    ThemedColor themed(String key, ThemedColor fallback) => ThemedColor(
      color: getColor('$key.color') ?? fallback.color,
      shadowEnabled: getBool('$key.shadowEnabled', fallback.shadowEnabled),
      shadowColor: getColor('$key.shadowColor') ?? fallback.shadowColor,
      shadowBlur: getDouble('$key.shadowBlur', fallback.shadowBlur),
    );

    return AppThemeColors(
      transitionType: transitionType,
      backgroundImagePath: imagePath,
      backgroundImageDisplayName: displayName, // 👈 добавлено
      useBackgroundImage: useImage,
      backgroundFitFill: fill,
      backgroundFitCover: cover,
      backgroundImageOpacity: backgroundImageOpacity,
      backgroundImageBrightness: brightness, // ✅ применяем
      backgroundImageContrast: contrast, // ✅ применяем

      navIconActive: themed('navIconActive', base.navIconActive),
      navIconInactive: themed('navIconInactive', base.navIconInactive),
      displayIconActive: themed('displayIconActive', base.displayIconActive),
      displayIconInactive: themed('displayIconInactive', base.displayIconInactive),
      controlElements: themed('controlElements', base.controlElements),
      widgetIconText: themed('widgetIconText', base.widgetIconText),
      buttonIconText: themed('buttonIconText', base.buttonIconText),
      currentValueText: themed('currentValueText', base.currentValueText),
      sliderActiveSegment: themed('sliderActiveSegment', base.sliderActiveSegment),
      sliderInactiveSegment: themed('sliderInactiveSegment', base.sliderInactiveSegment),
      playlistDeleteButton: themed('playlistDeleteButton', base.playlistDeleteButton),
      gradientDividerShadow: themed('gradientDividerShadow', base.gradientDividerShadow),
      topBarUpperShadow: themed('topBarUpperShadow', base.topBarUpperShadow),
      jogBackgroundShadow: themed('jogBackgroundShadow', base.jogBackgroundShadow),

      gradientDividerStart:
      getColor('gradientDividerStart') ?? base.gradientDividerStart,
      gradientDividerEnd:
      getColor('gradientDividerEnd') ?? base.gradientDividerEnd,
      topBarUpperStart: getColor('topBarUpperStart') ?? base.topBarUpperStart,
      topBarUpperEnd: getColor('topBarUpperEnd') ?? base.topBarUpperEnd,
      backgroundStart: getColor('backgroundStart') ?? base.backgroundStart,
      backgroundEnd: getColor('backgroundEnd') ?? base.backgroundEnd,
      jogBackgroundStart:
      getColor('jogBackgroundStart') ?? base.jogBackgroundStart,
      jogBackgroundEnd: getColor('jogBackgroundEnd') ?? base.jogBackgroundEnd,
    );
  }



  Future<void> saveTheme(String name, AppThemeColors colors) async {
    await saveThemeColors(name, colors);
    await saveSelectedThemeKey(name);
  }

  Future<void> resetTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();

    // Удаляем все сохранённые кастомные цвета для выбранной темы
    for (final key in AppThemeColors.colorKeys) {
      await prefs.remove('$themeName.$key.color');
      await prefs.remove('$themeName.$key.shadowEnabled');
      await prefs.remove('$themeName.$key.shadowColor');
      await prefs.remove('$themeName.$key.shadowBlur');
    }

    await prefs.remove('$themeName.transitionType');

    // Удаляем дополнительные ключи
    final colorKeys = [
      'gradientDividerStart',
      'gradientDividerEnd',
      'topBarUpperStart',
      'topBarUpperEnd',
      'backgroundStart',
      'backgroundEnd',
      'jogBackgroundStart',
      'jogBackgroundEnd',
    ];
    for (final key in colorKeys) {
      await prefs.remove('$themeName.$key');
    }

    // 🧹 Удаляем параметры фонового изображения
    await prefs.remove('$themeName.backgroundImagePath');
    await prefs.remove('$themeName.backgroundImageDisplayName'); // 👈 добавлено
    await prefs.remove('$themeName.useBackgroundImage');
    await prefs.remove('$themeName.backgroundFitFill');
    await prefs.remove('$themeName.backgroundFitCover');
    await prefs.remove('$themeName.backgroundImageOpacity');

    // 🧹 Удаляем параметры яркости и контраста
    await prefs.remove('$themeName.backgroundImageBrightness');
    await prefs.remove('$themeName.backgroundImageContrast');

    // Загружаем заводскую тему из пресета
    final defaultColors = presetThemesRaw[themeName];

    if (defaultColors != null) {
      print('[RESET] defaultColors.useBackgroundImage = ${defaultColors.useBackgroundImage}');
      print('[RESET] defaultColors.backgroundFitFill = ${defaultColors.backgroundFitFill}');
      print('[RESET] defaultColors.backgroundFitCover = ${defaultColors.backgroundFitCover}');
      print('[RESET] defaultColors.backgroundImageDisplayName = ${defaultColors.backgroundImageDisplayName}');

      // Устанавливаем тему в память
      _themeColors = defaultColors;

      // Сохраняем как "сохранённую"
      _savedThemeColors = defaultColors;

      // ✅ Применяем фоновые настройки, влияющие на чекбоксы
      applyBackgroundImageSettingsFromTheme(defaultColors);

      // Сохраняем в SharedPreferences как текущую
      await saveThemeColors(themeName, defaultColors);

      // Уведомляем UI
      notifyListeners();

      print('[RESET] Тема "$themeName" сброшена и сохранена');
    } else {
      print('[RESET] Пресет "$themeName" не найден');
    }
  }

  Future<void> saveSelectedThemeKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedThemeKey', key);
  }

  TimeDisplayStyle timeDisplayStyle = TimeDisplayStyle.mmss;

  void setTimeDisplayStyle(TimeDisplayStyle style) {
    timeDisplayStyle = style;
    persistentState.timeDisplayStyle = style.name;
    persistentState.save();
    notifyListeners();
  }

  SecondaryTimeType secondaryTimeType = SecondaryTimeType.remaining;

  void setSecondaryTimeType(SecondaryTimeType value) {
    secondaryTimeType = value;
    persistentState.secondaryTimeType = value.name; // ← вот эта строка!
    persistentState.save();
    notifyListeners();
  }

  int jogResolutionSecondsPerRevolution = 5; // Значение по умолчанию

  void setJogResolution(int seconds) {
    jogResolutionSecondsPerRevolution = seconds;
    persistentState.jogResolutionSecondsPerRevolution = seconds;
    persistentState.save();
    notifyListeners();
  }

  PlaybackButtonStyle playbackButtonStyle = PlaybackButtonStyle.precise;

  void setPlaybackButtonStyle(PlaybackButtonStyle style) {
    playbackButtonStyle = style;
    persistentState.playbackButtonStyle = style.name;
    persistentState.save();
    notifyListeners();
  }

  int minJogSkipSpeedMsPerSec = 200; // 0.2 сек/сек
  int maxJogSkipSpeedMsPerSec = 5000; // 5 сек/сек

  void setMinJogSkipSpeed(int value) {
    minJogSkipSpeedMsPerSec = value;

    // Автокоррекция при нарушении диапазона
    if (minJogSkipSpeedMsPerSec > maxJogSkipSpeedMsPerSec) {
      maxJogSkipSpeedMsPerSec = minJogSkipSpeedMsPerSec;
    }
    persistentState.minJogSkipSpeedMsPerSec = value;
    persistentState.save();
    notifyListeners();
  }

  void setMaxJogSkipSpeed(int value) {
    maxJogSkipSpeedMsPerSec = value;

    if (maxJogSkipSpeedMsPerSec < minJogSkipSpeedMsPerSec) {
      minJogSkipSpeedMsPerSec = maxJogSkipSpeedMsPerSec;
    }
    persistentState.maxJogSkipSpeedMsPerSec = value;
    persistentState.save();
    notifyListeners();
  }

  double minSpeed = 0.5;
  double maxSpeed = 2.0;

  void setMinSpeed(double value) {
    minSpeed = value;

    // если текущая скорость ниже нового минимума — корректируем
    if (playbackSpeed < minSpeed) {
      changeSpeed(minSpeed);
    }
    persistentState.minSpeed = value;
    persistentState.save();
    notifyListeners();
  }

  void setMaxSpeed(double value) {
    maxSpeed = value;

    // если текущая скорость выше нового максимума — корректируем
    if (playbackSpeed > maxSpeed) {
      changeSpeed(maxSpeed);
    }
    persistentState.maxSpeed = value;
    persistentState.save();
    notifyListeners();
  }

  void changeSpeed(double newSpeed) {
    playbackSpeed = newSpeed.clamp(minSpeed, maxSpeed);
    player.setSpeed(playbackSpeed);
    notifyListeners();
  }

// Метод изменения порядка
  void reorderWidgets(int oldIndex, int newIndex) {
    final item = widgetOrderIds.removeAt(oldIndex);
    widgetOrderIds.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
    notifyListeners();
  }

  // Переменные видимости для управления отображением виджетов на главном экране

  bool _showSilenceControlBar = true;

  bool get showSilenceControlBar => _showSilenceControlBar;

  void setShowSilenceControlBar(bool value, BuildContext context) {
    if (_showSilenceControlBar != value) {
      _showSilenceControlBar = value;
      persistentState.showSilenceControlBar = value;
      persistentState.save();
      notifyListeners();
    }
  }





  bool _showPlaybackButtons = true;

  bool get showPlaybackButtons => _showPlaybackButtons;

  set showPlaybackButtons(bool value) {
    if (_showPlaybackButtons != value) {
      _showPlaybackButtons = value;
      persistentState.showPlaybackButtons = value;
      persistentState.save();
      notifyListeners();
    }
  }

  bool _showJogAndSeekButtons = true;

  bool get showJogAndSeekButtons => _showJogAndSeekButtons;

  set showJogAndSeekButtons(bool value) {
    if (_showJogAndSeekButtons != value) {
      _showJogAndSeekButtons = value;
      persistentState.showJogAndSeekButtons = value;
      persistentState.save();
      notifyListeners();
    }
  }

  bool _showSpeedSlider = true;

  bool get showSpeedSlider => _showSpeedSlider;

  set showSpeedSlider(bool value) {
    if (_showSpeedSlider != value) {
      _showSpeedSlider = value;
      persistentState.showSpeedSlider = value;
      persistentState.save();
      notifyListeners();
    }
  }

  void updateSegmentPlaybackMode(PlaybackMode mode) {
    setPlaybackMode(mode);           // Сохраняет playbackMode (с вызовом save)
    lastSegmentPlaybackMode = mode;  // Сохраняет lastSegmentPlaybackMode (с вызовом save)
    // notifyListeners не нужен — оба сеттера уже вызывают его
  }


  void toggleShowMarkers() {
    showMarkers = !showMarkers;
    if (!showMarkers && playBetweenMarkers) {
      playBetweenMarkers = false;
    }
    // notifyListeners(); // Не надо — уже вызвано в сеттере
  }


  // --- Playback mode ---
  late PlaybackMode _playbackMode;

  PlaybackMode get playbackMode => _playbackMode;

  void setPlaybackMode(PlaybackMode mode) {
    if (_playbackMode == mode) return; // Если режим не меняется — выходим

    _playbackMode = mode;
    persistentState.playbackMode = mode.name;
    persistentState.save();
    notifyListeners();
  }



// Метод: показать/скрыть маркеры
  void toggleMarkers() {
    showMarkers = !showMarkers;

    notifyListeners();
  }


// Метод: переключить режим воспроизведения
  void cyclePlaybackMode() {
    final next = PlaybackMode
        .values[(_playbackMode.index + 1) % PlaybackMode.values.length];
    setPlaybackMode(next); // тут save уже будет вызван в setPlaybackMode
  }

/*
  int? _currentIndex; // Было: int _currentIndex = 0;
  int? get currentIndex => _currentIndex;
  set currentIndex(int? value) {
    if (value != _currentIndex) {
      print('[DEBUG] currentIndex меняется с $_currentIndex на $value');
      _currentIndex = value;
      notifyListeners();
    }
  }*/

  final ValueNotifier<int?> currentIndexVN = ValueNotifier(null);

  int? get currentIndex => currentIndexVN.value;
  set currentIndex(int? value) {
    if (currentIndexVN.value != value) {
      currentIndexVN.value = value;
      notifyListeners();
    }
  }




  List<int> _shuffleOrder = [];

  List<int> get shuffleOrder => _shuffleOrder;

  set shuffleOrder(List<int> value) {
    if (value != _shuffleOrder) {
      _shuffleOrder = value;
      notifyListeners();
    }
  }

  int _shufflePointer = 0;

  int get shufflePointer => _shufflePointer;

  set shufflePointer(int value) {
    if (value != _shufflePointer) {
      _shufflePointer = value;
      notifyListeners();
    }
  }

  List<String> _manualPlaylist = [];

  List<String> get manualPlaylist => _manualPlaylist;
  List<String> get tracks => _manualPlaylist;

  set manualPlaylist(List<String> value) {
    if (value != _manualPlaylist) {
      _manualPlaylist = value;
      notifyListeners();
    }
  }

  String? _currentTrackPath;

  String? get currentTrackPath => _currentTrackPath;

  set currentTrackPath(String? value) {
    if (_currentTrackPath != value) {
      _currentTrackPath = value;
      notifyListeners();
      // Всё. Здесь больше ничего!
    }
  }



  String? _originalTrackPath;

  String? get originalTrackPath => _originalTrackPath;

  set originalTrackPath(String? value) {
    if (value != _originalTrackPath) {
      _originalTrackPath = value;
      notifyListeners();
    }
  }

  bool _showMarkers = false;

  bool get showMarkers => _showMarkers;

  set showMarkers(bool value) {
    if (value != _showMarkers) {
      _showMarkers = value;
      persistentState.showMarkers = value;
      persistentState.save();
      notifyListeners();
    }
  }

  bool _playBetweenMarkers = false;

  bool get playBetweenMarkers => _playBetweenMarkers;

  set playBetweenMarkers(bool value) {
    if (value != _playBetweenMarkers) {
      if (value) {
        final d = duration;
        final left = markerA < markerB ? markerA : markerB;
        final right = markerA > markerB ? markerA : markerB;
        final valid = markerA != markerB &&
            left >= Duration.zero &&
            right <= d &&
            left < right;

        if (!valid) {
          print('[DEBUG][playBetweenMarkers] Не включаем: невалидные маркеры.');
          return;
        }

        // Сменить режим только при валидных маркерах:
        // playbackMode = ... (восстановить последний режим для маркеров)
        // или оставить здесь свой код переключения
      }

      _playBetweenMarkers = value;
      persistentState.playBetweenMarkers = value;
      persistentState.save();

      if (_playBetweenMarkers) {
        final left = markerA < markerB ? markerA : markerB;
        final right = markerA > markerB ? markerA : markerB;
        final pos = player.position;
        if (pos < left) {
          player.seek(left);
        } else if (pos > right) {
          player.seek(right);
        }
      }

      notifyListeners();
    }
  }



  Timer? _pcmTimer;

  Timer? get pcmTimer => _pcmTimer;

  set pcmTimer(Timer? value) {
    if (value != _pcmTimer) {
      _pcmTimer = value;
      notifyListeners();
    }
  }

  StreamSubscription<Duration>? _positionSub;

  StreamSubscription<Duration>? get positionSub => _positionSub;

  set positionSub(StreamSubscription<Duration>? sub) {
    _positionSub = sub;
  }

  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<int?>? _indexSub;

  bool _isDraggingKnob = false;

  bool get isDraggingKnob => _isDraggingKnob;

  set isDraggingKnob(bool value) {
    _isDraggingKnob = value;
  }

  Duration _previewPosition = Duration.zero;

  Duration get previewPosition => _previewPosition;

  set previewPosition(Duration value) {
    _previewPosition = value;
    notifyListeners();
  }

  bool _manualSeek = false;

  bool get manualSeek => _manualSeek;

  set manualSeek(bool value) {
    _manualSeek = value;
  }

  bool _isSeeking = false;

  bool get isSeeking => _isSeeking;

  set isSeeking(bool value) {
    _isSeeking = value;
  }

  bool _skipNextSeek = false;

  bool get skipNextSeek => _skipNextSeek;

  set skipNextSeek(bool value) {
    _skipNextSeek = value;
  }

  bool _isSeekingManually = false;

  bool get isSeekingManually => _isSeekingManually;

  set isSeekingManually(bool value) {
    _isSeekingManually = value;
  }

  Duration _markerA = Duration.zero;

  Duration get markerA => _markerA;

  set markerA(Duration value) {
    print('setter markerA: $value');
    _markerA = value;
    persistentState.markerA = value.inMilliseconds;
    persistentState.save();
    notifyListeners();
  }

  Duration _markerB = Duration.zero;

  Duration get markerB => _markerB;

  set markerB(Duration value) {
    _markerB = value;
    persistentState.markerB = value.inMilliseconds;
    persistentState.save();
    notifyListeners();
  }



  Duration _duration = Duration.zero;

  Duration get duration => _duration;

  set duration(Duration value) {
    _duration = value;
    notifyListeners();
  }

  bool _wasPlayingBeforeSeek = false;

  bool get wasPlayingBeforeSeek => _wasPlayingBeforeSeek;

  set wasPlayingBeforeSeek(bool value) {
    _wasPlayingBeforeSeek = value;
  }

  double _playbackSpeed = 1.0;

  double get playbackSpeed => _playbackSpeed;

  set playbackSpeed(double value) {
    _playbackSpeed = value;
    notifyListeners();
  }

  Timer? _rewindTimer;

  Timer? get rewindTimer => _rewindTimer;

  set rewindTimer(Timer? value) {
    _rewindTimer = value;
  }

  Timer? _forwardTimer;

  Timer? get forwardTimer => _forwardTimer;

  set forwardTimer(Timer? value) {
    _forwardTimer = value;
  }

  double _rewindSpeed = 1.0;

  double get rewindSpeed => _rewindSpeed;

  set rewindSpeed(double value) {
    _rewindSpeed = value;
  }

  double _forwardSpeed = 1.0;

  double get forwardSpeed => _forwardSpeed;

  set forwardSpeed(double value) {
    _forwardSpeed = value;
  }

  double _rewindZoneWidth = 120;

  double get rewindZoneWidth => _rewindZoneWidth;

  set rewindZoneWidth(double value) {
    _rewindZoneWidth = value;
  }

  Timer? _zoneTimer;

  Timer? get zoneTimer => _zoneTimer;

  set zoneTimer(Timer? value) {
    _zoneTimer = value;
  }

  bool _wasPlayingBeforeKnob = false;

  bool get wasPlayingBeforeKnob => _wasPlayingBeforeKnob;

  set wasPlayingBeforeKnob(bool value) {
    _wasPlayingBeforeKnob = value;
  }

  bool _suppressAutoRestart = false;

  bool get suppressAutoRestart => _suppressAutoRestart;

  set suppressAutoRestart(bool value) {
    _suppressAutoRestart = value;
  }


  PlaybackMode? _previousPlaybackMode;

  PlaybackMode? get previousPlaybackMode => _previousPlaybackMode;

  set previousPlaybackMode(PlaybackMode? value) {
    _previousPlaybackMode = value;
  }

  PlaybackMode _lastSegmentPlaybackMode = PlaybackMode.singleOnce;

  PlaybackMode get lastSegmentPlaybackMode => _lastSegmentPlaybackMode;

  set lastSegmentPlaybackMode(PlaybackMode value) {
    if (_lastSegmentPlaybackMode != value) {
      _lastSegmentPlaybackMode = value;
      persistentState.lastSegmentPlaybackMode = value.name;
      persistentState.save();
      notifyListeners();
    }
  }


  Offset _latestSeekTouch = Offset.zero;

  Offset get latestSeekTouch => _latestSeekTouch;

  set latestSeekTouch(Offset value) {
    _latestSeekTouch = value;
  }

  double _latestSeekHeight = 0.0;

  double get latestSeekHeight => _latestSeekHeight;

  set latestSeekHeight(double value) {
    _latestSeekHeight = value;
  }

  double _silenceThresholdDb = -35.0;

  double get silenceThresholdDb => _silenceThresholdDb;

  void setSilenceThresholdDb(double value, BuildContext context) {
    if (_silenceThresholdDb != value) {
      _silenceThresholdDb = value;

      notifyListeners();

      // Здесь больше нет автоматического запуска анализа.
      // Теперь ответственность за анализ лежит на уровне, где реально нужен запуск анализа
      // Например, экран сам может отреагировать на изменение и инициировать анализ.
    }
  }




  List<double> _pcmLevels = [];

  List<double> get pcmLevels => _pcmLevels;

  set pcmLevels(List<double> value) {
    if (!listEquals(_pcmLevels, value)) {
      _pcmLevels = value;
      notifyListeners();
    }
  }

  List<Duration> _silences = [];

  List<Duration> get silences => _silences;

  set silences(List<Duration> value) {
    if (!listEquals(_silences, value)) {
      _silences = value;
      notifyListeners();
    }
  }

  List<int> _playedIndices = [];

  List<int> get playedIndices => _playedIndices;

  set playedIndices(List<int> value) {
    _playedIndices = value;
    notifyListeners();
  }

  bool _isPlayerInitialized = false;

  bool get isPlayerInitialized => _isPlayerInitialized;

  set isPlayerInitialized(bool value) {
    _isPlayerInitialized = value;
  }

  int cacheRetentionDays = 7;
  int cacheMaxSizeMb = 1024;


  void setCacheRetentionDays(int days) {
    cacheRetentionDays = days;
    persistentState.cacheRetentionDays = days;
    persistentState.save();
    notifyListeners();
  }

  void setCacheMaxSizeMb(int sizeMb) {
    cacheMaxSizeMb = sizeMb;
    persistentState.cacheMaxSizeMb = sizeMb;
    persistentState.save();
    notifyListeners();
  }

  void restoreCacheSettings() {
    cacheRetentionDays = persistentState.cacheRetentionDays ?? 7;
    cacheMaxSizeMb = persistentState.cacheMaxSizeMb ?? 1024;
  }

  Future<void> clearAllTempCacheAndFolders(BuildContext context) async {
    // 1. Очищаем временные аудиофайлы
    await clearTempCache();

    // 2. Очищаем кэш плейлистов (Hive)
    try {
      var box = await Hive.openBox('folderCache');
      await box.clear();
      await box.close();
    } catch (_) {}

    // 3. SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_folder_playlist_root');
    await prefs.remove('last_folder_playlist_current');
    await prefs.remove('last_folder_playlist_stack');
    // Добавь и другие ключи, если есть

    // 4. Очищаем кэш длительностей аудио
    await clearDurationsCache();

    // 5. Очищаем кэш добавления файлов (если используется)
    try {
      var box = await Hive.openBox('add_files_folder_cache');
      await box.clear();
      await box.close();
    } catch (_) {}

    // 6. UI-уведомление
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.uriCacheResetSuccess)),
      );
    }
  }




  int cacheSizeBytes = 0;

  Future<void> updateCacheSize() async {
    final dir = await getTemporaryDirectory();
    int size = 0;
    await for (var entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        size += await entity.length();
      }
    }
    cacheSizeBytes = size;
    notifyListeners();
  }

  String get cacheSizeFormatted => formatBytes(cacheSizeBytes);

  String formatBytes(int bytes, [int decimals = 1]) {
    if (bytes == 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes != 0) ? (math.log(bytes) / math.log(1024)).floor() : 0;
    return ((bytes / math.pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
  }

  Future<int> getTempCacheSizeBytes() async {
    final dir = await getTemporaryDirectory(); // Это cacheDir для Android и iOS
    return await _dirSize(dir);
  }

  /// Рекурсивно считает размер папки
  Future<int> _dirSize(Directory dir) async {
    int size = 0;
    try {
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (_) {}
    return size;
  }

  late Box<dynamic> durationsBox;
  Map<String, int> audioDurationsCache = {};

  Future<void> initDurationsCache() async {
    durationsBox = await Hive.openBox('audioDurations');
    audioDurationsCache = Map<String, int>.from(durationsBox.toMap());
  }

  int? getAudioDurationFor(String uriOrPath) => audioDurationsCache[safeKey(uriOrPath)];


  Future<void> setAudioDurationFor(String uriOrPath, int durationMs) async {
    audioDurationsCache[safeKey(uriOrPath)] = durationMs;
    await durationsBox.put(safeKey(uriOrPath), durationMs);
    notifyListeners();
  }

  Future<void> clearDurationsCache() async {
    await durationsBox.clear();
    audioDurationsCache.clear();
    notifyListeners();
  }

  Future<String> getTempCacheDirectoryPath() async {
    final dir = await getTemporaryDirectory();
    // Важно: используем сам temp-каталог без подкаталога /audio_cache
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<void> enforceCacheLimits() async {
    final dir = Directory(await getTempCacheDirectoryPath());
    if (!await dir.exists()) return;

    final files = dir.listSync().whereType<File>().toList();

    if (files.isEmpty) return;

    final now = DateTime.now();
    final retentionDays = cacheRetentionDays; // твоя настройка
    final maxSizeMb = cacheMaxSizeMb;

    // --- 1. Удаляем файлы старше retentionDays ---
    final cutoff = now.subtract(Duration(days: retentionDays));
    for (final file in files) {
      final stat = await file.stat();
      if (stat.modified.isBefore(cutoff)) {
        await file.delete();
      }
    }

    // --- 2. Проверяем общий размер кэша ---
    final remainingFiles = dir.listSync().whereType<File>().toList();
    int totalBytes = 0;
    final fileStats = <MapEntry<File, DateTime>>[];

    for (final f in remainingFiles) {
      final s = await f.stat();
      totalBytes += s.size;
      fileStats.add(MapEntry(f, s.modified));
    }

    final maxBytes = maxSizeMb * 1024 * 1024;

    if (totalBytes > maxBytes) {
      // --- 3. Удаляем самые старые файлы, пока не освободим место ---
      fileStats.sort((a, b) => a.value.compareTo(b.value)); // по дате
      for (final entry in fileStats) {
        if (totalBytes <= maxBytes) break;
        try {
          final s = await entry.key.stat();
          await entry.key.delete();
          totalBytes -= s.size;
        } catch (_) {}
      }
    }
  }

  Timer? _delayedCacheCleanupTimer;

  Future<void> scheduleCacheCleanup() async {
    _delayedCacheCleanupTimer?.cancel();
    debugPrint('[CACHE] 🕒 Планируем проверку кэша через 10 секунд...');
    _delayedCacheCleanupTimer = Timer(const Duration(seconds: 10), () async {
      try {
        await _cleanupOneOldCacheFileIfNeeded();
      } catch (e, st) {
        debugPrint('[CACHE] ❌ Ошибка при очистке: $e\n$st');
      }
    });
  }

  Future<void> _cleanupOneOldCacheFileIfNeeded() async {
    final dirPath = await getTempCacheDirectoryPath();
    debugPrint('[CACHE] 🔍 Проверяем каталог кэша: $dirPath');

    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      debugPrint('[CACHE] ❌ Каталог не существует');
      return;
    }

    final files = dir.listSync(recursive: true).whereType<File>().toList();
    if (files.isEmpty) {
      debugPrint('[CACHE] 📂 Файлы отсутствуют');
      return;
    }

    final maxBytes = cacheMaxSizeMb * 1024 * 1024;
    int totalBytes = 0;
    final fileStats = <MapEntry<File, DateTime>>[];

    for (final f in files) {
      try {
        final s = await f.stat();
        totalBytes += s.size;
        fileStats.add(MapEntry(f, s.modified));
      } catch (e) {
        debugPrint('[CACHE] ⚠️ Ошибка чтения ${f.path}: $e');
      }
    }

    debugPrint('[CACHE] 💾 Текущий размер: ${(totalBytes / 1024 / 1024).toStringAsFixed(2)} MB, лимит: $cacheMaxSizeMb MB');

    if (totalBytes <= maxBytes) {
      debugPrint('[CACHE] ✅ Лимит не превышен, очистка не требуется');
      return;
    }

    // сортируем по дате модификации (старейшие в начале)
    fileStats.sort((a, b) => a.value.compareTo(b.value));

    int deletedCount = 0;
    for (final entry in fileStats) {
      if (totalBytes <= maxBytes) break;

      final file = entry.key;
      try {
        final stat = await file.stat();
        await file.delete();
        totalBytes -= stat.size;
        deletedCount++;
        debugPrint('[CACHE] 🗑 Удалён: ${file.path}');
      } catch (e) {
        debugPrint('[CACHE] ❌ Не удалось удалить ${file.path}: $e');
      }
    }

    debugPrint('[CACHE] ✅ Очистка завершена. Удалено файлов: $deletedCount. Текущий размер: ${(totalBytes / 1024 / 1024).toStringAsFixed(2)} MB');
  }

  /// Проверяет наличие свободного места для кэша.
  /// Если `asyncCleanup = true`, удаление старых файлов идёт в фоне, без ожидания.
  ///
  /// Возвращает `true`, если места достаточно, чтобы записать [requiredBytes].
  Future<bool> ensureCacheSpace(int requiredBytes, {bool asyncCleanup = false}) async {
    final dirPath = await getTempCacheDirectoryPath();
    final dir = Directory(dirPath);

    if (!await dir.exists()) return false;

    final files = dir.listSync(recursive: true).whereType<File>().toList();
    int totalBytes = 0;
    final fileStats = <MapEntry<File, DateTime>>[];

    for (final f in files) {
      try {
        final s = await f.stat();
        totalBytes += s.size;
        fileStats.add(MapEntry(f, s.modified));
      } catch (_) {}
    }

    final maxBytes = cacheMaxSizeMb * 1024 * 1024;
    final freeBytes = maxBytes - totalBytes;

    debugPrint('[CACHE] 📊 Свободно ${(freeBytes / 1024 / 1024).toStringAsFixed(2)} MB '
        '(лимит: ${cacheMaxSizeMb} MB), требуется ${(requiredBytes / 1024 / 1024).toStringAsFixed(2)} MB');

    if (requiredBytes <= freeBytes) {
      debugPrint('[CACHE] ✅ Достаточно места, запись разрешена.');
      return true;
    }

    // Если не хватает — можно запустить фоновую очистку
    if (asyncCleanup) {
      debugPrint('[CACHE] ⚙️ Недостаточно места, очищаем в фоне...');
      unawaited(_freeCacheSpace(requiredBytes, fileStats, totalBytes, maxBytes));
      return true; // продолжаем без ожидания
    }

    // Иначе — очищаем синхронно (дождаться)
    return await _freeCacheSpace(requiredBytes, fileStats, totalBytes, maxBytes);
  }

  /// Вспомогательный метод для освобождения места
  Future<bool> _freeCacheSpace(
      int requiredBytes,
      List<MapEntry<File, DateTime>> fileStats,
      int totalBytes,
      int maxBytes,
      ) async {
    fileStats.sort((a, b) => a.value.compareTo(b.value));

    for (final entry in fileStats) {
      if ((maxBytes - totalBytes) >= requiredBytes) break;
      final file = entry.key;
      try {
        final stat = await file.stat();
        await file.delete();
        totalBytes -= stat.size;
        debugPrint('[CACHE] 🗑 Удалён: ${file.path}');
      } catch (_) {}
    }

    final enough = (maxBytes - totalBytes) >= requiredBytes;
    debugPrint('[CACHE] ${enough ? '✅' : '❌'} После очистки доступно: '
        '${((maxBytes - totalBytes) / 1024 / 1024).toStringAsFixed(2)} MB');

    return enough;
  }



  // -----------------------------------АНАЛИТИКА--------------------------------------------------------------------

  String? _deviceId;

  Future<void> _loadOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id');
    if (_deviceId == null) {
      _deviceId = const Uuid().v4();
      await prefs.setString('device_id', _deviceId!);
    }
  }

  String get deviceId => _deviceId ?? 'unknown';



  Timer? _analyticsPollTimer;

// --- Предыдущее состояние для polling ---
  bool? _prevIsPlaying;
  int? _prevCurrentIndex;
  PlaybackMode? _prevPlaybackMode;
  double? _prevPlaybackSpeed;
  Duration? _prevMarkerA;
  Duration? _prevMarkerB;
  bool? _prevShowSilenceControlBar;
  bool? _prevShowPlaybackButtons;
  bool? _prevShowJogAndSeekButtons;
  bool? _prevShowSpeedSlider;
  bool? _prevShowMarkers;
  bool? _prevPlayBetweenMarkers;
  int? _prevKnobTouchEventId;
  Duration? _prevPosition;

  final knobTouchVN = ValueNotifier<int>(0); // Для джога

  void startAnalyticsPolling() {
    _analyticsPollTimer?.cancel();
    _analyticsPollTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      _pollAnalytics();
    });
  }

  void stopAnalyticsPolling() {
    _analyticsPollTimer?.cancel();
    _analyticsPollTimer = null;
  }

  void _pollAnalytics() {
    // 1. Воспроизведение / пауза
    if (_prevIsPlaying != isPlayingVN.value) {
      AppAnalytics.logEvent('play_pause', parameters: {
        'isPlaying': isPlayingVN.value,
        'position': positionVN.value.inSeconds,
        'mode': playbackMode.toString(),
        'device_id': deviceId, // ← вот эта строка
      });
      _prevIsPlaying = isPlayingVN.value;
    }

    // 2. Переключение трека
    if (_prevCurrentIndex != currentIndexVN.value) {
      AppAnalytics.logEvent('track_switched', parameters: {
        'mode': playbackMode.toString(),
        'device_id': deviceId,
      });
      _prevCurrentIndex = currentIndexVN.value;
    }

    // 3. Смена режима воспроизведения
    if (_prevPlaybackMode != playbackMode) {
      AppAnalytics.logEvent('playback_mode_changed', parameters: {
        'mode': playbackMode.toString(),
        'device_id': deviceId,
      });
      _prevPlaybackMode = playbackMode;
    }

    // 4. Смена скорости воспроизведения
    if (_prevPlaybackSpeed != playbackSpeed) {
      AppAnalytics.logEvent('playback_speed_changed', parameters: {
        'speed': playbackSpeed,
        'device_id': deviceId,
      });
      _prevPlaybackSpeed = playbackSpeed;
    }

    // 5. Смена маркера А
    if (_prevMarkerA != markerA) {
      AppAnalytics.logEvent('marker_a_changed', parameters: {
        'marker_a_ms': markerA.inMilliseconds,
        'device_id': deviceId,
      });
      _prevMarkerA = markerA;
    }

    // 6. Смена маркера B
    if (_prevMarkerB != markerB) {
      AppAnalytics.logEvent('marker_b_changed', parameters: {
        'marker_b_ms': markerB.inMilliseconds,
        'device_id': deviceId,
      });
      _prevMarkerB = markerB;
    }

    // 7. Появление/скрытие панели тишины
    if (_prevShowSilenceControlBar != showSilenceControlBar) {
      AppAnalytics.logEvent('silence_control_bar_visibility', parameters: {
        'visible': showSilenceControlBar,
        'device_id': deviceId,
      });
      _prevShowSilenceControlBar = showSilenceControlBar;
    }

    // 8. Видимость кнопок управления воспроизведением
    if (_prevShowPlaybackButtons != showPlaybackButtons) {
      AppAnalytics.logEvent('playback_buttons_visibility', parameters: {
        'visible': showPlaybackButtons,
        'device_id': deviceId,
      });
      _prevShowPlaybackButtons = showPlaybackButtons;
    }

    // 9. Видимость джога и кнопок перемотки
    if (_prevShowJogAndSeekButtons != showJogAndSeekButtons) {
      AppAnalytics.logEvent('jog_and_seek_visibility', parameters: {
        'visible': showJogAndSeekButtons,
        'device_id': deviceId,
      });
      _prevShowJogAndSeekButtons = showJogAndSeekButtons;
    }

    // 10. Видимость слайдера скорости
    if (_prevShowSpeedSlider != showSpeedSlider) {
      AppAnalytics.logEvent('speed_slider_visibility', parameters: {
        'visible': showSpeedSlider,
        'device_id': deviceId,
      });
      _prevShowSpeedSlider = showSpeedSlider;
    }

    // 11. Видимость маркеров
    if (_prevShowMarkers != showMarkers) {
      AppAnalytics.logEvent('markers_visibility', parameters: {
        'visible': showMarkers,
        'device_id': deviceId,
      });
      _prevShowMarkers = showMarkers;
    }

    // 12. Режим "между маркерами"
    if (_prevPlayBetweenMarkers != playBetweenMarkers) {
      AppAnalytics.logEvent('play_between_markers_toggled', parameters: {
        'active': playBetweenMarkers,
        'device_id': deviceId,
      });
      _prevPlayBetweenMarkers = playBetweenMarkers;
    }

    // 13. Взаимодействие с джогом (касаний кноба)
    if (_prevKnobTouchEventId != knobTouchVN.value) {
      AppAnalytics.logEvent('jog_knob_touch', parameters: {
        'event_id': knobTouchVN.value,
        'position': positionVN.value.inMilliseconds,
        'device_id': deviceId,
      });
      _prevKnobTouchEventId = knobTouchVN.value;
    }
/*
    // 14. Перемотка (seek) — логируем только если изменилось более чем на 1 сек
    if (_prevPosition == null ||
        (positionVN.value - _prevPosition!).inMilliseconds.abs() > 1000) {
      AppAnalytics.logEvent('seek', parameters: {
        'from_ms': _prevPosition?.inMilliseconds ?? 0,
        'to_ms': positionVN.value.inMilliseconds,
        'device_id': deviceId,
      });
      _prevPosition = positionVN.value;
    }*/
  }



  @override
  void dispose() {
    stopAnalyticsPolling();
    // ...остальной твой код dispose...
    super.dispose();
  }

}
