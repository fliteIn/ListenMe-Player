// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get searchBarHintText => 'Suche...';

  @override
  String get showWelcomeScreen => 'Begrüßung';

  @override
  String get welcomeTitle => 'Willkommen!';

  @override
  String get welcomeDescription =>
      'Vielen Dank, dass Sie sich für ListenMe Player entschieden haben!\n\nIhr unverzichtbares Werkzeug für die Arbeit mit Audio: schnelle und präzise Suche, komfortable Bedienung und vollständige Personalisierung der Oberfläche. Maximaler Komfort und volle Kontrolle sind jederzeit griffbereit.';

  @override
  String get welcomePolicyTitle => 'Rechtliche Hinweise';

  @override
  String get welcomePolicy =>
      'Die Anwendung überprüft nicht das Vorhandensein einer Lizenz oder von Urheberrechten bei hochgeladenen Dateien. Für deren Nutzung ist ausschließlich der Benutzer verantwortlich.';

  @override
  String get welcomeCopies =>
      'Zur Gewährleistung bestimmter Funktionen erstellt die Anwendung temporäre Kopien von Audiodateien in reduzierter Qualität. Diese Kopien werden ausschließlich lokal gespeichert und automatisch gelöscht, sobald die Originaldateien aus den Wiedergabelisten entfernt werden.';

  @override
  String get welcomeBackgroundImagesTitle => 'Hintergrundbilder';

  @override
  String get welcomeBackgroundImagesIntro =>
      'Hintergrundbilder stammen von Unsplash (https://unsplash.com) von den folgenden Autoren:';

  @override
  String get welcomeLegalSummary1 =>
      'ListenMe Player sammelt keine persönlichen Daten, analysiert Ihre Dateien nicht außerhalb Ihres Geräts und gibt sie nicht an Dritte weiter.';

  @override
  String get welcomeLegalSummary2 =>
      'Für die rechtmäßige Nutzung von Audiodateien ist ausschließlich der Nutzer verantwortlich.';

  @override
  String get welcomeLegalSummary3 =>
      'Die App benötigt Zugriff auf den Gerätespeicher, um Audiodateien wiederzugeben. Dieser Zugriff wird ausschließlich innerhalb der App genutzt und beinhaltet keine Weitergabe Ihrer Daten an Dritte.';

  @override
  String get welcomeLegalSummary4 =>
      'Für bestimmte Funktionen werden temporäre Audiokopien erstellt, die nur auf Ihrem Gerät gespeichert werden.';

  @override
  String get welcomeLegalDetails => 'Mehr zur Datenschutzrichtlinie';

  @override
  String get welcomeLegalAgreeNotice =>
      'Mit dem Klick auf „Weiter“ stimmen Sie den Bedingungen zu.';

  @override
  String get buttonNext => 'Weiter';

  @override
  String get buttonBack => 'Zurück';

  @override
  String get buttonAgree => 'Weiter';

  @override
  String get buttonClose => 'Schließen';

  @override
  String get interfaceLanguage => 'Sprache der Benutzeroberfläche';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get widgetOrderTitle => 'Anzeigereihenfolge der Widgets';

  @override
  String get darkTheme => 'Dunkles Design';

  @override
  String get lightTheme => 'Helles Design';

  @override
  String get systemTheme => 'Systemdesign';

  @override
  String get theme => 'Design';

  @override
  String get playback => 'Wiedergabe';

  @override
  String get jogAndSeek => 'Joggen und Spulen';

  @override
  String get interface => 'Benutzeroberfläche';

  @override
  String get timecode => 'Timecode';

  @override
  String get secondaryTimeTypeTitle => 'Modus des zweiten Zeitfeldes';

  @override
  String get secondaryTimeTypeRemaining => 'Verbleibende Zeit';

  @override
  String get secondaryTimeTypeTotalDuration => 'Titel-Gesamtdauer';

  @override
  String get backgroundImage => 'Hintergrundbild';

  @override
  String get chooseBackgroundImage => 'Bild auswählen';

  @override
  String get resetBackgroundImage => 'Bild zurücksetzen';

  @override
  String get useBackgroundImage => 'Hintergrundbild verwenden';

  @override
  String get stretchToFullScreen => 'Auf Vollbild strecken';

  @override
  String get fillScreen => 'Bildschirm ausfüllen';

  @override
  String transparency(Object value) {
    return 'Transparenz: $value%';
  }

  @override
  String get themeSelection => 'Thema auswählen';

  @override
  String get selectTheme => 'Thema auswählen';

  @override
  String get saveCurrentTheme => 'Aktuelles Thema speichern';

  @override
  String get resetToFactory => 'Zurücksetzen';

  @override
  String themeSaved(Object theme) {
    return 'Thema \"$theme\" gespeichert';
  }

  @override
  String themeReset(Object theme) {
    return 'Thema \"$theme\" zurückgesetzt';
  }

  @override
  String get colorSettings => 'Farbeinstellungen';

  @override
  String get main => 'Hauptfarbe';

  @override
  String get shadow => '--------------  Schatten  --------------';

  @override
  String get color => 'Farbe';

  @override
  String get enabled => 'Ein/Aus';

  @override
  String get blur => 'Unschärfe';

  @override
  String get gradientSettings => 'Farbverlauf-Einstellungen';

  @override
  String get navIconsActive => 'Navigationssymbole – aktiv';

  @override
  String get navIconsInactive => 'Navigationssymbole – inaktiv';

  @override
  String get displayIconsActive => 'Untere Symbolreihe – aktiv';

  @override
  String get displayIconsInactive => 'Untere Symbolreihe – inaktiv';

  @override
  String get controlElements => 'Steuerelemente';

  @override
  String get brightness => 'Helligkeit';

  @override
  String get contrast => 'Kontrast';

  @override
  String get widgetIconsText => 'Widget-Symbole/Text';

  @override
  String get buttonIconsText => 'Tasten-Symbole/Text';

  @override
  String get mainText => 'Haupttext';

  @override
  String get sliderActive => 'Schieberegler – aktiver Teil';

  @override
  String get sliderInactive => 'Schieberegler – inaktiver Teil';

  @override
  String get playlistDeleteButton => 'Titel löschen (in Playlist)';

  @override
  String get startEnd => '1         2';

  @override
  String get background => 'Hintergrund';

  @override
  String get divider => 'Trenner';

  @override
  String get topBar => 'Obere Leiste';

  @override
  String get jog => 'Jog';

  @override
  String get pickColor => 'Farbe auswählen';

  @override
  String get ok => 'OK';

  @override
  String get jogResolution => 'Jog-Auflösung';

  @override
  String get secondsPerRevolution => 'Sek/Umdr';

  @override
  String get minSeekSpeed => 'Suchgeschwindigkeit (Minimum)';

  @override
  String get maxSeekSpeed => 'Suchgeschwindigkeit (Maximum)';

  @override
  String get playbackButtonType => 'Wiedergabeschaltflächen-Typ';

  @override
  String get standard => 'Standard';

  @override
  String get extended => 'Erweitert';

  @override
  String get precise => 'Präzise';

  @override
  String get playbackSpeedRange => 'Bereich der Wiedergabegeschwindigkeit';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get timeFormatTitle => 'Zeitformatanzeige';

  @override
  String get timeFormatMmss => 'MM:SS';

  @override
  String get timeFormatMmss2digitMillis => 'MM:SS:MM';

  @override
  String get timeFormatMmss3digitMillis => 'MM:SS:MMM';

  @override
  String get autoHoursHint =>
      'Stunden werden automatisch angezeigt, wenn der Track länger als 1 Stunde ist.';

  @override
  String get widgetTrackTitle => 'Titel des Titels';

  @override
  String get widgetPositionGroup => 'Position und Markerblock';

  @override
  String get widgetPlaybackButtons => 'Wiedergabeschaltflächen';

  @override
  String get widgetJog => 'Jog und Tasten';

  @override
  String get widgetSpeedSlider => 'Geschwindigkeitsregler';

  @override
  String get widgetSilenceBar => 'Stille-Anzeige';

  @override
  String get transparencyLabel => 'Transparenz';

  @override
  String get themeWord => 'Design';

  @override
  String get savedWord => 'gespeichert';

  @override
  String get resetWord => 'zurückgesetzt';

  @override
  String get themeStandard => 'Standard';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeCustom => 'Benutzerdefiniert';

  @override
  String get msPerSec => 'ms/Sek';

  @override
  String get noTrack => 'Kein Titel';

  @override
  String get helpMenu => 'Hilfe';

  @override
  String get aboutApp => 'Über die App';

  @override
  String get widgets => 'Widgets';

  @override
  String get playlistHelpTitle => 'Wiedergabeliste';

  @override
  String get licenses => 'Lizenzen';

  @override
  String get copyrightText => '© 2025 Flitein. Alle Rechte vorbehalten.';

  @override
  String get transitionBlockTitle => 'Übergangsanimation';

  @override
  String get transitionTypeSlide => 'Gleiten';

  @override
  String get transitionTypeFade => 'Überblenden';

  @override
  String get transitionTypeScale => 'Skalieren';

  @override
  String get transitionTypeNone => 'Keine Animation';

  @override
  String get helpTopBarTitle => 'Navigationsmenü';

  @override
  String get helpTopBarLogoBack =>
      'App-Logo. Beim Aufruf eines Untermenüs für Einstellungen oder Hilfe erscheint an dieser Stelle ein \'Zurück\'-Pfeil, der Sie ins jeweilige Hauptmenü zurückbringt.';

  @override
  String get helpTopBarHome =>
      'Schaltfläche zum Wechsel zum Startbildschirm. Hier befinden sich alle Haupt-Widgets zur Steuerung des Players.';

  @override
  String get helpTopBarFolderPlaylist =>
      'Schaltfläche für den Ordner-Playlist. Damit können Sie Titel direkt aus einem ausgewählten Ordner auf dem internen oder externen Speichergerät abspielen. Praktisch ist, dass Sie keine Wiedergabeliste im Voraus erstellen müssen und schnell die gewünschten Audiodateien finden können.';

  @override
  String get helpTopBarManualPlaylist =>
      'Schaltfläche für die manuelle Playlist. Hier können Sie gezielt nur die gewünschten Titel zur Playlist hinzufügen. Die Titel können sich in verschiedenen Ordnern oder sogar auf unterschiedlichen Speichermedien befinden. In dieser Playlist lässt sich die Reihenfolge der Wiedergabe einfach per Drag & Drop ändern, Sie können denselben Titel beliebig oft hinzufügen und Titel einzeln oder alle auf einmal entfernen.';

  @override
  String get helpTopBarSettings =>
      'Schaltfläche zum Wechsel ins Einstellungsmenü. Hier stehen Ihnen Einstellungen wie Sprache, Theme, Widgets und mehr zur Verfügung.';

  @override
  String get helpTopBarHelp => 'Schaltfläche für das Hilfemenü.';

  @override
  String get helpTopBarEdit =>
      'Schaltfläche zur Aktivierung des Bearbeitungsmodus für die Widget-Anordnung auf dem Startbildschirm. In diesem Modus können Sie Widgets hinzufügen, entfernen oder per Drag & Drop verschieben, um die Benutzeroberfläche optimal auf Ihre Bedürfnisse abzustimmen.';

  @override
  String get helpTopBarDescription =>
      'Dieses Menü befindet sich immer am oberen Rand der App. Die Navigation erfolgt durch Tippen auf die jeweiligen Symbolschaltflächen. Im Menü \'Einstellungen\' und \'Hilfe\' gibt es zusätzliche Untermenüs. Um aus einem Untermenü ins Hauptmenü zurückzukehren, tippen Sie erneut auf das entsprechende Panel-Symbol oder auf den Zurück-Pfeil in der oberen oder systemeigenen Menüleiste.';

  @override
  String get helpGeneralControlsTitle => 'Kontrollpanel';

  @override
  String get helpGeneralControlsSchowSilenceControlBar =>
      '\"Anzeigen/Ausblenden\"-Schaltfläche für das Widget zum Springen zu Satzanfängen.';

  @override
  String get helpGeneralControlsSchowPlayback =>
      '\"Anzeigen/Ausblenden\"-Schaltfläche für das Widget mit Wiedergabesteuerung.';

  @override
  String get helpGeneralControlsSchowJog =>
      '\"Anzeigen/Ausblenden\"-Schaltfläche für das Jog-Widget.';

  @override
  String get helpGeneralControlsSchowSpeedSlider =>
      '\"Anzeigen/Ausblenden\"-Schaltfläche für das Widget zur Wiedergabegeschwindigkeit.';

  @override
  String get helpGeneralControlsPlaybackMode =>
      'Schaltfläche zum Umschalten des Wiedergabemodus. Wiederholtes Tippen schaltet zwischen den Modi um: -> \"1 Titel einmal\" -> \"1 Titel wiederholen\" -> \"Playlist einmal\" -> \"Playlist wiederholen\" -> \"Zufallswiedergabe\" ->. Ist der Abschnittswiedergabemodus (mit Schaltfläche (7), durch Marker aktiviert) aktiv, sind nur zwei Modi verfügbar: -> \"einmal\" -> \"wiederholen\" ->.';

  @override
  String get helpGeneralControlsSchowMarkers =>
      '\"Anzeigen/Ausblenden\"-Schaltfläche für die Marker zur Auswahl eines Abschnitts. Die reine Anzeige der Marker aktiviert den Abschnittswiedergabemodus nicht automatisch. Zum Aktivieren müssen Sie Schaltfläche (7) drücken.';

  @override
  String get helpGeneralControlsActivatePlayBetweenMarkers =>
      '\"Aktivieren/Deaktivieren\"-Schaltfläche für den Wiedergabemodus des markierten Abschnitts. Dieser Abschnitt wird einmal oder in einer Schleife wiedergegeben, abhängig vom gewählten Modus mit Schaltfläche (5). Sind die Marker falsch gesetzt (z. B. an derselben Stelle oder außerhalb des Tracks), wird der Modus nicht aktiviert.';

  @override
  String get helpGeneralControlsDescription =>
      'Hinweis: Die \"Anzeigen/Ausblenden\"-Schaltflächen dienen zum temporären Ausblenden nicht benötigter Widgets, selbst wenn sie im Bearbeitungsmodus hinzugefügt wurden (siehe Abschnitt \"Navigationsmenü\"), etwa wenn Sie häufig zwischen verschiedenen Aufgaben wie Musik hören und Textarbeit oder Hörübungen wechseln, für die zusätzliche Audiowerkzeuge erforderlich sind.';

  @override
  String get helpProgressSliderTitle => 'Fortschrittsanzeige';

  @override
  String get helpProgressSliderMinusButtons =>
      'Schaltflächen zur Feinabstimmung der Markerpositionen. Durch Gedrückthalten der Schaltfläche ändert sich die Markerposition mit zunehmender Geschwindigkeit.';

  @override
  String get helpProgressSliderPosition =>
      'Aktuelle Position des Tracks in *Stunden:Minuten:Sekunden:**Millisekunden.';

  @override
  String get helpProgressSliderMarkerA =>
      'Marker für den Beginn des Abschnitts (wenn links vom unteren Marker). Durch Doppeltippen auf die Markerskala wird der Marker automatisch auf die aktuelle Wiedergabeposition gesetzt.';

  @override
  String get helpProgressSliderPlayHead =>
      'Wiedergabecursor / Positionsregler. Ermöglicht eine visuelle Einschätzung und grobe Einstellung der aktuellen Trackposition.';

  @override
  String get helpProgressSliderMarkerB =>
      'Marker für das Ende des Abschnitts (wenn rechts vom oberen Marker). Doppeltippen auf die Markerskala setzt den Marker automatisch auf die aktuelle Position.';

  @override
  String get helpProgressSliderDuration =>
      'Verbleibende Zeit des Tracks /**Gesamtdauer in *Stunden:Minuten:Sekunden:**Millisekunden.';

  @override
  String get helpProgressSliderPlusButtons =>
      'Schaltflächen zur Feinabstimmung der Markerpositionen. Durch Gedrückthalten der Schaltfläche ändert sich die Markerposition mit zunehmender Geschwindigkeit.';

  @override
  String get helpProgressSliderDescription =>
      '*Erscheint automatisch, wenn die Trackdauer mehr als 60 Minuten beträgt.\n**Das Anzeigeformat kann im Menü \"Einstellungen/Timecode\" angepasst werden.\nMarker werden nur angezeigt, wenn sie im Kontrollpanel mit Schaltfläche (6) aktiviert wurden. Die Reihenfolge der Markersetzen spielt keine Rolle.';

  @override
  String get helpPlaybackStandardTitle => 'Standard-Wiedergabesteuerung';

  @override
  String get helpPlaybackExtendedTitle => 'Erweiterte Wiedergabesteuerung';

  @override
  String get helpPlaybackPreciseTitle => 'Präzise Wiedergabesteuerung';

  @override
  String get helpPlaybackPrevTrack =>
      'Schaltfläche zum Wechsel zum vorherigen Track / Anfang des Tracks oder Abschnitts, je nach Wiedergabemodus.';

  @override
  String get helpPlaybackJumpBack30 =>
      'Schaltfläche zum Springen 30 Sekunden zurück.';

  @override
  String get helpPlaybackJumpBack5 =>
      'Schaltfläche zum Springen 5 Sekunden zurück.';

  @override
  String get helpPlaybackRewind =>
      'Schaltfläche zum Zurückspulen. Halten Sie die Schaltfläche gedrückt, um die Spulgeschwindigkeit zu erhöhen.';

  @override
  String get helpPlaybackPlayPause =>
      '\"Wiedergabe/Pause\"-Schaltfläche. Startet oder stoppt den Track.';

  @override
  String get helpPlaybackFastForward =>
      'Schaltfläche zum Vorspulen. Halten Sie die Schaltfläche gedrückt, um die Spulgeschwindigkeit zu erhöhen.';

  @override
  String get helpPlaybackJumpForward5 =>
      'Schaltfläche zum Springen 5 Sekunden vor.';

  @override
  String get helpPlaybackJumpForward30 =>
      'Schaltfläche zum Springen 30 Sekunden vor.';

  @override
  String get helpPlaybackNextTrack =>
      'Schaltfläche zum Wechsel zum nächsten Track / Ende des Tracks oder Abschnitts, je nach Wiedergabemodus.';

  @override
  String get helpPlaybackStandardDescription =>
      'Dieses Widget dient der einfachen Wiedergabesteuerung, falls keine speziellen Aufgaben erforderlich sind.';

  @override
  String get helpPlaybackExtendedDescription =>
      'Dieses Widget ermöglicht grobe oder genauere Suche im Track, falls keine besondere Präzision erforderlich ist.';

  @override
  String get helpPlaybackPreciseDescription =>
      'Dieses Widget bietet sowohl grobe als auch sehr präzise Suche im Track.';

  @override
  String get helpJogTitle => 'Jog';

  @override
  String get helpJogPrevTrack =>
      'Schaltfläche zum Wechsel zum vorherigen Track / Anfang des Tracks oder Abschnitts, je nach Wiedergabemodus.';

  @override
  String get helpJogRewind =>
      'Schaltfläche zum Zurückspulen. Die Geschwindigkeit hängt davon ab, wo Sie die Taste drücken: unten langsam, oben schnell. Sie können die Taste entlang gleiten, um die Geschwindigkeit zu ändern. Die Spulgrenzen sind im Menü \"Einstellungen/Jog\" einstellbar.';

  @override
  String get helpJogPlayPauseKnob =>
      'Jog. Ermöglicht das Starten/Stoppen des Tracks sowie das präzise Einstellen der Position durch Drehen des Knopfs. Im Uhrzeigersinn vorwärts, gegen den Uhrzeigersinn rückwärts. Standardmäßig bewirkt eine Drehung des Jog-Knopfes eine Veränderung der Position um 5 Sekunden. Dieser Wert (Jog-Auflösung) kann im Menü \"Einstellungen/Jog\" angepasst werden.';

  @override
  String get helpJogFastForward =>
      'Schaltfläche zum Vorspulen. Funktioniert wie (2).';

  @override
  String get helpJogNextTrack =>
      'Schaltfläche zum Wechsel zum nächsten Track / Ende des Tracks oder Abschnitts, je nach Wiedergabemodus.';

  @override
  String get helpJogDescription =>
      'Dieses Widget ist für präzises Positionieren gedacht, z. B. schnelles Finden des Satzanfangs, insbesondere bei kurzen Phrasen, wiederholtes Anhören eines Abschnitts oder zum Setzen des Wiedergabecursors auf die gewünschte Position mit Millisekunden-Genauigkeit.';

  @override
  String get helpSpeedSliderTitle => 'Wiedergabegeschwindigkeitsregler';

  @override
  String get helpSpeedSliderMinusButton =>
      'Schaltfläche zum Verringern der Wiedergabegeschwindigkeit in Schritten von 0,1x (10%).';

  @override
  String get helpSpeedSliderThumb =>
      'Regler für die Wiedergabegeschwindigkeit. Ermöglicht das schnelle Einstellen der gewünschten Geschwindigkeit. Doppeltippen auf die Skala setzt die Geschwindigkeit auf 1x zurück.';

  @override
  String get helpSpeedSliderPlusButton =>
      'Schaltfläche zum Erhöhen der Wiedergabegeschwindigkeit in Schritten von 0,1x (10%).';

  @override
  String get helpSpeedSliderDescription =>
      'Hinweis: Die Grenzwerte für die Geschwindigkeit können im Menü \"Einstellungen/Wiedergabe\" eingestellt werden.';

  @override
  String get helpSilenceControlBarTitle => 'Widget zum Springen zum Satzanfang';

  @override
  String get helpSilenceControlBarJumpPrevPhrase =>
      'Schaltfläche zum Springen zum Anfang der vorherigen Phrase.';

  @override
  String get helpSilenceControlBarPCMLevel =>
      'Audiopegel-Anzeige. Zeigt während der Wiedergabe den Echtzeitpegel des Audiosignals an. Hilft bei der richtigen Einstellung des Schwellenwerts für Stille.';

  @override
  String get helpSilenceControlBarThumb =>
      'Regler zum Einstellen des Schwellenwerts für Stille. Der eingestellte Wert bestimmt, ab welchem Pegel ein Abschnitt als Anfang einer Phrase gilt. Bei Audiodateien ohne Hintergrundrauschen empfiehlt sich ein niedrigerer Schwellenwert. Bei stärkerem Rauschen sollte der Wert erhöht werden, sonst werden nicht alle Phrasen erkannt. Finden Sie den richtigen Wert durch Ausprobieren – ein mittlerer Wert ist oft ein guter Start.';

  @override
  String get helpSilenceControlBarJumpNextPhrase =>
      'Schaltfläche zum Springen zum Anfang der nächsten Phrase.';

  @override
  String get helpSilenceControlBarDescription =>
      'Dieses Widget erleichtert die Navigation zwischen Phrasen in der Audiodatei. Besonders geeignet für das genaue Anhören von Interviews, Hörbüchern oder Dialogen (z. B. beim Sprachenlernen).\nHinweis: Nach dem Wechsel des Tracks oder beim Verändern des Reglers kann für kurze Zeit ein rotierender Indikator erscheinen, der auf die laufende Analyse der Audiodatei hinweist. Während dieser Zeit funktionieren die Sprungtasten zu Satzanfängen möglicherweise nicht ganz präzise.';

  @override
  String get helpManualPlaylistTitle => 'Wiedergabeliste';

  @override
  String get helpManualPlaylistOpen =>
      'Schaltfläche zum Öffnen des Dateibrowsers, um Titel zur Wiedergabeliste hinzuzufügen.';

  @override
  String get helpManualPlaylistClear =>
      'Schaltfläche zum Löschen der gesamten Wiedergabeliste.';

  @override
  String get helpManualPlaylistSearch =>
      'Panel zum Suchen eines Titels anhand eines Ausschnitts aus dem Namen. Damit kann der gewünschte Titel in der Liste schnell gefunden werden.';

  @override
  String get helpManualPlaylistDrag =>
      'Griff zum Verschieben eines Titels an eine andere Stelle in der Liste. Dient dazu, die Reihenfolge der Titel in der Wiedergabeliste zu ändern. Wenn Sie den Griff des gewünschten Titels nach oben oder unten ziehen, wird dieser Titel aus seinem Slot gelöst und kann an eine neue Stelle verschoben werden.';

  @override
  String get helpManualPlaylistFilename =>
      'Dateiname der Audiodatei mit Erweiterung. Durch längeres Drücken auf einen Titel wird ein Fenster mit Informationen zur Datei und zu den Audiodaten angezeigt.';

  @override
  String get helpManualPlaylistNumber =>
      'Titelnummer in der Wiedergabeliste, Titellänge und Datei-Erweiterung/-Format.';

  @override
  String get helpManualPlaylistDelete =>
      'Schaltfläche zum Entfernen eines Titels aus der Wiedergabeliste.';

  @override
  String get helpManualPlaylistDescription =>
      'Hinweise.\n-Die Zeile des aktiven Titels in der Wiedergabeliste, der gerade abgespielt wird oder pausiert ist, wird hervorgehoben.\n-Ein Tipp auf einen anderen Titel in der Wiedergabeliste startet dessen Wiedergabe automatisch.\n-In diesem Fall ist eine manuelle Wiedergabeliste dargestellt. Die Ordner-Wiedergabeliste funktioniert genauso, außer dass die Wiedergabe direkt aus dem ausgewählten Ordner gestartet wird, die Reihenfolge der Titel nicht geändert und Titel nicht entfernt werden können.\n-Aktiv wird automatisch die Wiedergabeliste, aus der der Titel zur Wiedergabe gewählt wurde.';

  @override
  String get iapRemoveAdsTitle => 'Werbung entfernen';

  @override
  String get iapRemoveAdsDescription =>
      'Sie können alle Anzeigen vollständig entfernen, indem Sie einen einmaligen Kauf tätigen. Damit unterstützen Sie die Entwicklung von ListenMe Player und machen die Nutzung der App noch komfortabler.';

  @override
  String iapRemoveAdsButton(Object price) {
    return 'Werbung entfernen — $price';
  }

  @override
  String get iapRestorePurchaseButton => 'Kauf wiederherstellen';

  @override
  String get iapAdsRemovedMessage =>
      'Danke für den Kauf von ListenMe Player!\n\nWerbung wurde entfernt. Sie nutzen die Vollversion.';

  @override
  String get iapNotFound => 'Kauf nicht gefunden.';

  @override
  String get iapRestored => 'Kauf wiederhergestellt.';

  @override
  String get iapAlreadyOwned => 'Sie besitzen bereits die Vollversion.';

  @override
  String get iapShopUnavailable => 'Shop nicht verfügbar.';

  @override
  String get iapProductNotFound => 'Produkt nicht gefunden.';

  @override
  String get iapThankYou => 'Danke für Ihren Kauf!';

  @override
  String get iapError => 'Kauf fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get iapCancelled => 'Kauf wurde abgebrochen.';

  @override
  String get iapPending => 'Warte auf Zahlungsbestätigung...';

  @override
  String get iapRestoreStarted => 'Wiederherstellung der Käufe gestartet';

  @override
  String get fileInfo => 'Dateiinformationen';

  @override
  String get fileName => 'Name';

  @override
  String get filePath => 'Pfad';

  @override
  String get fileSize => 'Größe';

  @override
  String get fileFormat => 'Format';

  @override
  String get fileCodec => 'Codec';

  @override
  String get fileSampleFormat => 'Sample-Format';

  @override
  String get fileBitDepth => 'Bit-Tiefe';

  @override
  String get fileDuration => 'Dauer';

  @override
  String get fileBitrate => 'Bitrate';

  @override
  String get fileChannels => 'Kanäle';

  @override
  String get fileSampleRate => 'Abtastrate';

  @override
  String get fileBitrateType => 'Bitraten-Typ';

  @override
  String get fileStartOffset => 'Startoffset';

  @override
  String get fileTagsSection => '--- Tags ---';

  @override
  String get fileNoTags => 'Keine Tags';

  @override
  String get mono => 'Mono';

  @override
  String get stereo => 'Stereo';

  @override
  String get mb => 'MB';

  @override
  String get kbps => 'kbit/s';

  @override
  String get khz => 'kHz';

  @override
  String get vbr => 'VBR';

  @override
  String get cbr => 'CBR';

  @override
  String get close => 'Schließen';

  @override
  String get fileTagTitle => 'Titel';

  @override
  String get fileTagArtist => 'Künstler';

  @override
  String get fileTagAlbum => 'Album';

  @override
  String get fileTagAlbumArtist => 'Album-Künstler';

  @override
  String get fileTagGenre => 'Genre';

  @override
  String get fileTagTrack => 'Titelnummer';

  @override
  String get fileTagComposer => 'Komponist';

  @override
  String get fileTagYear => 'Jahr';

  @override
  String get fileTagDate => 'Datum';

  @override
  String playlistRemovedTracks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Dateien aus der Wiedergabeliste entfernt (auf dem Gerät nicht gefunden).',
      one:
          '$count Datei aus der Wiedergabeliste entfernt (auf dem Gerät nicht gefunden).',
      zero: 'Nichts entfernt',
    );
    return '$_temp0';
  }

  @override
  String folderRemovedTracks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Dateien aus der Ordnerliste entfernt (im Ordner nicht gefunden).',
      one:
          '$count Datei aus der Ordnerliste entfernt (im Ordner nicht gefunden).',
      zero: 'Keine Dateien entfernt',
    );
    return '$_temp0';
  }

  @override
  String folderAddedTracks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neue Dateien im Ordner gefunden.',
      one: '$count neue Datei im Ordner gefunden.',
      zero: 'Keine neuen Dateien gefunden',
    );
    return '$_temp0';
  }

  @override
  String get noFilePermission => 'Keine Berechtigung für Dateizugriff.';

  @override
  String get audioMetadataError =>
      'Audio-Dateimetadaten konnten nicht abgerufen werden.';

  @override
  String get tempFiles => 'Temporäre Dateien';

  @override
  String get tempFilesDeleteWav => 'Temporäre WAV-Dateien löschen';

  @override
  String get tempFilesDeleteWavDesc =>
      'Lösche generierten wav-Kopien von Audiodateien aus dem App-Cache.';

  @override
  String get tempFilesDeleteSuccess => 'Temporäre wav-Dateien wurden gelöscht.';

  @override
  String get tempFilesDeleteConfirm =>
      'Möchten Sie wirklich alle temporären wav-Dateien löschen? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get tempFilesNone => 'Keine temporären Dateien zum Löschen vorhanden.';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get enableEqualizer => 'Ein/Aus';

  @override
  String get preset => 'Voreinstellung';

  @override
  String get presetFlat => 'Neutral';

  @override
  String get presetRock => 'Rock';

  @override
  String get presetPop => 'Pop';

  @override
  String get presetJazz => 'Jazz';

  @override
  String get presetClassical => 'Klassik';

  @override
  String get presetManual => 'Manuell';

  @override
  String get resetBands => 'Reset';

  @override
  String get equalizerPlayToActivate =>
      'Zum Aktivieren des Equalizers bitte einen Titel abspielen';

  @override
  String get uriCacheResetTitle => 'Ordner- und URI-Cache zurücksetzen';

  @override
  String get uriCacheResetDesc =>
      'Diese Aktion löscht alle gespeicherten Datei- und Ordnerlisten für Playlists sowie die zuletzt geöffneten Ordner. Nach dem Zurücksetzen wird die Dateiliste neu geladen.';

  @override
  String get uriCacheResetButton => 'Ordner-Cache zurücksetzen';

  @override
  String get uriCacheResetSuccess =>
      'Der Ordner-Cache wurde erfolgreich zurückgesetzt.';

  @override
  String get uriCacheResetConfirmTitle => 'Cache zurücksetzen?';

  @override
  String get uriCacheResetConfirmDesc =>
      'Diese Aktion löscht alle zwischengespeicherten Datei- und Ordnerlisten. Fortfahren?';

  @override
  String get tempFilesRetentionDaysTitle => 'Tage zum Behalten des Caches';

  @override
  String get tempFilesRetentionDaysUnit => 'Tage';

  @override
  String get tempFilesMaxSizeTitle => 'Maximale Cache-Größe';

  @override
  String get tempFilesMaxSizeUnit => 'MB';

  @override
  String get tempFilesClearButton => 'Cache leeren';

  @override
  String get tempFilesCacheCleared => 'Cache geleert';

  @override
  String get tempFilesInfoText =>
      'Temporäre Dateien werden zur Wiedergabe und Analyse von Audiodateien verwendet, da der direkte Dateizugriff durch die Sicherheitsrichtlinien von Google Play eingeschränkt ist. Es wird empfohlen, eine moderate Cache-Größe festzulegen, um den Speicherverschleiß zu verringern.';

  @override
  String get tempFilesTitle => 'Temporäre Dateien';

  @override
  String get cacheUsed => 'Belegt';

  @override
  String get calculatingCacheSize => 'Berechne Cachegröße...';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get pleaseWait => 'Bitte warten Sie...';
}
