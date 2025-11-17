import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_model.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/themed_slider_shapes.dart';
import '../../widgets/themed_buttons.dart';
import '../../widgets/themed_text.dart';
import '../../utils/shadow_utils.dart';

// Адаптивный горизонтальный паддинг
double getAdaptiveHorizontalPadding(BuildContext context) {
  final app = Provider.of<AppModel>(context, listen: false);
  return app.isTablet ? 64.0 : 16.0;
}

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({Key? key}) : super(key: key);

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  static const _channel = MethodChannel('equalizer_channel');

  bool _enabled = false;
  List<Map<String, dynamic>> _bands = [];
  String _preset = 'flat';
  bool _loading = false;

  final List<String> _presetKeys = [
    'flat',
    'rock',
    'pop',
    'jazz',
    'classical',
    'manual',
  ];

  late AppModel app;
  bool _loadingState = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    app = Provider.of<AppModel>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _loadState().then((_) async {
      if (Platform.isAndroid) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // Не сбрасываем эквалайзер! Только получаем значения
          await _loadBands();
        });
      }
    });
  }

  Future<void> _loadBands() async {
    final bands = await _channel.invokeMethod('getBands');
    final prefs = await SharedPreferences.getInstance();

    List<Map<String, dynamic>> newBands = (bands as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    if (_preset == 'manual') {
      for (var band in newBands) {
        final saved = prefs.getInt('eq_band_manual_${band['band']}');
        if (saved != null) {
          band['currentLevel'] = saved.toDouble();
        }
      }
    }

    setState(() {
      _bands = newBands;
    });
  }

  void _setBandLevel(int idx, double value) async {
    final prefs = await SharedPreferences.getInstance();

    // Если не manual — сохраняем все значения как новый manual
    if (_preset != 'manual') {
      for (var band in _bands) {
        await prefs.setInt(
          'eq_band_manual_${band['band']}',
          band['currentLevel'].round(),
        );
      }
      await prefs.setString('equalizer_preset', 'manual');
      setState(() {
        _preset = 'manual';
      });
    }

    setState(() {
      _bands[idx]['currentLevel'] = value;
    });

    // Обновляем на платформе
    await _channel.invokeMethod('setBandLevel', {
      'band': _bands[idx]['band'],
      'level': value.round(),
    });

    // Всегда сохраняем все полосы
    for (var band in _bands) {
      await prefs.setInt(
        'eq_band_manual_${band['band']}',
        band['currentLevel'].round(),
      );
    }
  }

  Future<void> _applyPreset(String preset) async {
    setState(() {
      _preset = preset;
      _loading = true;
    });

    // Сохраняем выбранный пресет в prefs (даже если manual)
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('equalizer_preset', preset);

    await _channel.invokeMethod('setPreset', {'preset': preset});
    await Future.delayed(const Duration(milliseconds: 100));
    await _loadBands();

    // Если ручной режим — восстанавливаем значения из prefs
    if (preset == 'manual') {
      for (var band in _bands) {
        final saved = prefs.getInt('eq_band_manual_${band['band']}');
        if (saved != null) {
          band['currentLevel'] = saved.toDouble();
          // Обновить на платформе
          await _channel.invokeMethod('setBandLevel', {
            'band': band['band'],
            'level': saved,
          });
        }
      }
      setState(() {}); // Чтобы обновился UI
    }

    setState(() => _loading = false);
  }

  Future<void> _setEnabled(bool enabled) async {
    await _channel.invokeMethod('setEnabled', {'enabled': enabled});
    setState(() => _enabled = enabled);
    _saveState();
  }

  Future<void> _resetBands() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _loading = true);

    for (var band in _bands) {
      final bandIdx = band['band'];
      band['currentLevel'] = 0.0;

      // Выставить на платформе (Android)
      await _channel.invokeMethod('setBandLevel', {
        'band': bandIdx,
        'level': 0,
      });

      // Сохранить 0 в prefs для ручного режима
      await prefs.setInt('eq_band_manual_$bandIdx', 0);
    }

    // Обновить выбранный пресет на 'manual'
    setState(() {
      _preset = 'manual';
      _loading = false;
    });

    // Сохранить пресет
    await prefs.setString('equalizer_preset', 'manual');
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('equalizer_enabled', _enabled);
    prefs.setString('equalizer_preset', _preset);
    for (var band in _bands) {
      prefs.setInt('eq_band_${band['band']}', band['currentLevel'].round());
    }
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('equalizer_enabled') ?? false;
    final preset = prefs.getString('equalizer_preset') ?? 'manual';
    setState(() {
      _enabled = enabled;
      _preset = preset; // Всегда тот, что в prefs
      _loadingState = false;
    });
  }

  String _formatFreq(num hz) {
    if (hz >= 1000) {
      if (hz >= 10000) {
        return '${(hz / 1000).toStringAsFixed(0)}K';
      } else {
        return '${(hz / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
      }
    }
    return hz.toStringAsFixed(0);
  }

  String _formatDbValue(dynamic value) {
    final numVal = value is num ? value : num.tryParse(value.toString()) ?? 0;
    final db =
        numVal / 100; // если band['currentLevel'] хранит значение в сотых
    return db.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = context.watch<AppModel>().themeColors;
    final sliderActive = theme.sliderActiveSegment;
    final sliderInactive = theme.sliderInactiveSegment;
    final control = theme.controlElements;
    final buttonTextColor = theme.buttonIconText;
    final double dropdownFontSize = 16;
    final double bandLabelFontSize = 15;
    final adaptivePadding = getAdaptiveHorizontalPadding(context);

    final bool equalizerAvailable =
        Platform.isAndroid && context.read<AppModel>().player.androidAudioSessionId != null;

    final presetItems = [
      DropdownMenuItem(value: 'flat', child: Center(child: buildShadowedTextSimple(loc.presetFlat, buttonTextColor, fontSize: dropdownFontSize))),
      DropdownMenuItem(value: 'rock', child: Center(child: buildShadowedTextSimple(loc.presetRock, buttonTextColor, fontSize: dropdownFontSize))),
      DropdownMenuItem(value: 'pop', child: Center(child: buildShadowedTextSimple(loc.presetPop, buttonTextColor, fontSize: dropdownFontSize))),
      DropdownMenuItem(value: 'jazz', child: Center(child: buildShadowedTextSimple(loc.presetJazz, buttonTextColor, fontSize: dropdownFontSize))),
      DropdownMenuItem(value: 'classical', child: Center(child: buildShadowedTextSimple(loc.presetClassical, buttonTextColor, fontSize: dropdownFontSize))),
      DropdownMenuItem(value: 'manual', child: Center(child: buildShadowedTextSimple(loc.presetManual, buttonTextColor, fontSize: dropdownFontSize))),
    ];
    final presetValues = presetItems.map((e) => e.value).toList();
    final dropdownValue = presetValues.contains(_preset) ? _preset : 'manual';

    if (!Platform.isAndroid) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: buildShadowedText(
            context,
            'Equalizer is only available on Android',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    }

    if (_loadingState) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Заголовок ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: adaptivePadding),
                child: Center(
                  child: buildShadowedText(
                    context,
                    loc.equalizer,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Дропдаун пресетов ---
              if (equalizerAvailable)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: adaptivePadding),
                  child: Center(
                    child: SizedBox(
                      width: 300,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          alignment: Alignment.center,
                          dropdownColor: theme.backgroundStart.withOpacity(0.95),

                          // слегка светлее и в цвет фона
                          style: TextStyle(
                            color: theme.buttonIconText.color,
                            // правильный цвет текста
                            fontSize: dropdownFontSize,
                            fontWeight: FontWeight.normal, // не жирный!
                          ),
                          value: dropdownValue,
                          icon: Icon(Icons.arrow_drop_down),
                          onChanged: (val) =>
                          val != null ? _applyPreset(val) : null,
                          items: [
                            DropdownMenuItem(
                              value: 'flat',
                              child: Center(
                                child: buildShadowedText(
                                  context,
                                  loc.presetFlat,
                                  fontSize: dropdownFontSize,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'rock',
                              child: Center(
                                child: buildShadowedText(
                                  context,
                                  loc.presetRock,
                                  fontSize: dropdownFontSize,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'pop',
                              child: Center(
                                child: buildShadowedText(
                                  context,
                                  loc.presetPop,
                                  fontSize: dropdownFontSize,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'jazz',
                              child: Center(
                                child: buildShadowedText(
                                  context,
                                  loc.presetJazz,
                                  fontSize: dropdownFontSize,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'classical',
                              child: Center(
                                child: buildShadowedText(
                                  context,
                                  loc.presetClassical,
                                  fontSize: dropdownFontSize,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'manual',
                              child: Center(
                                child: buildShadowedText(
                                  context,
                                  loc.presetManual,
                                  fontSize: dropdownFontSize,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              if (!equalizerAvailable)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24),
                  child: Center(
                    child: buildShadowedText(
                      context,
                      loc.equalizerPlayToActivate,
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              if (equalizerAvailable)
                const SizedBox(height: 16),

              // --- Основная область ---
              Expanded(
                child: equalizerAvailable
                    ? SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: adaptivePadding,
                    vertical: 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- Слайдеры ----
                      Expanded(
                        child: _loading || _bands.isEmpty
                            ? const Padding(
                          padding: EdgeInsets.only(top: 64),
                          child: Center(child: CircularProgressIndicator()),
                        )
                            : Column(
                          children: List.generate(_bands.length, (idx) {
                            final band = _bands[idx];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 56,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        buildShadowedTextSimple(
                                          _formatFreq(band['centerFreq']),
                                          theme.currentValueText,
                                          fontSize: bandLabelFontSize,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        const SizedBox(width: 2),
                                        buildShadowedTextSimple(
                                          'Hz',
                                          theme.currentValueText,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onDoubleTap: () {
                                      final zero = 0.0;
                                      setState(() {
                                        _bands[idx]['currentLevel'] = zero;
                                      });
                                      _channel.invokeMethod('setBandLevel', {
                                        'band': _bands[idx]['band'],
                                        'level': zero.round(),
                                      });
                                    },
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 4,
                                        activeTrackColor: sliderActive.color,
                                        inactiveTrackColor: sliderInactive.color,
                                        trackShape: DoubleShadowTrackShape(
                                          active: sliderActive,
                                          inactive: sliderInactive,
                                        ),
                                        thumbColor: control.color,
                                        thumbShape: ThemedThumbShape(
                                          color: control.color,
                                          shadowColor: control.shadowEnabled ? control.shadowColor : Colors.transparent,
                                          shadowBlur: control.shadowEnabled ? control.shadowBlur : 0.0,
                                          shadowEnabled: control.shadowEnabled,
                                        ),
                                      ),
                                      child: Slider(
                                        min: band['minLevel'].toDouble(),
                                        max: band['maxLevel'].toDouble(),
                                        divisions: band['maxLevel'] - band['minLevel'],
                                        value: (band['currentLevel'] as num).toDouble(),
                                        onChanged: (value) => _setBandLevel(idx, value),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 46,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        buildShadowedTextSimple(
                                          _formatDbValue(band['currentLevel']),
                                          theme.currentValueText,
                                          fontSize: bandLabelFontSize,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        const SizedBox(width: 2),
                                        buildShadowedTextSimple(
                                          'dB',
                                          theme.currentValueText,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // ---- Правая колонка ----
                      Padding(
                        padding: const EdgeInsets.only(top: 12, right: 0, left: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: buildShadowedText(
                                context,
                                loc.enableEqualizer,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            ThemedBlurSwitch(
                              value: _enabled,
                              onChanged: (v) => _setEnabled(v),
                              width: 50,
                              height: 32,
                            ),
                            const SizedBox(height: 28),
                            ThemedButton(
                              width: 54,
                              height: 36,
                              child: buildShadowedTextSimple(
                                loc.resetBands,
                                buttonTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                              onTap: _bands.isNotEmpty ? () => _resetBands() : () {},
                              background: control,
                              foreground: buttonTextColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
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
