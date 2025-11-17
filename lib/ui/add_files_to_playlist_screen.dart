import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_model.dart';
import '../models/playlist_model.dart';
import '../widgets/icon_with_shadow.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/themed_list_container.dart';
import 'package:flutter/gestures.dart';
import '../utils/saf.dart';
import 'package:path/path.dart' as p;
import 'package:hive/hive.dart';
import '../widgets/bread_crumbs_bar.dart';
import '../widgets/file_info_dialog.dart';
import 'dart:async';
import '../../l10n/app_localizations.dart';
import '../main.dart';

class FolderEntry {
  final String uriOrPath;
  final String name;
  final bool isDirectory;
  final bool isSaf;

  FolderEntry({
    required this.uriOrPath,
    required this.name,
    required this.isDirectory,
    this.isSaf = true,
  });
}

class AddFilesToPlaylistScreen extends StatefulWidget {
  final String? initialPath;

  const AddFilesToPlaylistScreen({Key? key, this.initialPath})
    : super(key: key);

  @override
  State<AddFilesToPlaylistScreen> createState() =>
      _AddFilesToPlaylistScreenState();
}

class _AddFilesToPlaylistScreenState extends State<AddFilesToPlaylistScreen> {
  List<SafPathEntry> safPathStack = [];
  String? currentPath;
  String? _currentFolderName;

  List<String> selectedPaths = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String? rootPath;

  static const String _prefsKeyRoot = 'add_files_saf_root';
  static const String _prefsKeyPath = 'add_files_saf_path';

  final ScrollController _scrollController = ScrollController();

  final Map<String, Timer> _durationTimers = {};
  final Set<String> _durationsLoading = {};
  bool _isScrolling = false;
  Timer? _scrollEndTimer;

