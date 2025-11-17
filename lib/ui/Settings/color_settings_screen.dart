import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/app_model.dart';
import '../../widgets/top_menu_bar.dart';
import '../../models/app_theme_colors.dart';
import '../../utils/theme_presets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../l10n/app_localizations.dart'; // 👈 локализация
import '../../utils/theme_export_utils.dart';
import '../../utils/shadow_utils.dart';
import '../../widgets/themed_slider_shapes.dart';
import '../../widgets/themed_buttons.dart';
import '../../widgets/themed_text.dart';
import '../../main.dart';
import 'dart:io';
import 'package:path/path.dart' as p; // обязательно в импорты, если ещё нет
import 'dart:async';
/*
class ExportThemeButton extends StatelessWidget {
  const ExportThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('📋 Скопировать текущую тему в консоль'),
      onPressed: () {
        final app = context.watch<AppModel>();
        final theme = app.themeColors;
        final code =
            generateThemeFactory(theme, functionName: 'customExportedTheme');
        debugPrint(code);
      },
    );
  }
}*/

class ColorSettingsScreen extends StatefulWidget {
  const ColorSettingsScreen({super.key});

  @override
  State<ColorSettingsScreen> createState() => _ColorSettingsScreenState();
}

class _ColorSettingsScreenState extends State<ColorSettingsScreen> {
  bool _themeWasSaved = false;

