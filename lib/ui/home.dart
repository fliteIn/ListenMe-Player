//---------------------ГЛАВНЫЙ ЭКРАН-----------------------------------------

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import 'Settings/settings_home_screen.dart';
import '../widgets/top_menu_bar.dart';
import '../widgets/track_title.dart';
import '../widgets/playback_time.dart';
import '../widgets/progress_slider.dart';
import '../widgets/jog_wheel.dart';
import '../widgets/rewind_fast_forward.dart';
import '../widgets/marker_slider.dart';
import '../widgets/speed_slider.dart';
import '../widgets/playback_mode_button.dart';
import '../widgets/open_files_button.dart';
import '../widgets/playback_standard.dart';
import '../widgets/playback_extended.dart';
import '../widgets/playback_precise.dart';
import '../widgets/gradient_divider.dart';
import '../widgets/silence_control_bar.dart';
import '../utils/temp_audio_files_utils.dart';
import '../enums/enums.dart';
import '../widgets/playback_extended.dart';
import 'package:provider/provider.dart';
import '../models/audio_to_levels_model.dart';
import '../models/purchase_model.dart';
import '../widgets/general_controls.dart';
import '../widgets/my_banner_ad_widget.dart';
import 'package:flutter/services.dart';


IconData getSectionIcon(PlayerSection section) {
  switch (section) {
    case PlayerSection.homeBottomControls:
      return Icons.view_module;
    case PlayerSection.trackTitle:
      return Icons.title;
    case PlayerSection.progressSlider:
      return Icons.timeline;
    case PlayerSection.playback:
      return Icons.play_circle;
    case PlayerSection.jogWheel:
      return Icons.radio_button_checked;
    case PlayerSection.speedSlider:
      return Icons.speed;
    case PlayerSection.silenceControlBar:
      return Icons.graphic_eq;
    default:
      return Icons.device_unknown;
  }
}

bool willOverlapY(double newY,
    double height,
    SectionSlot movingSlot,
    List<SectionSlot> slots,
    Map<PlayerSection, double> heights,) {
  final newTop = newY;
  final newBottom = newY + height;

  for (final other in slots) {
    if (!other.active || other == movingSlot) continue;
    final otherTop = other.positionY;
    final otherHeight = heights[other.type]!;
    final otherBottom = otherTop + otherHeight;
    if ((newTop < otherBottom) && (newBottom > otherTop)) {
      return true;
    }
  }
  return false;
}

Map<PlayerSection, double> getAdaptiveSectionHeights(BuildContext context) {
  final app = Provider.of<AppModel>(context, listen: false);
  return app.isTablet ? sectionHeightsTablet : sectionHeightsPhone;
}

double applySnapY({
  required double desiredY,
  required double height,
  required SectionSlot movingSlot,
  required List<SectionSlot> slots,
  required Map<PlayerSection, double> heights,
  required double minY,
  required double maxY,
  double snapDistanceNear = 5.0,
  double snapDistanceOverlap = 5.0,
}) {
  double y = desiredY;
  for (final other in slots) {
    if (other == movingSlot || !other.active) continue;

    final otherHeight = heights[other.type] ?? 80.0;
    final otherTop = other.positionY;
    final otherBottom = other.positionY + otherHeight;

    // Сверху — snap к top другого блока
    final nearTopDist = (desiredY - otherTop).abs();
    if (nearTopDist < snapDistanceNear) {
      y = otherTop;
    }
    // Снизу — snap к bottom другого блока
    final nearBottomDist = (desiredY + height - otherBottom).abs();
    if (nearBottomDist < snapDistanceNear) {
      y = otherBottom - height;
    }

    // Перекрытие сверху или снизу — отталкиваем сильнее
    if (desiredY < otherBottom && desiredY + height > otherTop) {
      // Сверху
      if ((otherBottom - desiredY) < snapDistanceOverlap) {
        y = otherBottom;
      }
      // Снизу
      if ((desiredY + height - otherTop) < snapDistanceOverlap) {
        y = otherTop - height;
      }
    }
  }
  // Не даём вылезать за экран
  return y.clamp(minY, maxY - height);
}

const double tabletScale = 1.4;

