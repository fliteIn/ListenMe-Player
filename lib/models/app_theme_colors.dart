import 'package:flutter/material.dart';
import '../utils/theme_presets.dart';
import '../../main.dart';

class ThemedColor {
  final Color color;
  final bool shadowEnabled;
  final Color shadowColor;
  final double shadowBlur;

  ThemedColor({
    required this.color,
    required this.shadowEnabled,
    required this.shadowColor,
    required this.shadowBlur,
  });

  ThemedColor copyWith({
    Color? color,
    bool? shadowEnabled,
    Color? shadowColor,
    double? shadowBlur,
  }) {
    return ThemedColor(
      color: color ?? this.color,
      shadowEnabled: shadowEnabled ?? this.shadowEnabled,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowBlur: shadowBlur ?? this.shadowBlur,
    );
  }
}

class AppThemeColors {
  final AppTransitionType transitionType;
  final String? backgroundImagePath; // путь к изображению: assets или файл
  final String? backgroundImageDisplayName;
  final bool useBackgroundImage; // использовать ли изображение
  final bool backgroundFitFill; // растянуть
  final bool backgroundFitCover; // заполнить
  final double? backgroundImageBrightness;
  final double? backgroundImageContrast;
  final double? backgroundImageOpacity;

  final ThemedColor navIconActive;
  final ThemedColor navIconInactive;
  final ThemedColor displayIconActive;
  final ThemedColor displayIconInactive;
  final ThemedColor controlElements;
  final ThemedColor widgetIconText;
  final ThemedColor buttonIconText;
  final ThemedColor currentValueText;
  final ThemedColor sliderActiveSegment;
  final ThemedColor sliderInactiveSegment;
  final ThemedColor playlistDeleteButton;

  final ThemedColor topBarUpperShadow;
  final ThemedColor jogBackgroundShadow;

  final Color backgroundStart;
  final Color backgroundEnd;
  final Color topBarUpperStart;
  final Color topBarUpperEnd;
  final Color jogBackgroundStart;
  final Color jogBackgroundEnd;

  final Color gradientDividerStart;
  final Color gradientDividerEnd;
  final ThemedColor gradientDividerShadow;

  AppThemeColors({
    this.transitionType = AppTransitionType.slide,
    this.backgroundImagePath,
    this.backgroundImageDisplayName,
    this.useBackgroundImage = false,
    this.backgroundFitFill = false,
    this.backgroundFitCover = true,
    this.backgroundImageBrightness,
    this.backgroundImageContrast,
    this.backgroundImageOpacity,
    required this.navIconActive,
    required this.navIconInactive,
    required this.displayIconActive,
    required this.displayIconInactive,
    required this.controlElements,
    required this.widgetIconText,
    required this.buttonIconText,
    required this.currentValueText,
    required this.sliderActiveSegment,
    required this.sliderInactiveSegment,
    required this.playlistDeleteButton,
    required this.topBarUpperShadow,
    required this.jogBackgroundShadow,
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.topBarUpperStart,
    required this.topBarUpperEnd,
    required this.jogBackgroundStart,
    required this.jogBackgroundEnd,
    required this.gradientDividerStart,
    required this.gradientDividerEnd,
    required this.gradientDividerShadow,
  });