  String? selectedTheme;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _loadThemeName();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final offset = context.read<AppModel>().colorSettingsScrollOffset ?? 0.0;
      if (offset > 0.0 && _scrollController.hasClients) {
        _scrollController.jumpTo(offset);
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        context.read<AppModel>().colorSettingsScrollOffset =
            _scrollController.offset;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadThemeName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTheme = prefs.getString('selectedThemeKey') ?? 'dark';
    });
  }

  Future<ImageInfo> _getImageInfo(ImageProvider provider) async {
    final completer = Completer<ImageInfo>();
    final imageStream = provider.resolve(ImageConfiguration.empty);
    final listener = ImageStreamListener((info, _) {
      completer.complete(info);
    });
    imageStream.addListener(listener);
    return completer.future;
  }

  Widget _buildSlider(
      BuildContext context, {
        required double value,
        required double min,
        required double max,
        required int divisions,
        required ValueChanged<double> onChanged,
        required VoidCallback onDoubleTap,
        required ThemedColor active,
        required ThemedColor inactive,
        required ThemedColor control,
      }) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        overlayShape: SliderComponentShape.noOverlay,
        overlayColor: Colors.transparent,
        activeTrackColor: active.color,
        inactiveTrackColor: inactive.color,
        trackShape: DoubleShadowTrackShape(active: active, inactive: inactive),
        thumbColor: control.color,
        thumbShape: ThemedThumbShape(
          color: control.color,
          shadowColor:
          control.shadowEnabled ? control.shadowColor : Colors.transparent,
          shadowBlur: control.shadowEnabled ? control.shadowBlur : 0.0,
          shadowEnabled: control.shadowEnabled,
        ),
      ),
      child: GestureDetector(
        onDoubleTap: onDoubleTap,
        child: Slider(
          min: min,
          max: max,
          divisions: divisions,
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final theme = app.themeColors;
    final loc = AppLocalizations.of(context)!;
    final sidePadding = app.isTablet ? 64.0 : 16.0;

    app.updateSystemUi(theme);

    return Scaffold(
      backgroundColor: Colors.transparent, // 👈 важно
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Прокручиваемый контент
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 68, // запас под кнопки
            ),
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all(theme.controlElements.color),
                thickness: MaterialStateProperty.all(8),
                radius: const Radius.circular(8),
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                interactive: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      sidePadding,
                      16,
                      sidePadding,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ..._buildThemeSelector(context),
                        const SizedBox(height: 16),
                        _buildTransitionTypeSection(context, app),
                        const SizedBox(height: 16),
                        _buildBackgroundImageSection(context, app),
                        ..._buildColorSettings(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Кнопки SAVE/UNDO/SCROLL — фиксированы снизу, поверх прокрутки
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 8,
            right: 16,
            child: Row(
              children: [
                // SAVE
                GestureDetector(
                  onTap: () async {
                    await app.saveCurrentTheme();
                    setState(() {
                      _themeWasSaved = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${loc.themeWord} "${selectedTheme ?? ""}" ${loc.savedWord}',
                        ),
                      ),
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
                    child: Icon(
                      Icons.save,
                      color: theme.buttonIconText.color,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 36),
                // Undo
                GestureDetector(
                  onTap: () {
                    context.read<AppModel>().undoThemeChange();
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
                    child: Icon(Icons.undo, color: theme.buttonIconText.color),
                  ),
                ),
                const SizedBox(width: 8),
                // Redo
                GestureDetector(
                  onTap: () {
                    context.read<AppModel>().redoThemeChange();
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
                    child: Icon(Icons.redo, color: theme.buttonIconText.color),
                  ),
                ),
                const SizedBox(width: 16),
                // Scroll Up
                GestureDetector(
                  onTap: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
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
                    child: Icon(Icons.arrow_upward, color: theme.buttonIconText.color),
                  ),
                ),
                const SizedBox(width: 8),
                // Scroll Down
                GestureDetector(
                  onTap: () {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
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
                    child: Icon(Icons.arrow_downward, color: theme.buttonIconText.color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildThemeSelector(BuildContext context) {
    final app = context.watch<AppModel>();
    final loc = AppLocalizations.of(context)!;

    // Мапа: ключ темы → локализованное название
    final presets = presetThemes(context);
    final themeKeys = ['standard', 'dark', 'light', 'custom'];

    final localizedNames = {
      'standard': loc.themeStandard,
      'dark': loc.themeDark,
      'light': loc.themeLight,
      'custom': loc.themeCustom,
    };
    final textColor = app.themeColors.currentValueText.color;
    final buttonTextColor = app.themeColors.buttonIconText.color;
    return [
      const SizedBox(height: 24),
      Center(
        child: buildShadowedText(
          context,
          loc.themeSelection,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      Center(
        child: SizedBox(
          width: 300,
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory, // для Android 12+
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              alignment: Alignment.center,
              dropdownColor: app.themeColors.backgroundStart.withOpacity(0.95),
              value: themeKeys.contains(selectedTheme) ? selectedTheme : null,
              onChanged: (newKey) async {
                if (newKey == null) return;
                final theme = await app.loadSavedThemeColors(newKey);
                await app.saveSelectedThemeKey(newKey);
                app.updateThemeColorsPartial((_) => theme);
                // Используй именно app.themeColors после применения!
                app.applyBackgroundImageSettingsFromTheme(app.themeColors);
                setState(() => selectedTheme = newKey);
              },
              items: themeKeys.map((key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Center(
                    child: buildShadowedText(context, localizedNames[key]!),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          SizedBox(
            width: 300,
            child: ThemedButton(
              child: buildShadowedTextSimple(
                loc.saveCurrentTheme,
                app.themeColors.buttonIconText,
                fontSize: 16,
                fontWeight: FontWeight.normal, // ⬅️ без жирности
              ),
              onTap: () async {
                await app
                    .saveCurrentTheme(); // сохраняем в SharedPreferences + savedThemeColors
                setState(() {
                  _themeWasSaved = true; // чтобы dispose() знал, что сохраняли
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${loc.themeWord} "${localizedNames[selectedTheme!]}" ${loc.savedWord}',
                    ),
                  ),
                );
              },
              background: app.themeColors.controlElements,
              foreground: app.themeColors.buttonIconText,
              width: 280,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 300,
            child: ThemedButton(
              child: buildShadowedTextSimple(
                loc.resetToFactory,
                app.themeColors.buttonIconText,
                fontSize: 16,
                fontWeight: FontWeight.normal, // ⬅️ без жирности
              ),
              onTap: () async {
                if (selectedTheme != null &&
                    presets.containsKey(selectedTheme)) {
                  final themeName = selectedTheme!;

                  // 🧹 Сброс к заводской теме
                  await app.resetTheme(themeName);

                  // 💾 Сохраняем как текущую
                  await app.saveCurrentTheme();

                  // ✅ Применяем фоновые настройки из актуальной темы!
                  app.applyBackgroundImageSettingsFromTheme(app.themeColors);

                  // 🎯 Обновляем имя темы
                  await _loadThemeName();

                  // ⏳ Короткая задержка, чтобы успел отработать notifyListeners
                  await Future.delayed(Duration(milliseconds: 50));

                  // 🔄 Перерисовываем UI
                  setState(() {});

                  // 📝 Показываем уведомление
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${loc.themeWord} "${localizedNames[themeName]}" ${loc.resetWord}',
                      ),
                    ),
                  );
                }
              },
              background: app.themeColors.controlElements,
              foreground: app.themeColors.buttonIconText,
              width: 280,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildTransitionTypeSection(BuildContext context, AppModel app) {
    final loc = AppLocalizations.of(context)!;
    final theme = app.themeColors;

    final transitionNames = {
      AppTransitionType.slide: loc.transitionTypeSlide,
      AppTransitionType.fade: loc.transitionTypeFade,
      AppTransitionType.scale: loc.transitionTypeScale,
      AppTransitionType.none: loc.transitionTypeNone,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Center(
          child: buildShadowedText(
            context,
            loc.transitionBlockTitle,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: 300,
            child: DropdownButton<AppTransitionType>(
              isExpanded: true,
              // НЕ используем icon, используем дефолтную стрелку!
              // НЕ оборачиваем в DropdownButtonHideUnderline
              value: theme.transitionType,
              dropdownColor: theme.backgroundStart.withOpacity(0.95),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: theme.buttonIconText.color,
                  ),
              items: AppTransitionType.values.map((type) {
                return DropdownMenuItem<AppTransitionType>(
                  value: type,
                  child: Center(
                    child: buildShadowedText(context, transitionNames[type]!),
                  ),
                );
              }).toList(),
              onChanged: (selected) {
                if (selected != null) {
                  app.updateThemeColorsPartial(
                    (c) => c.copyWith(transitionType: selected),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundImageSection(BuildContext context, AppModel app) {
    final loc = AppLocalizations.of(context)!;
    final textColor = app.themeColors.currentValueText.color;
    final buttonTextColor = app.themeColors.buttonIconText.color;

    final active = app.themeColors.sliderActiveSegment;
    final inactive = app.themeColors.sliderInactiveSegment;
    final control = app.themeColors.controlElements;
    final controlColor = app.themeColors.controlElements.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // Заголовок "Фоновое изображение"
        Center(
          child: buildShadowedText(
            context,
            loc.backgroundImage,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        // === Кнопка выбрать ===
        Center(
          child: ThemedButton(
            child: buildShadowedTextSimple(
              loc.chooseBackgroundImage,
              app.themeColors.buttonIconText,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            onTap: () async {
              final result =
              await FilePicker.platform.pickFiles(type: FileType.image);
              if (result != null && result.files.single.path != null) {
                final pickedPath = result.files.single.path!;
                final pickedName = result.files.single.name;
                app.updateBackgroundImageSettings(
                  imagePath: pickedPath,
                  displayName: pickedName,
                );
              }
            },
            background: app.themeColors.controlElements,
            foreground: app.themeColors.buttonIconText,
            width: 300,
          ),
        ),

        const SizedBox(height: 12),

        // === Кнопка удалить ===
        Center(
          child: ThemedButton(
            child: buildShadowedTextSimple(
              loc.resetBackgroundImage,
              app.themeColors.buttonIconText,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            onTap: () {
              final preset = presetThemesRaw[app.selectedThemeKey];
              if (preset != null) {
                app.updateBackgroundImageSettings(
                  imagePath: preset.backgroundImagePath,
                  displayName: preset.backgroundImageDisplayName,
                );
              } else {
                app.updateBackgroundImageSettings(
                  imagePath: null,
                  displayName: null,
                );
              }
            },
            background: app.themeColors.controlElements,
            foreground: app.themeColors.buttonIconText,
            width: 300,
          ),
        ),

        // === Превью и имя файла ===
        Builder(
          builder: (context) {
            final imagePath = app.themeColors.backgroundImagePath;
            final isAsset = imagePath != null && imagePath.startsWith('assets/');
            final fileExists = imagePath != null && !isAsset
                ? File(imagePath).existsSync()
                : true;

            if (imagePath == null || !fileExists) return const SizedBox();

            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final maxSize = screenWidth * 0.5;
            final maxHeight = screenHeight * 0.5;

            final imageProvider = isAsset
                ? AssetImage(imagePath) as ImageProvider
                : FileImage(File(imagePath));

            return FutureBuilder<ImageInfo>(
              future: _getImageInfo(imageProvider),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();

                final imageInfo = snapshot.data!;
                final imageWidth = imageInfo.image.width.toDouble();
                final imageHeight = imageInfo.image.height.toDouble();

                final widthRatio = maxSize / imageWidth;
                final heightRatio = maxHeight / imageHeight;
                final scale = widthRatio < heightRatio ? widthRatio : heightRatio;

                final displayWidth = imageWidth * scale;
                final displayHeight = imageHeight * scale;

                final displayPath = isAsset
                    ? imagePath
                    : (app.themeColors.backgroundImageDisplayName?.isNotEmpty == true
                    ? app.themeColors.backgroundImageDisplayName!
                    : p.basename(imagePath));

                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: displayWidth,
                        height: displayHeight,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        displayPath,
                        style: TextStyle(
                          fontSize: 12,
                          color: app.themeColors.currentValueText.color,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            );
          },
        ),

        // === Использовать фоновое изображение ===
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: app.themeColors.buttonIconText.color,
                  checkboxTheme: CheckboxThemeData(
                    checkColor:
                    MaterialStateProperty.all(app.themeColors.buttonIconText.color),
                    fillColor:
                    MaterialStateProperty.all(app.themeColors.controlElements.color),
                  ),
                ),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: buildShadowedText(context, loc.useBackgroundImage,
                      textAlign: TextAlign.left),
                  value: app.themeColors.useBackgroundImage,
                  onChanged: (v) {
                    if (v != null) {
                      app.updateBackgroundImageSettings(useBackgroundImage: v);
                    }
                  },
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              ),
            ),
          ],
        ),

        // === Растянуть на весь экран ===
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: app.themeColors.buttonIconText.color,
                  checkboxTheme: CheckboxThemeData(
                    checkColor:
                    MaterialStateProperty.all(app.themeColors.buttonIconText.color),
                    fillColor:
                    MaterialStateProperty.all(app.themeColors.controlElements.color),
                  ),
                ),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: buildShadowedText(context, loc.stretchToFullScreen,
                      textAlign: TextAlign.left),
                  value: app.themeColors.backgroundFitFill,
                  onChanged: (v) {
                    if (v != null) {
                      app.updateBackgroundImageSettings(fitFill: v);
                    }
                  },
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              ),
            ),
          ],
        ),

        // === Повторять изображение (Cover/Repeat) ===
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: app.themeColors.buttonIconText.color,
                  checkboxTheme: CheckboxThemeData(
                    checkColor:
                    MaterialStateProperty.all(app.themeColors.buttonIconText.color),
                    fillColor:
                    MaterialStateProperty.all(app.themeColors.controlElements.color),
                  ),
                ),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: buildShadowedText(context, loc.fillScreen,
                      textAlign: TextAlign.left),
                  value: app.themeColors.backgroundFitCover,
                  onChanged: (v) {
                    if (v != null) {
                      app.updateBackgroundImageSettings(fitCover: v);
                    }
                  },
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              ),
            ),
          ],
        ),

        // === Слайдеры (яркость, контраст, прозрачность) ===
        SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            final double brightness =
                app.themeColors.backgroundImageBrightness ?? 1.0;
            final double contrast =
                app.themeColors.backgroundImageContrast ?? 1.0;
            final double opacity =
                app.themeColors.backgroundImageOpacity ?? 1.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Яркость
                Center(
                  child: buildShadowedText(
                    context,
                    '${loc.brightness}: ${(brightness * 100).round()}%',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSlider(
                  context,
                  value: brightness,
                  min: 0.0,
                  max: 2.0,
                  divisions: 200,
                  onChanged: (v) {
                    app.updateBackgroundImageSettings(brightness: v);
                    setState(() {});
                  },
                  onDoubleTap: () {
                    app.updateBackgroundImageSettings(brightness: 1.0);
                    setState(() {});
                  },
                  active: active,
                  inactive: inactive,
                  control: control,
                ),
                const SizedBox(height: 16),

                // Контраст
                Center(
                  child: buildShadowedText(
                    context,
                    '${loc.contrast}: ${(contrast * 100).round()}%',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSlider(
                  context,
                  value: contrast,
                  min: 0.0,
                  max: 2.0,
                  divisions: 200,
                  onChanged: (v) {
                    app.updateBackgroundImageSettings(contrast: v);
                    setState(() {});
                  },
                  onDoubleTap: () {
                    app.updateBackgroundImageSettings(contrast: 1.0);
                    setState(() {});
                  },
                  active: active,
                  inactive: inactive,
                  control: control,
                ),
                const SizedBox(height: 16),

                // Прозрачность
                Center(
                  child: buildShadowedText(
                    context,
                    '${loc.transparencyLabel}: ${((1.0 - opacity) * 100).round()}%',
                    fontSize: 14,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSlider(
                  context,
                  value: 1.0 - opacity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  onChanged: (v) {
                    app.updateBackgroundImageOpacity(1.0 - v);
                    setState(() {});
                  },
                  onDoubleTap: () {
                    app.updateBackgroundImageOpacity(1.0);
                    setState(() {});
                  },
                  active: active,
                  inactive: inactive,
                  control: control,
                ),
              ],
            );
          },
        ),
      ],
    );
  }


  List<Widget> _buildColorSettings(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final app = context.watch<AppModel>();
    final textColor = app.themeColors.currentValueText.color;
    final buttonTextColor = app.themeColors.buttonIconText.color;

    final items = <Widget>[
      const SizedBox(height: 36),
      Center(
        child: Center(
          child: buildShadowedText(
            context,
            loc.colorSettings,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 16),

      // Таблица объяснений
      Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: buildShadowedText(context, loc.main,
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 6,
                child: Center(
                  child: buildShadowedText(context, loc.shadow,
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: buildShadowedText(context, loc.color,
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Center(
                    child:
                        buildShadowedText(context, loc.enabled, fontSize: 13),
                  )),
              Expanded(
                  flex: 2,
                  child: Center(
                    child: buildShadowedText(context, loc.color, fontSize: 13),
                  )),
              Expanded(
                  flex: 2,
                  child: Center(
                    child: buildShadowedText(context, loc.blur, fontSize: 13),
                  )),
            ],
          ),
        ],
      ),

      _buildThemedColorRow(context, loc.navIconsActive, (c) => c.navIconActive,
          (c, v) => c.copyWith(navIconActive: v)),
      _buildThemedColorRow(context, loc.navIconsInactive,
          (c) => c.navIconInactive, (c, v) => c.copyWith(navIconInactive: v)),
      _buildThemedColorRow(
          context,
          loc.displayIconsActive,
          (c) => c.displayIconActive,
          (c, v) => c.copyWith(displayIconActive: v)),
      _buildThemedColorRow(
          context,
          loc.displayIconsInactive,
          (c) => c.displayIconInactive,
          (c, v) => c.copyWith(displayIconInactive: v)),
      _buildThemedColorRow(context, loc.controlElements,
          (c) => c.controlElements, (c, v) => c.copyWith(controlElements: v)),
      _buildThemedColorRow(context, loc.widgetIconsText,
          (c) => c.widgetIconText, (c, v) => c.copyWith(widgetIconText: v)),
      _buildThemedColorRow(context, loc.buttonIconsText,
          (c) => c.buttonIconText, (c, v) => c.copyWith(buttonIconText: v)),
      _buildThemedColorRow(context, loc.mainText, (c) => c.currentValueText,
          (c, v) => c.copyWith(currentValueText: v)),
      _buildThemedColorRow(
          context,
          loc.sliderActive,
          (c) => c.sliderActiveSegment,
          (c, v) => c.copyWith(sliderActiveSegment: v)),
      _buildThemedColorRow(
          context,
          loc.sliderInactive,
          (c) => c.sliderInactiveSegment,
          (c, v) => c.copyWith(sliderInactiveSegment: v)),
      _buildThemedColorRow(
          context,
          loc.playlistDeleteButton,
          (c) => c.playlistDeleteButton,
          (c, v) => c.copyWith(playlistDeleteButton: v)),
      SizedBox(height: 16),
      Center(
        child: buildShadowedText(
          context,
          loc.gradientSettings,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 12),
      // Первая строка заголовков
      Row(
        children: [
          Expanded(
              flex: 2,
              child: Center(
                child: buildShadowedText(context, loc.color,
                    fontSize: 13, fontWeight: FontWeight.bold),
              )),
          Expanded(
              flex: 6,
              child: Center(
                child: buildShadowedText(context, loc.shadow,
                    fontSize: 13, fontWeight: FontWeight.bold),
              )),
        ],
      ),
      // Вторая строка подзаголовков
      Row(
        children: [
          Expanded(
              flex: 2,
              child: Center(
                child: buildShadowedText(context, loc.startEnd, fontSize: 13),
              )),
          Expanded(
              flex: 2,
              child: Center(
                child: buildShadowedText(context, loc.enabled, fontSize: 13),
              )),
          Expanded(
              flex: 2,
              child: Center(
                child: buildShadowedText(context, loc.color, fontSize: 13),
              )),
          Expanded(
              flex: 2,
              child: Center(
                child: buildShadowedText(context, loc.blur, fontSize: 13),
              )),
        ],
      ),
      _buildGradientColorRow(
        context,
        loc.background,
        (c) => c.backgroundStart,
        (c) => c.backgroundEnd,
        (c, v) => c.copyWith(backgroundStart: v),
        (c, v) => c.copyWith(backgroundEnd: v),
      ),
      _buildGradientColorRow(
        context,
        loc.divider,
        (c) => c.gradientDividerStart,
        (c) => c.gradientDividerEnd,
        (c, v) => c.copyWith(gradientDividerStart: v),
        (c, v) => c.copyWith(gradientDividerEnd: v),
        (c) => c.gradientDividerShadow,
        (c, v) => c.copyWith(gradientDividerShadow: v),
      ),
      _buildGradientColorRow(
        context,
        loc.topBar,
        (c) => c.topBarUpperStart,
        (c) => c.topBarUpperEnd,
        (c, v) => c.copyWith(topBarUpperStart: v),
        (c, v) => c.copyWith(topBarUpperEnd: v),
        (c) => c.topBarUpperShadow,
        (c, v) => c.copyWith(topBarUpperShadow: v),
      ),
      _buildGradientColorRow(
        context,
        loc.jog,
        (c) => c.jogBackgroundStart,
        (c) => c.jogBackgroundEnd,
        (c, v) => c.copyWith(jogBackgroundStart: v),
        (c, v) => c.copyWith(jogBackgroundEnd: v),
        (c) => c.jogBackgroundShadow,
        (c, v) => c.copyWith(jogBackgroundShadow: v),
      ),
    ];

    return items;
  }

  Widget _buildThemedColorRow(
    BuildContext context,
    String label,
    ThemedColor Function(AppThemeColors) getter,
    AppThemeColors Function(AppThemeColors, ThemedColor) fieldSetter, {
    bool showMainColorCircle = true,
  }) {
    final app = context.watch<AppModel>();
    final currentColors = app.themeColors;
    final themed = getter(currentColors);

    final textColor = app.themeColors.currentValueText.color;
    final buttonTextColor = app.themeColors.buttonIconText.color;

    final active = app.themeColors.sliderActiveSegment;
    final inactive = app.themeColors.sliderInactiveSegment;
    final control = app.themeColors.controlElements;

    void updateThemedColor(ThemedColor Function(ThemedColor) transform) {
      app.updateThemeColorsPartial((current) {
        final currentField = getter(current);
        final updatedField = transform(currentField);
        final isNavIcons = label.contains('Иконки навигации');
        if (isNavIcons) {
          // Форсим epoch после любого изменения цвета/тени/blur navIcon
          WidgetsBinding.instance.addPostFrameCallback((_) {
            app.bumpNavIconThemeEpoch();
          });
        }
        return fieldSetter(current, updatedField);
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: buildShadowedText(context, label, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Основной цвет
              Expanded(
                flex: 2,
                child: showMainColorCircle
                    ? Center(
                        child: GestureDetector(
                          onTap: () => _pickColor(
                            context,
                            themed.color,
                            (newColor) => updateThemedColor(
                                (tc) => tc.copyWith(color: newColor)),
                          ),
                          child: _circle(themed.color),
                        ),
                      )
                    : const SizedBox(),
              ),

              // Вкл/Выкл тени
              Expanded(
                flex: 2,
                child: Center(
                  child: ThemedBlurSwitch(
                    value: themed.shadowEnabled,
                    onChanged: (enabled) => updateThemedColor(
                      (tc) => tc.copyWith(shadowEnabled: enabled),
                    ),
                  ),
                ),
              ),

              // Цвет тени
              Expanded(
                flex: 2,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _pickColor(
                      context,
                      themed.shadowColor,
                      (newColor) => updateThemedColor(
                          (tc) => tc.copyWith(shadowColor: newColor)),
                    ),
                    child: _circle(themed.shadowColor),
                  ),
                ),
              ),

              // Размытие тени
              Expanded(
                flex: 2,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    overlayShape: SliderComponentShape.noOverlay,
                    overlayColor: Colors.transparent,
                    activeTrackColor: active.color,
                    inactiveTrackColor: inactive.color,
                    trackShape: DoubleShadowTrackShape(
                      active: active,
                      inactive: inactive,
                    ),
                    thumbColor: control.color,
                    thumbShape: ThemedThumbShape(
                      color: control.color,
                      shadowColor: control.shadowEnabled
                          ? control.shadowColor
                          : Colors.transparent,
                      shadowBlur:
                          control.shadowEnabled ? control.shadowBlur : 0.0,
                      shadowEnabled: control.shadowEnabled,
                    ),
                  ),
                  child: Slider(
                    min: 0,
                    max: 20,
                    value: themed.shadowBlur,
                    onChanged: (value) => updateThemedColor(
                        (tc) => tc.copyWith(shadowBlur: value)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradientColorRow(
    BuildContext context,
    String label,
    Color Function(AppThemeColors) getStart,
    Color Function(AppThemeColors) getEnd,
    AppThemeColors Function(AppThemeColors, Color) setStart,
    AppThemeColors Function(AppThemeColors, Color) setEnd, [
    ThemedColor Function(AppThemeColors)? getShadow,
    AppThemeColors Function(AppThemeColors, ThemedColor)? setShadow,
  ]) {
    final app = context.watch<AppModel>();
    final startColor = getStart(app.themeColors);
    final endColor = getEnd(app.themeColors);
    final ThemedColor? shadow =
        getShadow != null ? getShadow(app.themeColors) : null;

    void updateShadow(ThemedColor newValue) {
      if (setShadow != null) {
        app.updateThemeColorsPartial((current) {
          return setShadow(
              current, newValue); // ⚠️ тоже должен вернуть AppThemeColors
        });
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Center(
            child: buildShadowedText(context, label, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Start color
              Expanded(
                flex: 1,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _pickColor(
                      context,
                      startColor,
                      (c) => app.updateThemeColorsPartial(
                        (current) => setStart(current, c),
                      ),
                    ),
                    child: _circle(startColor),
                  ),
                ),
              ),

              // End color
              Expanded(
                flex: 1,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _pickColor(
                      context,
                      endColor,
                      (c) => app.updateThemeColorsPartial(
                        (current) => setEnd(current, c),
                      ),
                    ),
                    child: _circle(endColor),
                  ),
                ),
              ),

              // Если тень есть — отобразить остальные элементы
              if (shadow != null) ...[
                // Shadow toggle
                Expanded(
                  flex: 2,
                  child: Center(
                      child: ThemedBlurSwitch(
                    value: shadow.shadowEnabled,
                    onChanged: (v) =>
                        updateShadow(shadow.copyWith(shadowEnabled: v)),
                  )),
                ),

                // Shadow color
                Expanded(
                  flex: 2,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _pickColor(
                        context,
                        shadow.shadowColor,
                        (c) => updateShadow(shadow.copyWith(shadowColor: c)),
                      ),
                      child: _circle(shadow.shadowColor),
                    ),
                  ),
                ),

                // Shadow blur
                Expanded(
                  flex: 2,
                  child: Builder(
                    builder: (context) {
                      final app = context.watch<AppModel>();
                      final themeColors = app.themeColors;

                      final active = themeColors.sliderActiveSegment;
                      final inactive = themeColors.sliderInactiveSegment;
                      final control = themeColors.controlElements;
                      final localShadow = shadow!;

                      return SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          overlayShape: SliderComponentShape.noOverlay,
                          overlayColor: Colors.transparent,
                          trackHeight: 4,
                          activeTrackColor: active.color,
                          inactiveTrackColor: inactive.color,
                          trackShape: DoubleShadowTrackShape(
                            active: active,
                            inactive: inactive,
                          ),
                          thumbColor: control.color,
                          thumbShape: ThemedThumbShape(
                            color: control.color,
                            shadowColor: control.shadowEnabled
                                ? control.shadowColor
                                : Colors.transparent,
                            shadowBlur: control.shadowEnabled
                                ? control.shadowBlur
                                : 0.0,
                            shadowEnabled: control.shadowEnabled,
                          ),
                        ),
                        child: Slider(
                          min: 0,
                          max: 20,
                          value: localShadow.shadowBlur,
                          onChanged: (v) =>
                              updateShadow(localShadow.copyWith(shadowBlur: v)),
                        ),
                      );
                    },
                  ),
                ),
              ] else
                const Expanded(flex: 6, child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickColor(
    BuildContext context,
    Color currentColor,
    void Function(Color) onColorSelected,
  ) async {
    final loc = AppLocalizations.of(context)!;
    Color pickerColor = currentColor;
    final controller = TextEditingController(
      text:
          '#${currentColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
    );

    await showDialog<bool>(
      context: context,
      builder: (context) {
        return Center(
          child: SizedBox(
            width: 220, // ⬅️ ограничиваем ширину всего диалога
            child: Dialog(
              insetPadding: EdgeInsets.zero, // ⬅️ убираем внешние отступы
              shape: RoundedRectangleBorder(
                // 👈 вот здесь
                borderRadius:
                    BorderRadius.circular(8), // уменьши до нужного значения
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 600, // ⬅️ ограничиваем максимальную высоту
                ),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              // 🎨 ColorPicker с отступом вниз под HEX и кнопки
                              Padding(
                                padding: const EdgeInsets.only(bottom: 80),
                                child: ColorPicker(
                                  pickerColor: pickerColor,
                                  onColorChanged: (color) {
                                    setState(() {
                                      pickerColor = color;
                                      controller.text =
                                          '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
                                    });
                                  },
                                  enableAlpha: true,
                                  displayThumbColor: true,
                                  showLabel: false,
                                  pickerAreaHeightPercent: 0.7,
                                  colorPickerWidth: 200,
                                  pickerAreaBorderRadius:
                                      BorderRadius.circular(5),
                                ),
                              ),

                              // 🆔 HEX-поле
                              Positioned(
                                bottom: 60,
                                left: 0,
                                right: 0,
                                child: SizedBox(
                                  height: 40,
                                  child: TextField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      labelText: 'HEX',
                                    ),
                                    onChanged: (value) {
                                      final hex = value.replaceAll('#', '');
                                      if (hex.length == 6) {
                                        final parsed =
                                            int.tryParse('FF$hex', radix: 16);
                                        if (parsed != null) {
                                          setState(() {
                                            pickerColor = Color(parsed);
                                          });
                                        }
                                      } else if (hex.length == 8) {
                                        final parsed =
                                            int.tryParse(hex, radix: 16);
                                        if (parsed != null) {
                                          setState(() {
                                            pickerColor = Color(parsed);
                                          });
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),

                              // ✅ Кнопки OK / Cancel
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text(loc.cancel),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                        onColorSelected(pickerColor);
                                      },
                                      child: Text(loc.ok),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _circle(Color color) {
    final app = context.watch<AppModel>();
    final themed = app.themeColors.controlElements;

    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black26),
        boxShadow: themed.shadowEnabled
            ? [
                BoxShadow(
                  color: themed.shadowColor,
                  blurRadius: themed.shadowBlur,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
    );
  }
}

class ThemedBlurSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final double borderRadius;

  const ThemedBlurSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 50,
    this.height = 32,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppModel>().themeColors;
    debugPrint('--- BUILD TopMenuBar ----');
    debugPrint('navIconActive: ${theme.navIconActive}');
    debugPrint('navIconInactive: ${theme.navIconInactive}');
    final control = theme.controlElements;
    final background = theme.buttonIconText.color;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Фон под переключателем
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: control.shadowEnabled
                    ? [
                        BoxShadow(
                          color: control.shadowColor,
                          blurRadius: control.shadowBlur,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
            ),
          ),

          // Переключатель
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: background,
            // цвет бегунка
            inactiveThumbColor: control.color,
            activeTrackColor: control.color,
            inactiveTrackColor: background,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
