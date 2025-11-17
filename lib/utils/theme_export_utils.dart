import 'dart:ui';
import '../models/app_theme_colors.dart';

String generateThemeFactory(AppThemeColors theme, {String functionName = 'customLight'}) {
  final map = theme.toMap();

  String themed(String name) {
    final color = Color(map['$name.color'] ?? 0xFF000000);
    final shadowEnabled = map['$name.shadowEnabled'] ?? false;
    final shadowColor = Color(map['$name.shadowColor'] ?? 0x00000000);
    final shadowBlur = map['$name.shadowBlur'] ?? 0;

    return '''
  $name: ThemedColor(
    color: Color(0x${color.value.toRadixString(16).padLeft(8, '0')}),
    shadowEnabled: $shadowEnabled,
    shadowColor: Color(0x${shadowColor.value.toRadixString(16).padLeft(8, '0')}),
    shadowBlur: $shadowBlur,
  ),''';
  }


  String plain(String name) {
    final value = map[name];
    final color = Color(value ?? 0xFF000000);
    return '$name: Color(0x${color.value.toRadixString(16).padLeft(8, '0')}),';
  }


  final buffer = StringBuffer()
    ..writeln('AppThemeColors $functionName() => AppThemeColors(')
    ..writeln(themed('navIconActive'))
    ..writeln(themed('navIconInactive'))
    ..writeln(themed('displayIconActive'))
    ..writeln(themed('displayIconInactive'))
    ..writeln(themed('controlElements'))
    ..writeln(themed('widgetIconText'))
    ..writeln(themed('buttonIconText'))
    ..writeln(themed('currentValueText'))
    ..writeln(themed('sliderActiveSegment'))
    ..writeln(themed('sliderInactiveSegment'))
    ..writeln(themed('playlistDeleteButton'))
    ..writeln(themed('gradientDividerShadow'))
    ..writeln(themed('topBarUpperShadow'))
    ..writeln(themed('jogBackgroundShadow'))
    ..writeln(plain('gradientDividerStart'))
    ..writeln(plain('gradientDividerEnd'))
    ..writeln(plain('topBarUpperStart'))
    ..writeln(plain('topBarUpperEnd'))
    ..writeln(plain('backgroundStart'))
    ..writeln(plain('backgroundEnd'))
    ..writeln(plain('jogBackgroundStart'))
    ..writeln(plain('jogBackgroundEnd'))
    ..writeln(');');

  return buffer.toString();
}
