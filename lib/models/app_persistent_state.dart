import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../enums/enums.dart';

/// Основной класс, в котором перечислены ВСЕ параметры для хранения/восстановления.
/// Для примера указаны важнейшие поля. Добавляй и расширяй их по мере необходимости.

class AppPersistentState {
  // --- Playback state ---
  String currentTrackPath;
  int currentIndex;
  double playbackSpeed;
  double silenceThreshold;
  int markerA;
  int markerB;
  bool showPlaybackButtons;
  bool showJogAndSeekButtons;
  bool showSpeedSlider;
  bool showSilenceControlBar;
  String playbackMode;
  String lastSegmentPlaybackMode;
  bool showMarkers;
  bool playBetweenMarkers;
  String playlistSource;
  String? localeCode;
  String playbackButtonStyle;
  double minSpeed;
  double maxSpeed;
  String timeDisplayStyle;
  int jogResolutionSecondsPerRevolution;
  int minJogSkipSpeedMsPerSec;
  int maxJogSkipSpeedMsPerSec;

  // Новое поле для secondaryTimeType
  String secondaryTimeType;

  // Новое поле (пример)
  String? lastUsedFolderPath;

  int cacheRetentionDays;
  int cacheMaxSizeMb;


  AppPersistentState({
    this.currentTrackPath = '',
    this.currentIndex = 0,
    this.playbackSpeed = 1.0,
    this.silenceThreshold = -35.0,
    this.markerA = 0,
    this.markerB = 0,
    this.showPlaybackButtons = true,
    this.showJogAndSeekButtons = true,
    this.showSpeedSlider = true,
    this.showSilenceControlBar = true,
    this.playbackMode = 'playlistLoop',
    this.lastSegmentPlaybackMode = 'singleLoop',
    this.showMarkers = false,
    this.playBetweenMarkers = false,
    this.playlistSource = 'manual',
    this.localeCode,
    this.playbackButtonStyle = 'precise',
    this.minSpeed = 0.5,
    this.maxSpeed = 2.0,
    this.timeDisplayStyle = 'mmss',
    this.jogResolutionSecondsPerRevolution = 5,
    this.minJogSkipSpeedMsPerSec = 200,
    this.maxJogSkipSpeedMsPerSec = 20000,

    // Новое поле для secondaryTimeType
    this.secondaryTimeType = 'remaining',

    // Пример нового поля
    this.lastUsedFolderPath = '',
    this.cacheRetentionDays = 7,
    this.cacheMaxSizeMb = 512,
  });

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('currentTrackPath', currentTrackPath);
    prefs.setInt('currentIndex', currentIndex);
    prefs.setDouble('playbackSpeed', playbackSpeed);
    prefs.setDouble('silenceThreshold', silenceThreshold);
    prefs.setInt('markerA', markerA);
    prefs.setInt('markerB', markerB);
    prefs.setBool('showPlaybackButtons', showPlaybackButtons);
    prefs.setBool('showJogAndSeekButtons', showJogAndSeekButtons);
    prefs.setBool('showSpeedSlider', showSpeedSlider);
    prefs.setBool('showSilenceControlBar', showSilenceControlBar);
    prefs.setString('playbackMode', playbackMode);
    prefs.setString('lastSegmentPlaybackMode', lastSegmentPlaybackMode);
    prefs.setBool('showMarkers', showMarkers);
    prefs.setBool('playBetweenMarkers', playBetweenMarkers);
    prefs.setString('playlistSource', playlistSource);
    prefs.setString('localeCode', localeCode ?? 'en');
    prefs.setString('playbackButtonStyle', playbackButtonStyle);
    prefs.setDouble('minSpeed', minSpeed);
    prefs.setDouble('maxSpeed', maxSpeed);
    prefs.setString('timeDisplayStyle', timeDisplayStyle);
    prefs.setInt('jogResolutionSecondsPerRevolution', jogResolutionSecondsPerRevolution);
    prefs.setInt('minJogSkipSpeedMsPerSec', minJogSkipSpeedMsPerSec);
    prefs.setInt('maxJogSkipSpeedMsPerSec', maxJogSkipSpeedMsPerSec);

    // Сохраняем secondaryTimeType
    prefs.setString('secondaryTimeType', secondaryTimeType);

    // Пример: сохраняем lastUsedFolderPath
    if (lastUsedFolderPath != null && lastUsedFolderPath!.isNotEmpty) {
      prefs.setString('lastUsedFolderPath', lastUsedFolderPath!);
    } else {
      prefs.remove('lastUsedFolderPath'); // очищаем, если пусто или null
    }
    prefs.setInt('cacheRetentionDays', cacheRetentionDays);
    prefs.setInt('cacheMaxSizeMb', cacheMaxSizeMb);


  }

  static Future<AppPersistentState> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPersistentState(
      currentTrackPath: prefs.getString('currentTrackPath') ?? '',
      currentIndex: prefs.getInt('currentIndex') ?? 0,
      playbackSpeed: prefs.getDouble('playbackSpeed') ?? 1.0,
      silenceThreshold: prefs.getDouble('silenceThreshold') ?? -35.0,
      markerA: prefs.getInt('markerA') ?? 0,
      markerB: prefs.getInt('markerB') ?? 0,
      showPlaybackButtons: prefs.getBool('showPlaybackButtons') ?? true,
      showJogAndSeekButtons: prefs.getBool('showJogAndSeekButtons') ?? true,
      showSpeedSlider: prefs.getBool('showSpeedSlider') ?? true,
      showSilenceControlBar: prefs.getBool('showSilenceControlBar') ?? true,
      playbackMode: prefs.getString('playbackMode') ?? 'playlistLoop',
      lastSegmentPlaybackMode: prefs.getString('lastSegmentPlaybackMode') ?? 'singleLoop',
      showMarkers: prefs.getBool('showMarkers') ?? false,
      playBetweenMarkers: prefs.getBool('playBetweenMarkers') ?? false,
      playlistSource: prefs.getString('playlistSource') ?? 'manual',
      localeCode: prefs.getString('localeCode'),
      playbackButtonStyle: prefs.getString('playbackButtonStyle') ?? 'precise',
      minSpeed: prefs.getDouble('minSpeed') ?? 0.5,
      maxSpeed: prefs.getDouble('maxSpeed') ?? 2.0,
      timeDisplayStyle: prefs.getString('timeDisplayStyle') ?? 'mmss',
      jogResolutionSecondsPerRevolution: prefs.getInt('jogResolutionSecondsPerRevolution') ?? 5,
      minJogSkipSpeedMsPerSec: prefs.getInt('minJogSkipSpeedMsPerSec') ?? 200,
      maxJogSkipSpeedMsPerSec: prefs.getInt('maxJogSkipSpeedMsPerSec') ?? 20000,

      // Загружаем secondaryTimeType
      secondaryTimeType: prefs.getString('secondaryTimeType') ?? 'remaining',

      // Пример: загружаем lastUsedFolderPath
      lastUsedFolderPath: prefs.getString('lastUsedFolderPath'),
      cacheRetentionDays: prefs.getInt('cacheRetentionDays') ?? 7,
      cacheMaxSizeMb: prefs.getInt('cacheMaxSizeMb') ?? 512,

    );
  }
}
