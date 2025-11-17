import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @searchBarHintText.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchBarHintText;

  /// No description provided for @showWelcomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get showWelcomeScreen;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeTitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Thank you for choosing ListenMe Player!\n\nYour indispensable tool for working with audio: fast and precise search, convenient controls, and full interface personalization. Maximum comfort and total control always at your fingertips.'**
  String get welcomeDescription;

  /// No description provided for @welcomePolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Information'**
  String get welcomePolicyTitle;

  /// No description provided for @welcomePolicy.
  ///
  /// In en, this message translates to:
  /// **'The application does not verify the presence of a license or copyright for uploaded files. Users are solely responsible for their use.'**
  String get welcomePolicy;

  /// No description provided for @welcomeCopies.
  ///
  /// In en, this message translates to:
  /// **'To ensure the operation of certain features, the application creates temporary low-quality copies of audio files. These copies are stored locally only and are automatically deleted when the original files are removed from playlists.'**
  String get welcomeCopies;

  /// No description provided for @welcomeBackgroundImagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Background Images'**
  String get welcomeBackgroundImagesTitle;

  /// No description provided for @welcomeBackgroundImagesIntro.
  ///
  /// In en, this message translates to:
  /// **'Background images are provided by Unsplash (https://unsplash.com) from the following authors:'**
  String get welcomeBackgroundImagesIntro;

  /// No description provided for @welcomeLegalSummary1.
  ///
  /// In en, this message translates to:
  /// **'ListenMe Player does not collect your personal data, does not analyze your files outside your device, and does not share them with third parties.'**
  String get welcomeLegalSummary1;

  /// No description provided for @welcomeLegalSummary2.
  ///
  /// In en, this message translates to:
  /// **'You are solely responsible for the lawful use of audio files.'**
  String get welcomeLegalSummary2;

  /// No description provided for @welcomeLegalSummary3.
  ///
  /// In en, this message translates to:
  /// **'The app requires permission to access your device storage in order to play audio files. This access is used only within the app and does not involve sharing your data with third parties.'**
  String get welcomeLegalSummary3;

  /// No description provided for @welcomeLegalSummary4.
  ///
  /// In en, this message translates to:
  /// **'For some features, temporary audio copies are created and stored only on your device.'**
  String get welcomeLegalSummary4;

  /// No description provided for @welcomeLegalDetails.
  ///
  /// In en, this message translates to:
  /// **'Read more in the privacy policy'**
  String get welcomeLegalDetails;

  /// No description provided for @welcomeLegalAgreeNotice.
  ///
  /// In en, this message translates to:
  /// **'By clicking \"Continue\", you agree to the terms.'**
  String get welcomeLegalAgreeNotice;

  /// No description provided for @buttonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get buttonNext;

  /// No description provided for @buttonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get buttonBack;

  /// No description provided for @buttonAgree.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get buttonAgree;

  /// No description provided for @buttonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// No description provided for @interfaceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Interface language'**
  String get interfaceLanguage;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @widgetOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Widget display order'**
  String get widgetOrderTitle;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get lightTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System theme'**
  String get systemTheme;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @playback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playback;

  /// No description provided for @jogAndSeek.
  ///
  /// In en, this message translates to:
  /// **'Jog and seek'**
  String get jogAndSeek;

  /// No description provided for @interface.
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get interface;

  /// No description provided for @timecode.
  ///
  /// In en, this message translates to:
  /// **'Timecode'**
  String get timecode;

  /// No description provided for @secondaryTimeTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Secondary time display mode'**
  String get secondaryTimeTypeTitle;

  /// No description provided for @secondaryTimeTypeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining time'**
  String get secondaryTimeTypeRemaining;

  /// No description provided for @secondaryTimeTypeTotalDuration.
  ///
  /// In en, this message translates to:
  /// **'Track duration'**
  String get secondaryTimeTypeTotalDuration;

  /// No description provided for @backgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Background image'**
  String get backgroundImage;

  /// No description provided for @chooseBackgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Choose image'**
  String get chooseBackgroundImage;

  /// No description provided for @resetBackgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Reset image'**
  String get resetBackgroundImage;

  /// No description provided for @useBackgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Use background image'**
  String get useBackgroundImage;

  /// No description provided for @stretchToFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Stretch to full screen'**
  String get stretchToFullScreen;

  /// No description provided for @fillScreen.
  ///
  /// In en, this message translates to:
  /// **'Fill screen'**
  String get fillScreen;

  /// No description provided for @transparency.
  ///
  /// In en, this message translates to:
  /// **'Transparency: {value}%'**
  String transparency(Object value);

  /// No description provided for @themeSelection.
  ///
  /// In en, this message translates to:
  /// **'Theme selection'**
  String get themeSelection;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select theme'**
  String get selectTheme;

  /// No description provided for @saveCurrentTheme.
  ///
  /// In en, this message translates to:
  /// **'Save current theme'**
  String get saveCurrentTheme;

  /// No description provided for @resetToFactory.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetToFactory;

  /// No description provided for @themeSaved.
  ///
  /// In en, this message translates to:
  /// **'Theme \"{theme}\" saved'**
  String themeSaved(Object theme);

  /// No description provided for @themeReset.
  ///
  /// In en, this message translates to:
  /// **'Theme \"{theme}\" reset'**
  String themeReset(Object theme);

  /// No description provided for @colorSettings.
  ///
  /// In en, this message translates to:
  /// **'Color settings'**
  String get colorSettings;

  /// No description provided for @main.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get main;

  /// No description provided for @shadow.
  ///
  /// In en, this message translates to:
  /// **'---------------  Shadow  ---------------'**
  String get shadow;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'color'**
  String get color;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'on/off'**
  String get enabled;

  /// No description provided for @blur.
  ///
  /// In en, this message translates to:
  /// **'blur'**
  String get blur;

  /// No description provided for @gradientSettings.
  ///
  /// In en, this message translates to:
  /// **'Gradient settings'**
  String get gradientSettings;

  /// No description provided for @navIconsActive.
  ///
  /// In en, this message translates to:
  /// **'Navigation icons - active'**
  String get navIconsActive;

  /// No description provided for @navIconsInactive.
  ///
  /// In en, this message translates to:
  /// **'Navigation icons - inactive'**
  String get navIconsInactive;

  /// No description provided for @displayIconsActive.
  ///
  /// In en, this message translates to:
  /// **'Bottom row icons - active'**
  String get displayIconsActive;

  /// No description provided for @displayIconsInactive.
  ///
  /// In en, this message translates to:
  /// **'Bottom row icons - inactive'**
  String get displayIconsInactive;

  /// No description provided for @controlElements.
  ///
  /// In en, this message translates to:
  /// **'Control Elements'**
  String get controlElements;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @contrast.
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get contrast;

  /// No description provided for @widgetIconsText.
  ///
  /// In en, this message translates to:
  /// **'Widget icons/text'**
  String get widgetIconsText;

  /// No description provided for @buttonIconsText.
  ///
  /// In en, this message translates to:
  /// **'Button icons/text'**
  String get buttonIconsText;

  /// No description provided for @mainText.
  ///
  /// In en, this message translates to:
  /// **'Main text'**
  String get mainText;

  /// No description provided for @sliderActive.
  ///
  /// In en, this message translates to:
  /// **'Slider - active part'**
  String get sliderActive;

  /// No description provided for @sliderInactive.
  ///
  /// In en, this message translates to:
  /// **'Slider - inactive part'**
  String get sliderInactive;

  /// No description provided for @playlistDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Track delete button (in playlist)'**
  String get playlistDeleteButton;

  /// No description provided for @startEnd.
  ///
  /// In en, this message translates to:
  /// **'1         2'**
  String get startEnd;

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @divider.
  ///
  /// In en, this message translates to:
  /// **'Divider'**
  String get divider;

  /// No description provided for @topBar.
  ///
  /// In en, this message translates to:
  /// **'Top bar'**
  String get topBar;

  /// No description provided for @jog.
  ///
  /// In en, this message translates to:
  /// **'Jog'**
  String get jog;

  /// No description provided for @pickColor.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get pickColor;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @jogResolution.
  ///
  /// In en, this message translates to:
  /// **'Jog resolution'**
  String get jogResolution;

  /// No description provided for @secondsPerRevolution.
  ///
  /// In en, this message translates to:
  /// **'Sek/Umdr'**
  String get secondsPerRevolution;

  /// No description provided for @minSeekSpeed.
  ///
  /// In en, this message translates to:
  /// **'Seek speed (minimum)'**
  String get minSeekSpeed;

  /// No description provided for @maxSeekSpeed.
  ///
  /// In en, this message translates to:
  /// **'Seek speed (maximum)'**
  String get maxSeekSpeed;

  /// No description provided for @playbackButtonType.
  ///
  /// In en, this message translates to:
  /// **'Playback button type'**
  String get playbackButtonType;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @extended.
  ///
  /// In en, this message translates to:
  /// **'Extended'**
  String get extended;

  /// No description provided for @precise.
  ///
  /// In en, this message translates to:
  /// **'Precise'**
  String get precise;

  /// No description provided for @playbackSpeedRange.
  ///
  /// In en, this message translates to:
  /// **'Playback speed range'**
  String get playbackSpeedRange;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get min;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @timeFormatTitle.
  ///
  /// In en, this message translates to:
  /// **'Time display format'**
  String get timeFormatTitle;

  /// No description provided for @timeFormatMmss.
  ///
  /// In en, this message translates to:
  /// **'MM:SS'**
  String get timeFormatMmss;

  /// No description provided for @timeFormatMmss2digitMillis.
  ///
  /// In en, this message translates to:
  /// **'MM:SS:MM'**
  String get timeFormatMmss2digitMillis;

  /// No description provided for @timeFormatMmss3digitMillis.
  ///
  /// In en, this message translates to:
  /// **'MM:SS:MMM'**
  String get timeFormatMmss3digitMillis;

  /// No description provided for @autoHoursHint.
  ///
  /// In en, this message translates to:
  /// **'Hours are shown automatically if the track is longer than 1 hour.'**
  String get autoHoursHint;

  /// No description provided for @widgetTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Track title'**
  String get widgetTrackTitle;

  /// No description provided for @widgetPositionGroup.
  ///
  /// In en, this message translates to:
  /// **'Position and marker block'**
  String get widgetPositionGroup;

  /// No description provided for @widgetPlaybackButtons.
  ///
  /// In en, this message translates to:
  /// **'Playback buttons'**
  String get widgetPlaybackButtons;

  /// No description provided for @widgetJog.
  ///
  /// In en, this message translates to:
  /// **'Jog and buttons'**
  String get widgetJog;

  /// No description provided for @widgetSpeedSlider.
  ///
  /// In en, this message translates to:
  /// **'Speed slider'**
  String get widgetSpeedSlider;

  /// No description provided for @widgetSilenceBar.
  ///
  /// In en, this message translates to:
  /// **'Silence panel'**
  String get widgetSilenceBar;

  /// No description provided for @transparencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Transparency'**
  String get transparencyLabel;

  /// No description provided for @themeWord.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeWord;

  /// No description provided for @savedWord.
  ///
  /// In en, this message translates to:
  /// **'saved'**
  String get savedWord;

  /// No description provided for @resetWord.
  ///
  /// In en, this message translates to:
  /// **'reset'**
  String get resetWord;

  /// No description provided for @themeStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get themeStandard;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get themeCustom;

  /// No description provided for @msPerSec.
  ///
  /// In en, this message translates to:
  /// **'ms/Sek'**
  String get msPerSec;

  /// No description provided for @noTrack.
  ///
  /// In en, this message translates to:
  /// **'No track'**
  String get noTrack;

  /// No description provided for @helpMenu.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpMenu;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get aboutApp;

  /// No description provided for @widgets.
  ///
  /// In en, this message translates to:
  /// **'Widgets'**
  String get widgets;

  /// No description provided for @playlistHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlistHelpTitle;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @copyrightText.
  ///
  /// In en, this message translates to:
  /// **'© 2025 Flitein. All rights reserved.'**
  String get copyrightText;

  /// No description provided for @transitionBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Transition animation'**
  String get transitionBlockTitle;

  /// No description provided for @transitionTypeSlide.
  ///
  /// In en, this message translates to:
  /// **'Slide'**
  String get transitionTypeSlide;

  /// No description provided for @transitionTypeFade.
  ///
  /// In en, this message translates to:
  /// **'Fade'**
  String get transitionTypeFade;

  /// No description provided for @transitionTypeScale.
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get transitionTypeScale;

  /// No description provided for @transitionTypeNone.
  ///
  /// In en, this message translates to:
  /// **'No animation'**
  String get transitionTypeNone;

  /// No description provided for @helpTopBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation Menu'**
  String get helpTopBarTitle;

  /// No description provided for @helpTopBarLogoBack.
  ///
  /// In en, this message translates to:
  /// **'App logo. When you open a settings or help submenu, a \'back\' arrow appears here, returning you to the corresponding root menu.'**
  String get helpTopBarLogoBack;

  /// No description provided for @helpTopBarHome.
  ///
  /// In en, this message translates to:
  /// **'Button to go to the home screen. Here you\'ll find all the main widgets for controlling the player.'**
  String get helpTopBarHome;

  /// No description provided for @helpTopBarFolderPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Button to open the folder playlist. Here, you can play tracks directly from a selected folder on your device\'s internal or external storage. The main advantage is that you don\'t need to create a playlist in advance and can quickly find the audio files you need.'**
  String get helpTopBarFolderPlaylist;

  /// No description provided for @helpTopBarManualPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Button to open the manual playlist. Here you can add only the tracks you need. Tracks can be located in different folders or even on different storage devices. In this playlist, you can change the playback order by simply dragging tracks, add the same track any number of times, and remove tracks one by one or all at once.'**
  String get helpTopBarManualPlaylist;

  /// No description provided for @helpTopBarSettings.
  ///
  /// In en, this message translates to:
  /// **'Button to open the settings menu. Here you can configure options like interface language, themes, widgets, and more.'**
  String get helpTopBarSettings;

  /// No description provided for @helpTopBarHelp.
  ///
  /// In en, this message translates to:
  /// **'Button to open the help menu.'**
  String get helpTopBarHelp;

  /// No description provided for @helpTopBarEdit.
  ///
  /// In en, this message translates to:
  /// **'Button to activate widget arrangement editing mode on the home screen. In this mode, you can add or remove widgets and change their positions by dragging, customizing your home screen the way you want.'**
  String get helpTopBarEdit;

  /// No description provided for @helpTopBarDescription.
  ///
  /// In en, this message translates to:
  /// **'This menu is always at the top of the app. All navigation is done via the icon buttons. The settings and help menus also contain submenu items. To return from a submenu to the root menu, press the panel icon again or use the back arrow in the top or system menu.'**
  String get helpTopBarDescription;

  /// No description provided for @helpGeneralControlsTitle.
  ///
  /// In en, this message translates to:
  /// **'Control Panel'**
  String get helpGeneralControlsTitle;

  /// No description provided for @helpGeneralControlsSchowSilenceControlBar.
  ///
  /// In en, this message translates to:
  /// **'\"Show/Hide\" button for the silence jump widget.'**
  String get helpGeneralControlsSchowSilenceControlBar;

  /// No description provided for @helpGeneralControlsSchowPlayback.
  ///
  /// In en, this message translates to:
  /// **'\"Show/Hide\" button for the playback control buttons widget.'**
  String get helpGeneralControlsSchowPlayback;

  /// No description provided for @helpGeneralControlsSchowJog.
  ///
  /// In en, this message translates to:
  /// **'\"Show/Hide\" button for the jog widget.'**
  String get helpGeneralControlsSchowJog;

  /// No description provided for @helpGeneralControlsSchowSpeedSlider.
  ///
  /// In en, this message translates to:
  /// **'\"Show/Hide\" button for the playback speed slider widget.'**
  String get helpGeneralControlsSchowSpeedSlider;

  /// No description provided for @helpGeneralControlsPlaybackMode.
  ///
  /// In en, this message translates to:
  /// **'Button to switch playback mode. Repeated presses cycle through modes: -> \"1 track once\" -> \"1 track loop\" -> \"playlist once\" -> \"playlist loop\" -> \"shuffle\" ->. If segment playback mode is activated with button (7) and markers, only two modes are available: -> \"once\" -> \"loop\" ->.'**
  String get helpGeneralControlsPlaybackMode;

  /// No description provided for @helpGeneralControlsSchowMarkers.
  ///
  /// In en, this message translates to:
  /// **'\"Show/Hide\" button for track segment markers. Simply displaying the markers does not automatically activate segment playback. To activate, press button (7).'**
  String get helpGeneralControlsSchowMarkers;

  /// No description provided for @helpGeneralControlsActivatePlayBetweenMarkers.
  ///
  /// In en, this message translates to:
  /// **'\"Activate/Deactivate\" button for segment playback using markers. The selected segment will play once or in a loop, depending on the mode selected with button (5). If the markers are set incorrectly (at the same place or outside the track), this mode will not be activated.'**
  String get helpGeneralControlsActivatePlayBetweenMarkers;

  /// No description provided for @helpGeneralControlsDescription.
  ///
  /// In en, this message translates to:
  /// **'Note: \"Show/Hide\" widget buttons are for temporarily disabling unnecessary widgets, even if they were added in editing mode (see \"Navigation Menu\"). This is useful if you often switch between different tasks, such as regular music listening and working with text or listening exercises that require additional audio tools.'**
  String get helpGeneralControlsDescription;

  /// No description provided for @helpProgressSliderTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress Bar'**
  String get helpProgressSliderTitle;

  /// No description provided for @helpProgressSliderMinusButtons.
  ///
  /// In en, this message translates to:
  /// **'Buttons for fine-tuning marker positions. Pressing and holding the button changes the marker\'s position with increasing speed.'**
  String get helpProgressSliderMinusButtons;

  /// No description provided for @helpProgressSliderPosition.
  ///
  /// In en, this message translates to:
  /// **'Current track position in *hours:minutes:seconds:**milliseconds.'**
  String get helpProgressSliderPosition;

  /// No description provided for @helpProgressSliderMarkerA.
  ///
  /// In en, this message translates to:
  /// **'Start marker for segment playback (if it is to the left of the lower marker). Double-tapping the marker scale automatically sets the marker opposite the playhead.'**
  String get helpProgressSliderMarkerA;

  /// No description provided for @helpProgressSliderPlayHead.
  ///
  /// In en, this message translates to:
  /// **'Playback cursor / position slider. Lets you visually see the current track position and roughly set a new one.'**
  String get helpProgressSliderPlayHead;

  /// No description provided for @helpProgressSliderMarkerB.
  ///
  /// In en, this message translates to:
  /// **'End marker for segment playback (if it is to the right of the upper marker). Double-tapping the marker scale automatically sets the marker opposite the playhead.'**
  String get helpProgressSliderMarkerB;

  /// No description provided for @helpProgressSliderDuration.
  ///
  /// In en, this message translates to:
  /// **'Remaining track time /**total track duration in *hours:minutes:seconds:**milliseconds.'**
  String get helpProgressSliderDuration;

  /// No description provided for @helpProgressSliderPlusButtons.
  ///
  /// In en, this message translates to:
  /// **'Buttons for fine-tuning marker positions. Pressing and holding the button changes the marker\'s position with increasing speed.'**
  String get helpProgressSliderPlusButtons;

  /// No description provided for @helpProgressSliderDescription.
  ///
  /// In en, this message translates to:
  /// **'*Appears automatically if the track duration exceeds 60 minutes.\n**The display format can be set in the \"Settings/Timecode\" menu.\nMarkers are only displayed if activated on the control panel with button (6). The order in which you set markers does not matter.'**
  String get helpProgressSliderDescription;

  /// No description provided for @helpPlaybackStandardTitle.
  ///
  /// In en, this message translates to:
  /// **'Standard Playback Controls'**
  String get helpPlaybackStandardTitle;

  /// No description provided for @helpPlaybackExtendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Extended Playback Controls'**
  String get helpPlaybackExtendedTitle;

  /// No description provided for @helpPlaybackPreciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Precise Playback Controls'**
  String get helpPlaybackPreciseTitle;

  /// No description provided for @helpPlaybackPrevTrack.
  ///
  /// In en, this message translates to:
  /// **'Button to switch to the previous track / start of the track or segment, depending on playback mode.'**
  String get helpPlaybackPrevTrack;

  /// No description provided for @helpPlaybackJumpBack30.
  ///
  /// In en, this message translates to:
  /// **'Button to jump back 30 seconds.'**
  String get helpPlaybackJumpBack30;

  /// No description provided for @helpPlaybackJumpBack5.
  ///
  /// In en, this message translates to:
  /// **'Button to jump back 5 seconds.'**
  String get helpPlaybackJumpBack5;

  /// No description provided for @helpPlaybackRewind.
  ///
  /// In en, this message translates to:
  /// **'Rewind button. Holding the button increases rewind speed.'**
  String get helpPlaybackRewind;

  /// No description provided for @helpPlaybackPlayPause.
  ///
  /// In en, this message translates to:
  /// **'\"Play/Pause\" button. Starts or stops playback.'**
  String get helpPlaybackPlayPause;

  /// No description provided for @helpPlaybackFastForward.
  ///
  /// In en, this message translates to:
  /// **'Fast forward button. Holding the button increases fast forward speed.'**
  String get helpPlaybackFastForward;

  /// No description provided for @helpPlaybackJumpForward5.
  ///
  /// In en, this message translates to:
  /// **'Button to jump forward 5 seconds.'**
  String get helpPlaybackJumpForward5;

  /// No description provided for @helpPlaybackJumpForward30.
  ///
  /// In en, this message translates to:
  /// **'Button to jump forward 30 seconds.'**
  String get helpPlaybackJumpForward30;

  /// No description provided for @helpPlaybackNextTrack.
  ///
  /// In en, this message translates to:
  /// **'Button to switch to the next track / end of the track or segment, depending on playback mode.'**
  String get helpPlaybackNextTrack;

  /// No description provided for @helpPlaybackStandardDescription.
  ///
  /// In en, this message translates to:
  /// **'This widget is for simplified playback control if you do not need special features.'**
  String get helpPlaybackStandardDescription;

  /// No description provided for @helpPlaybackExtendedDescription.
  ///
  /// In en, this message translates to:
  /// **'This widget allows rough or more precise searching for the required part of the track if you do not need extra accuracy.'**
  String get helpPlaybackExtendedDescription;

  /// No description provided for @helpPlaybackPreciseDescription.
  ///
  /// In en, this message translates to:
  /// **'This widget provides both rough and very precise searching for the required part of the track.'**
  String get helpPlaybackPreciseDescription;

  /// No description provided for @helpJogTitle.
  ///
  /// In en, this message translates to:
  /// **'Jog'**
  String get helpJogTitle;

  /// No description provided for @helpJogPrevTrack.
  ///
  /// In en, this message translates to:
  /// **'Button to switch to the previous track / start of the track or segment, depending on playback mode.'**
  String get helpJogPrevTrack;

  /// No description provided for @helpJogRewind.
  ///
  /// In en, this message translates to:
  /// **'Rewind button. The rewind speed depends on the area of the button you press. At the bottom, the speed is slow, at the top, it\'s fast. You can slide along the button to change the speed. The speed limits can be set in the \"Settings/Jog\" menu.'**
  String get helpJogRewind;

  /// No description provided for @helpJogPlayPauseKnob.
  ///
  /// In en, this message translates to:
  /// **'Jog. Allows you to start and stop playback, and precisely set the current track position by turning the knob in the desired direction. Turning clockwise moves forward, counterclockwise moves backward. By default, one full turn changes the position by 5 seconds. This value (jog resolution) can be changed in the \"Settings/Jog\" menu.'**
  String get helpJogPlayPauseKnob;

  /// No description provided for @helpJogFastForward.
  ///
  /// In en, this message translates to:
  /// **'Fast forward button. Works the same as (2).'**
  String get helpJogFastForward;

  /// No description provided for @helpJogNextTrack.
  ///
  /// In en, this message translates to:
  /// **'Button to switch to the next track / end of the track or segment, depending on playback mode.'**
  String get helpJogNextTrack;

  /// No description provided for @helpJogDescription.
  ///
  /// In en, this message translates to:
  /// **'This widget is for precise positioning tasks, such as quickly finding the start of phrases—especially with short phrases, when you need to listen to a fragment many times or just set the playback cursor to the required millisecond.'**
  String get helpJogDescription;

  /// No description provided for @helpSpeedSliderTitle.
  ///
  /// In en, this message translates to:
  /// **'Playback Speed Slider'**
  String get helpSpeedSliderTitle;

  /// No description provided for @helpSpeedSliderMinusButton.
  ///
  /// In en, this message translates to:
  /// **'Button to decrease playback speed by 0.1x (10%).'**
  String get helpSpeedSliderMinusButton;

  /// No description provided for @helpSpeedSliderThumb.
  ///
  /// In en, this message translates to:
  /// **'Playback speed slider knob. Lets you quickly set the desired speed. Double-tap the slider to reset to the normal speed (1x).'**
  String get helpSpeedSliderThumb;

  /// No description provided for @helpSpeedSliderPlusButton.
  ///
  /// In en, this message translates to:
  /// **'Button to increase playback speed by 0.1x (10%).'**
  String get helpSpeedSliderPlusButton;

  /// No description provided for @helpSpeedSliderDescription.
  ///
  /// In en, this message translates to:
  /// **'Note: Speed limits can be set in the \"Settings/Playback\" menu.'**
  String get helpSpeedSliderDescription;

  /// No description provided for @helpSilenceControlBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Silence Jump Widget'**
  String get helpSilenceControlBarTitle;

  /// No description provided for @helpSilenceControlBarJumpPrevPhrase.
  ///
  /// In en, this message translates to:
  /// **'Button to jump to the start of the previous phrase.'**
  String get helpSilenceControlBarJumpPrevPhrase;

  /// No description provided for @helpSilenceControlBarPCMLevel.
  ///
  /// In en, this message translates to:
  /// **'Audio signal level indicator. During playback, it shows the audio signal level in real time. It helps you set the correct silence detection threshold.'**
  String get helpSilenceControlBarPCMLevel;

  /// No description provided for @helpSilenceControlBarThumb.
  ///
  /// In en, this message translates to:
  /// **'Slider for setting the silence detection threshold. Its position determines what audio signal level is considered the start of a phrase. If there\'s no background noise in the audio file, it\'s worth using lower threshold values. Then the jump buttons can find phrases more accurately. If there is significant background noise, you should increase the threshold value, otherwise some phrases may not be detected. The threshold should be chosen by experimentation. It is recommended to start with medium values.'**
  String get helpSilenceControlBarThumb;

  /// No description provided for @helpSilenceControlBarJumpNextPhrase.
  ///
  /// In en, this message translates to:
  /// **'Button to jump to the start of the next phrase.'**
  String get helpSilenceControlBarJumpNextPhrase;

  /// No description provided for @helpSilenceControlBarDescription.
  ///
  /// In en, this message translates to:
  /// **'This widget is for convenient navigation by phrases in an audio file. It is well suited for detailed listening to interviews, audiobooks, dialogues (for example, when learning foreign languages).\nNote: After switching the track or changing the slider position, a spinning indicator may appear briefly, indicating audio file analysis is in progress. During this time, the phrase jump buttons may not function precisely.'**
  String get helpSilenceControlBarDescription;

  /// No description provided for @helpManualPlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get helpManualPlaylistTitle;

  /// No description provided for @helpManualPlaylistOpen.
  ///
  /// In en, this message translates to:
  /// **'Button to open the file picker for adding tracks to the playlist.'**
  String get helpManualPlaylistOpen;

  /// No description provided for @helpManualPlaylistClear.
  ///
  /// In en, this message translates to:
  /// **'Button to clear the entire playlist.'**
  String get helpManualPlaylistClear;

  /// No description provided for @helpManualPlaylistSearch.
  ///
  /// In en, this message translates to:
  /// **'A panel to search for a track by a fragment of its title. Allows you to quickly find the desired track in the list.'**
  String get helpManualPlaylistSearch;

  /// No description provided for @helpManualPlaylistDrag.
  ///
  /// In en, this message translates to:
  /// **'Handle for moving a track to a different position in the list. Used to change the order of tracks in the playlist. If you pull the handle of the desired track up or down, the track will \'pop out\' of its slot and can be placed in a new position.'**
  String get helpManualPlaylistDrag;

  /// No description provided for @helpManualPlaylistFilename.
  ///
  /// In en, this message translates to:
  /// **'The name of the audio file with its extension. Pressing and holding a track opens a window with some information about the file and audio data.'**
  String get helpManualPlaylistFilename;

  /// No description provided for @helpManualPlaylistNumber.
  ///
  /// In en, this message translates to:
  /// **'Track number in the playlist, track duration, and file extension/format.'**
  String get helpManualPlaylistNumber;

  /// No description provided for @helpManualPlaylistDelete.
  ///
  /// In en, this message translates to:
  /// **'Button to remove a track from the playlist.'**
  String get helpManualPlaylistDelete;

  /// No description provided for @helpManualPlaylistDescription.
  ///
  /// In en, this message translates to:
  /// **'Notes.\n-The row of the active track in the playlist, which is currently playing or paused, is highlighted.\n-Tapping another track in the playlist automatically starts its playback.\n-In this example, a manual playlist is shown. The folder playlist functions the same way, except that playback is started directly from the selected folder, the order of tracks cannot be changed, and tracks cannot be removed.\n-The playlist in which the track was selected for playback becomes active automatically.'**
  String get helpManualPlaylistDescription;

  /// No description provided for @iapRemoveAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get iapRemoveAdsTitle;

  /// No description provided for @iapRemoveAdsDescription.
  ///
  /// In en, this message translates to:
  /// **'You can completely remove all ads by making a one-time purchase. This will support the development of ListenMe Player and make using the app even more convenient.'**
  String get iapRemoveAdsDescription;

  /// No description provided for @iapRemoveAdsButton.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads — {price}'**
  String iapRemoveAdsButton(Object price);

  /// No description provided for @iapRestorePurchaseButton.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get iapRestorePurchaseButton;

  /// No description provided for @iapAdsRemovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for purchasing\nListenMe Player!\n\nAds have been removed. You are using the full version.'**
  String get iapAdsRemovedMessage;

  /// No description provided for @iapNotFound.
  ///
  /// In en, this message translates to:
  /// **'Purchase not found.'**
  String get iapNotFound;

  /// No description provided for @iapRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchase restored.'**
  String get iapRestored;

  /// No description provided for @iapAlreadyOwned.
  ///
  /// In en, this message translates to:
  /// **'You already own the full version.'**
  String get iapAlreadyOwned;

  /// No description provided for @iapShopUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Store unavailable.'**
  String get iapShopUnavailable;

  /// No description provided for @iapProductNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found.'**
  String get iapProductNotFound;

  /// No description provided for @iapThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your purchase!'**
  String get iapThankYou;

  /// No description provided for @iapError.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get iapError;

  /// No description provided for @iapCancelled.
  ///
  /// In en, this message translates to:
  /// **'Purchase was cancelled.'**
  String get iapCancelled;

  /// No description provided for @iapPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment confirmation...'**
  String get iapPending;

  /// No description provided for @iapRestoreStarted.
  ///
  /// In en, this message translates to:
  /// **'Restoring purchases started'**
  String get iapRestoreStarted;

  /// No description provided for @fileInfo.
  ///
  /// In en, this message translates to:
  /// **'File information'**
  String get fileInfo;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fileName;

  /// No description provided for @filePath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get filePath;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get fileSize;

  /// No description provided for @fileFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get fileFormat;

  /// No description provided for @fileCodec.
  ///
  /// In en, this message translates to:
  /// **'Codec'**
  String get fileCodec;

  /// No description provided for @fileSampleFormat.
  ///
  /// In en, this message translates to:
  /// **'Sample format'**
  String get fileSampleFormat;

  /// No description provided for @fileBitDepth.
  ///
  /// In en, this message translates to:
  /// **'Bit depth'**
  String get fileBitDepth;

  /// No description provided for @fileDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get fileDuration;

  /// No description provided for @fileBitrate.
  ///
  /// In en, this message translates to:
  /// **'Bitrate'**
  String get fileBitrate;

  /// No description provided for @fileChannels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get fileChannels;

  /// No description provided for @fileSampleRate.
  ///
  /// In en, this message translates to:
  /// **'Sample rate'**
  String get fileSampleRate;

  /// No description provided for @fileBitrateType.
  ///
  /// In en, this message translates to:
  /// **'Bitrate type'**
  String get fileBitrateType;

  /// No description provided for @fileStartOffset.
  ///
  /// In en, this message translates to:
  /// **'Start offset'**
  String get fileStartOffset;

  /// No description provided for @fileTagsSection.
  ///
  /// In en, this message translates to:
  /// **'--- Tags ---'**
  String get fileTagsSection;

  /// No description provided for @fileNoTags.
  ///
  /// In en, this message translates to:
  /// **'No tags'**
  String get fileNoTags;

  /// No description provided for @mono.
  ///
  /// In en, this message translates to:
  /// **'Mono'**
  String get mono;

  /// No description provided for @stereo.
  ///
  /// In en, this message translates to:
  /// **'Stereo'**
  String get stereo;

  /// No description provided for @mb.
  ///
  /// In en, this message translates to:
  /// **'MB'**
  String get mb;

  /// No description provided for @kbps.
  ///
  /// In en, this message translates to:
  /// **'kbps'**
  String get kbps;

  /// No description provided for @khz.
  ///
  /// In en, this message translates to:
  /// **'kHz'**
  String get khz;

  /// No description provided for @vbr.
  ///
  /// In en, this message translates to:
  /// **'VBR'**
  String get vbr;

  /// No description provided for @cbr.
  ///
  /// In en, this message translates to:
  /// **'CBR'**
  String get cbr;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @fileTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fileTagTitle;

  /// No description provided for @fileTagArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get fileTagArtist;

  /// No description provided for @fileTagAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get fileTagAlbum;

  /// No description provided for @fileTagAlbumArtist.
  ///
  /// In en, this message translates to:
  /// **'Album artist'**
  String get fileTagAlbumArtist;

  /// No description provided for @fileTagGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get fileTagGenre;

  /// No description provided for @fileTagTrack.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get fileTagTrack;

  /// No description provided for @fileTagComposer.
  ///
  /// In en, this message translates to:
  /// **'Composer'**
  String get fileTagComposer;

  /// No description provided for @fileTagYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get fileTagYear;

  /// No description provided for @fileTagDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fileTagDate;

  /// No description provided for @playlistRemovedTracks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing removed} one{{count} file removed from playlist (missing on device).} other{{count} files removed from playlist (missing on device).}}'**
  String playlistRemovedTracks(num count);

  /// No description provided for @folderRemovedTracks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No files removed} one{{count} file removed from folder list (missing in folder).} other{{count} files removed from folder list (missing in folder).}}'**
  String folderRemovedTracks(num count);

  /// No description provided for @folderAddedTracks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No new files found} one{{count} new file found in folder.} other{{count} new files found in folder.}}'**
  String folderAddedTracks(num count);

  /// No description provided for @noFilePermission.
  ///
  /// In en, this message translates to:
  /// **'No permission to access files.'**
  String get noFilePermission;

  /// No description provided for @audioMetadataError.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve audio file metadata.'**
  String get audioMetadataError;

  /// No description provided for @tempFiles.
  ///
  /// In en, this message translates to:
  /// **'Temporary files'**
  String get tempFiles;

  /// No description provided for @tempFilesDeleteWav.
  ///
  /// In en, this message translates to:
  /// **'Delete temporary WAV files'**
  String get tempFilesDeleteWav;

  /// No description provided for @tempFilesDeleteWavDesc.
  ///
  /// In en, this message translates to:
  /// **'Delete generated wav copies of audio files from the app cache.'**
  String get tempFilesDeleteWavDesc;

  /// No description provided for @tempFilesDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Temporary wav files have been deleted.'**
  String get tempFilesDeleteSuccess;

  /// No description provided for @tempFilesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all temporary wav files? This action cannot be undone.'**
  String get tempFilesDeleteConfirm;

  /// No description provided for @tempFilesNone.
  ///
  /// In en, this message translates to:
  /// **'No temporary files to delete.'**
  String get tempFilesNone;

  /// No description provided for @equalizer.
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get equalizer;

  /// No description provided for @enableEqualizer.
  ///
  /// In en, this message translates to:
  /// **'On/Off'**
  String get enableEqualizer;

  /// No description provided for @preset.
  ///
  /// In en, this message translates to:
  /// **'Preset'**
  String get preset;

  /// No description provided for @presetFlat.
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get presetFlat;

  /// No description provided for @presetRock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get presetRock;

  /// No description provided for @presetPop.
  ///
  /// In en, this message translates to:
  /// **'Pop'**
  String get presetPop;

  /// No description provided for @presetJazz.
  ///
  /// In en, this message translates to:
  /// **'Jazz'**
  String get presetJazz;

  /// No description provided for @presetClassical.
  ///
  /// In en, this message translates to:
  /// **'Classical'**
  String get presetClassical;

  /// No description provided for @presetManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get presetManual;

  /// No description provided for @resetBands.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetBands;

  /// No description provided for @equalizerPlayToActivate.
  ///
  /// In en, this message translates to:
  /// **'To activate the equalizer, please start playing a track'**
  String get equalizerPlayToActivate;

  /// No description provided for @uriCacheResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset folder and URI cache'**
  String get uriCacheResetTitle;

  /// No description provided for @uriCacheResetDesc.
  ///
  /// In en, this message translates to:
  /// **'This action will delete all remembered file and folder lists for playlists, as well as the last opened folders. After resetting, the file list will be reloaded.'**
  String get uriCacheResetDesc;

  /// No description provided for @uriCacheResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset folder cache'**
  String get uriCacheResetButton;

  /// No description provided for @uriCacheResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Folder cache has been successfully reset.'**
  String get uriCacheResetSuccess;

  /// No description provided for @uriCacheResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset cache?'**
  String get uriCacheResetConfirmTitle;

  /// No description provided for @uriCacheResetConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'This action will delete all cached file and folder lists. Continue?'**
  String get uriCacheResetConfirmDesc;

  /// No description provided for @tempFilesRetentionDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Days to keep cache'**
  String get tempFilesRetentionDaysTitle;

  /// No description provided for @tempFilesRetentionDaysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get tempFilesRetentionDaysUnit;

  /// No description provided for @tempFilesMaxSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Maximum cache size'**
  String get tempFilesMaxSizeTitle;

  /// No description provided for @tempFilesMaxSizeUnit.
  ///
  /// In en, this message translates to:
  /// **'MB'**
  String get tempFilesMaxSizeUnit;

  /// No description provided for @tempFilesClearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get tempFilesClearButton;

  /// No description provided for @tempFilesCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get tempFilesCacheCleared;

  /// No description provided for @tempFilesInfoText.
  ///
  /// In en, this message translates to:
  /// **'Temporary files are used for audio playback and analysis, as direct file access is restricted by Google Play security policies. It is recommended to set a moderate cache size to reduce storage wear.'**
  String get tempFilesInfoText;

  /// No description provided for @tempFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Temporary files'**
  String get tempFilesTitle;

  /// No description provided for @cacheUsed.
  ///
  /// In en, this message translates to:
  /// **'Cache used'**
  String get cacheUsed;

  /// No description provided for @calculatingCacheSize.
  ///
  /// In en, this message translates to:
  /// **'Calculating cache size...'**
  String get calculatingCacheSize;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