// Можно поместить в utils, но для простоты вставь рядом.
double getSectionSnapNear(PlayerSection section, bool isTablet) {
  // Для планшета — больше зазор, и для некоторых секций еще больше (например, джог и прогресс)
  if (isTablet) {
    switch (section) {
      case PlayerSection.jogWheel:
        return 24.0;
      case PlayerSection.progressSlider:
        return 20.0;
      case PlayerSection.silenceControlBar:
        return 18.0;
      case PlayerSection.speedSlider:
        return 14.0;
      default:
        return 10.0;
    }
  } else {
    // Для смартфона — минимальный, чтобы не раздражал
    switch (section) {
      case PlayerSection.jogWheel:
        return 12.0;
      case PlayerSection.progressSlider:
        return 9.0;
      case PlayerSection.silenceControlBar:
        return 8.0;
      case PlayerSection.speedSlider:
        return 6.0;
      default:
        return 5.0;
    }
  }
}

double getSectionSnapOverlap(PlayerSection section, bool isTablet) {
  if (isTablet) {
    switch (section) {
      case PlayerSection.jogWheel:
        return 38.0;
      case PlayerSection.progressSlider:
        return 32.0;
      case PlayerSection.silenceControlBar:
        return 26.0;
      case PlayerSection.speedSlider:
        return 20.0;
      default:
        return 16.0;
    }
  } else {
    switch (section) {
      case PlayerSection.jogWheel:
        return 18.0;
      case PlayerSection.progressSlider:
        return 15.0;
      case PlayerSection.silenceControlBar:
        return 13.0;
      case PlayerSection.speedSlider:
        return 11.0;
      default:
        return 8.0;
    }
  }
}



class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _dropInProgress = false;

  double adaptiveSize(bool isTablet, double phone, [double? tablet]) =>
      isTablet ? (tablet ?? phone * 1.4) : phone;


  @override
  void initState() {
    super.initState();
    //print('🟢 [UI] AudioPlayerScreen.initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    //print('[DISPOSE] Home.dispose (${hashCode})');
    //_scrollController?.dispose(); // если есть
    //_myStreamSubscription?.cancel(); // если есть
    super.dispose();
  }

  void updateSectionPositionY(BuildContext context, String id, double newY,
      double screenH) {
    final app = Provider.of<AppModel>(context, listen: false);
    final sectionSlots = app.sectionSlots;

    SectionSlot? slot;
    try {
      slot = sectionSlots.firstWhere((s) => s.id == id);
    } catch (_) {
      slot = null;
    }

    if (slot != null) {
      final sectionHeights = getAdaptiveSectionHeights(context);
      final height = sectionHeights[slot.type] ?? 60;
      final clampedY = newY.clamp(0.0, screenH - height);
      if ((slot.positionY - clampedY).abs() > 0.01) {
        slot.positionY = clampedY;
        app.saveSectionSlots(app.sectionSlots);
        app.notifyListeners();
      }
    }
  }

