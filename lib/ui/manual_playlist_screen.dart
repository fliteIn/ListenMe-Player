import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import '../models/audio_to_levels_model.dart';
import '../utils/temp_audio_files_utils.dart';
import '../utils/global_keys.dart';
import '../models/playlist_model.dart';
import '../widgets/open_files_button.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/progress_slider.dart';
import '../widgets/playback_standard.dart';
import '../widgets/playback_extended.dart';
import '../widgets/playback_precise.dart';
import '../widgets/playback_time.dart';
import '../widgets/track_title.dart';
import '../widgets/icon_with_shadow.dart';
import '../widgets/themed_list_container.dart';
import '../widgets/file_info_dialog.dart';
import '../enums/enums.dart';
import 'add_files_to_playlist_screen.dart';
import '../main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/my_banner_ad_widget.dart';
import 'package:reorderables/reorderables.dart';
import '../../l10n/app_localizations.dart';
import '../models/purchase_model.dart';
import '../utils/temp_audio_files_utils.dart';
import '../utils/saf.dart';
import 'dart:async';
import '../../l10n/app_localizations.dart';

class PlaylistScreen extends StatefulWidget {
  final PlaylistModel audioState;
  final void Function(int index) onTrackSelected;
  final Future<void> Function(String deletedPath)? onTrackDeleted;

