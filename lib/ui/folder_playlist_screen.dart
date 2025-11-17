import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_model.dart';
import '../models/audio_to_levels_model.dart';
import '../models/purchase_model.dart';
import '../models/playlist_model.dart';
import '../widgets/themed_list_container.dart';
import '../widgets/folder_path_display.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/progress_slider.dart';
import '../widgets/playback_standard.dart';
import '../widgets/playback_extended.dart';
import '../widgets/playback_precise.dart';
import '../widgets/playback_time.dart';
import '../widgets/track_title.dart';
import '../widgets/file_info_dialog.dart';
import '../enums/enums.dart';
import 'dart:convert';
import '../widgets/my_banner_ad_widget.dart';
import '../../l10n/app_localizations.dart';
import '../main.dart'; // путь до main, где объявлен currentAppRoute
import '../utils/saf.dart'; // Это твой платформенный класс для работы с SAF
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:collection/collection.dart';
import 'dart:async';
import '../widgets/bread_crumbs_bar.dart';
import 'dart:io';

final List<String> _audioExtensions = [
  '.mp3',
  '.wav',
  '.flac',
  '.aac',
  '.m4a',
  '.ogg',
  '.opus',
  '.wma',
];

class FolderEntry {
  final String uriOrPath; // SAF URI для файла/папки
  final String name;
  final bool isDirectory;
  final bool isSaf;

  FolderEntry({
    required this.uriOrPath,
    required this.name,
    required this.isDirectory,
    required this.isSaf,
  });
}

class CachedFolderData {
  final List<CachedEntry> entries;
  final Map<String, int> durationsMs;
  final DateTime cachedAt;

  CachedFolderData({
    required this.entries,
    required this.durationsMs,
    required this.cachedAt,
  });
}

class CachedEntry {
  final String uri;
  final String name;
  final bool isDirectory;

  CachedEntry({
    required this.uri,
    required this.name,
    required this.isDirectory,
  });
}

class FolderPlaylistScreen extends StatefulWidget {
  final PlaylistModel audioState;
  final void Function(int index) onTrackSelected;

  const FolderPlaylistScreen({
    super.key,
    required this.audioState,
    required this.onTrackSelected,
  });

  @override
  State<FolderPlaylistScreen> createState() => _FolderPlaylistScreenState();
}