  factory AppThemeColors.standard() => AppThemeColors(
        transitionType: AppTransitionType.none,
        backgroundImagePath: 'assets/backgrounds/standard.jpg',
        backgroundImageDisplayName: '',
        useBackgroundImage: true,
        backgroundFitFill: true,
        backgroundFitCover: false,
        backgroundImageBrightness: 1.0,
        backgroundImageContrast: 1.05,
        backgroundImageOpacity: 0.95,
        navIconActive: ThemedColor(
          color: Color(0xff3f51b5),
          shadowEnabled: true,
          shadowColor: Color(0xff8b8b8b),
          shadowBlur: 3.0,
        ),
        navIconInactive: ThemedColor(
          color: Color(0xff9e9e9e),
          shadowEnabled: true,
          shadowColor: Color(0xff8b8b8b),
          shadowBlur: 3.0,
        ),
        displayIconActive: ThemedColor(
          color: Color(0xff3f51b5),
          shadowEnabled: true,
          shadowColor: Color(0xff8b8b8b),
          shadowBlur: 3.0,
        ),
        displayIconInactive: ThemedColor(
          color: Color(0xff9e9e9e),
          shadowEnabled: true,
          shadowColor: Color(0xff8b8b8b),
          shadowBlur: 3.0,
        ),
        controlElements: ThemedColor(
          color: Color(0xff3f51b5),
          shadowEnabled: true,
          shadowColor: Color(0xff8b8b8b),
          shadowBlur: 3.0,
        ),
        widgetIconText: ThemedColor(
          color: Color(0xff000000),
          shadowEnabled: false,
          shadowColor: Color(0xff8b8b8b),
          shadowBlur: 3.0,
        ),
        buttonIconText: ThemedColor(
          color: Color(0xffffffff),
          shadowEnabled: false,
          shadowColor: Color(0xff8b8b8b),
          shadowBlur: 3.0,
        ),
        currentValueText: ThemedColor(
          color: Color(0xff000000),
          shadowEnabled: true,
          shadowColor: Color(0x828b8b8b),
          shadowBlur: 6.0,
        ),
        sliderActiveSegment: ThemedColor(
          color: Color(0xff3f51b5),
          shadowEnabled: true,
          shadowColor: Color(0xff8b8b8b),
          shadowBlur: 3.0,
        ),
        sliderInactiveSegment: ThemedColor(
          color: Color(0xffe0e0e0),
          shadowEnabled: true,
          shadowColor: Color(0xff8b8b8b),
          shadowBlur: 3.0,
        ),
        playlistDeleteButton: ThemedColor(
          color: Color(0xffe53935),
          shadowEnabled: true,
          shadowColor: Color(0xff8b8b8b),
          shadowBlur: 3.0,
        ),
        gradientDividerShadow: ThemedColor(
          color: Color(0xff000000),
          shadowEnabled: true,
          shadowColor: Color(0xff8b8b8b),
          shadowBlur: 3.0,
        ),
        topBarUpperShadow: ThemedColor(
          color: Color(0xff000000),
          shadowEnabled: true,
          shadowColor: Color(0xff8b8b8b),
          shadowBlur: 3.0,
        ),
        jogBackgroundShadow: ThemedColor(
          color: Color(0xff000000),
          shadowEnabled: true,
          shadowColor: Color(0xff8b8b8b),
          shadowBlur: 3.0,
        ),
        gradientDividerStart: Color(0xfff5f5f5),
        gradientDividerEnd: Color(0xffbdbdbd),
        topBarUpperStart: Color(0xffe3f2fd),
        topBarUpperEnd: Color(0xffbbdefb),
        backgroundStart: Color(0x88f5f5f5),
        backgroundEnd: Color(0xffffffff),
        jogBackgroundStart: Color(0xfff5f5f5),
        jogBackgroundEnd: Color(0xffbdbdbd),
      );

