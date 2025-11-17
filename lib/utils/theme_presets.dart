import 'package:flutter/material.dart';
import '../models/app_theme_colors.dart';
import '../l10n/app_localizations.dart';

class ThemeKeys {
  static const standard = 'standard';
  static const dark = 'dark';
  static const light = 'light';
  static const custom = 'custom';
}

final Map<String, AppThemeColors> presetThemesRaw = {
  ThemeKeys.standard: AppThemeColors.standard(),
  ThemeKeys.dark: AppThemeColors.dark(),
  ThemeKeys.light: AppThemeColors.light(),
  ThemeKeys.custom: AppThemeColors.custom(),
};

Map<String, AppThemeColors> presetThemes(BuildContext context) {
  // Если тебе когда-либо понадобится использовать context (например, для локализации), ты сможешь
  // это сделать здесь. Пока просто возвращаем map.
  return presetThemesRaw;
}