//-----------------------------------------------------------------------------
//------------------ЭЛЕМЕНТЫ УПРАВЛЕНИЯ И КОНТРОЛЯ-----------------------------
//-----------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppModel>(context);

    final editMode = app.editMode;
    final theme = context
        .watch<AppModel>()
        .themeColors;
    app.updateSystemUi(theme);


    debugPrint('isTablet: $app.isTablet');
    final mainPadding = app.isTablet ? 10.0 : 0.0;
    final maxContentWidth = app.isTablet ? 950.0 : double.infinity;

    return WillPopScope(
      onWillPop: () async {
        const platform = MethodChannel('com.listenme.player/app');
        await platform.invokeMethod('moveTaskToBack');
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
          body: SafeArea(
            top: false,
            bottom: true,
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: mainPadding),
                      child: editMode
                          ? _buildEditModeFreeLayout(context, isTablet: app.isTablet)
                          : _buildNormalModeFreeLayout(context, isTablet: app.isTablet),
                    ),
                  ),
                ),
                // ---- Вот это — твой баннер на весь экран!
                if (!context.watch<PurchaseModel>().adsDisabled)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: MyBannerAdWidget(),
                  ),
                if (editMode)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: _buildWidgetDrawer(context, app, isTablet: app.isTablet),
                  ),
              ],
            ),
          ),

      ),
    );
  }


  Widget _buildSection(BuildContext context, PlayerSection section,
      {required bool editMode, bool isTablet = false}) {
    final app = Provider.of<AppModel>(context);
    final theme = app.themeColors;

    // Используем адаптивную высоту для секции
    final sectionHeights = getAdaptiveSectionHeights(context);
    final heights = sectionHeights;
    final baseHeight = heights[section] ?? 60.0;
    final height = adaptiveSize(isTablet, baseHeight);
    Widget child;
    switch (section) {
      case PlayerSection.homeBottomControls:
        child = IgnorePointer(
          ignoring: editMode,
            child: GeneralControls(
              iconSize: adaptiveSize(isTablet, 24, 24*1.4),
              iconBtnSize: adaptiveSize(isTablet, 48, 48*1.4),
              controlBarHeight: adaptiveSize(isTablet, 60, 60*1.4),
              iconGap: adaptiveSize(isTablet, 0, 4*1.4),

            )

        );
        break;

      case PlayerSection.trackTitle:
        child = IgnorePointer(
          ignoring: editMode,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery
                      .of(context)
                      .size
                      .width - adaptiveSize(isTablet, 32.0, 32.0 * 1.4),
                ),
                child: TrackTitle(
                  fontSize: adaptiveSize(isTablet, 16.0, 16.0 * 1.3),

                ),
              ),
            ),
          ),
        );
        break;

      case PlayerSection.progressSlider:
        final sectionHeight = adaptiveSize(
          isTablet,
          sectionHeights[PlayerSection.progressSlider] ?? 102.0,
        );

        child = SizedBox(
          height: sectionHeight,
          child: IgnorePointer(
            ignoring: editMode,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ValueListenableBuilder<Duration>(
                  valueListenable: app.positionVN,
                  builder: (context, position, _) {
                    return PlaybackTime(
                      position: position,
                      duration: app.duration ?? Duration.zero,
                      style: app.timeDisplayStyle,
                      secondaryTimeType: app.secondaryTimeType,
                      fontSize: adaptiveSize(isTablet, 14.0, 14.0 * 1.4),
                      height: adaptiveSize(isTablet, 20.0, 20.0 * 1.4),
                      sideButtonWidth: adaptiveSize(isTablet, 58.0, 75.0),
                    );
                  },
                ),
                if (app.showMarkers)
                  MarkerSlider(
                    marker: app.markerA,
                    duration: app.duration,
                    currentPosition: app.position,
                    onChanged: (d) => setState(() => app.markerA = d),
                    isUp: true,
                    height: adaptiveSize(isTablet, 26.0, 26.0 * 1.4),
                    buttonSize: adaptiveSize(isTablet, 22.0, 22.0 * 1.4),
                    thumbSize: adaptiveSize(isTablet, 20.0, 18.0 * 1.4),
                    trackHeight: adaptiveSize(isTablet, 1.0, 1.0 * 1.4),
                    edgePadding: adaptiveSize(isTablet, 14.0, 26.0),

                  ),
                const SizedBox(height: 5),
                RepaintBoundary(
                  child: ValueListenableBuilder<Duration>(
                    valueListenable: app.positionVN,
                    builder: (context, position, _) {
                      return ProgressSlider(
                        position: position,
                        duration: app.duration,
                        markerA: app.markerA,
                        markerB: app.markerB,
                        showMarkers: app.showMarkers,
                        playBetweenMarkers: app.playBetweenMarkers,
                        onSeekStart: app.playbackModel.handleSeekStart,
                        onSeekEnd: app.playbackModel.handleSeekEnd,
                        onSeek: (d) => app.player.seek(d),
                        height: adaptiveSize(isTablet, 20.0, 30.0 * 1.4),
                        thumbSize: adaptiveSize(isTablet, 20.0, 18.0 * 1.4),
                        trackHeight: adaptiveSize(isTablet, 4.0, 4.0 * 1.4),
                        sideButtonSize: adaptiveSize(isTablet, 22.0, 22.0 * 1.4),
                        sideGap: adaptiveSize(isTablet, 5.0, 18.0),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 5),
                if (app.showMarkers)
                  MarkerSlider(
                    marker: app.markerB,
                    duration: app.duration,
                    currentPosition: app.position,
                    onChanged: (d) => setState(() => app.markerB = d),
                    isUp: false,
                    height: adaptiveSize(isTablet, 26.0, 26.0 * 1.4),
                    buttonSize: adaptiveSize(isTablet, 22.0, 22.0 * 1.4),
                    thumbSize: adaptiveSize(isTablet, 20.0, 18.0 * 1.4),
                    trackHeight: adaptiveSize(isTablet, 1.0, 1.0 * 1.4),
                    edgePadding: adaptiveSize(isTablet, 14.0, 26.0),
                  ),
              ],
            ),
          ),
        );
        break;

      case PlayerSection.jogWheel:
        child = IgnorePointer(
          ignoring: editMode,
          child: (editMode || app.showJogAndSeekButtons)
              ? GestureDetector(
            onVerticalDragDown: (_) {},
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CurvedRewindButton(
                      side: ButtonSide.left,
                      size: adaptiveSize(isTablet, 140.0, 140.0 * 1.4),
                      rewindButtonWidth: adaptiveSize(isTablet, 54.0, 54.0 * 1.4),
                      trackSwitchWidth: adaptiveSize(isTablet, 28.0, 28.0 * 1.4),
                      gap: adaptiveSize(isTablet, 3.0, 3.0 * 1.4),
                      iconSize: adaptiveSize(isTablet, 20.0, 20.0), // ← размер иконки внутри кнопки перемотки
                      trackSwitchIconSize: adaptiveSize(isTablet, 26.0, 26.0*1.2), // ← размер иконки skip
                      onPanStart: (local, height) =>
                          app.playbackModel
                              .startZoneSeek(local, height, false),
                      onPanUpdate: (local, height) =>
                          app.playbackModel
                              .updateZoneSeekSpeed(local, height),
                      onPanEnd: app.playbackModel.stopZoneSeek,
                      onTrackSwitch: app.playbackModel.handlePrevious,
                    ),
                    SizedBox(width: adaptiveSize(isTablet, 5.0, 15.0)),
                    RepaintBoundary(
                      child: ValueListenableBuilder<Duration>(
                        valueListenable: app.positionVN,
                        builder: (context, value, _) {
                          return JogWheel(
                            position: value,
                            duration: app.duration,
                            markerA: app.markerA,
                            markerB: app.markerB,
                            playBetweenMarkers: app.playBetweenMarkers,
                            isPlaying: app.isPlaying,
                            onKnobTouchStart: () {
                              app.playbackModel.handleKnobTouchStart();
                            },
                            onKnobTouchEnd: () {
                              app.playbackModel.handleKnobTouchEnd();
                            },
                            onKnobPanUpdate: (newPosition) {
                              app.withManualSeek(() async {
                                await app.player.seek(newPosition);
                                app.position = newPosition;
                              });
                            },
                            onKnobPanEnd: (newPosition) {
                              app.withManualSeek(() async {
                                await app.player.seek(newPosition);
                                app.position = newPosition;
                              });
                            },
                            onPlayPauseToggle:
                            app.playbackModel.handlePlayPause,
                            size: adaptiveSize(isTablet, 140.0, 140.0 * 1.4),
                            // <-- Внешний размер джога (у тебя уже есть)
                            knobSize: adaptiveSize(isTablet, 20.0, 18.0 * 1.4),
                            // <-- Размер кноба (кружок по кругу)
                            innerButtonSize: adaptiveSize(isTablet, 54.0, 54.0 * 1.4),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: adaptiveSize(isTablet, 5, 15.0)),
                    CurvedRewindButton(
                      side: ButtonSide.right,
                      size: adaptiveSize(isTablet, 140.0, 140.0 * 1.4),
                      rewindButtonWidth: adaptiveSize(
                          isTablet, 54.0, 54.0 * 1.4),
                      trackSwitchWidth: adaptiveSize(
                          isTablet, 28.0, 28.0 * 1.4),
                      gap: adaptiveSize(isTablet, 3.0, 3.0 * 1.4),
                      iconSize: adaptiveSize(isTablet, 20.0, 20.0), // ← размер иконки внутри кнопки перемотки
                      trackSwitchIconSize: adaptiveSize(isTablet, 26.0, 26.0*1.2), // ← размер иконки skip
                      onPanStart: (local, height) =>
                          app.playbackModel
                              .startZoneSeek(local, height, true),
                      onPanUpdate: (local, height) =>
                          app.playbackModel
                              .updateZoneSeekSpeed(local, height),
                      onPanEnd: app.playbackModel.stopZoneSeek,
                      onTrackSwitch: app.playbackModel.handleNext,
                    ),
                  ],
                ),
              ],
            ),
          )
              : Container(height: height),
        );
        break;

      case PlayerSection.playback:
        child = IgnorePointer(
          ignoring: editMode,
          child: (editMode || app.showPlaybackButtons)
              ? Builder(
            builder: (context) {
              switch (app.playbackButtonStyle) {
              case PlaybackButtonStyle.standard:
              return ValueListenableBuilder<bool>(
              valueListenable: app.isPlayingVN,
              builder: (context, _, __) =>
                  PlaybackStandard(
                    app: app,
                    iconSize: adaptiveSize(isTablet, 30.0, 30.0*1.4),             // стандартные иконки
                    playIconSize: adaptiveSize(isTablet, 42.0, 42.0*1.4),         // иконка Play/Pause
                    switchTrackIconSize: adaptiveSize(isTablet, 36.0, 36.0*1.4),  // skip_prev/next
                    buttonSize: adaptiveSize(isTablet, 36.0, 36.0*1.4),           // размер кнопки-обёртки
                    spacing: adaptiveSize(isTablet, 0.0, 0.0),                // малый отступ
                    bigSpacing: adaptiveSize(isTablet, 12.0, 12.0*1.4),           // большой отступ
                    height: adaptiveSize(isTablet, 64.0, 64.0*1.4),
                  )

              );
              case PlaybackButtonStyle.extended:
              return ValueListenableBuilder<bool>(
              valueListenable: app.isPlayingVN,
              builder: (context, _, __) =>
              PlaybackExtended(app: app,
                iconSize: adaptiveSize(isTablet, 30.0, 30.0*1.4),             // стандартные иконки
                playIconSize: adaptiveSize(isTablet, 42.0, 42.0*1.4),         // иконка Play/Pause
                switchTrackIconSize: adaptiveSize(isTablet, 36.0, 36.0*1.4),  // skip_prev/next
                buttonSize: adaptiveSize(isTablet, 36.0, 36.0*1.4),           // размер кнопки-обёртки
                spacing: adaptiveSize(isTablet, 0.0, 0.0),                // малый отступ
                bigSpacing: adaptiveSize(isTablet, 12.0, 12.0*1.4),           // большой отступ
                height: adaptiveSize(isTablet, 64.0, 64.0*1.4),
              ),
              );
              case PlaybackButtonStyle.precise:
              return ValueListenableBuilder<bool>(
              valueListenable: app.isPlayingVN,
              builder: (context, _, __) =>
                  PlaybackPrecise(
                    app: app,
                    iconSize: adaptiveSize(isTablet, 30.0, 30.0*1.4),             // стандартные иконки
                    playIconSize: adaptiveSize(isTablet, 42.0, 42.0*1.4),         // иконка Play/Pause
                    switchTrackIconSize: adaptiveSize(isTablet, 36.0, 36.0*1.4),  // skip_prev/next
                    buttonSize: adaptiveSize(isTablet, 36.0, 36.0*1.4),           // размер кнопки-обёртки
                    spacing: adaptiveSize(isTablet, 0.0, 0.0),                // малый отступ
                    bigSpacing: adaptiveSize(isTablet, 12.0, 12.0*1.4),           // большой отступ
                    height: adaptiveSize(isTablet, 64.0, 64.0*1.4),               // высота всей строки
                  ),

              );
              }
            },
          )
              : Container(height: height),
        );
        break;

      case PlayerSection.speedSlider:
        child = IgnorePointer(
          ignoring: editMode,
          child: (editMode || app.showSpeedSlider)
              ? SpeedSlider(
            playbackSpeed: app.playbackSpeed,
            onSpeedChanged: app.playbackModel.changeSpeed,
            height: adaptiveSize(isTablet, 50.0, 50.0*1.4),          // Высота всей секции
            sliderHeight: adaptiveSize(isTablet, 28.0, 28.0*1.4),    // Высота слайдера
            thumbSize: adaptiveSize(isTablet, 20.0, 18.0*1.4),       // Размер бегунка
            buttonSize: adaptiveSize(isTablet, 22.0, 22.0*1.4),      // Кнопки "+" и "−"
            fontSize: adaptiveSize(isTablet, 14.0, 14.0*1.3),        // Размер текста
            trackHeight: adaptiveSize(isTablet, 4.0, 4.0*1.4),       // Высота трека слайдера
            symbolSpacing: adaptiveSize(isTablet, 7.0, 4.0*1.4),   // Отступ между кнопками/слайдером
            edgePadding: adaptiveSize(isTablet, 14.0, 26.0),
          )
              : Container(height: height),
        );
        break;


      case PlayerSection.silenceControlBar:

        double adaptiveSize(bool isTablet, double phone, [double? tablet]) =>
            isTablet ? (tablet ?? phone * 1.4) : phone;

        child = IgnorePointer(
          ignoring: editMode,
          child: (editMode || app.showSilenceControlBar)
              ? ChangeNotifierProvider<AudioToLevelsModel>.value(
            value: app.audio_to_levels,
            child: RepaintBoundary(
              child: ValueListenableBuilder<double>(
                valueListenable: app.currentPcmLevelVN,
                builder: (context, currentLevel, _) {
                  return SilenceControlBar(
                    silenceThresholdDb: app.silenceThresholdDb,
                    currentPcmLevel: currentLevel,
                    pcmLevels: app.pcmLevels,
                    onJumpToPrevSilence:
                    app.playbackModel.jumpToPrevSilencefromWidget,
                    onJumpToNextSilence:
                    app.playbackModel.jumpToNextSilencefromWidget,
                    onThresholdChanged: (value) {
                      setState(() {
                        app.setSilenceThresholdDb(value, context);
                      });
                    },
                    onThresholdChangeEnd: () {
                      app.audio_to_levels.analyzeTrack(
                        full: false,
                      );
                    },
                    // --- адаптивные параметры:
                    height: adaptiveSize(isTablet, 56.0, 56.0 * 1.4),
                    fontSize: adaptiveSize(isTablet, 14.0, 14.0 * 1.3),

                    sideButtonWidth: adaptiveSize(isTablet, 56.0, 56.0 * 1.4),
                    triangleSize: adaptiveSize(isTablet, 32.0, 32.0 * 1.4),
                    sliderHeight: adaptiveSize(isTablet, 28.0, 28.0 * 1.4),
                    sliderThumbRadius: adaptiveSize(isTablet, 10.0, 10.0 * 1.4),
                    spinnerSize: adaptiveSize(isTablet, 12.0, 12.0 * 1.4),
                    trackHeight: adaptiveSize(isTablet, 4.0, 4.0 * 1.4),
                  );
                },
              ),
            ),
          )
              : Container(height: height),
        );
        break;


      case PlayerSection.gradientDivider:
        child = Align(
          alignment: Alignment.center,
          child: GradientDivider(
          ),
        );
        break;

      default:
        child = Container(height: height);
        break;
    }

    // Оборачиваем в Align, чтобы отцентрировать по высоте секции
    child = SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.center,
        child: child,
      ),
    );

    // ======== Градиентный фон только в editMode ==========
    if (editMode) {
      child = Container(
        height: height, // <--- вот это добавь!
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.backgroundStart,
              theme.backgroundEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
    }


    return child;
  }

  Widget buildNormalSlot(BuildContext context, SectionSlot slot,
      {int? index, required bool isTablet}) {
    final heights = getAdaptiveSectionHeights(context);

    final height = heights[slot.type] ?? 60;
    return Container(
      color: index == null
          ? Colors.transparent
          : Colors.red.withOpacity(0.07 * (index + 1)),
      child: SizedBox(
        height: height,
        child: _buildSection(
            context, slot.type, editMode: false, isTablet: isTablet),
      ),
    );
  }

  Widget _buildEditModeFreeLayout(BuildContext context, {bool isTablet = false}) {
    final app = Provider.of<AppModel>(context);
    final theme = app.themeColors;
    final slots = app.sectionSlots.where((s) => s.active).toList();
    final sidePadding = isTablet ? 40.0 : 0.0;
    final maxContentWidth = isTablet ? 950.0 : double.infinity;
    final drawerWidth = isTablet ? 90.0 : 60.0;
    const bool editMode = true;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenH = constraints.maxHeight;
              return Stack(
                children: [
                  // DragTarget на всю рабочую зону!
                  DragTarget<PlayerSection>(
                    onWillAccept: (data) => true,
                    onAcceptWithDetails: (details) {
                      final app = Provider.of<AppModel>(context, listen: false);
                      final box = context.findRenderObject() as RenderBox;
                      final localOffset = box.globalToLocal(details.offset);

                      final dropDy = localOffset.dy;
                      final section = details.data;
                      final sectionHeights = getAdaptiveSectionHeights(context);
                      final height = sectionHeights[section] ?? 80.0;
                      final minY = 0.0;
                      final maxY = constraints.maxHeight;
                      final slots = app.sectionSlots.where((s) => s.active).toList();

                      // Временный slot для расчёта snapY
                      final tempSlot = SectionSlot(
                        id: section == PlayerSection.gradientDivider
                            ? 'gradientDivider_${DateTime.now().millisecondsSinceEpoch}_${UniqueKey()}'
                            : section.toString(),
                        type: section,
                        active: true,
                        positionY: dropDy,
                      );

                      final heights = getAdaptiveSectionHeights(context);

                      final snapDistanceNear = getSectionSnapNear(section, app.isTablet);
                      final snapDistanceOverlap = getSectionSnapOverlap(section, app.isTablet);

                      final y = applySnapY(
                        desiredY: dropDy,
                        height: height,
                        movingSlot: tempSlot,
                        slots: slots,
                        heights: heights,
                        minY: minY,
                        maxY: maxY,
                        snapDistanceNear: snapDistanceNear,
                        snapDistanceOverlap: snapDistanceOverlap,
                      );

                      if (section == PlayerSection.gradientDivider) {
                        app.sectionSlots.add(
                          SectionSlot(
                            id: 'gradientDivider_${DateTime.now().millisecondsSinceEpoch}_${UniqueKey()}',
                            type: PlayerSection.gradientDivider,
                            active: true,
                            positionY: y,
                          ),
                        );
                        app.saveSectionSlots(app.sectionSlots);
                        app.notifyListeners();
                      } else {
                        final slot = app.sectionSlots.cast<SectionSlot?>().firstWhere(
                              (s) => s?.type == section,
                          orElse: () => null,
                        );
                        if (slot != null) {
                          app.restoreSection(slot.id, y);
                        }
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Stack(
                        children: [
                          ...slots.map((slot) {
                            final section = slot.type;
                            final sectionHeights = getAdaptiveSectionHeights(context);
                            final baseHeight = sectionHeights[section] ?? 80.0;
                            final height = baseHeight;
                            return Positioned(
                              key: ValueKey('section_${slot.id}'),
                              left: 0,
                              right: 0,
                              top: slot.positionY,
                              height: height,
                              child: _MovableSection(
                                key: ValueKey('movable_${slot.id}'),
                                slot: slot,
                                height: height,
                                screenH: screenH,
                                onPositionChanged: (newY) {
                                  updateSectionPositionY(
                                      context, slot.id, newY, screenH);
                                },
                                onRemove: () {
                                  app.removeSectionById(slot.id);
                                },
                                child: _buildSection(
                                  context,
                                  section,
                                  editMode: true,
                                  isTablet: isTablet, // <=== вот так!
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNormalModeFreeLayout(BuildContext context,
      {bool isTablet = false}) {
    final app = Provider.of<AppModel>(context);
    final slots = app.sectionSlots.where((s) => s.active).toList();
    final sidePadding = isTablet ? 40.0 : 0.0;
    final maxContentWidth = isTablet ? 950.0 : double.infinity;
    final adsDisabled = context
        .watch<PurchaseModel>()
        .adsDisabled;

    // Используем ConstrainedBox и Padding для универсальности
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          child: Stack(
            children: [
              ...slots.map((slot) {
                final section = slot.type;
                // Увеличиваем высоту секций только на планшете!
                final sectionHeights = getAdaptiveSectionHeights(context);
                final height = sectionHeights[section] ?? 80.0;


                return Positioned(
                  key: ValueKey('section_${slot.id}'),
                  left: 0,
                  right: 0,
                  top: slot.positionY,
                  // чуть больше расстояния между секциями на планшете
                  height: height,
                  child: _buildSection(
                    context,
                    section,
                    editMode: false,
                    isTablet: isTablet, // ⬅️ прокинь внутрь секции, чтобы увеличить элементы внутри
                  ),
                );
              }),
              if (!adsDisabled)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: MyBannerAdWidget(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildWidgetDrawer(BuildContext context, AppModel app,
      {required bool isTablet}) {
    final theme = app.themeColors;

    final unusedSections = app.sectionSlots
        .where((s) => !s.active && s.type != PlayerSection.gradientDivider)
        .map((s) => s.type)
        .toList();

    const double drawerWidth = 60.0;
    const double iconHeight = 36.0;
    const double iconPadding = 4.0;
    const double totalIconHeight = iconHeight + iconPadding * 2;
    const double resetIconSize = 40.0;
    const double drawerHeight = 500.0; // фиксированная высота ящика
    final sectionHeights = getAdaptiveSectionHeights(context);

    final double screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: drawerWidth,
        height: drawerHeight,
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: theme.backgroundStart.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Секции
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                radius: const Radius.circular(12),
                thickness: 4,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final section in unusedSections)
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: iconPadding),
                        child: Draggable<PlayerSection>(
                          data: section,
                          feedback: Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: screenWidth, // ⬅️ 100% ширина
                              height: sectionHeights[section] ?? 80.0,
                              child: _buildSection(
                                  context, section, editMode: true,
                                  isTablet: isTablet),

                            ),
                          ),
                          child: SizedBox(
                            height: totalIconHeight,
                            child: Center(
                              child: Icon(
                                getSectionIcon(section),
                                size: iconHeight,
                                color: theme.controlElements.color,
                              ),
                            ),
                          ),
                          childWhenDragging: SizedBox(
                            height: totalIconHeight, // 👈 одинаково с child
                          ),
                        ),
                      ),

                    // Разделитель (GradientDivider)
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: iconPadding),
                      child: Draggable<PlayerSection>(
                        data: PlayerSection.gradientDivider,
                        feedback: Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            width: screenWidth,
                            height:

                            sectionHeights[PlayerSection.gradientDivider] ??
                                16.0,
                            child: GradientDivider(),
                          ),
                        ),
                        child: SizedBox(
                          height: totalIconHeight,
                          child: Center(
                            child: Icon(
                              Icons.horizontal_rule,
                              size: iconHeight,
                              color: theme.controlElements.color,
                            ),
                          ),
                        ),
                        childWhenDragging: SizedBox(height: totalIconHeight),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Кнопка сброса
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, top: 10),
              child: GestureDetector(
                onTap: () {
                  app.sectionSlots = app.getDefaultSectionSlots();
                  app.saveSectionSlots(app.sectionSlots);
                  app.notifyListeners();
                },
                child: Center(
                  child: Icon(
                    Icons.settings_backup_restore,
                    size: resetIconSize,
                    color: theme.playlistDeleteButton.color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child,
      AxisDirection axisDirection) {
    return child; // убираем эффекты прокрутки
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const NeverScrollableScrollPhysics(); // 🔒 полностью отключаем прокрутку
  }
}

class _DraggableVerticalSection extends StatefulWidget {
  final SectionSlot slot;
  final double slotHeight;
  final List<SectionSlot> slots;
  final Map<PlayerSection, double> heights;
  final double minY;
  final double maxY;
  final ValueChanged<double> onPositionChanged;
  final Widget child;

  const _DraggableVerticalSection({
    super.key,
    required this.slot,
    required this.slotHeight,
    required this.slots,
    required this.heights,
    required this.minY,
    required this.maxY,
    required this.onPositionChanged,
    required this.child,
  });

  @override
  State<_DraggableVerticalSection> createState() =>
      _DraggableVerticalSectionState();
}

class _DraggableVerticalSectionState extends State<_DraggableVerticalSection> {
  late double dragStartY;
  late double dragOriginY;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        dragOriginY = widget.slot.positionY;
        dragStartY = details.globalPosition.dy;
      },
      onPanUpdate: (details) {
        final dy = details.globalPosition.dy - dragStartY;
        final newY = (dragOriginY + dy)
            .clamp(widget.minY, widget.maxY - widget.slotHeight);
        widget.onPositionChanged(newY);
      },
      child: Material(
        elevation: 8,
        child: widget.child,
      ),
    );
  }
}

class _MovableSection extends StatefulWidget {
  final SectionSlot slot;
  final double height;
  final double screenH;
  final Widget child;
  final ValueChanged<double> onPositionChanged;
  final VoidCallback onRemove;

  const _MovableSection({
    Key? key,
    required this.slot,
    required this.height,
    required this.screenH,
    required this.child,
    required this.onPositionChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<_MovableSection> createState() => _MovableSectionState();
}

class _MovableSectionState extends State<_MovableSection> {
  double? dragStartY;
  double? slotStartY;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppModel>(context, listen: false).themeColors;
    final app = Provider.of<AppModel>(context, listen: false);

    return GestureDetector(
      onPanStart: (details) {
        dragStartY = details.globalPosition.dy;
        slotStartY = widget.slot.positionY;
      },
      onPanUpdate: (details) {
        final dragDelta = details.globalPosition.dy - (dragStartY ?? 0);
        double desiredY = (slotStartY ?? 0) + dragDelta;
        final minY = 0.0;
        final maxY = widget.screenH;

        final sectionSlots = app.sectionSlots.where((s) => s.active).toList();
        final sectionHeights = getAdaptiveSectionHeights(context);

        final sectionType = widget.slot.type;

        final snappedY = applySnapY(
          desiredY: desiredY,
          height: widget.height,
          movingSlot: widget.slot,
          slots: sectionSlots,
          heights: sectionHeights,
          minY: minY,
          maxY: maxY,
          snapDistanceNear: 5.0,
          snapDistanceOverlap: 5.0,
        );


        widget.onPositionChanged(snappedY);
      },
      child: Stack(
        children: [
          widget.child,
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: widget.onRemove,
                child: Icon(Icons.delete,
                    size: 26, color: theme.playlistDeleteButton.color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