  factory AppThemeColors.dark() => AppThemeColors(
        transitionType: AppTransitionType.none,
        backgroundImagePath: 'assets/backgrounds/dark.jpg',
        backgroundImageDisplayName: '',
        useBackgroundImage: true,
        backgroundFitFill: false,
        backgroundFitCover: true,
        backgroundImageBrightness: 1.0,
        backgroundImageContrast: 1.0,
        backgroundImageOpacity: 1.0,
        navIconActive: ThemedColor(
          color: Color(0xffbdbdbd),
          shadowEnabled: true,
          shadowColor: Color(0xff000000),
          shadowBlur: 2.0,
        ),
        navIconInactive: ThemedColor(
          color: Color(0xff616161),
          shadowEnabled: true,
          shadowColor: Color(0xff000000),
          shadowBlur: 3.0,
        ),
        displayIconActive: ThemedColor(
          color: Color(0xffbdbdbd),
          shadowEnabled: true,
          shadowColor: Color(0xff000000),
          shadowBlur: 3.0,
        ),
        displayIconInactive: ThemedColor(
          color: Color(0xff616161),
          shadowEnabled: true,
          shadowColor: Color(0xff000000),
          shadowBlur: 4.0,
        ),
        controlElements: ThemedColor(
          color: Color(0xffbdbdbd),
          shadowEnabled: false,
          shadowColor: Color(0x82ffffff),
          shadowBlur: 6.0,
        ),
        widgetIconText: ThemedColor(
          color: Color(0xc5dedede),
          shadowEnabled: false,
          shadowColor: Color(0xff676767),
          shadowBlur: 7.0,
        ),
        buttonIconText: ThemedColor(
          color: Color(0xff191919),
          shadowEnabled: false,
          shadowColor: Color(0x7dffffff),
          shadowBlur: 3.0,
        ),
        currentValueText: ThemedColor(
          color: Color(0xffbdbdbd),
          shadowEnabled: false,
          shadowColor: Color(0x75ffffff),
          shadowBlur: 5.0,
        ),
        sliderActiveSegment: ThemedColor(
          color: Color(0x72dedede),
          shadowEnabled: false,
          shadowColor: Color(0x80ffffff),
          shadowBlur: 3.5,
        ),
        sliderInactiveSegment: ThemedColor(
          color: Color(0x32dedede),
          shadowEnabled: false,
          shadowColor: Color(0x85ffffff),
          shadowBlur: 3.5,
        ),
        playlistDeleteButton: ThemedColor(
          color: Color(0xff1ac6ca),
          shadowEnabled: false,
          shadowColor: Color(0x79ffffff),
          shadowBlur: 3.0,
        ),
        gradientDividerShadow: ThemedColor(
          color: Color(0xff000000),
          shadowEnabled: false,
          shadowColor: Color(0x8Bffffff),
          shadowBlur: 3.0,
        ),
        topBarUpperShadow: ThemedColor(
          color: Color(0xff000000),
          shadowEnabled: false,
          shadowColor: Color(0x8B000000),
          shadowBlur: 3.0,
        ),
        jogBackgroundShadow: ThemedColor(
          color: Color(0xff000000),
          shadowEnabled: false,
          shadowColor: Color(0x8B000000),
          shadowBlur: 3.0,
        ),
        gradientDividerStart: Color(0x00414141),
        gradientDividerEnd: Color(0xff414141),
        topBarUpperStart: Color(0x88414141),
        topBarUpperEnd: Color(0x88272727),
        backgroundStart: Color(0x88000000),
        backgroundEnd: Color(0xff191919),
        jogBackgroundStart: Color(0xc5414141),
        jogBackgroundEnd: Color(0xc6272727),
      );

  factory AppThemeColors.light() => AppThemeColors(
        transitionType: AppTransitionType.none,
        backgroundImagePath: 'assets/backgrounds/light.png',
        backgroundImageDisplayName: '',
        useBackgroundImage: true,
        backgroundFitFill: false,
        backgroundFitCover: true,
        backgroundImageBrightness: 1.0,
        backgroundImageContrast: 1.0,
        backgroundImageOpacity: 1.0,
        navIconActive: ThemedColor(
          color: Color(0xff434343),
          shadowEnabled: true,
          shadowColor: Color(0xff8b8b8b),
          shadowBlur: 3.0,
        ),
        navIconInactive: ThemedColor(
          color: Color(0xff9e9e9e),
          shadowEnabled: true,
          shadowColor: Color(0x8b8b8b8b),
          shadowBlur: 3.0,
        ),
        displayIconActive: ThemedColor(
          color: Color(0xff434343),
          shadowEnabled: true,
          shadowColor: Color(0x8b8b8b8b),
          shadowBlur: 3.0,
        ),
        displayIconInactive: ThemedColor(
          color: Color(0xff9e9e9e),
          shadowEnabled: true,
          shadowColor: Color(0x8b8b8b8b),
          shadowBlur: 3.0,
        ),
        controlElements: ThemedColor(
          color: Color(0xff434343),
          shadowEnabled: true,
          shadowColor: Color(0x8b959595),
          shadowBlur: 3.0,
        ),
        widgetIconText: ThemedColor(
          color: Color(0xff000000),
          shadowEnabled: false,
          shadowColor: Color(0x8b8b8b8b),
          shadowBlur: 3.0,
        ),
        buttonIconText: ThemedColor(
          color: Color(0xffd0d0d0),
          shadowEnabled: false,
          shadowColor: Color(0x8b8b8b8b),
          shadowBlur: 3.0,
        ),
        currentValueText: ThemedColor(
          color: Color(0xff000000),
          shadowEnabled: true,
          shadowColor: Color(0x8b9d9d9d),
          shadowBlur: 3.0,
        ),
        sliderActiveSegment: ThemedColor(
          color: Color(0xde434343),
          shadowEnabled: true,
          shadowColor: Color(0x8b8b8b8b),
          shadowBlur: 3.0,
        ),
        sliderInactiveSegment: ThemedColor(
          color: Color(0x22434343),
          shadowEnabled: true,
          shadowColor: Color(0x8b8b8b8b),
          shadowBlur: 3.0,
        ),
        playlistDeleteButton: ThemedColor(
          color: Color(0xffe53935),
          shadowEnabled: true,
          shadowColor: Color(0x8b8b8b8b),
          shadowBlur: 3.0,
        ),
        gradientDividerShadow: ThemedColor(
          color: Color(0xff000000),
          shadowEnabled: true,
          shadowColor: Color(0x8bbebebe),
          shadowBlur: 3.0,
        ),
        topBarUpperShadow: ThemedColor(
          color: Color(0xff000000),
          shadowEnabled: true,
          shadowColor: Color(0x8bbebebe),
          shadowBlur: 3.0,
        ),
        jogBackgroundShadow: ThemedColor(
          color: Color(0xff000000),
          shadowEnabled: true,
          shadowColor: Color(0x8bbebebe),
          shadowBlur: 3.0,
        ),
        gradientDividerStart: Color(0xffbdbdbd),
        gradientDividerEnd: Color(0xff434343),
        topBarUpperStart: Color(0xffffffff),
        topBarUpperEnd: Color(0xffe7e7e7),
        backgroundStart: Color(0x88ffffff),
        backgroundEnd: Color(0xffffffff),
        jogBackgroundStart: Color(0xfff5f5f5),
        jogBackgroundEnd: Color(0xffbdbdbd),
      );