  List<FolderEntry> get filteredEntries => _searchQuery.isEmpty
      ? currentEntries
      : currentEntries
            .where(
              (e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    for (final timer in _durationTimers.values) {
      timer.cancel();
    }
    _durationTimers.clear();
    _scrollEndTimer?.cancel();
    super.dispose();
  }

  List<FolderEntry> currentEntries = [];

  bool _isLoadingDirectory = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVisibleDurations();
    });

    _initializeSaf();
  }

  void _onScroll() {
    _isScrolling = true;
    _scrollEndTimer?.cancel();
    _scrollEndTimer = Timer(const Duration(milliseconds: 200), () {
      _isScrolling = false;
      if (mounted) setState(() {});
      _loadVisibleDurations();
    });
  }

  List<int> _calculateVisibleIndices() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !_scrollController.hasClients) return [];

    const double itemHeight = 65.0;
    final double scrollOffset = _scrollController.offset;
    final double viewportHeight = renderBox.size.height;

    int firstIndex = (scrollOffset / itemHeight).floor();
    int lastIndex = ((scrollOffset + viewportHeight) / itemHeight).ceil();

    final entriesLength = filteredEntries.length;
    firstIndex = (firstIndex - 1).clamp(0, entriesLength - 1);
    lastIndex = (lastIndex + 1).clamp(0, entriesLength - 1);
    if (lastIndex < firstIndex) return [];
    return List.generate(lastIndex - firstIndex + 1, (i) => firstIndex + i);
  }

  void _loadVisibleDurations() {
    if (_isScrolling) return;

    final visible = _calculateVisibleIndices();
    final appModel = context.read<AppModel>();
    final entries = filteredEntries;

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
          debugPrint('[ERROR] _loadVisibleDurations: $e');
        } finally {
          _durationsLoading.remove(entry.uriOrPath);
        }
      }),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _initializeSaf() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRoot = prefs.getString(_prefsKeyRoot);
    final savedPath = prefs.getString(_prefsKeyPath);

    if (savedRoot != null) {
      rootPath = savedRoot;
      if (savedPath != null) {
        currentPath = savedPath;
        await _loadSafDirectory(savedPath); // открываем подпапку!
      } else {
        await _loadSafDirectory(savedRoot);
      }
    } else {
      await _pickSafFolder();
    }
  }

  Future<void> _saveLastVisitedPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyPath, path);
  }

  Future<void> _pickSafFolder() async {
    final pickedUri = await SAF.openDocumentTree();
    if (pickedUri == null) return;

    try {
      await SAF.persistPermissions(pickedUri);
    } catch (e) {
      debugPrint('[SAF] persistPermissions failed: $e');
    }

    // Сброс хлебных крошек и имени папки
    safPathStack.clear();
    _currentFolderName = null;

    rootPath = pickedUri;
    currentPath = pickedUri;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyRoot, pickedUri);

    // ✅ Добавляем сохранение последнего пути
    await _saveLastVisitedPath(pickedUri);

    await _loadSafDirectory(pickedUri);
  }

  Future<void> _loadSafDirectory(String uri) async {
    setState(() {
      _isLoadingDirectory = true;
      currentEntries = [];
    });

    // 1. Пробуем загрузить из кэша
    Map<String, dynamic>? cached;
    try {
      cached = await _loadFolderCache(uri);
    } catch (_) {}

    if (cached != null && cached['entries'] != null) {
      List<FolderEntry> entries = [];
      try {
        entries = (cached['entries'] as List)
            .map(
              (map) => FolderEntry(
                uriOrPath: map['uri'],
                name: map['name'],
                isDirectory: map['isDirectory'],
              ),
            )
            .toList();

        // сортировка: папки вверх, потом файлы по алфавиту
        entries.sort((a, b) {
          if (a.isDirectory != b.isDirectory) return b.isDirectory ? 1 : -1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      } catch (_) {}

      setState(() {
        currentEntries = entries;
        currentPath = uri;
        _isLoadingDirectory = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadVisibleDurations();
      });

      // ✅ сохраняем текущий путь даже при загрузке из кэша
      await _saveLastVisitedPath(uri);

      return;
    }

    // 2. Если кэша нет — грузим из SAF
    List<Map<String, dynamic>> entriesData = [];
    try {
      entriesData = await SAF.getDirectoryContent(uri);
    } catch (_) {}

    final entries = entriesData.map((e) {
      return FolderEntry(
        uriOrPath: e['uri'] as String,
        name: e['name'] as String,
        isDirectory: e['isDirectory'] as bool,
      );
    }).toList();

    entries.sort((a, b) {
      if (a.isDirectory != b.isDirectory) return b.isDirectory ? 1 : -1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    setState(() {
      currentEntries = entries;
      currentPath = uri;
      _isLoadingDirectory = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVisibleDurations();
    });

    // ✅ сохраняем путь каждый раз, когда загружается новая папка
    if (uri.isNotEmpty) {
      await _saveLastVisitedPath(uri);
    }

    // 4. Сохраняем кэш — не ждём!
    _saveFolderCache(uri, entries);
  }

  Future<void> _goUp() async {
    if (currentPath == null || rootPath == null) {
      await _pickSafFolder();
      return;
    }

    if (currentPath == rootPath) {
      await _pickSafFolder();
      return;
    }

    // Пробуем убрать последний сегмент из URI
    final uri = currentPath!;
    final lastIdx = uri.lastIndexOf('%2F');
    if (lastIdx != -1) {
      final parentUri = uri.substring(0, lastIdx);
      await _loadSafDirectory(parentUri);
    } else {
      await _pickSafFolder();
    }
  }

  bool _isAudio(String name) {
    final ext = p.extension(name).toLowerCase();
    return ['.mp3', '.wav', '.m4a', '.aac', '.flac', '.ogg'].contains(ext);
  }

  void _addSelectedFiles() async {
    print('[DEBUG] Кнопка "Добавить" нажата!');
    print('[DEBUG] selectedPaths: $selectedPaths');
    print('[DEBUG] currentEntries: ${currentEntries.length}');
    if (selectedPaths.isEmpty) {
      print('[DEBUG] selectedPaths пустой!');
      return;
    }

    final app = context.read<AppModel>();
    final appModel = app; // или context.read<AppModel>();
    final playlistModel = context.read<PlaylistModel>();
    final wasEmpty = playlistModel.manualPlaylist.isEmpty;

    Navigator.pop(context);

    // Преобразуем выбранные пути в ManualTrackEntry с уже определённой длительностью!
    final manualEntries = currentEntries
        .where((entry) => selectedPaths.contains(entry.uriOrPath))
        .map(
          (entry) => ManualTrackEntry(uri: entry.uriOrPath, name: entry.name),
        )
        .toList();

    print('[DEBUG] manualEntries: ${manualEntries.map((e) => e.uri).toList()}');
    print('[DEBUG] Вызываю addSafFiles с ${manualEntries.length} треками');
    await playlistModel.addSafFiles(manualEntries);
    /*
    if (wasEmpty && playlistModel.manualPlaylist.isNotEmpty) {
      await app.initializePlayer();
    }
  */
  }

  static const String _folderCacheBox = 'add_files_folder_cache';

  // Загрузи кэш из Hive (или SharedPreferences, если так удобнее)
  Future<Map<String, dynamic>?> _loadFolderCache(String folderUri) async {
    var box = await Hive.openBox(_folderCacheBox);
    final data = box.get(folderUri);
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  // Сохрани кэш (после получения длительностей и списка файлов)
  Future<void> _saveFolderCache(
    String folderUri,
    List<FolderEntry> entries,
    // Map<String, int> durationsMs,  <--- УБРАТЬ этот параметр!
  ) async {
    var box = await Hive.openBox(_folderCacheBox);
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
      // 'durationsMs': durationsMs,   <--- УБРАТЬ эту строку!
      'cachedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final theme = app.themeColors;
    final themedText = theme.currentValueText;
    final themedScrollThumb = theme.controlElements;
    final buttonSize = 54.0;
    final iconSize = 46.0;

    final audioEntries = filteredEntries
        .where((e) => !e.isDirectory && _isAudio(e.name))
        .toList();

    app.updateSystemUi(theme);

    return WillPopScope(
      onWillPop: () async {
        lastRouteForAnimation = currentAppRoute.value;
        navigatorKey.currentState?.pushReplacementNamed('/playlist');
        return false; // всегда отменяем pop, делаем только переход на /home
      },

      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Блок пути, как в папочном плейлисте
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
                  if (uri == '..') {
                    safPathStack.clear();
                    _currentFolderName = null;
                    await _pickSafFolder();
                  } else {
                    safPathStack = safPathStack.sublist(0, index);
                    _currentFolderName = safPathStack.isNotEmpty
                        ? safPathStack.last.name
                        : getSafFolderName(uri);

                    await _loadSafDirectory(uri);
                  }
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
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

            // Список файлов — окно как в папочном плейлисте
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
                          scrollController: _scrollController,
                          itemCount: filteredEntries.length + 1,
                          separatorBuilder: (context, index) {
                            if (index == 0) return const SizedBox.shrink();
                            final entity = filteredEntries[index - 1];
                            if (!entity.isDirectory && _isAudio(entity.name)) {
                              return Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey.withOpacity(0.18),
                                indent: 0,
                                endIndent: 0,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: SizedBox(
                                  height:
                                      36, // такая же высота, как у строк аудиофайлов
                                  child: Stack(
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () async {
                                          if (safPathStack.isNotEmpty) {
                                            // ⬅️ Есть предыдущая папка — поднимаемся вверх
                                            final prev = safPathStack
                                                .removeLast();
                                            _currentFolderName = prev.name;
                                            await _loadSafDirectory(prev.uri);
                                            await _saveLastVisitedPath(
                                              prev.uri,
                                            );
                                          } else {
                                            // ⬅️ Уже в корне
                                            safPathStack.clear();
                                            _currentFolderName = null;

                                            if (rootPath != null &&
                                                currentPath == rootPath) {
                                              // 🔄 Корень выбран — вызываем SAF для выбора новой папки
                                              await _pickSafFolder();
                                            } else if (rootPath != null) {
                                              // 🔁 Если почему-то путь сбился, возвращаемся в корень
                                              await _loadSafDirectory(
                                                rootPath!,
                                              );
                                              await _saveLastVisitedPath(
                                                rootPath!,
                                              );
                                            } else {
                                              // ❌ Корень не задан — вызываем SAF
                                              await _pickSafFolder();
                                            }
                                          }
                                        },

                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
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
                                                    color: themedText.color,
                                                    fontSize: 14,
                                                    shadows:
                                                        themedText.shadowEnabled
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
                                      // Нижняя линия-разделитель (как у файлов)
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
                            }

                            final entity = filteredEntries[index - 1];
                            final path = entity.uriOrPath;
                            final name = entity.name;
                            final audioIndex = audioEntries.indexWhere(
                              (e) => e.uriOrPath == entity.uriOrPath,
                            );
                            // Папки
                            if (entity.isDirectory) {
                              return ListTile(
                                visualDensity: const VisualDensity(
                                  vertical: -4,
                                ),
                                leading: Icon(
                                  Icons.folder,
                                  color: theme
                                      .controlElements
                                      .color, // цвет папок = цвет кнопок управления
                                ),
                                title: Text(
                                  entity.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: themedText
                                        .color, // цвет текста как у файлов
                                    shadows: themedText.shadowEnabled
                                        ? [
                                            Shadow(
                                              color: themedText.shadowColor,
                                              blurRadius: themedText.shadowBlur,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () async {
                                  if (currentPath != null &&
                                      currentPath != entity.uriOrPath) {
                                    safPathStack.add(
                                      SafPathEntry(
                                        currentPath!,
                                        _currentFolderName ??
                                            getSafFolderName(currentPath!),
                                      ),
                                    );
                                  }
                                  _currentFolderName = entity.name;

                                  setState(() {
                                    _isLoadingDirectory = true;
                                    currentEntries = [];
                                  });

                                  // дождёмся следующего кадра, чтобы UI успел показать "часики"
                                  await Future.delayed(
                                    const Duration(milliseconds: 50),
                                  );

                                  await _loadSafDirectory(entity.uriOrPath);
                                },
                              );
                            }
                            // Файлы (только аудио)
                            else if (!entity.isDirectory &&
                                _isAudio(entity.name)) {
                              final path = entity.uriOrPath;
                              final name = entity.name;

                              final originalIndex = currentEntries.indexWhere(
                                (e) => e.uriOrPath == path,
                              );

                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    if (selectedPaths.contains(
                                      entity.uriOrPath,
                                    )) {
                                      selectedPaths.remove(entity.uriOrPath);
                                    } else {
                                      selectedPaths.add(entity.uriOrPath);
                                    }
                                  });
                                },
                                onLongPress: () async {
                                  final info = await SAF.getAudioMetadata(path);
                                  if (info != null) {
                                    showFileInfoDialog(context, path, info);
                                  }
                                },
                                child: SizedBox(
                                  height: 65,
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // 🎵 Нота
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 4,
                                                right: 8,
                                              ),
                                              child: Icon(
                                                Icons.music_note,
                                                size: 20,
                                                color: themedText.color,
                                              ),
                                            ),

                                            // 📄 Название файла
                                            Expanded(
                                              child: Text(
                                                name.replaceAll(
                                                  RegExp(r'\s+\.'),
                                                  '.',
                                                ),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: themedText.color,
                                                  shadows:
                                                      themedText.shadowEnabled
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
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                              ),
                                            ),

                                            const SizedBox(width: 12),

                                            // 🔢 Номер, длительность, расширение
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
                                                      color: theme
                                                          .controlElements
                                                          .color,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            2,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      audioIndex != -1
                                                          ? '${audioIndex + 1}'
                                                          : '',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: theme
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
                                                  child: (() {
                                                    final ms = context
                                                        .watch<AppModel>()
                                                        .getAudioDurationFor(
                                                          entity.uriOrPath,
                                                        );
                                                    if (ms == null) {
                                                      return Text(
                                                        '--:--',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          color:
                                                              themedText.color,
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
                                                                          1,
                                                                        ),
                                                                  ),
                                                                ]
                                                              : null,
                                                        ),
                                                      );
                                                    }
                                                    final d = Duration(
                                                      milliseconds: ms,
                                                    );
                                                    final withHours =
                                                        d.inHours > 0;
                                                    String twoDigits(int n) => n
                                                        .toString()
                                                        .padLeft(2, '0');
                                                    final formatted = [
                                                      if (withHours)
                                                        twoDigits(d.inHours),
                                                      twoDigits(
                                                        d.inMinutes % 60,
                                                      ),
                                                      twoDigits(
                                                        d.inSeconds % 60,
                                                      ),
                                                    ].join(':');
                                                    return Text(
                                                      formatted,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color: themedText.color,
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
                                                                        1,
                                                                      ),
                                                                ),
                                                              ]
                                                            : null,
                                                      ),
                                                    );
                                                  })(),
                                                ),

                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 2,
                                                      ),
                                                  child: Text(
                                                    name
                                                        .split('.')
                                                        .last
                                                        .toLowerCase(),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color: themedText.color,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // ✅ Чекбокс
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8,
                                                right: 20,
                                              ),
                                              child: IconWithShadow(
                                                icon:
                                                    selectedPaths.contains(
                                                      entity.uriOrPath,
                                                    )
                                                    ? Icons.check_box
                                                    : Icons
                                                          .check_box_outline_blank,
                                                size: 26,
                                                color:
                                                    selectedPaths.contains(
                                                      entity.uriOrPath,
                                                    )
                                                    ? theme
                                                          .controlElements
                                                          .color
                                                    : theme
                                                          .widgetIconText
                                                          .color,
                                                shadowColor: theme
                                                    .controlElements
                                                    .shadowColor,
                                                shadowBlur: theme
                                                    .controlElements
                                                    .shadowBlur,
                                                shadowEnabled: theme
                                                    .controlElements
                                                    .shadowEnabled,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // 🔻 Нижняя граница
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
                            }

                            // Всё остальное игнорируем
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 8),
            // Кнопка "Добавить" — под списком файлов
            SafeArea(
              top: false,
              left: false,
              right: false,
              bottom: true,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                  left: 16,
                  right: 16,
                  top: 8,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Кнопка "Добавить" всегда по центру
                    GestureDetector(
                      onTap: selectedPaths.isEmpty
                          ? null
                          : () => _addSelectedFiles(),
                      child: SizedBox(
                        width: buttonSize,
                        height: buttonSize,
                        child: IconWithShadow(
                          icon: Icons.check_circle,
                          size: iconSize,
                          color: selectedPaths.isEmpty
                              ? theme.controlElements.color.withOpacity(0.4)
                              : theme.controlElements.color,
                          shadowColor: theme.controlElements.shadowColor,
                          shadowBlur: theme.controlElements.shadowBlur,
                          shadowEnabled: theme.controlElements.shadowEnabled,
                        ),
                      ),
                    ),

                    // Счетчик + чекбокс — строго справа
                    Positioned(
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selectedPaths.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                '(${selectedPaths.length})',
                                style: TextStyle(
                                  color: theme.controlElements.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          Transform.scale(
                            scale: 1.6,
                            child: Checkbox(
                              value:
                                  selectedPaths.isNotEmpty &&
                                  currentEntries
                                      .where(
                                        (e) =>
                                            !e.isDirectory && _isAudio(e.name),
                                      )
                                      .every(
                                        (e) =>
                                            selectedPaths.contains(e.uriOrPath),
                                      ),

                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    selectedPaths.addAll(
                                      currentEntries
                                          .where(
                                            (e) =>
                                                !e.isDirectory &&
                                                _isAudio(e.name),
                                          )
                                          .map((e) => e.uriOrPath),
                                    );
                                  } else {
                                    selectedPaths.clear();
                                  }
                                });
                              },

                              activeColor: theme.controlElements.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