class _FolderPlaylistScreenState extends State<FolderPlaylistScreen>
    with WidgetsBindingObserver {
  List<FolderEntry> currentEntries = [];
  String? currentPath; // SAF URI выбранной папки
  String? rootPath; // SAF URI корневой папки
  bool _isLoadingDirectory = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  double? _bannerHeight;

  late final ValueNotifier<int?> _currentIndexVN;

  List<SafPathEntry> safPathStack = [];

  final Map<String, Timer> _durationTimers = {};
  final Set<String> _durationsLoading = {};

  Timer? _afterScrollTimer;
  Timer? _scrollEndTimer;
  bool _isScrolling = false;

  void _onScroll() {
    _isScrolling = true;
    // Перезапускаем таймер: если пользователь скроллит — сбрасываем его
    _scrollEndTimer?.cancel();
    _scrollEndTimer = Timer(const Duration(milliseconds: 200), () {
      // Через 100 мс после последнего скролла — считаем что скролл завершён
      _isScrolling = false;
      setState(() {}); // Обновляем интерфейс, можно прогружать длительности
      _loadVisibleDurations(); // твоя логика загрузки длительностей видимых строк
    });
  }

  List<FolderEntry> get filteredEntries => _searchQuery.isEmpty
      ? currentEntries
      : currentEntries
            .where(
              (e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

  void _loadVisibleDurations() {
    if (_isScrolling) return;

    final visible = _calculateVisibleIndices();
    final appModel = context.read<AppModel>();
    final entries = filteredEntries; // <--- используем именно filteredEntries!

    final toLoad = <FolderEntry>[];
    for (final index in visible) {
      if (index < 0 || index >= entries.length) continue;
      final entry = entries[index];
      final isAudioFile = !entry.isDirectory && _isAudio(entry.name);

      if (isAudioFile &&
          appModel.getAudioDurationFor(entry.uriOrPath) == null &&
          !_durationsLoading.contains(entry.uriOrPath)) {
        _durationsLoading.add(entry.uriOrPath);
        toLoad.add(entry);
      }
    }

    if (toLoad.isEmpty) return;

    Future.wait(
      toLoad.map((entry) async {
        try {
          final ms = await SAF.getAudioDuration(entry.uriOrPath);
          if (ms != null) {
            appModel.setAudioDurationFor(entry.uriOrPath, ms);
          }
        } catch (e) {
          print('[ERROR] _loadVisibleDurations: $e');
        } finally {
          _durationsLoading.remove(entry.uriOrPath);
        }
      }),
    ).then((_) async {
      if (mounted) setState(() {});

      // Обновляем кэш по полной версии папки (по currentEntries, не filteredEntries!)
      if (currentPath != null) {
        final durationsMs = <String, int>{};
        for (final e in currentEntries) {
          final v = appModel.audioDurationsCache[e.uriOrPath];
          if (v != null) durationsMs[e.uriOrPath] = v;
        }
        await saveFolderCache(currentPath!, currentEntries, durationsMs);
        print(
          '[CACHE][UPDATE] Обновлён кэш длительностей (batch=${toLoad.length})',
        );
      }
    });
  }

  List<int> _calculateVisibleIndices() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !_scrollController.hasClients) return [];

    final double itemHeight = 65.0; // Твоя стандартная высота строки
    final double scrollOffset = _scrollController.offset;
    final double viewportHeight = renderBox.size.height;

    int firstIndex = (scrollOffset / itemHeight).floor();
    int lastIndex = ((scrollOffset + viewportHeight) / itemHeight).ceil();
    // Добавим небольшой запас (например, по 1 строке сверху и снизу)
    final entriesLength = filteredEntries.length; // <------ ВАЖНО!
    firstIndex = (firstIndex - 1).clamp(0, entriesLength - 1);
    lastIndex = (lastIndex + 1).clamp(0, entriesLength - 1);
    if (lastIndex < firstIndex) return [];
    return List.generate(lastIndex - firstIndex + 1, (i) => firstIndex + i);
  }

  double adaptiveSize(bool isTablet, double phone, [double? tablet]) =>
      isTablet ? (tablet ?? phone * 1.4) : phone;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkFolderChanges();
    }
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);
    _currentIndexVN = context.read<AppModel>().currentIndexVN;

    // Автопрокрутка после смены трека/индекса
    _currentIndexVN.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentTrack();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appModel = context.read<AppModel>();
      final prefs = await SharedPreferences.getInstance();
      var savedRoot = prefs.getString('last_folder_playlist_root');
      final stackJson = prefs.getString('last_folder_playlist_stack');

      print('\n==============================');
      print('[INIT] FolderPlaylistScreen START');
      print('[INIT] savedRoot=$savedRoot');
      print('[INIT] currentPlaylistSource=${appModel.currentPlaylistSource}');
      print('[INIT] currentTrackPath=${appModel.currentTrackPath}');
      print('==============================\n');

      // === ДОБАВЛЕННЫЙ БЛОК ===
      // Фиксим ошибочно сохранённый root-путь с "/document/"
      if (savedRoot != null && savedRoot.contains('/document/')) {
        final idx = savedRoot.indexOf('/tree/');
        final idxDoc = savedRoot.indexOf('/document/');
        if (idx != -1 && idxDoc > idx) {
          savedRoot = savedRoot.substring(0, idxDoc);
          print('[INIT][FIX] Исправлен savedRoot: $savedRoot');
        }
      }

      if (savedRoot != null) {
        rootPath = normalizeTreeUri(savedRoot);
        rootFolderName = getSafFolderName(savedRoot);
        print(
          '[INIT][PATH] rootPath=$rootPath, rootFolderName=$rootFolderName',
        );

        // Восстанавливаем стек путей
        if (stackJson != null) {
          try {
            final list = (jsonDecode(stackJson) as List);
            safPathStack = list
                .map(
                  (e) => SafPathEntry(e['uri'] as String, e['name'] as String),
                )
                .toList();
            print(
              '[INIT][STACK] safPathStack восстановлен: ${safPathStack.map((e) => e.name).join(" / ")}',
            );
          } catch (e) {
            print('[INIT][STACK][ERROR] Ошибка парсинга stackJson: $e');
          }
        } else {
          print('[INIT][STACK] stackJson отсутствует (null)');
        }

        bool autoOpened = false;

        // 1. Пробуем открыть по текущему треку
        setState(() => _isLoadingDirectory = true);
        try {
          autoOpened = await _autoOpenPlayingFolder();
          if (autoOpened) {
            print(
              '[INIT][AUTO] ✅ Подпапка открыта по currentTrackPath, корень пропускаем.',
            );
          }
        } catch (e, st) {
          print(
            '[INIT][AUTO][ERROR] ❌ Ошибка при автооткрытии подпапки: $e\n$st',
          );
        }
        if (mounted) setState(() => _isLoadingDirectory = false);

        // 2. Если не удалось — пробуем открыть по сохранённому последнему треку
        if (!autoOpened) {
          final lastTrack = await loadLastFolderTrack();
          final lastTrackPath = lastTrack?['path'];
          if (lastTrackPath != null && lastTrackPath.startsWith('content://')) {
            setState(() => _isLoadingDirectory = true);
            try {
              autoOpened = await _autoOpenFolderForSavedTrack(lastTrackPath);
              if (autoOpened) {
                print(
                  '[INIT][AUTO] ✅ Подпапка открыта по last_folder_track_path.',
                );
              }
            } catch (e, st) {
              print(
                '[INIT][AUTO][ERROR] ❌ Ошибка при автооткрытии по last_folder_track_path: $e\n$st',
              );
            }
            if (mounted) setState(() => _isLoadingDirectory = false);
          }
        }

        // 3. Если всё равно не удалось — просто открываем root
        if (!autoOpened) {
          print('[INIT][AUTO] ▶️ Открываем root SAF: $rootPath');
          if (rootPath != null &&
              (safPathStack.isEmpty || safPathStack.last.uri != rootPath)) {
            safPathStack.add(SafPathEntry(rootPath!, rootFolderName ?? 'Root'));
            await saveLastSafPathStack(safPathStack);
            print('[INIT][STACK] Added root to safPathStack: $rootPath');
          }

          currentPath = rootPath!;
          final folderName = getSafFolderName(currentPath!);

          if (!mounted) return;
          setState(() => _isLoadingDirectory = true);

          try {
            await _loadSafDirectory(
              currentPath!,
              folderNameFromTap: folderName,
              source: 'AUTO',
            );
            print('[INIT][DONE] ✅ _loadSafDirectory завершён успешно (root)');
          } catch (e, st) {
            print(
              '[INIT][ERROR] ❌ Ошибка при вызове _loadSafDirectory: $e\n$st',
            );
          } finally {
            if (mounted) setState(() => _isLoadingDirectory = false);
          }
        }

        print('==============================\n');
      } else {
        print(
          '[INIT][AUTO] ⚠️ Корневая папка не найдена, открываем выбор вручную.',
        );
        if (!mounted) return;
        try {
          await _pickFolder();
        } catch (e, st) {
          print('[INIT][ERROR] ❌ Ошибка при _pickFolder(): $e\n$st');
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVisibleDurations();
    });
  }

  Future<bool> _autoOpenPlayingFolder() async {
    final appModel = context.read<AppModel>();
    final trackUri = appModel.currentTrackPath;
    final playlistSource =
        appModel.currentPlaylistSource; // Обнови название, если другое

    if (playlistSource == PlaylistSource.folder) {
      // Папочный плейлист: открываем подпапку, где играет трек
      if (trackUri == null || !trackUri.startsWith('content://')) {
        print('[AUTO_OPEN] ❌ Нет активного трека или он не SAF.');
        return false;
      }

      if (rootPath == null) {
        print(
          '[AUTO_OPEN] ❌ rootPath отсутствует, невозможно открыть подпапку.',
        );
        return false;
      }

      print('[AUTO_OPEN] ▶️ Пытаемся определить подпапку для трека: $trackUri');
      print('[AUTO_OPEN] rootPath=$rootPath');

      // Извлекаем относительный путь трека относительно root
      final relativePath = getRelativeSubPath(rootPath!, trackUri);
      if (relativePath == null || relativePath.isEmpty) {
        print('[AUTO_OPEN] ℹ️ Трек в корне, ничего не делаем.');
        return false;
      }

      final segments = relativePath.split('/');
      if (segments.length <= 1) {
        print('[AUTO_OPEN] ℹ️ Трек без подпапок: $relativePath');
        return false;
      }

      // Собираем путь к последней подпапке перед файлом
      final subPath = segments.sublist(0, segments.length - 1).join('/');
      final subfolderUri = buildSafSubfolderUri(rootPath!, subPath);

      print('[AUTO_OPEN] 🔹 Найден путь к подпапке: $subPath');
      print('[AUTO_OPEN] 🔹 SAF URI подпапки: $subfolderUri');

      try {
        await _loadSafDirectory(
          subfolderUri,
          folderNameFromTap: segments[segments.length - 2],
          source: 'AUTO_OPEN',
        );
        print('[AUTO_OPEN] ✅ Подпапка успешно открыта: ${segments.last}');
        return true;
      } catch (e, st) {
        print('[AUTO_OPEN] ❌ Ошибка при открытии подпапки: $e\n$st');
        return false;
      }
    } else {
      // Ручной плейлист: открываем last_folder_playlist_current (или root)
      final lastCurrent = await readLastSafCurrentPath();
      final toOpen = lastCurrent ?? rootPath;
      if (toOpen == null) {
        print('[AUTO_OPEN] ❌ Нет сохранённого SAF-пути для ручного плейлиста.');
        return false;
      }

      final folderName = getSafFolderName(toOpen);

      print(
        '[AUTO_OPEN] ▶️ Открываем сохранённую подпапку для ручного плейлиста: $toOpen',
      );

      try {
        await _loadSafDirectory(
          toOpen,
          folderNameFromTap: folderName,
          source: 'AUTO_OPEN_MANUAL',
        );
        print('[AUTO_OPEN] ✅ Сохранённая подпапка открыта.');
        return true;
      } catch (e, st) {
        print(
          '[AUTO_OPEN] ❌ Ошибка при открытии сохранённой подпапки: $e\n$st',
        );
        return false;
      }
    }
  }

  Future<void> saveLastFolderTrack(String path, int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_folder_track_path', path);
    await prefs.setInt('last_folder_track_index', index);
  }

  Future<Map<String, dynamic>?> loadLastFolderTrack() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('last_folder_track_path');
    final index = prefs.getInt('last_folder_track_index');
    if (path != null && index != null) {
      return {'path': path, 'index': index};
    }
    return null;
  }

  /// Автоматически открывает подпапку текущего трека, если возможно.
  Future<bool> _autoOpenFolderForSavedTrack(String trackUri) async {
    if (trackUri == null || !trackUri.startsWith('content://')) {
      print('[AUTO_OPEN_SAVED] ❌ Нет трека или он не SAF.');
      return false;
    }

    if (rootPath == null) {
      print(
        '[AUTO_OPEN_SAVED] ❌ rootPath отсутствует, невозможно открыть подпапку.',
      );
      return false;
    }

    print(
      '[AUTO_OPEN_SAVED] ▶️ Пытаемся определить подпапку для трека: $trackUri',
    );
    print('[AUTO_OPEN_SAVED] rootPath=$rootPath');

    // Извлекаем относительный путь трека относительно root
    final relativePath = getRelativeSubPath(rootPath!, trackUri);
    if (relativePath == null || relativePath.isEmpty) {
      print('[AUTO_OPEN_SAVED] ℹ️ Трек в корне, ничего не делаем.');
      return false;
    }

    final segments = relativePath.split('/');
    if (segments.length <= 1) {
      print('[AUTO_OPEN_SAVED] ℹ️ Трек без подпапок: $relativePath');
      return false;
    }

    // Собираем путь к последней подпапке перед файлом
    final subPath = segments.sublist(0, segments.length - 1).join('/');
    final subfolderUri = buildSafSubfolderUri(rootPath!, subPath);

    print('[AUTO_OPEN_SAVED] 🔹 Найден путь к подпапке: $subPath');
    print('[AUTO_OPEN_SAVED] 🔹 SAF URI подпапки: $subfolderUri');

    try {
      await _loadSafDirectory(
        subfolderUri,
        folderNameFromTap: segments[segments.length - 2],
        source: 'AUTO_OPEN_SAVED',
      );
      print('[AUTO_OPEN_SAVED] ✅ Подпапка успешно открыта: ${segments.last}');
      return true;
    } catch (e, st) {
      print('[AUTO_OPEN_SAVED] ❌ Ошибка при открытии подпапки: $e\n$st');
      return false;
    }
  }

  /// Получить SAF-document-URI подпапки относительно root
  String buildSafDocumentUriFromTree(String treeUri, String subfolderTreeUri) {
    final prefix = 'content://com.android.externalstorage.documents/tree/';
    if (!treeUri.startsWith(prefix) || !subfolderTreeUri.startsWith(prefix))
      return treeUri;
    final rootId = Uri.decodeComponent(treeUri.substring(prefix.length));
    final subId = Uri.decodeComponent(
      subfolderTreeUri.substring(prefix.length),
    );
    if (rootId == subId) return treeUri; // Корень
    if (!subId.startsWith('$rootId/')) return treeUri; // Не вложено
    final subPath = subId.substring(rootId.length + 1); // всё после первого /
    final fullDocId = '$rootId/$subPath';
    final encoded = Uri.encodeComponent(fullDocId);
    return 'content://com.android.externalstorage.documents/tree/${Uri.encodeComponent(rootId)}/document/$encoded';
  }

  /// Построение корректного SAF URI для подпапки внутри root.
  /// Возвращает document-путь, а не новое дерево (tree),
  /// чтобы не требовалось отдельное разрешение.
  String buildSafSubfolderUri(String rootUri, String subPath) {
    // Пример:
    // rootUri = content://com.android.externalstorage.documents/tree/0000-0000%3AMusic
    // subPath = Сталкер или Music/Сталкер
    final encodedSubPath = Uri.encodeComponent(subPath);
    final match = RegExp(r'tree/([^/]+)').firstMatch(rootUri);
    final baseId = match != null ? match.group(1) : null;

    if (baseId == null) {
      print(
        '[UTIL][buildSafSubfolderUri] ❌ Не удалось извлечь baseId из $rootUri',
      );
      return rootUri;
    }

    // SAF ожидает формат document/<baseId>%2F<subPath>
    final result =
        'content://com.android.externalstorage.documents/tree/$baseId/document/$baseId%2F$encodedSubPath';

    print(
      '[UTIL][buildSafSubfolderUri] root=$rootUri → sub=$subPath → $result',
    );
    return result;
  }

  // Получить относительный путь подпапки внутри root
  String? getRelativeSubPath(String rootTreeUri, String? subfolderUri) {
    if (subfolderUri == null) return null;
    final prefix = 'content://com.android.externalstorage.documents/tree/';
    if (!rootTreeUri.startsWith(prefix) || !subfolderUri.startsWith(prefix))
      return null;
    final rootId = Uri.decodeComponent(rootTreeUri.substring(prefix.length));
    if (subfolderUri.contains('/document/')) {
      final parts = subfolderUri.split('/document/');
      if (parts.length == 2) {
        final docId = Uri.decodeComponent(parts[1]);
        if (docId.startsWith('$rootId/')) {
          return docId.substring(rootId.length + 1);
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    _currentIndexVN.removeListener(_scrollToCurrentTrack);
    _scrollController.dispose();
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    // Очищаем таймеры подгрузки длительности
    for (final timer in _durationTimers.values) {
      timer.cancel();
    }
    _durationTimers.clear();

    super.dispose();
  }

  Future<void> _checkFolderChanges() async {
    if (currentPath == null) return;

    // 1. Получаем новый и старый списки файлов
    final freshEntriesData = await SAF.getDirectoryContent(currentPath!);
    final freshUris = freshEntriesData.map((e) => e['uri'] as String).toSet();
    final oldUris = currentEntries.map((e) => e.uriOrPath).toSet();

    final removed = oldUris.difference(freshUris);
    final added = freshUris.difference(oldUris);

    // 2. Если что-то изменилось — обновляем список и кэш, перезагружаем папку
    if (removed.isNotEmpty || added.isNotEmpty) {
      // Удаляем отсутствующие файлы из currentEntries
      if (removed.isNotEmpty) {
        setState(() {
          currentEntries.removeWhere((e) => removed.contains(e.uriOrPath));
        });
      }

      // Добавляем новые файлы (если появились)
      if (added.isNotEmpty) {
        final newEntries = freshEntriesData
            .map(
              (map) => FolderEntry(
                uriOrPath: map['uri'] as String,
                name: map['name'] as String,
                isDirectory: map['isDirectory'] as bool,
                isSaf: true,
              ),
            )
            .toList();

        newEntries.sort((a, b) {
          if (a.isDirectory != b.isDirectory) return b.isDirectory ? 1 : -1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

        setState(() {
          currentEntries = newEntries;
        });
      }

      // Обновляем кэш
      final app = context.read<AppModel>();
      final durationsMs = <String, int>{};
      for (final entry in currentEntries) {
        final v = app.audioDurationsCache[entry.uriOrPath];
        if (v != null) durationsMs[entry.uriOrPath] = v;
      }
      await saveFolderCache(currentPath!, currentEntries, durationsMs);

      // Перезагружаем папку (и показываем снеки — если это реализовано внутри _loadSafDirectory)
      await _loadSafDirectory(currentPath!, source: 'CHECK_CHANGES');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVisibleDurations();
    });
  }

  Future<Map<String, dynamic>?> loadFolderCache(String folderUri) async {
    var box = await Hive.openBox('folderCache');
    final data = box.get(folderUri);
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  Future<void> saveLastSafPathStack(List<SafPathEntry> stack) async {
    final prefs = await SharedPreferences.getInstance();
    final list = stack.map((e) => {'uri': e.uri, 'name': e.name}).toList();
    await prefs.setString('last_folder_playlist_stack', jsonEncode(list));
  }

  Future<void> saveFolderCache(
    String folderUri,
    List<FolderEntry> entries,
    Map<String, int> durationsMs,
  ) async {
    var box = await Hive.openBox('folderCache');
    box.put(folderUri, {
      'entries': entries
          .map(
            (e) => {
              'uri': e.uriOrPath,
              'name': e.name,
              'isDirectory': e.isDirectory,
            },
          )
          .toList(),
      'durationsMs': durationsMs,
      'cachedAt': DateTime.now().toIso8601String(),
    });
  }

  String getParentSafTreeUri(String uri) {
    final parts = uri.split('%2F');
    if (parts.length <= 1) return uri;
    parts.removeLast();
    return parts.join('%2F');
  }

  void _scrollToCurrentTrack() {
    if (!mounted) return;
    final app = context.read<AppModel>();
    if (app.currentPlaylistSource != PlaylistSource.folder) return;

    final filteredEntries = _searchQuery.isEmpty
        ? currentEntries
        : currentEntries
              .where(
                (entity) => entity.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();

    final currentTrackPath = app.currentTrackPath;
    if (currentTrackPath == null || !_scrollController.hasClients) return;

    int targetIndex = filteredEntries.indexWhere(
      (f) => f.uriOrPath == currentTrackPath,
    );
    int listViewIndex = targetIndex + 1; // +1 для ".."

    // --- ЛОГИ ---
    print('\n==== SCROLL DEBUG (FolderPlaylistScreen) ====');
    print('currentTrackPath: $currentTrackPath');
    print('filteredEntries.length: ${filteredEntries.length}');
    for (var i = 0; i < filteredEntries.length; i++) {
      final e = filteredEntries[i];
      final isCurrent = e.uriOrPath == currentTrackPath;
      print(
        '  [$i] ${e.name} | ${e.uriOrPath}' +
            (isCurrent ? '   <--- CURRENT' : ''),
      );
      // --- Новый лог совпадения по endsWith ---
      if (!isCurrent && e.uriOrPath.endsWith(currentTrackPath)) {
        print('    (endsWith match)');
      }
    }
    print('targetIndex: $targetIndex');
    print('listViewIndex: $listViewIndex');
    print('currentEntries.length: ${currentEntries.length}');
    print(
      'currentEntries (names): ${currentEntries.map((e) => e.name).join(", ")}',
    );
    print('scrollController.hasClients: ${_scrollController.hasClients}');
    print('============================================\n');
    // --- КОНЕЦ ЛОГОВ ---

    if (targetIndex == -1) {
      print('⚠️ Текущий трек не найден в filteredEntries!');
      return;
    }

    // Можно сделать адаптацию для планшета, если нужно:
    // final double rowHeight = adaptiveSize(app.isTablet, 65.0, 80.0);
    // final double offsetRows = app.isTablet ? 1.7 : 2.0;
    const double rowHeight = 65.0;
    const double offsetRows = 2.0;

    double scrollTo = rowHeight * (listViewIndex - offsetRows);
    scrollTo = scrollTo.clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(
      scrollTo,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  String? rootFolderName;

  String getSafFolderName(String uri) {
    final decoded = Uri.decodeComponent(uri);

    // 🔹 Убираем всё до "primary:" или "XXXX-XXXX:" (идентификатор тома)
    final cut = decoded
        .replaceAll(RegExp(r'.*primary:'), '')
        .replaceAll(RegExp(r'.*[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}:'), '')
        .replaceAll(RegExp(r'.*document/'), '');

    // 🔹 Теперь берём последний сегмент после '/'
    final clean = cut.split('/').where((s) => s.isNotEmpty).lastOrNull;

    // 🔹 Если ничего не нашли — fallback
    return clean ?? 'storage';
  }

  String normalizeTreeUri(String uri) {
    if (uri.contains('/document/')) {
      final parts = uri.split('/document/');
      final base = parts.first; // content://.../tree/0000-0000%3ALanguages
      final afterDoc = parts.last.split('%3A').last; // Languages%2FCD4
      return '$base%2F$afterDoc'; // content://.../tree/0000-0000%3ALanguages%2FCD4
    }
    return uri;
  }

  Future<void> _pickFolder() async {
    final pickedUri = await SAF.openDocumentTree();
    if (pickedUri == null) return;

    try {
      await SAF.persistPermissions(pickedUri);
    } catch (e) {
      print('[SAF] ❌ persistPermissions failed: $e');
    }

    // Оставляем только tree-URI (корень, без document/...)
    String treeUri = pickedUri;
    if (treeUri.contains('/document/')) {
      treeUri = treeUri.split('/document/').first;
    }
    final normalizedUri = normalizeTreeUri(treeUri);
    final rootName = getSafFolderName(normalizedUri);

    rootPath = normalizedUri;
    rootFolderName = rootName;
    currentPath = normalizedUri;

    safPathStack.clear();
    safPathStack.add(SafPathEntry(normalizedUri, rootName));

    await saveLastSafFolderUri(normalizedUri); // сохраняем корень папки
    await saveLastSafPathStack(safPathStack);

    // Сохраняем также last_folder_playlist_current для логики автоматического открытия
    await saveLastSafCurrentPath(normalizedUri);

    await _loadSafDirectory(normalizedUri, folderNameFromTap: rootName);
  }

  Future<void> saveLastSafFolderUri(String uri) async {
    final prefs = await SharedPreferences.getInstance();
    // Сохраняем только "tree" (корневой) URI!
    final rootUri = normalizeTreeUri(uri);
    await prefs.setString('last_folder_playlist_root', rootUri);
  }

  Future<void> saveLastSafCurrentPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_folder_playlist_current', path);
  }

  Future<String?> readLastSafCurrentPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_folder_playlist_current');
  }

  Future<bool> hasPermissionOrAncestor(String targetUri) async {
    final List<String> persistedUris = await SAF.getPersistedUriPermissions();
    // Проверяем не только точное совпадение, но и доступ к родительской папке
    return persistedUris.any(
      (persistedUri) => targetUri.startsWith(persistedUri),
    );
  }

  Future<void> _loadSafDirectory(
    String uri, {
    String? folderNameFromTap,
    String source = 'AUTO', // 🟢 различение источников вызова
  }) async {
    print('\n==============================');
    print('[LOAD][$source] ▶️ Вызов _loadSafDirectory');
    print('[LOAD][$source] uri=$uri');
    print('[LOAD][$source] folderNameFromTap=$folderNameFromTap');
    print('[LOAD][$source] currentPath (до)=$currentPath');
    print('[LOAD][$source] rootPath=$rootPath');
    print(
      '[LOAD][$source] safPathStack: ${safPathStack.map((e) => e.name).join(" / ")}',
    );
    print('------------------------------');

    final appModel = context.read<AppModel>();
    final normalizedUri = normalizeTreeUri(uri);
    print('[LOAD][$source][STEP] normalizedUri=$normalizedUri');

    // 🧩 Проверяем разрешения перед загрузкой
    bool hasPerm = false;
    try {
      hasPerm = await SAF.checkUriPermission(uri);
      print('[LOAD][$source][PERM] 🔍 checkUriPermission=$hasPerm');
    } catch (e, st) {
      print('[LOAD][$source][ERROR] checkUriPermission threw: $e\n$st');
    }

    // Если нет разрешения — пробуем восстановить
    if (!hasPerm) {
      print('[LOAD][$source][PERM] ⚠️ Нет разрешения! Пробуем восстановить...');
      try {
        await SAF.persistPermissions(uri);
        print('[LOAD][$source][PERM] 🔄 persistPermissions() вызван');
      } catch (e, st) {
        print('[LOAD][$source][ERROR] persistPermissions failed: $e\n$st');
      }

      try {
        hasPerm = await SAF.checkUriPermission(uri);
        print(
          '[LOAD][$source][PERM] 🔁 checkUriPermission повторно → $hasPerm',
        );
      } catch (e, st) {
        print(
          '[LOAD][$source][ERROR] checkUriPermission (повтор) threw: $e\n$st',
        );
      }
    }

    // 🟢 Пробуем загрузить из кэша
    print('[LOAD][$source][CACHE] 🔍 Проверяем наличие кэша...');
    Map<String, dynamic>? cached;
    try {
      cached = await loadFolderCache(uri);
    } catch (e, st) {
      print('[LOAD][$source][ERROR] loadFolderCache threw: $e\n$st');
    }

    if (cached != null &&
        cached['entries'] != null &&
        cached['durationsMs'] != null) {
      print('[LOAD][$source][CACHE] ✅ Кэш найден для $uri');

      List<FolderEntry> entries = [];
      try {
        entries = (cached['entries'] as List)
            .map(
              (map) => FolderEntry(
                uriOrPath: map['uri'],
                name: map['name'],
                isDirectory: map['isDirectory'],
                isSaf: true,
              ),
            )
            .toList();

        entries.sort((a, b) {
          if (a.isDirectory != b.isDirectory) return b.isDirectory ? 1 : -1;
          return compareNatural(a.name.toLowerCase(), b.name.toLowerCase());
        });
      } catch (e, st) {
        print('[LOAD][$source][ERROR] parsing cached entries: $e\n$st');
      }

      // 🟢 Восстанавливаем длительности из кэша
      try {
        final durations = cached['durationsMs'] as Map;
        durations.forEach((k, v) {
          appModel.audioDurationsCache[k as String] = v as int;
        });
        print(
          '[LOAD][$source][CACHE] 🔹 Восстановлено ${durations.length} длительностей',
        );
      } catch (e, st) {
        print(
          '[LOAD][$source][CACHE][ERROR] Не удалось восстановить durationsMs: $e\n$st',
        );
      }

      final audioPaths = entries
          .where((e) => !e.isDirectory && _isAudio(e.name))
          .map((e) => e.uriOrPath)
          .toList();

      if (!mounted) return;
      setState(() {
        currentPath = uri;
        _currentFolderName = folderNameFromTap ?? getSafFolderName(uri);
        currentEntries = entries;
        _isLoadingDirectory = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadVisibleDurations(); // ← Важно! Подгружаем длительности для видимых
      });

      print(
        '[LOAD][$source][CACHE] 🔹 Папка загружена из кэша: $_currentFolderName',
      );
      print(
        '[LOAD][$source][CACHE] Файлов: ${entries.length}, аудио: ${audioPaths.length}',
      );

      if (currentEntries.isEmpty && rootPath != null && uri != rootPath) {
        print(
          '[LOAD][$source][CACHE][FALLBACK] ❗ Папка пуста, возврат к root!',
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(_loadSafDirectory(rootPath!, source: '$source-FALLBACK'));
        });
        return;
      }

      if (audioPaths.isNotEmpty) {
        await saveLastSafCurrentPath(uri);
        print(
          '[LOAD][$source][CACHE] 💾 Сохранён last_folder_playlist_current=$uri',
        );
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print(
            '[LOAD][$source][POSTFRAME] 🔁 double postFrame → _scrollToCurrentTrack() [CACHED]',
          );
          _scrollToCurrentTrack();
        });
      });

      print('[LOAD][$source][CACHE] ✅ Завершено (кэш)');
      print('==============================\n');
      return;
    }

    // 🔄 Если кэша нет — подгружаем через SAF
    print(
      '[LOAD][$source][SAF] ⚙️ Кэш не найден, запрашиваем SAF.getDirectoryContent...',
    );
    if (!mounted) return;
    setState(() => _isLoadingDirectory = true);

    await Future.delayed(const Duration(milliseconds: 20));

    List<Map<String, dynamic>> entriesData = [];
    try {
      final start = DateTime.now();
      entriesData = await SAF.getDirectoryContent(uri);
      final durationMs = DateTime.now().difference(start).inMilliseconds;
      print(
        '[LOAD][$source][SAF] SAF.getDirectoryContent DONE за ${durationMs} мс. Count: ${entriesData.length}',
      );
    } catch (e, st) {
      print('[LOAD][$source][ERROR] SAF.getDirectoryContent threw: $e\n$st');
    }

    final entries = entriesData
        .map(
          (map) => FolderEntry(
            uriOrPath: map['uri'] as String,
            name: map['name'] as String,
            isDirectory: map['isDirectory'] as bool,
            isSaf: true,
          ),
        )
        .where((e) => e.isDirectory || _isAudio(e.name))
        .toList();

    entries.sort((a, b) {
      if (a.isDirectory != b.isDirectory) return b.isDirectory ? 1 : -1;
      return compareNatural(a.name.toLowerCase(), b.name.toLowerCase());
    });

    final folderName = folderNameFromTap ?? getSafFolderName(uri);
    final audioPaths = entries
        .where((e) => !e.isDirectory && _isAudio(e.name))
        .map((e) => e.uriOrPath)
        .toList();

    if (!mounted) return;
    setState(() {
      currentPath = uri;
      _currentFolderName = folderName;
      currentEntries = entries;
      _isLoadingDirectory = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVisibleDurations(); // ← Важно! Подгружаем длительности для видимых
    });

    print('[LOAD][$source][SAF] 📁 Папка загружена через SAF: $folderName');
    print(
      '[LOAD][$source][SAF] Файлов: ${entries.length}, аудио: ${audioPaths.length}',
    );
    print('[LOAD][$source][SAF] currentPath (после setState)=$currentPath');

    if (currentEntries.isEmpty && rootPath != null && uri != rootPath) {
      print('[LOAD][$source][SAF][FALLBACK] ❗ Папка пуста, возврат к root!');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_loadSafDirectory(rootPath!, source: '$source-FALLBACK'));
      });
      return;
    }

    if (audioPaths.isNotEmpty) {
      await saveLastSafCurrentPath(uri);
      print(
        '[LOAD][$source][SAF] 💾 Сохранён last_folder_playlist_current=$uri',
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print(
          '[LOAD][$source][POSTFRAME] 🔁 double postFrame → _scrollToCurrentTrack() [SAF]',
        );
        _scrollToCurrentTrack();
      });
    });

    // Сохраняем кэш сразу после загрузки списка
    final durationsMs = <String, int>{};
    for (final entry in entries) {
      final v = appModel.audioDurationsCache[entry.uriOrPath];
      if (v != null) durationsMs[entry.uriOrPath] = v;
    }
    await saveFolderCache(uri, entries, durationsMs);

    if (source != 'PLAYING_TRACK') {
      await saveLastSafCurrentPath(uri);
    }
  }

  bool _isAudio(String path) {
    final lower = path.toLowerCase();
    return _audioExtensions.any((ext) => lower.endsWith(ext));
  }

  List<FileSystemEntity> filterAudioFiles(List<FileSystemEntity> allFiles) {
    return allFiles
        .where((entity) => entity is File && _isAudio(entity.path))
        .toList();
  }

  List<String> filterAudioPaths(List<String> paths) {
    return paths.where(_isAudio).toList();
  }

  String? _currentFolderName;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final adsDisabled = context.watch<PurchaseModel>().adsDisabled;
    final themedText = app.themeColors.currentValueText;
    final theme = app.themeColors;

    final ix = app.currentIndex;
    final playingPath =
        (ix != null && ix >= 0 && ix < app.currentPlaylist.length)
        ? app.currentPlaylist[ix]
        : null;

    final filteredEntries = _searchQuery.isEmpty
        ? currentEntries
        : currentEntries
              .where(
                (entity) => entity.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();

    final showAds = !adsDisabled;

    final currentTrackPath = app.currentTrackPath;
    final isCurrentTrackVisible = filteredEntries.any(
      (e) => e.uriOrPath == currentTrackPath,
    );

    app.updateSystemUi(theme);

    return WillPopScope(
      onWillPop: () async {
        lastRouteForAnimation = currentAppRoute.value;
        navigatorKey.currentState?.pushReplacementNamed('/home');
        return false; // всегда отменяем pop, делаем только переход на /home
      },

      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: showAds ? (_bannerHeight ?? 0) : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                    child: BreadCrumbsBar(
                      safPathStack: safPathStack,
                      currentPath: currentPath,
                      currentFolderName: _currentFolderName,
                      textColor: themedText.color,
                      shadowEnabled: themedText.shadowEnabled,
                      shadowColor: themedText.shadowColor,
                      shadowBlur: themedText.shadowBlur,
                      onSegmentTap: (index, uri) async {
                        setState(() {
                          if (uri == '..') {
                            safPathStack.clear();
                            _currentFolderName = null;
                            _pickFolder();
                          } else {
                            safPathStack = safPathStack.sublist(0, index);
                            _currentFolderName = safPathStack.isNotEmpty
                                ? safPathStack.last.name
                                : getSafFolderName(uri);
                            _loadSafDirectory(uri);
                          }
                        });
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _isLoadingDirectory
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.hourglass_empty,
                                    size: 52,
                                    color: themedText.color.withOpacity(0.30),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    AppLocalizations.of(context)!.pleaseWait,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: themedText.color.withOpacity(0.65),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RawScrollbar(
                              controller: _scrollController,
                              thumbVisibility: true,
                              interactive: true,
                              thickness: 8,
                              radius: const Radius.circular(4),
                              thumbColor: theme.controlElements.color,
                              child: ThemedListContainer(
                                itemCount: filteredEntries.length + 1,

                                separatorBuilder: (_, __) =>
                                    const SizedBox.shrink(),
                                scrollController: _scrollController,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    final isAtRoot =
                                        (rootPath != null &&
                                        currentPath == rootPath);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: SizedBox(
                                        height: 36,
                                        // такая же высота, как у остальных строк
                                        child: Stack(
                                          children: [
                                            GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              // Для "строки .." (вверх по папке или выбор новой папки)
                                              onTap: () async {
                                                if (rootPath == null ||
                                                    currentPath == rootPath) {
                                                  safPathStack.clear();
                                                  await saveLastSafPathStack(
                                                    safPathStack,
                                                  );
                                                  // ВАЖНО! Сохраняем rootPath как текущий путь, если в корне
                                                  if (rootPath != null) {
                                                    await saveLastSafCurrentPath(
                                                      rootPath!,
                                                    );
                                                  }
                                                  await _pickFolder();
                                                } else if (safPathStack
                                                    .isNotEmpty) {
                                                  final parentEntry =
                                                      safPathStack.removeLast();
                                                  await saveLastSafPathStack(
                                                    safPathStack,
                                                  );
                                                  await saveLastSafCurrentPath(
                                                    parentEntry.uri,
                                                  ); // ВАЖНО! Сохраняй путь при возврате
                                                  await _loadSafDirectory(
                                                    parentEntry.uri,
                                                  );
                                                } else {
                                                  await saveLastSafPathStack(
                                                    safPathStack,
                                                  );
                                                  if (rootPath != null) {
                                                    await saveLastSafCurrentPath(
                                                      rootPath!,
                                                    );
                                                  }
                                                  await _pickFolder();
                                                }
                                              },

                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                    ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 4,
                                                            right: 8,
                                                          ),
                                                      child: Icon(
                                                        Icons.arrow_upward,
                                                        color: themedText.color,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        '..',
                                                        style: TextStyle(
                                                          color:
                                                              themedText.color,
                                                          fontSize: 14,
                                                          shadows:
                                                              themedText
                                                                  .shadowEnabled
                                                              ? [
                                                                  Shadow(
                                                                    color: themedText
                                                                        .shadowColor,
                                                                    blurRadius:
                                                                        themedText
                                                                            .shadowBlur,
                                                                    offset:
                                                                        const Offset(
                                                                          0,
                                                                          2,
                                                                        ),
                                                                  ),
                                                                ]
                                                              : null,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Линия-разделитель снизу — если она нужна как у треков
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                height: 1,
                                                color: theme
                                                    .controlElements
                                                    .color
                                                    .withOpacity(0.4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  final entry = filteredEntries[index - 1];
                                  final name = entry.name;
                                  final allAudioFiles = currentEntries
                                      .where(
                                        (e) =>
                                            !e.isDirectory && _isAudio(e.name),
                                      )
                                      .toList();
                                  final originalIndex = allAudioFiles
                                      .indexWhere(
                                        (e) => e.uriOrPath == entry.uriOrPath,
                                      );

                                  // Папки
                                  if (entry.isDirectory) {
                                    return ListTile(
                                      visualDensity: const VisualDensity(
                                        vertical: -4,
                                      ),
                                      leading: Icon(
                                        Icons.folder,
                                        color: theme.controlElements.color,
                                      ),
                                      title: Text(
                                        entry.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: themedText.color,
                                          shadows: themedText.shadowEnabled
                                              ? [
                                                  Shadow(
                                                    color:
                                                        themedText.shadowColor,
                                                    blurRadius:
                                                        themedText.shadowBlur,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                      ),
                                      onTap: () async {
                                        if (_isLoadingDirectory) {
                                          print(
                                            '[MANUAL] ⚠️ Пропуск: уже идёт загрузка директории',
                                          );
                                          return;
                                        }
                                        if (!entry.isDirectory) {
                                          print(
                                            '[MANUAL] ⚠️ Пропуск: ${entry.name} не является директорией',
                                          );
                                          return;
                                        }

                                        print(
                                          '\n==============================',
                                        );
                                        print(
                                          '[MANUAL] ▶️ Пользователь нажал на папку: "${entry.name}"',
                                        );
                                        print(
                                          '[MANUAL] URI: ${entry.uriOrPath}',
                                        );
                                        print(
                                          '[MANUAL] currentPath (до перехода): $currentPath',
                                        );
                                        print(
                                          '[MANUAL] safPathStack (до): ${safPathStack.map((e) => e.name).join(" / ")}',
                                        );
                                        print('==============================');

                                        // 🧩 1. Добавляем текущую папку в стек (если это не корень)
                                        if (currentPath != null &&
                                            currentPath != entry.uriOrPath &&
                                            (safPathStack.isEmpty ||
                                                safPathStack.last.uri !=
                                                    currentPath)) {
                                          safPathStack.add(
                                            SafPathEntry(
                                              currentPath!,
                                              _currentFolderName ??
                                                  getSafFolderName(
                                                    currentPath!,
                                                  ),
                                            ),
                                          );
                                          await saveLastSafPathStack(
                                            safPathStack,
                                          );
                                          print(
                                            '[MANUAL] ➕ Добавлено в safPathStack: $currentPath',
                                          );
                                        } else {
                                          print(
                                            '[MANUAL] ℹ️ Не добавляем текущий путь в стек (уже есть или корень)',
                                          );
                                        }

                                        // 🕐 2. Помечаем загрузку
                                        setState(
                                          () => _isLoadingDirectory = true,
                                        );
                                        print(
                                          '[MANUAL] ⏳ Начата загрузка подпапки...',
                                        );

                                        // 🧭 3. Загружаем содержимое подпапки
                                        await _loadSafDirectory(
                                          entry.uriOrPath,
                                          folderNameFromTap: entry.name,
                                        );
                                        print(
                                          '[MANUAL] ✅ Завершена загрузка подпапки: ${entry.name}',
                                        );
                                        print(
                                          '[MANUAL] currentPath (после загрузки): $currentPath',
                                        );
                                        print(
                                          '[MANUAL] safPathStack (после): ${safPathStack.map((e) => e.name).join(" / ")}',
                                        );

                                        // ⏹ 4. Сбрасываем флаг загрузки
                                        setState(
                                          () => _isLoadingDirectory = false,
                                        );
                                        print(
                                          '[MANUAL] 🟢 _isLoadingDirectory сброшен',
                                        );
                                        print(
                                          '==============================\n',
                                        );
                                      },
                                    );
                                  }

                                  // Для аудиофайлов (используй функцию _isAudio(entry.name))
                                  if (!_isAudio(entry.name))
                                    return const SizedBox.shrink();

                                  final isPlaying =
                                      app.currentPlaylistSource ==
                                          PlaylistSource.folder &&
                                      entry.uriOrPath == currentTrackPath;

                                  // Автоматическая подгрузка длительности, если её нет
                                  final appModel = context.read<AppModel>();
                                  final durationMs = appModel
                                      .getAudioDurationFor(entry.uriOrPath);
                                  final isAudioFile =
                                      !entry.isDirectory &&
                                      _isAudio(entry.name);

                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () async {
                                      final appModel = context.read<AppModel>();
                                      final allAudioFiles = currentEntries
                                          .where(
                                            (e) =>
                                                !e.isDirectory &&
                                                _isAudio(e.name),
                                          )
                                          .toList();
                                      final audioPaths = allAudioFiles
                                          .map((e) => e.uriOrPath)
                                          .toList();
                                      final indexToPlay = audioPaths.indexOf(
                                        entry.uriOrPath,
                                      );

                                      final playlistUnchanged =
                                          appModel.currentPlaylistSource ==
                                              PlaylistSource.folder &&
                                          appModel.currentPlaylist.length ==
                                              audioPaths.length &&
                                          ListEquality().equals(
                                            appModel.currentPlaylist,
                                            audioPaths,
                                          );

                                      if (!playlistUnchanged) {
                                        appModel.setCurrentPlaylistSource(
                                          PlaylistSource.folder,
                                        );
                                        appModel.setFolderPlaylist(audioPaths);
                                        appModel
                                                .persistentState
                                                .lastUsedFolderPath =
                                            currentPath!;
                                        await appModel.persistentState.save();
                                        await appModel.playFolderTrack(
                                          indexToPlay,
                                          autoplay: true,
                                        );
                                      } else {
                                        // Только смена трека!
                                        await appModel.playbackModel
                                            .playTrackAt(
                                              indexToPlay,
                                              autoplay: true,
                                            );
                                      }
                                    },

                                    onLongPress: () async {
                                      final info = await SAF.getAudioMetadata(
                                        entry.uriOrPath,
                                      );
                                      if (info != null) {
                                        showFileInfoDialog(
                                          context,
                                          entry.uriOrPath,
                                          info,
                                        );
                                      }
                                    },
                                    child: SizedBox(
                                      height: 65,
                                      child: Stack(
                                        children: [
                                          Container(
                                            color: isPlaying
                                                ? theme.controlElements.color
                                                : Colors.transparent,
                                          ),

                                          // 🔹 Содержимое строки
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 4,
                                                        right: 8,
                                                      ),
                                                  child: Icon(
                                                    Icons.music_note,
                                                    size: 20,
                                                    color: isPlaying
                                                        ? theme
                                                              .buttonIconText
                                                              .color
                                                        : themedText.color,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    name.replaceAll(
                                                      RegExp(r'\s+\.'),
                                                      '.',
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: isPlaying
                                                          ? theme
                                                                .buttonIconText
                                                                .color
                                                          : themedText.color,
                                                      shadows: isPlaying
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
                                                          : (themedText
                                                                    .shadowEnabled
                                                                ? [
                                                                    Shadow(
                                                                      color: themedText
                                                                          .shadowColor,
                                                                      blurRadius:
                                                                          themedText
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
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    softWrap: true,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    if (originalIndex != -1)
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 3,
                                                              vertical: 0,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: isPlaying
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
                                                            color: isPlaying
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
                                                        (() {
                                                          final ms = context
                                                              .read<AppModel>()
                                                              .getAudioDurationFor(
                                                                entry.uriOrPath,
                                                              );
                                                          if (ms == null)
                                                            return '--:--';
                                                          final d = Duration(
                                                            milliseconds: ms,
                                                          );
                                                          final withHours =
                                                              d.inHours > 0;
                                                          String twoDigits(
                                                            int n,
                                                          ) => n
                                                              .toString()
                                                              .padLeft(2, '0');
                                                          return [
                                                            if (withHours)
                                                              twoDigits(
                                                                d.inHours,
                                                              ),
                                                            twoDigits(
                                                              d.inMinutes % 60,
                                                            ),
                                                            twoDigits(
                                                              d.inSeconds % 60,
                                                            ),
                                                          ].join(':');
                                                        })(),

                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          color: isPlaying
                                                              ? theme
                                                                    .buttonIconText
                                                                    .color
                                                              : themedText
                                                                    .color,
                                                          shadows: isPlaying
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
                                                                          offset: const Offset(
                                                                            0,
                                                                            1,
                                                                          ),
                                                                        ),
                                                                      ]
                                                                    : null)
                                                              : (themedText
                                                                        .shadowEnabled
                                                                    ? [
                                                                        Shadow(
                                                                          color:
                                                                              themedText.shadowColor,
                                                                          blurRadius:
                                                                              themedText.shadowBlur,
                                                                          offset: const Offset(
                                                                            0,
                                                                            1,
                                                                          ),
                                                                        ),
                                                                      ]
                                                                    : null),
                                                        ),
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 2,
                                                          ),
                                                      child: Text(
                                                        entry.name
                                                            .split('.')
                                                            .last
                                                            .toLowerCase(),
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          color: isPlaying
                                                              ? theme
                                                                    .buttonIconText
                                                                    .color
                                                              : themedText
                                                                    .color,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 12),
                                              ],
                                            ),
                                          ),

                                          // 🔸 Нижняя линия — часть этой строки
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: const TrackTitle(),
                      ),
                    ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            // ---- Баннер рекламы (если нужно) ----
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