  factory AppThemeColors.custom() => AppThemeColors(
        transitionType: AppTransitionType.slide,
        backgroundImagePath: 'assets/backgrounds/custom.jpg',
        backgroundImageDisplayName: '',
        useBackgroundImage: true,
        backgroundFitFill: true,
        backgroundFitCover: false,
        backgroundImageBrightness: 1.0,
        backgroundImageContrast: 1.0,
        backgroundImageOpacity: 0.75,
        navIconActive: ThemedColor(
          color: Color(0xc240f4ff),
          shadowEnabled: true,
          shadowColor: Color(0x8B000000),
          shadowBlur: 4.0,
        ),
        navIconInactive: ThemedColor(
          color: Color(0xe31e757a),
          shadowEnabled: true,
          shadowColor: Color(0x8B000000),
          shadowBlur: 4.0,
        ),
        displayIconActive: ThemedColor(
          color: Color(0xc240f4ff),
          shadowEnabled: true,
          shadowColor: Color(0x8B000000),
          shadowBlur: 4.0,
        ),
        displayIconInactive: ThemedColor(
          color: Color(0xe31e757a),
          shadowEnabled: true,
          shadowColor: Color(0x8B000000),
          shadowBlur: 4.0,
        ),
        controlElements: ThemedColor(
          color: Color(0xb0cdff00),
          shadowEnabled: true,
          shadowColor: Color(0x8B000000),
          shadowBlur: 10.0,
        ),
        widgetIconText: ThemedColor(
          color: Color(0xb0cdff00),
          shadowEnabled: true,
          shadowColor: Color(0x8B000000),
          shadowBlur: 4.0,
        ),
        buttonIconText: ThemedColor(
          color: Color(0xff186367),
          shadowEnabled: false,
          shadowColor: Color(0x8B000000),
          shadowBlur: 4.0,
        ),
        currentValueText: ThemedColor(
          color: Color(0xf3cdff00),
          shadowEnabled: true,
          shadowColor: Color(0x8B000000),
          shadowBlur: 5.0,
        ),
        sliderActiveSegment: ThemedColor(
          color: Color(0xe32faeb6),
          shadowEnabled: false,
          shadowColor: Color(0x8Bff0000),
          shadowBlur: 4.0,
        ),
        sliderInactiveSegment: ThemedColor(
          color: Color(0x6f2faeb6),
          shadowEnabled: false,
          shadowColor: Color(0x8Bff0000),
          shadowBlur: 4.0,
        ),
        playlistDeleteButton: ThemedColor(
          color: Color(0xa6ff00db),
          shadowEnabled: true,
          shadowColor: Color(0x8B000000),
          shadowBlur: 4.0,
        ),
        gradientDividerShadow: ThemedColor(
          color: Color(0x00000000),
          shadowEnabled: true,
          shadowColor: Color(0x8B000000),
          shadowBlur: 4.0,
        ),
        topBarUpperShadow: ThemedColor(
          color: Color(0xff000000),
          shadowEnabled: true,
          shadowColor: Color(0x8B000000),
          shadowBlur: 4.0,
        ),
        jogBackgroundShadow: ThemedColor(
          color: Color(0xff000000),
          shadowEnabled: true,
          shadowColor: Color(0x8B000000),
          shadowBlur: 4.0,
        ),
        gradientDividerStart: Color(0x8Bcdff00),
        gradientDividerEnd: Color(0x8Bcdff00),
        topBarUpperStart: Color(0x8B158f97),
        topBarUpperEnd: Color(0x8B167379),
        backgroundStart: Color(0x8B000000),
        backgroundEnd: Color(0x8B222222),
        jogBackgroundStart: Color(0x8B21858b),
        jogBackgroundEnd: Color(0x8B2bbbc4),
      );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['transitionType'] = transitionType.name;
    map['backgroundImagePath'] = backgroundImagePath ?? '';
    map['backgroundImageDisplayName'] = backgroundImageDisplayName ?? '';
    map['useBackgroundImage'] = useBackgroundImage.toString();
    map['backgroundFitFill'] = backgroundFitFill.toString();
    map['backgroundFitCover'] = backgroundFitCover.toString();
    map['backgroundImageBrightness'] = backgroundImageBrightness?.toString();
    map['backgroundImageContrast'] = backgroundImageContrast?.toString();
    map['backgroundImageOpacity'] = backgroundImageOpacity?.toString();

