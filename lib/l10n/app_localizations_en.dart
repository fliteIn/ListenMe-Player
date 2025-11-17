// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get searchBarHintText => 'Search...';

  @override
  String get showWelcomeScreen => 'Welcome';

  @override
  String get welcomeTitle => 'Welcome!';

  @override
  String get welcomeDescription =>
      'Thank you for choosing ListenMe Player!\n\nYour indispensable tool for working with audio: fast and precise search, convenient controls, and full interface personalization. Maximum comfort and total control always at your fingertips.';

  @override
  String get welcomePolicyTitle => 'Legal Information';

  @override
  String get welcomePolicy =>
      'The application does not verify the presence of a license or copyright for uploaded files. Users are solely responsible for their use.';

  @override
  String get welcomeCopies =>
      'To ensure the operation of certain features, the application creates temporary low-quality copies of audio files. These copies are stored locally only and are automatically deleted when the original files are removed from playlists.';

  @override
  String get welcomeBackgroundImagesTitle => 'Background Images';

  @override
  String get welcomeBackgroundImagesIntro =>
      'Background images are provided by Unsplash (https://unsplash.com) from the following authors:';

  @override
  String get welcomeLegalSummary1 =>
      'ListenMe Player does not collect your personal data, does not analyze your files outside your device, and does not share them with third parties.';

  @override
  String get welcomeLegalSummary2 =>
      'You are solely responsible for the lawful use of audio files.';

  @override
  String get welcomeLegalSummary3 =>
      'The app requires permission to access your device storage in order to play audio files. This access is used only within the app and does not involve sharing your data with third parties.';

  @override
  String get welcomeLegalSummary4 =>
      'For some features, temporary audio copies are created and stored only on your device.';

  @override
  String get welcomeLegalDetails => 'Read more in the privacy policy';

  @override
  String get welcomeLegalAgreeNotice =>
      'By clicking \"Continue\", you agree to the terms.';

  @override
  String get buttonNext => 'Next';

  @override
  String get buttonBack => 'Back';

  @override
  String get buttonAgree => 'Continue';

  @override
  String get buttonClose => 'Close';

  @override
  String get interfaceLanguage => 'Interface language';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get widgetOrderTitle => 'Widget display order';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get systemTheme => 'System theme';

  @override
  String get theme => 'Theme';

  @override
  String get playback => 'Playback';

  @override
  String get jogAndSeek => 'Jog and seek';

  @override
  String get interface => 'Interface';

  @override
  String get timecode => 'Timecode';

  @override
  String get secondaryTimeTypeTitle => 'Secondary time display mode';

  @override
  String get secondaryTimeTypeRemaining => 'Remaining time';

  @override
  String get secondaryTimeTypeTotalDuration => 'Track duration';

  @override
  String get backgroundImage => 'Background image';

  @override
  String get chooseBackgroundImage => 'Choose image';

  @override
  String get resetBackgroundImage => 'Reset image';

  @override
  String get useBackgroundImage => 'Use background image';

  @override
  String get stretchToFullScreen => 'Stretch to full screen';

  @override
  String get fillScreen => 'Fill screen';

  @override
  String transparency(Object value) {
    return 'Transparency: $value%';
  }

  @override
  String get themeSelection => 'Theme selection';

  @override
  String get selectTheme => 'Select theme';

  @override
  String get saveCurrentTheme => 'Save current theme';

  @override
  String get resetToFactory => 'Reset';

  @override
  String themeSaved(Object theme) {
    return 'Theme \"$theme\" saved';
  }

  @override
  String themeReset(Object theme) {
    return 'Theme \"$theme\" reset';
  }

  @override
  String get colorSettings => 'Color settings';

  @override
  String get main => 'Main';

  @override
  String get shadow => '---------------  Shadow  ---------------';

  @override
  String get color => 'color';

  @override
  String get enabled => 'on/off';

  @override
  String get blur => 'blur';

  @override
  String get gradientSettings => 'Gradient settings';

  @override
  String get navIconsActive => 'Navigation icons - active';

  @override
  String get navIconsInactive => 'Navigation icons - inactive';

  @override
  String get displayIconsActive => 'Bottom row icons - active';

  @override
  String get displayIconsInactive => 'Bottom row icons - inactive';

  @override
  String get controlElements => 'Control Elements';

  @override
  String get brightness => 'Brightness';

  @override
  String get contrast => 'Contrast';

  @override
  String get widgetIconsText => 'Widget icons/text';

  @override
  String get buttonIconsText => 'Button icons/text';

  @override
  String get mainText => 'Main text';

  @override
  String get sliderActive => 'Slider - active part';

  @override
  String get sliderInactive => 'Slider - inactive part';

  @override
  String get playlistDeleteButton => 'Track delete button (in playlist)';

  @override
  String get startEnd => '1         2';

  @override
  String get background => 'Background';

  @override
  String get divider => 'Divider';

  @override
  String get topBar => 'Top bar';

  @override
  String get jog => 'Jog';

  @override
  String get pickColor => 'Pick a color';

  @override
  String get ok => 'OK';

  @override
  String get jogResolution => 'Jog resolution';

  @override
  String get secondsPerRevolution => 'Sek/Umdr';

  @override
  String get minSeekSpeed => 'Seek speed (minimum)';

  @override
  String get maxSeekSpeed => 'Seek speed (maximum)';

  @override
  String get playbackButtonType => 'Playback button type';

  @override
  String get standard => 'Standard';

  @override
  String get extended => 'Extended';

  @override
  String get precise => 'Precise';

  @override
  String get playbackSpeedRange => 'Playback speed range';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get timeFormatTitle => 'Time display format';

  @override
  String get timeFormatMmss => 'MM:SS';

  @override
  String get timeFormatMmss2digitMillis => 'MM:SS:MM';

  @override
  String get timeFormatMmss3digitMillis => 'MM:SS:MMM';

  @override
  String get autoHoursHint =>
      'Hours are shown automatically if the track is longer than 1 hour.';

  @override
  String get widgetTrackTitle => 'Track title';

  @override
  String get widgetPositionGroup => 'Position and marker block';

  @override
  String get widgetPlaybackButtons => 'Playback buttons';

  @override
  String get widgetJog => 'Jog and buttons';

  @override
  String get widgetSpeedSlider => 'Speed slider';

  @override
  String get widgetSilenceBar => 'Silence panel';

  @override
  String get transparencyLabel => 'Transparency';

  @override
  String get themeWord => 'Theme';

  @override
  String get savedWord => 'saved';

  @override
  String get resetWord => 'reset';

  @override
  String get themeStandard => 'Standard';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeCustom => 'Custom';

  @override
  String get msPerSec => 'ms/Sek';

  @override
  String get noTrack => 'No track';

  @override
  String get helpMenu => 'Help';

  @override
  String get aboutApp => 'About the app';

  @override
  String get widgets => 'Widgets';

  @override
  String get playlistHelpTitle => 'Playlist';

  @override
  String get licenses => 'Licenses';

  @override
  String get copyrightText => '© 2025 Flitein. All rights reserved.';

  @override
  String get transitionBlockTitle => 'Transition animation';

  @override
  String get transitionTypeSlide => 'Slide';

  @override
  String get transitionTypeFade => 'Fade';

  @override
  String get transitionTypeScale => 'Scale';

  @override
  String get transitionTypeNone => 'No animation';

  @override
  String get helpTopBarTitle => 'Navigation Menu';

  @override
  String get helpTopBarLogoBack =>
      'App logo. When you open a settings or help submenu, a \'back\' arrow appears here, returning you to the corresponding root menu.';

  @override
  String get helpTopBarHome =>
      'Button to go to the home screen. Here you\'ll find all the main widgets for controlling the player.';

  @override
  String get helpTopBarFolderPlaylist =>
      'Button to open the folder playlist. Here, you can play tracks directly from a selected folder on your device\'s internal or external storage. The main advantage is that you don\'t need to create a playlist in advance and can quickly find the audio files you need.';

  @override
  String get helpTopBarManualPlaylist =>
      'Button to open the manual playlist. Here you can add only the tracks you need. Tracks can be located in different folders or even on different storage devices. In this playlist, you can change the playback order by simply dragging tracks, add the same track any number of times, and remove tracks one by one or all at once.';

  @override
  String get helpTopBarSettings =>
      'Button to open the settings menu. Here you can configure options like interface language, themes, widgets, and more.';

  @override
  String get helpTopBarHelp => 'Button to open the help menu.';

  @override
  String get helpTopBarEdit =>
      'Button to activate widget arrangement editing mode on the home screen. In this mode, you can add or remove widgets and change their positions by dragging, customizing your home screen the way you want.';

  @override
  String get helpTopBarDescription =>
      'This menu is always at the top of the app. All navigation is done via the icon buttons. The settings and help menus also contain submenu items. To return from a submenu to the root menu, press the panel icon again or use the back arrow in the top or system menu.';

  @override
  String get helpGeneralControlsTitle => 'Control Panel';

  @override
  String get helpGeneralControlsSchowSilenceControlBar =>
      '\"Show/Hide\" button for the silence jump widget.';

  @override
  String get helpGeneralControlsSchowPlayback =>
      '\"Show/Hide\" button for the playback control buttons widget.';

  @override
  String get helpGeneralControlsSchowJog =>
      '\"Show/Hide\" button for the jog widget.';

  @override
  String get helpGeneralControlsSchowSpeedSlider =>
      '\"Show/Hide\" button for the playback speed slider widget.';

  @override
  String get helpGeneralControlsPlaybackMode =>
      'Button to switch playback mode. Repeated presses cycle through modes: -> \"1 track once\" -> \"1 track loop\" -> \"playlist once\" -> \"playlist loop\" -> \"shuffle\" ->. If segment playback mode is activated with button (7) and markers, only two modes are available: -> \"once\" -> \"loop\" ->.';

  @override
  String get helpGeneralControlsSchowMarkers =>
      '\"Show/Hide\" button for track segment markers. Simply displaying the markers does not automatically activate segment playback. To activate, press button (7).';

  @override
  String get helpGeneralControlsActivatePlayBetweenMarkers =>
      '\"Activate/Deactivate\" button for segment playback using markers. The selected segment will play once or in a loop, depending on the mode selected with button (5). If the markers are set incorrectly (at the same place or outside the track), this mode will not be activated.';

  @override
  String get helpGeneralControlsDescription =>
      'Note: \"Show/Hide\" widget buttons are for temporarily disabling unnecessary widgets, even if they were added in editing mode (see \"Navigation Menu\"). This is useful if you often switch between different tasks, such as regular music listening and working with text or listening exercises that require additional audio tools.';

  @override
  String get helpProgressSliderTitle => 'Progress Bar';

  @override
  String get helpProgressSliderMinusButtons =>
      'Buttons for fine-tuning marker positions. Pressing and holding the button changes the marker\'s position with increasing speed.';

  @override
  String get helpProgressSliderPosition =>
      'Current track position in *hours:minutes:seconds:**milliseconds.';

  @override
  String get helpProgressSliderMarkerA =>
      'Start marker for segment playback (if it is to the left of the lower marker). Double-tapping the marker scale automatically sets the marker opposite the playhead.';

  @override
  String get helpProgressSliderPlayHead =>
      'Playback cursor / position slider. Lets you visually see the current track position and roughly set a new one.';

  @override
  String get helpProgressSliderMarkerB =>
      'End marker for segment playback (if it is to the right of the upper marker). Double-tapping the marker scale automatically sets the marker opposite the playhead.';

  @override
  String get helpProgressSliderDuration =>
      'Remaining track time /**total track duration in *hours:minutes:seconds:**milliseconds.';

  @override
  String get helpProgressSliderPlusButtons =>
      'Buttons for fine-tuning marker positions. Pressing and holding the button changes the marker\'s position with increasing speed.';

  @override
  String get helpProgressSliderDescription =>
      '*Appears automatically if the track duration exceeds 60 minutes.\n**The display format can be set in the \"Settings/Timecode\" menu.\nMarkers are only displayed if activated on the control panel with button (6). The order in which you set markers does not matter.';

  @override
  String get helpPlaybackStandardTitle => 'Standard Playback Controls';

  @override
  String get helpPlaybackExtendedTitle => 'Extended Playback Controls';

  @override
  String get helpPlaybackPreciseTitle => 'Precise Playback Controls';

  @override
  String get helpPlaybackPrevTrack =>
      'Button to switch to the previous track / start of the track or segment, depending on playback mode.';

  @override
  String get helpPlaybackJumpBack30 => 'Button to jump back 30 seconds.';

  @override
  String get helpPlaybackJumpBack5 => 'Button to jump back 5 seconds.';

  @override
  String get helpPlaybackRewind =>
      'Rewind button. Holding the button increases rewind speed.';

  @override
  String get helpPlaybackPlayPause =>
      '\"Play/Pause\" button. Starts or stops playback.';

  @override
  String get helpPlaybackFastForward =>
      'Fast forward button. Holding the button increases fast forward speed.';

  @override
  String get helpPlaybackJumpForward5 => 'Button to jump forward 5 seconds.';

  @override
  String get helpPlaybackJumpForward30 => 'Button to jump forward 30 seconds.';

  @override
  String get helpPlaybackNextTrack =>
      'Button to switch to the next track / end of the track or segment, depending on playback mode.';

  @override
  String get helpPlaybackStandardDescription =>
      'This widget is for simplified playback control if you do not need special features.';

  @override
  String get helpPlaybackExtendedDescription =>
      'This widget allows rough or more precise searching for the required part of the track if you do not need extra accuracy.';

  @override
  String get helpPlaybackPreciseDescription =>
      'This widget provides both rough and very precise searching for the required part of the track.';

  @override
  String get helpJogTitle => 'Jog';

  @override
  String get helpJogPrevTrack =>
      'Button to switch to the previous track / start of the track or segment, depending on playback mode.';

  @override
  String get helpJogRewind =>
      'Rewind button. The rewind speed depends on the area of the button you press. At the bottom, the speed is slow, at the top, it\'s fast. You can slide along the button to change the speed. The speed limits can be set in the \"Settings/Jog\" menu.';

  @override
  String get helpJogPlayPauseKnob =>
      'Jog. Allows you to start and stop playback, and precisely set the current track position by turning the knob in the desired direction. Turning clockwise moves forward, counterclockwise moves backward. By default, one full turn changes the position by 5 seconds. This value (jog resolution) can be changed in the \"Settings/Jog\" menu.';

  @override
  String get helpJogFastForward =>
      'Fast forward button. Works the same as (2).';

  @override
  String get helpJogNextTrack =>
      'Button to switch to the next track / end of the track or segment, depending on playback mode.';

  @override
  String get helpJogDescription =>
      'This widget is for precise positioning tasks, such as quickly finding the start of phrases—especially with short phrases, when you need to listen to a fragment many times or just set the playback cursor to the required millisecond.';

  @override
  String get helpSpeedSliderTitle => 'Playback Speed Slider';

  @override
  String get helpSpeedSliderMinusButton =>
      'Button to decrease playback speed by 0.1x (10%).';

  @override
  String get helpSpeedSliderThumb =>
      'Playback speed slider knob. Lets you quickly set the desired speed. Double-tap the slider to reset to the normal speed (1x).';

  @override
  String get helpSpeedSliderPlusButton =>
      'Button to increase playback speed by 0.1x (10%).';

  @override
  String get helpSpeedSliderDescription =>
      'Note: Speed limits can be set in the \"Settings/Playback\" menu.';

  @override
  String get helpSilenceControlBarTitle => 'Silence Jump Widget';

  @override
  String get helpSilenceControlBarJumpPrevPhrase =>
      'Button to jump to the start of the previous phrase.';

  @override
  String get helpSilenceControlBarPCMLevel =>
      'Audio signal level indicator. During playback, it shows the audio signal level in real time. It helps you set the correct silence detection threshold.';

  @override
  String get helpSilenceControlBarThumb =>
      'Slider for setting the silence detection threshold. Its position determines what audio signal level is considered the start of a phrase. If there\'s no background noise in the audio file, it\'s worth using lower threshold values. Then the jump buttons can find phrases more accurately. If there is significant background noise, you should increase the threshold value, otherwise some phrases may not be detected. The threshold should be chosen by experimentation. It is recommended to start with medium values.';

  @override
  String get helpSilenceControlBarJumpNextPhrase =>
      'Button to jump to the start of the next phrase.';

  @override
  String get helpSilenceControlBarDescription =>
      'This widget is for convenient navigation by phrases in an audio file. It is well suited for detailed listening to interviews, audiobooks, dialogues (for example, when learning foreign languages).\nNote: After switching the track or changing the slider position, a spinning indicator may appear briefly, indicating audio file analysis is in progress. During this time, the phrase jump buttons may not function precisely.';

  @override
  String get helpManualPlaylistTitle => 'Playlist';

  @override
  String get helpManualPlaylistOpen =>
      'Button to open the file picker for adding tracks to the playlist.';

  @override
  String get helpManualPlaylistClear => 'Button to clear the entire playlist.';

  @override
  String get helpManualPlaylistSearch =>
      'A panel to search for a track by a fragment of its title. Allows you to quickly find the desired track in the list.';

  @override
  String get helpManualPlaylistDrag =>
      'Handle for moving a track to a different position in the list. Used to change the order of tracks in the playlist. If you pull the handle of the desired track up or down, the track will \'pop out\' of its slot and can be placed in a new position.';

  @override
  String get helpManualPlaylistFilename =>
      'The name of the audio file with its extension. Pressing and holding a track opens a window with some information about the file and audio data.';

  @override
  String get helpManualPlaylistNumber =>
      'Track number in the playlist, track duration, and file extension/format.';

  @override
  String get helpManualPlaylistDelete =>
      'Button to remove a track from the playlist.';

  @override
  String get helpManualPlaylistDescription =>
      'Notes.\n-The row of the active track in the playlist, which is currently playing or paused, is highlighted.\n-Tapping another track in the playlist automatically starts its playback.\n-In this example, a manual playlist is shown. The folder playlist functions the same way, except that playback is started directly from the selected folder, the order of tracks cannot be changed, and tracks cannot be removed.\n-The playlist in which the track was selected for playback becomes active automatically.';

  @override
  String get iapRemoveAdsTitle => 'Remove Ads';

  @override
  String get iapRemoveAdsDescription =>
      'You can completely remove all ads by making a one-time purchase. This will support the development of ListenMe Player and make using the app even more convenient.';

  @override
  String iapRemoveAdsButton(Object price) {
    return 'Remove Ads — $price';
  }

  @override
  String get iapRestorePurchaseButton => 'Restore purchase';

  @override
  String get iapAdsRemovedMessage =>
      'Thank you for purchasing\nListenMe Player!\n\nAds have been removed. You are using the full version.';

  @override
  String get iapNotFound => 'Purchase not found.';

  @override
  String get iapRestored => 'Purchase restored.';

  @override
  String get iapAlreadyOwned => 'You already own the full version.';

  @override
  String get iapShopUnavailable => 'Store unavailable.';

  @override
  String get iapProductNotFound => 'Product not found.';

  @override
  String get iapThankYou => 'Thank you for your purchase!';

  @override
  String get iapError => 'Purchase failed. Please try again.';

  @override
  String get iapCancelled => 'Purchase was cancelled.';

  @override
  String get iapPending => 'Waiting for payment confirmation...';

  @override
  String get iapRestoreStarted => 'Restoring purchases started';

  @override
  String get fileInfo => 'File information';

  @override
  String get fileName => 'Name';

  @override
  String get filePath => 'Path';

  @override
  String get fileSize => 'Size';

  @override
  String get fileFormat => 'Format';

  @override
  String get fileCodec => 'Codec';

  @override
  String get fileSampleFormat => 'Sample format';

  @override
  String get fileBitDepth => 'Bit depth';

  @override
  String get fileDuration => 'Duration';

  @override
  String get fileBitrate => 'Bitrate';

  @override
  String get fileChannels => 'Channels';

  @override
  String get fileSampleRate => 'Sample rate';

  @override
  String get fileBitrateType => 'Bitrate type';

  @override
  String get fileStartOffset => 'Start offset';

  @override
  String get fileTagsSection => '--- Tags ---';

  @override
  String get fileNoTags => 'No tags';

  @override
  String get mono => 'Mono';

  @override
  String get stereo => 'Stereo';

  @override
  String get mb => 'MB';

  @override
  String get kbps => 'kbps';

  @override
  String get khz => 'kHz';

  @override
  String get vbr => 'VBR';

  @override
  String get cbr => 'CBR';

  @override
  String get close => 'Close';

  @override
  String get fileTagTitle => 'Title';

  @override
  String get fileTagArtist => 'Artist';

  @override
  String get fileTagAlbum => 'Album';

  @override
  String get fileTagAlbumArtist => 'Album artist';

  @override
  String get fileTagGenre => 'Genre';

  @override
  String get fileTagTrack => 'Track';

  @override
  String get fileTagComposer => 'Composer';

  @override
  String get fileTagYear => 'Year';

  @override
  String get fileTagDate => 'Date';

  @override
  String playlistRemovedTracks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files removed from playlist (missing on device).',
      one: '$count file removed from playlist (missing on device).',
      zero: 'Nothing removed',
    );
    return '$_temp0';
  }

  @override
  String folderRemovedTracks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files removed from folder list (missing in folder).',
      one: '$count file removed from folder list (missing in folder).',
      zero: 'No files removed',
    );
    return '$_temp0';
  }

  @override
  String folderAddedTracks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new files found in folder.',
      one: '$count new file found in folder.',
      zero: 'No new files found',
    );
    return '$_temp0';
  }

  @override
  String get noFilePermission => 'No permission to access files.';

  @override
  String get audioMetadataError => 'Failed to retrieve audio file metadata.';

  @override
  String get tempFiles => 'Temporary files';

  @override
  String get tempFilesDeleteWav => 'Delete temporary WAV files';

  @override
  String get tempFilesDeleteWavDesc =>
      'Delete generated wav copies of audio files from the app cache.';

  @override
  String get tempFilesDeleteSuccess => 'Temporary wav files have been deleted.';

  @override
  String get tempFilesDeleteConfirm =>
      'Are you sure you want to delete all temporary wav files? This action cannot be undone.';

  @override
  String get tempFilesNone => 'No temporary files to delete.';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get enableEqualizer => 'On/Off';

  @override
  String get preset => 'Preset';

  @override
  String get presetFlat => 'Flat';

  @override
  String get presetRock => 'Rock';

  @override
  String get presetPop => 'Pop';

  @override
  String get presetJazz => 'Jazz';

  @override
  String get presetClassical => 'Classical';

  @override
  String get presetManual => 'Manual';

  @override
  String get resetBands => 'Reset';

  @override
  String get equalizerPlayToActivate =>
      'To activate the equalizer, please start playing a track';

  @override
  String get uriCacheResetTitle => 'Reset folder and URI cache';

  @override
  String get uriCacheResetDesc =>
      'This action will delete all remembered file and folder lists for playlists, as well as the last opened folders. After resetting, the file list will be reloaded.';

  @override
  String get uriCacheResetButton => 'Reset folder cache';

  @override
  String get uriCacheResetSuccess =>
      'Folder cache has been successfully reset.';

  @override
  String get uriCacheResetConfirmTitle => 'Reset cache?';

  @override
  String get uriCacheResetConfirmDesc =>
      'This action will delete all cached file and folder lists. Continue?';

  @override
  String get tempFilesRetentionDaysTitle => 'Days to keep cache';

  @override
  String get tempFilesRetentionDaysUnit => 'days';

  @override
  String get tempFilesMaxSizeTitle => 'Maximum cache size';

  @override
  String get tempFilesMaxSizeUnit => 'MB';

  @override
  String get tempFilesClearButton => 'Clear cache';

  @override
  String get tempFilesCacheCleared => 'Cache cleared';

  @override
  String get tempFilesInfoText =>
      'Temporary files are used for audio playback and analysis, as direct file access is restricted by Google Play security policies. It is recommended to set a moderate cache size to reduce storage wear.';

  @override
  String get tempFilesTitle => 'Temporary files';

  @override
  String get cacheUsed => 'Cache used';

  @override
  String get calculatingCacheSize => 'Calculating cache size...';

  @override
  String get refresh => 'Refresh';

  @override
  String get pleaseWait => 'Please wait...';
}