  const PlaylistScreen({
    super.key,
    required this.audioState,
    required this.onTrackSelected,
    this.onTrackDeleted,
  });

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen>
    with WidgetsBindingObserver {
  late final ValueNotifier<int?> _currentIndexVN;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final ScrollController _scrollController = ScrollController();

  int? _lastScrollTarget;
  double? _bannerHeight;

  Timer? _scrollEndTimer;

  List<ManualTrackEntry> get filteredEntries {
    final playlistModel = context.read<PlaylistModel>();
    if (_searchQuery == null || _searchQuery.isEmpty) {
      return playlistModel.manualPlaylist;
    }
    return playlistModel.manualPlaylist
        .where(
          (entry) =>
              entry.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  double adaptiveSize(bool isTablet, double phone, [double? tablet]) =>
      isTablet ? (tablet ?? phone * 1.4) : phone;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _currentIndexVN = context.read<AppModel>().currentIndexVN;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentIndexVN.addListener(_scrollToCurrentTrack);
      _scrollToCurrentTrack();
      _cleanupMissingTracksIfManual();

      _loadVisibleDurations();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _currentIndexVN.removeListener(_scrollToCurrentTrack); // <--- исправлено!
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Ловим события жизненного цикла приложения
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cleanupMissingTracksIfManual();
    }
  }

  // Метод для автоматической очистки несуществующих файлов из плейлиста
  Future<void> _cleanupMissingTracksIfManual() async {
    print('[cleanupMissingTracksIfManual] Вызвано');
    final app = context.read<AppModel>();
    final playlistModel = context.read<PlaylistModel>();
    final loc = AppLocalizations.of(context)!;

    // Только если находимся в ручном плейлисте!
    print(
      '[cleanupMissingTracksIfManual] app.currentPlaylistSource = ${app.currentPlaylistSource}',
    );
    if (app.currentPlaylistSource == PlaylistSource.manual) {
      final removedCount = await playlistModel.removeMissingTracks();
      print(
        '[cleanupMissingTracksIfManual] removeMissingTracks вернул: $removedCount',
      );
      if (removedCount > 0 && mounted) {
        print(
          '[cleanupMissingTracksIfManual] Показываю SnackBar о том, что треки удалены',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.playlistRemovedTracks(removedCount))),
        );
        setState(() {});
      } else {
        print('[cleanupMissingTracksIfManual] Нет удалённых треков');
      }
    } else {
      print(
        '[cleanupMissingTracksIfManual] Не ручной плейлист, ничего не делаю',
      );
    }
  }

  void _loadVisibleDurations() {
    if (!_scrollController.hasClients) return;
    final appModel = context.read<AppModel>();
    final entries = filteredEntries;
    final double itemHeight = 65.0;
    final double scrollOffset = _scrollController.offset;
    final double viewportHeight = _scrollController.position.viewportDimension;

    int firstIndex = (scrollOffset / itemHeight).floor();
    int lastIndex = ((scrollOffset + viewportHeight) / itemHeight).ceil();

    firstIndex = firstIndex.clamp(0, entries.length - 1);
    lastIndex = lastIndex.clamp(0, entries.length - 1);

    for (int i = firstIndex; i <= lastIndex; i++) {
      final track = entries[i];
      if (appModel.getAudioDurationFor(track.uri) == null) {
        SAF.getAudioDuration(track.uri).then((ms) {
          if (ms != null) {
            appModel.setAudioDurationFor(track.uri, ms);
          }
        });
      }
    }
  }



  void _onScroll() {
    _scrollEndTimer?.cancel();
    _scrollEndTimer = Timer(const Duration(milliseconds: 200), () {
      _loadVisibleDurations();
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // ВАЖНО: УДАЛЯЕМ _maybeScrollToCurrent И ВСЕ АВТОСКРОЛЛЫ ИЗ ДРУГИХ МЕСТ!

  void _scrollToCurrentTrack() {
    if (!mounted) return;
    final app = context.read<AppModel>();
    final playlistModel = context.read<PlaylistModel>();

    // --- Блокировка: только если активен ручной плейлист ---
    if (app.currentPlaylistSource != PlaylistSource.manual) return;

    final currentIndex = app.currentIndexVN.value;
    if (currentIndex == null || !_scrollController.hasClients) return;

    final filteredEntries = _searchQuery.isEmpty
        ? playlistModel.manualPlaylist
        : playlistModel.manualPlaylist
              .where(
                (entry) => entry.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();

    String? currentPath =
        currentIndex >= 0 && currentIndex < playlistModel.manualPlaylist.length
        ? playlistModel.manualPlaylist[currentIndex].uri
        : null;
    final filteredIndex = currentPath != null
        ? filteredEntries.indexWhere((track) => track.uri == currentPath)
        : -1;

    if (filteredIndex != -1) {
      int scrollToIndex = (filteredIndex - 2).clamp(
        0,
        filteredEntries.length - 1,
      );
      if (_lastScrollTarget != scrollToIndex) {
        _lastScrollTarget = scrollToIndex;
        final double scrollTo = scrollToIndex * 65.0;
        _scrollController.animateTo(
          scrollTo.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final playlistModel = context.watch<PlaylistModel>();
    final adsDisabled = context.watch<PurchaseModel>().adsDisabled;
    final themedDelete = app.themeColors.playlistDeleteButton;

    const double buttonSize = 36;
    const double iconSize = 30;
    final theme = context.watch<AppModel>().themeColors;

    final showAds = !adsDisabled; // или свой флаг для рекламы

    app.updateSystemUi(theme);

    return WillPopScope(
      onWillPop: () async {
        lastRouteForAnimation = currentAppRoute.value;
        navigatorKey.currentState?.pushReplacementNamed('/home');
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ВЕСЬ основной контент — твой Column, только теперь с отступом снизу
            Padding(
              padding: EdgeInsets.only(
                bottom: showAds ? (_bannerHeight ?? 0.0) : 0.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //TopMenuBar(),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
                    child: SizedBox(
                      height: 40, // Поддерживает единый визуальный ритм
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: buttonSize,
                            height: buttonSize,
                            child: IconButton(
                              icon: IconWithShadow(
                                icon: Icons.folder_open,
                                size: iconSize,
                                color: app.themeColors.controlElements.color,
                                shadowColor:
                                    app.themeColors.controlElements.shadowColor,
                                shadowBlur:
                                    app.themeColors.controlElements.shadowBlur,
                                shadowEnabled: app
                                    .themeColors
                                    .controlElements
                                    .shadowEnabled,
                              ),
                              tooltip: 'Добавить из папки',
                              onPressed: () {
                                // Для анимации перехода — запомнить откуда переход
                                lastRouteForAnimation =
                                    ModalRoute.of(context)?.settings.name ??
                                    '/playlist';
                                Navigator.pushNamed(
                                  context,
                                  '/playlist/add_files',
                                );
                              },
                              splashRadius: buttonSize / 2,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: buttonSize,
                            height: buttonSize,
                            child: IconButton(
                              icon: IconWithShadow(
                                icon: Icons.delete_forever,
                                size: iconSize,
                                color:
                                    app.themeColors.playlistDeleteButton.color,
                                // ← Цвет из темы!
                                shadowColor: app
                                    .themeColors
                                    .playlistDeleteButton
                                    .shadowColor,
                                shadowBlur: app
                                    .themeColors
                                    .playlistDeleteButton
                                    .shadowBlur,
                                shadowEnabled: app
                                    .themeColors
                                    .playlistDeleteButton
                                    .shadowEnabled,
                              ),
                              tooltip: 'Очистить плейлист',
                              onPressed: () async {
                                final toDelete = List<ManualTrackEntry>.from(
                                  playlistModel.manualPlaylist,
                                );

                                // ОЧИСТИТЬ сам плейлист:
                                playlistModel.clearManualPlaylist();

                                // Очистить состояние аудиоплеера:
                                widget.audioState.clearManualPlaylist();

                                for (final track in toDelete) {
                                  if (widget.onTrackDeleted != null)
                                    await widget.onTrackDeleted!(track.uri);
                                }
                              },

                              splashRadius: buttonSize / 2,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      left: 8,
                      right: 8,
                      bottom: 0,
                    ),
                    child: CustomSearchBar(
                      controller: _searchController,
                      query: _searchQuery,
                      onChanged: (v) {
                        setState(() => _searchQuery = v);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _loadVisibleDurations();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Consumer2<AppModel, PlaylistModel>(
                      builder: (context, app, playlistModel, _) {
                        final theme = app.themeColors;
                        final textThemed = theme.currentValueText;
                        final currentIndex = app.currentIndex;
                        final filteredEntries = _searchQuery.isEmpty
                            ? playlistModel.manualPlaylist
                            : playlistModel.manualPlaylist
                                  .where(
                                    (entry) => entry.name
                                        .toLowerCase()
                                        .contains(_searchQuery.toLowerCase()),
                                  )
                                  .toList();

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.backgroundStart,
                              border: Border.all(
                                color: Colors.black.withOpacity(0.2),
                              ),
                            ),
                            child: RawScrollbar(
                              controller: _scrollController,
                              thumbVisibility: true,
                              interactive: true,
                              thumbColor: theme.controlElements.color,
                              thickness: 8,
                              radius: const Radius.circular(4),
                              child: ReorderableListView.builder(
                                scrollController: _scrollController,
                                buildDefaultDragHandles: false,
                                itemCount: filteredEntries.length,
                                onReorder: (oldIndex, newIndex) async {
                                  if (newIndex > oldIndex) newIndex -= 1;
                                  final oldPath = filteredEntries[oldIndex];
                                  final newPath = filteredEntries[newIndex];
                                  final oldOriginalIndex = playlistModel
                                      .manualPlaylist
                                      .indexWhere((t) => t.uri == oldPath.uri);
                                  final newOriginalIndex = playlistModel
                                      .manualPlaylist
                                      .indexWhere((t) => t.uri == newPath.uri);

                                  await widget.audioState.reorderTracks(
                                    oldOriginalIndex,
                                    newOriginalIndex,
                                  );
                                  setState(() {});
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    _loadVisibleDurations();
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final track = filteredEntries[index];
                                  final name = track.name;

                                  int instance = 0;
                                  for (int i = 0; i <= index; i++) {
                                    if (filteredEntries[i].uri == track.uri)
                                      instance++;
                                  }
                                  int seen = 0, originalIndex = -1;
                                  for (
                                    int i = 0;
                                    i < playlistModel.manualPlaylist.length;
                                    i++
                                  ) {
                                    if (playlistModel.manualPlaylist[i].uri ==
                                        track.uri) {
                                      seen++;
                                      if (seen == instance) {
                                        originalIndex = i;
                                        break;
                                      }
                                    }
                                  }

                                  final selected =
                                      app.currentPlaylistSource ==
                                          PlaylistSource.manual &&
                                      originalIndex == currentIndex;

                                  // 1. Получаем durationMs из глобального кэша AppModel
                                  final appModel = context.read<AppModel>();
                                  final durationMs = appModel
                                      .getAudioDurationFor(track.uri);

                                  // 2. Переводим в Duration
                                  final duration = durationMs != null
                                      ? Duration(milliseconds: durationMs)
                                      : null;

                                  return GestureDetector(
                                    key: ValueKey(
                                      'track_${originalIndex}_${track.uri}',
                                    ),
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () async {
                                      final appModel = context.read<AppModel>();
                                      appModel.setCurrentPlaylistSource(
                                        PlaylistSource.manual,
                                      );
                                      await appModel.playbackModel.playTrackAt(
                                        originalIndex,
                                        autoplay: true,
                                      );
                                    },
                                    onLongPress: () async {
                                      final info = await SAF.getAudioMetadata(
                                        track.uri,
                                      );
                                      if (info != null) {
                                        showFileInfoDialog(
                                          context,
                                          track.uri,
                                          info,
                                          fileName: track.name,
                                        );
                                      }
                                    },

                                    child: SizedBox(
                                      height: 65,
                                      child: Stack(
                                        children: [
                                          // Фон строки при выделении
                                          Container(
                                            color: selected
                                                ? theme.controlElements.color
                                                : Colors.transparent,
                                          ),
                                          // Содержимое строки
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // Drag handle
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 4,
                                                        right: 10,
                                                      ),
                                                  child: ReorderableDragStartListener(
                                                    index: index,
                                                    child: Icon(
                                                      Icons.drag_handle,
                                                      size: 20,
                                                      color: selected
                                                          ? theme
                                                                .buttonIconText
                                                                .color
                                                          : textThemed.color,
                                                    ),
                                                  ),
                                                ),
                                                // Название трека
                                                Expanded(
                                                  child: Text(
                                                    name.replaceAll(
                                                      RegExp(r'\s+\.'),
                                                      '.',
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: selected
                                                          ? theme
                                                                .buttonIconText
                                                                .color
                                                          : textThemed.color,
                                                      shadows: selected
                                                          ? (theme
                                                                    .buttonIconText
                                                                    .shadowEnabled
                                                                ? [
                                                                    Shadow(
                                                                      color: theme
                                                                          .buttonIconText
                                                                          .shadowColor,
                                                                      blurRadius: theme
                                                                          .buttonIconText
                                                                          .shadowBlur,
                                                                      offset:
                                                                          const Offset(
                                                                            0,
                                                                            2,
                                                                          ),
                                                                    ),
                                                                  ]
                                                                : null)
                                                          : (textThemed
                                                                    .shadowEnabled
                                                                ? [
                                                                    Shadow(
                                                                      color: textThemed
                                                                          .shadowColor,
                                                                      blurRadius:
                                                                          textThemed
                                                                              .shadowBlur,
                                                                      offset:
                                                                          const Offset(
                                                                            0,
                                                                            2,
                                                                          ),
                                                                    ),
                                                                  ]
                                                                : null),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                // Номер, длительность, расширение
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    if (originalIndex != -1)
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 3,
                                                              vertical: 0,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: selected
                                                              ? theme
                                                                    .buttonIconText
                                                                    .color
                                                              : theme
                                                                    .controlElements
                                                                    .color,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                2,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          '${originalIndex + 1}',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: selected
                                                                ? theme
                                                                      .controlElements
                                                                      .color
                                                                : theme
                                                                      .buttonIconText
                                                                      .color,
                                                          ),
                                                        ),
                                                      ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 2,
                                                          ),
                                                      child: Text(
                                                        duration != null
                                                            ? _formatDuration(
                                                                duration,
                                                              )
                                                            : '--:--',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          color: selected
                                                              ? theme
                                                                    .buttonIconText
                                                                    .color
                                                              : textThemed
                                                                    .color,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 2,
                                                          ),
                                                      child: Text(
                                                        track.name.contains('.')
                                                            ? track.name
                                                                  .split('.')
                                                                  .last
                                                                  .toLowerCase()
                                                            : '---',

                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          color: selected
                                                              ? theme
                                                                    .buttonIconText
                                                                    .color
                                                              : textThemed
                                                                    .color,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 12),
                                                // Кнопка удаления
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 8,
                                                      ),
                                                  child: GestureDetector(
                                                    behavior:
                                                        HitTestBehavior.opaque,
                                                    onTap: () async {
                                                      playlistModel.removeTrack(originalIndex);
                                                      setState(() {});
                                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                                        _loadVisibleDurations();
                                                      });
                                                    },


                                                    child: IconWithShadow(
                                                      icon: Icons.delete,
                                                      size: 24,
                                                      color: theme
                                                          .playlistDeleteButton
                                                          .color,
                                                      shadowColor: theme
                                                          .playlistDeleteButton
                                                          .shadowColor,
                                                      shadowBlur: theme
                                                          .playlistDeleteButton
                                                          .shadowBlur,
                                                      shadowEnabled: theme
                                                          .playlistDeleteButton
                                                          .shadowEnabled,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Нижний разделитель
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              height: 1,
                                              color: theme.controlElements.color
                                                  .withOpacity(0.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Consumer<AppModel>(
                    builder: (context, app, _) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: TrackTitle(),
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ValueListenableBuilder<Duration>(
                      valueListenable: app.positionVN,
                      builder: (context, position, _) {
                        return PlaybackTime(
                          position: position,
                          duration: app.duration ?? Duration.zero,
                          style: app.timeDisplayStyle,
                          secondaryTimeType: app.secondaryTimeType,
                          fontSize: adaptiveSize(app.isTablet, 14.0, 14.0),
                          height: adaptiveSize(app.isTablet, 20.0, 20.0),
                          sideButtonWidth: adaptiveSize(
                            app.isTablet,
                            58.0,
                            75.0,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: ValueListenableBuilder<Duration>(
                      valueListenable: app.positionVN,
                      builder: (context, value, _) {
                        return ProgressSlider(
                          position: value,
                          duration: app.duration,
                          markerA: app.markerA,
                          markerB: app.markerB,
                          showMarkers: app.showMarkers,
                          playBetweenMarkers: app.playBetweenMarkers,
                          onSeekStart: app.playbackModel.handleSeekStart,
                          onSeekEnd: app.playbackModel.handleSeekEnd,
                          onSeek: (d) => app.player.seek(d),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      MediaQuery.of(context).padding.bottom + 8, // ← вот магия!
                    ),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: app.isPlayingVN,
                      builder: (context, _, __) {
                        switch (app.playbackButtonStyle) {
                          case PlaybackButtonStyle.standard:
                            return PlaybackStandard(app: app);
                          case PlaybackButtonStyle.extended:
                            return PlaybackExtended(app: app);
                          case PlaybackButtonStyle.precise:
                            return PlaybackPrecise(app: app);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            // === Баннер рекламы в самом низу экрана ===
            if (showAds)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  child: MyBannerAdWidget(
                    onHeightChanged: (h) {
                      if (_bannerHeight != h) setState(() => _bannerHeight = h);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