    void addThemedColor(String key, ThemedColor c) {
      map['$key.color'] = c.color.value;
      map['$key.shadowEnabled'] = c.shadowEnabled;
      map['$key.shadowColor'] = c.shadowColor.value;
      map['$key.shadowBlur'] = c.shadowBlur;
    }

    void addColor(String key, Color c) {
      map[key] = c.value;
    }

    addThemedColor('navIconActive', navIconActive);
    addThemedColor('navIconInactive', navIconInactive);
    addThemedColor('displayIconActive', displayIconActive);
    addThemedColor('displayIconInactive', displayIconInactive);
    addThemedColor('controlElements', controlElements);
    addThemedColor('widgetIconText', widgetIconText);
    addThemedColor('buttonIconText', buttonIconText);
    addThemedColor('currentValueText', currentValueText);
    addThemedColor('sliderActiveSegment', sliderActiveSegment);
    addThemedColor('sliderInactiveSegment', sliderInactiveSegment);
    addThemedColor('playlistDeleteButton', playlistDeleteButton);
    addThemedColor('gradientDividerShadow', gradientDividerShadow);

    addColor('backgroundStart', backgroundStart);
    addColor('backgroundEnd', backgroundEnd);
    addColor('topBarUpperStart', topBarUpperStart);
    addColor('topBarUpperEnd', topBarUpperEnd);
    addColor('jogBackgroundStart', jogBackgroundStart);
    addColor('jogBackgroundEnd', jogBackgroundEnd);
    addColor('gradientDividerStart', gradientDividerStart);
    addColor('gradientDividerEnd', gradientDividerEnd);

