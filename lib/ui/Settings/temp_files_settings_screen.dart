import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../models/app_theme_colors.dart';
import '../../widgets/themed_text.dart';
import '../../widgets/themed_slider_shapes.dart';
import '../../widgets/themed_buttons.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/shadow_utils.dart';
import 'dart:async';


class TempFilesSettingsScreen extends StatefulWidget {
  const TempFilesSettingsScreen({Key? key}) : super(key: key);

  @override
  State<TempFilesSettingsScreen> createState() =>
      _TempFilesSettingsScreenState();
}

class _TempFilesSettingsScreenState extends State<TempFilesSettingsScreen> {
  int? _cacheSizeMb;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refreshCacheSize();
  }

  Future<void> _refreshCacheSize() async {
    setState(() => _loading = true);
    final appModel = context.read<AppModel>();
    final cacheSizeBytes = await appModel.getTempCacheSizeBytes();
    setState(() {
      _cacheSizeMb = (cacheSizeBytes / (1024 * 1024)).round();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final theme = app.themeColors;
    final loc = AppLocalizations.of(context)!;

    app.updateSystemUi(theme);

    final horizontalPadding = app.isTablet ? 64.0 : 32.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding:
        EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
        children: [
          // === Заголовок ===
          Center(
            child: buildShadowedText(
              context,
              loc.tempFilesTitle,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),

          // === Количество дней хранения ===
          _buildSliderBlock(
            context: context,
            title: loc.tempFilesRetentionDaysTitle,
            value: app.cacheRetentionDays,
            unit: loc.tempFilesRetentionDaysUnit,
            min: 1,
            max: 30,
            divisions: 29,
            onChanged: (val) => app.setCacheRetentionDays(val.round()),
            theme: theme,
          ),

          // === Максимальный размер кэша ===
          _buildSliderBlock(
            context: context,
            title: loc.tempFilesMaxSizeTitle,
            value: app.cacheMaxSizeMb,
            unit: loc.tempFilesMaxSizeUnit,
            min: 100,
            max: 4096,
            divisions: (4096 - 100) ~/ 50,
            onChanged: (val) => app.setCacheMaxSizeMb(val.round()),
            theme: theme,
          ),

          const SizedBox(height: 24),

          // === Текущий размер кэша ===
          Center(
            child: buildShadowedText(
              context,
              _loading
                  ? '${loc.calculatingCacheSize ?? "Berechne Cachegröße..."}'
                  : '${loc.cacheUsed ?? "Belegt"}: ${_cacheSizeMb ?? "?"} ${loc.tempFilesMaxSizeUnit}',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          // === Кнопка обновления размера кэша ===
          Center(
            child: ThemedButton(
              child: buildShadowedTextSimple(
                loc.refresh,
                app.themeColors.buttonIconText,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              background: app.themeColors.controlElements,
              foreground: app.themeColors.buttonIconText,
              width: 180,
              onTap: () {
                _refreshCacheSize();
              },

            ),
          ),

          const SizedBox(height: 32),

// === Кнопка очистки кэша ===
          Center(
            child: ThemedButton(
              child: buildShadowedTextSimple(
                loc.tempFilesClearButton,
                app.themeColors.buttonIconText,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              background: app.themeColors.controlElements,
              foreground: app.themeColors.buttonIconText,
              width: 260,
              onTap: () async {
                await app.clearAllTempCacheAndFolders(context);
                await _refreshCacheSize();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.tempFilesCacheCleared)),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // === Пояснение ===
          Center(
            child: buildShadowedText(
              context,
              loc.tempFilesInfoText,
              fontSize: 12,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderBlock({
    required BuildContext context,
    required String title,
    required int value,
    required String unit,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required AppThemeColors theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildShadowedText(
            context,
            title,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          buildShadowedText(
            context,
            '$value $unit',
            fontSize: 14,
            textAlign: TextAlign.center,
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: ThemedThumbShape(
                color: theme.controlElements.color,
                shadowColor: theme.controlElements.shadowColor,
                shadowBlur: theme.controlElements.shadowBlur,
                shadowEnabled: theme.controlElements.shadowEnabled,
              ),
              trackShape: DoubleShadowTrackShape(
                active: theme.sliderActiveSegment,
                inactive: theme.sliderInactiveSegment,
              ),
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: value.toDouble(),
              onChanged: onChanged,
              min: min,
              max: max,
              divisions: divisions,
            ),
          ),
        ],
      ),
    );
  }
}