    return map;
  }

  AppThemeColors copyWith({
    AppTransitionType? transitionType,
    String? backgroundImagePath,
    String? backgroundImageDisplayName,
    bool? useBackgroundImage,
    bool? backgroundFitFill,
    bool? backgroundFitCover,
    double? backgroundImageBrightness,
    double? backgroundImageContrast,
    double? backgroundImageOpacity,
    ThemedColor? navIconActive,
    ThemedColor? navIconInactive,
    ThemedColor? displayIconActive,
    ThemedColor? displayIconInactive,
    ThemedColor? controlElements,
    ThemedColor? widgetIconText,
    ThemedColor? buttonIconText,
    ThemedColor? currentValueText,
    ThemedColor? sliderActiveSegment,
    ThemedColor? sliderInactiveSegment,
    ThemedColor? playlistDeleteButton,
    ThemedColor? gradientDividerShadow,
    ThemedColor? topBarUpperShadow,
    ThemedColor? jogBackgroundShadow,
    Color? gradientDividerStart,
    Color? gradientDividerEnd,
    Color? topBarUpperStart,
    Color? topBarUpperEnd,
    Color? backgroundStart,
    Color? backgroundEnd,
    Color? jogBackgroundStart,
    Color? jogBackgroundEnd,
  }) {
    return AppThemeColors(
      transitionType: transitionType ?? this.transitionType,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      backgroundImageDisplayName:
          backgroundImageDisplayName ?? this.backgroundImageDisplayName,
      useBackgroundImage: useBackgroundImage ?? this.useBackgroundImage,
      backgroundFitFill: backgroundFitFill ?? this.backgroundFitFill,
      backgroundFitCover: backgroundFitCover ?? this.backgroundFitCover,
      backgroundImageBrightness:
          backgroundImageBrightness ?? this.backgroundImageBrightness,
      backgroundImageContrast:
          backgroundImageContrast ?? this.backgroundImageContrast,
      backgroundImageOpacity:
          backgroundImageOpacity ?? this.backgroundImageOpacity,
      navIconActive: navIconActive ?? this.navIconActive,
      navIconInactive: navIconInactive ?? this.navIconInactive,
      displayIconActive: displayIconActive ?? this.displayIconActive,
      displayIconInactive: displayIconInactive ?? this.displayIconInactive,
      controlElements: controlElements ?? this.controlElements,
      widgetIconText: widgetIconText ?? this.widgetIconText,
      buttonIconText: buttonIconText ?? this.buttonIconText,
      currentValueText: currentValueText ?? this.currentValueText,
      sliderActiveSegment: sliderActiveSegment ?? this.sliderActiveSegment,
      sliderInactiveSegment:
          sliderInactiveSegment ?? this.sliderInactiveSegment,
      playlistDeleteButton: playlistDeleteButton ?? this.playlistDeleteButton,
      gradientDividerShadow:
          gradientDividerShadow ?? this.gradientDividerShadow,
      topBarUpperShadow: topBarUpperShadow ?? this.topBarUpperShadow,
      jogBackgroundShadow: jogBackgroundShadow ?? this.jogBackgroundShadow,
      gradientDividerStart: gradientDividerStart ?? this.gradientDividerStart,
      gradientDividerEnd: gradientDividerEnd ?? this.gradientDividerEnd,
      topBarUpperStart: topBarUpperStart ?? this.topBarUpperStart,
      topBarUpperEnd: topBarUpperEnd ?? this.topBarUpperEnd,
      backgroundStart: backgroundStart ?? this.backgroundStart,
      backgroundEnd: backgroundEnd ?? this.backgroundEnd,
      jogBackgroundStart: jogBackgroundStart ?? this.jogBackgroundStart,
      jogBackgroundEnd: jogBackgroundEnd ?? this.jogBackgroundEnd,
    );
  }

  static AppThemeColors fromMap(Map<String, String> map) {
    Color parseColor(String? hex) =>
        Color(int.parse(hex ?? '0xff000000', radix: 16));
    bool parseBool(String? s) => s == 'true';
    double parseDouble(String? s) => double.tryParse(s ?? '') ?? 0;

    ThemedColor themed(String key) => ThemedColor(
          color: parseColor(map['$key.color']),
          shadowEnabled: parseBool(map['$key.shadowEnabled']),
          shadowColor: parseColor(map['$key.shadowColor']),
          shadowBlur: parseDouble(map['$key.shadowBlur']),
        );

    return AppThemeColors(
      transitionType: map['transitionType'] != null
          ? AppTransitionType.values.firstWhere(
              (e) => e.name == map['transitionType'],
              orElse: () => AppTransitionType.slide,
            )
          : AppTransitionType.slide,
      backgroundImagePath: map['backgroundImagePath'],
      backgroundImageDisplayName: map['backgroundImageDisplayName'],
      useBackgroundImage: parseBool(map['useBackgroundImage']),
      backgroundFitFill: parseBool(map['backgroundFitFill']),
      backgroundFitCover: parseBool(map['backgroundFitCover']),
      backgroundImageBrightness: parseDouble(map['backgroundImageBrightness']),
      backgroundImageContrast: parseDouble(map['backgroundImageContrast']),
      backgroundImageOpacity: parseDouble(map['backgroundImageOpacity']),
      navIconActive: themed('navIconActive'),
      navIconInactive: themed('navIconInactive'),
      displayIconActive: themed('displayIconActive'),
      displayIconInactive: themed('displayIconInactive'),
      controlElements: themed('controlElements'),
      widgetIconText: themed('widgetIconText'),
      buttonIconText: themed('buttonIconText'),
      currentValueText: themed('currentValueText'),
      sliderActiveSegment: themed('sliderActiveSegment'),
      sliderInactiveSegment: themed('sliderInactiveSegment'),
      playlistDeleteButton: themed('playlistDeleteButton'),
      gradientDividerShadow: themed('gradientDividerShadow'),
      topBarUpperShadow: themed('topBarUpperShadow'),
      jogBackgroundShadow: themed('jogBackgroundShadow'),
      gradientDividerStart: parseColor(map['gradientDividerStart']),
      gradientDividerEnd: parseColor(map['gradientDividerEnd']),
      topBarUpperStart: parseColor(map['topBarUpperStart']),
      topBarUpperEnd: parseColor(map['topBarUpperEnd']),
      backgroundStart: parseColor(map['backgroundStart']),
      backgroundEnd: parseColor(map['backgroundEnd']),
      jogBackgroundStart: parseColor(map['jogBackgroundStart']),
      jogBackgroundEnd: parseColor(map['jogBackgroundEnd']),
    );
  }

  static List<String> get colorKeys => [
        'transitionType',
        'backgroundImagePath',
        'backgroundImageDisplayName',
        'useBackgroundImage',
        'backgroundFitFill',
        'backgroundFitCover',
        'backgroundImageBrightness',
        'backgroundImageContrast',
        'backgroundImageOpacity',
        'navIconActive.color',
        'navIconActive.shadowEnabled',
        'navIconActive.shadowColor',
        'navIconActive.shadowBlur',
        'navIconInactive.color',
        'navIconInactive.shadowEnabled',
        'navIconInactive.shadowColor',
        'navIconInactive.shadowBlur',
        'displayIconActive.color',
        'displayIconActive.shadowEnabled',
        'displayIconActive.shadowColor',
        'displayIconActive.shadowBlur',
        'displayIconInactive.color',
        'displayIconInactive.shadowEnabled',
        'displayIconInactive.shadowColor',
        'displayIconInactive.shadowBlur',
        'controlElements.color',
        'controlElements.shadowEnabled',
        'controlElements.shadowColor',
        'controlElements.shadowBlur',
        'widgetIconText.color',
        'widgetIconText.shadowEnabled',
        'widgetIconText.shadowColor',
        'widgetIconText.shadowBlur',
        'buttonIconText.color',
        'buttonIconText.shadowEnabled',
        'buttonIconText.shadowColor',
        'buttonIconText.shadowBlur',
        'currentValueText.color',
        'currentValueText.shadowEnabled',
        'currentValueText.shadowColor',
        'currentValueText.shadowBlur',
        'sliderActiveSegment.color',
        'sliderActiveSegment.shadowEnabled',
        'sliderActiveSegment.shadowColor',
        'sliderActiveSegment.shadowBlur',
        'sliderInactiveSegment.color',
        'sliderInactiveSegment.shadowEnabled',
        'sliderInactiveSegment.shadowColor',
        'sliderInactiveSegment.shadowBlur',
        'playlistDeleteButton.color',
        'playlistDeleteButton.shadowEnabled',
        'playlistDeleteButton.shadowColor',
        'playlistDeleteButton.shadowBlur',
        'gradientDividerShadow.color',
        'gradientDividerShadow.shadowEnabled',
        'gradientDividerShadow.shadowColor',
        'gradientDividerShadow.shadowBlur',
        'backgroundStart',
        'backgroundEnd',
        'topBarUpperStart',
        'topBarUpperEnd',
        'jogBackgroundStart',
        'jogBackgroundEnd',
        'gradientDividerStart',
        'gradientDividerEnd',
      ];
}
