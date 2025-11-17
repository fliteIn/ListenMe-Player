// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get searchBarHintText => 'Поиск...';

  @override
  String get showWelcomeScreen => 'Приветствие';

  @override
  String get welcomeTitle => 'Добро пожаловать!';

  @override
  String get welcomeDescription =>
      'Спасибо, что выбрали ListenMe Player!\n\nЭто ваш незаменимый инструмент для работы с аудио: быстрый и точный поиск, удобное управление и полная персонализация интерфейса. Максимальный комфорт и полный контроль всегда под рукой.';

  @override
  String get welcomePolicyTitle => 'Правовая информация';

  @override
  String get welcomePolicy =>
      'Приложение не проверяет наличие лицензии или авторских прав у загружаемых файлов. Ответственность за их использование несёт пользователь.';

  @override
  String get welcomeCopies =>
      'Для обеспечения работы отдельных функций приложение создаёт временные копии аудиофайлов пониженного качества. Эти копии хранятся только локально и автоматически удаляются при исключении оригиналов из плейлистов.';

  @override
  String get welcomeBackgroundImagesTitle => 'Фоновые изображения';

  @override
  String get welcomeBackgroundImagesIntro =>
      'Фоновые изображения использованы с сайта Unsplash (https://unsplash.com) от авторов:';

  @override
  String get welcomeLegalSummary1 =>
      'ListenMe Player не собирает Ваши личные данные, не анализирует ваши файлы вне устройства и не передает их третьим лицам.';

  @override
  String get welcomeLegalSummary2 =>
      'Ответственность за законность использования аудиофайлов несёт пользователь.';

  @override
  String get welcomeLegalSummary3 =>
      'Приложению требуется разрешение на доступ к памяти устройства для воспроизведения аудиофайлов. Этот доступ используется только внутри приложения и не подразумевает передачу данных третьим лицам.';

  @override
  String get welcomeLegalSummary4 =>
      'Для работы отдельных функций создаются временные копии аудио, которые хранятся только на вашем устройстве.';

  @override
  String get welcomeLegalDetails => 'Подробнее о политике конфиденциальности';

  @override
  String get welcomeLegalAgreeNotice =>
      'Нажимая «Продолжить», вы соглашаетесь с условиями.';

  @override
  String get buttonNext => 'Далее';

  @override
  String get buttonBack => 'Назад';

  @override
  String get buttonAgree => 'Продолжить';

  @override
  String get buttonClose => 'Закрыть';

  @override
  String get interfaceLanguage => 'Язык интерфейса';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get widgetOrderTitle => 'Порядок отображения элементов';

  @override
  String get darkTheme => 'Тёмная тема';

  @override
  String get lightTheme => 'Светлая тема';

  @override
  String get systemTheme => 'Системная тема';

  @override
  String get theme => 'Тема';

  @override
  String get playback => 'Воспроизведение';

  @override
  String get jogAndSeek => 'Джог и перемотка';

  @override
  String get interface => 'Интерфейс';

  @override
  String get timecode => 'Таймкод';

  @override
  String get secondaryTimeTypeTitle => 'Режим второго поля времени';

  @override
  String get secondaryTimeTypeRemaining => 'Оставшееся время';

  @override
  String get secondaryTimeTypeTotalDuration => 'Длительность трека';

  @override
  String get backgroundImage => 'Фоновое изображение';

  @override
  String get chooseBackgroundImage => 'Выбрать изображение';

  @override
  String get resetBackgroundImage => 'Сбросить изображение';

  @override
  String get useBackgroundImage => 'Использовать фоновое изображение';

  @override
  String get stretchToFullScreen => 'Растянуть на весь экран';

  @override
  String get fillScreen => 'Заполнить экран';

  @override
  String transparency(Object value) {
    return 'Прозрачность: $value%';
  }

  @override
  String get themeSelection => 'Выбор темы';

  @override
  String get selectTheme => 'Выбрать тему';

  @override
  String get saveCurrentTheme => 'Сохранить текущую тему';

  @override
  String get resetToFactory => 'Сбросить';

  @override
  String themeSaved(Object theme) {
    return 'Тема \"$theme\" сохранена';
  }

  @override
  String themeReset(Object theme) {
    return 'Тема \"$theme\" сброшена';
  }

  @override
  String get colorSettings => 'Настройки цветов';

  @override
  String get main => 'Основной';

  @override
  String get shadow => '----------------  Тень  ----------------';

  @override
  String get color => 'цвет';

  @override
  String get enabled => 'вкл/выкл';

  @override
  String get blur => 'размытие';

  @override
  String get gradientSettings => 'Настройки градиентов';

  @override
  String get navIconsActive => 'Иконки навигации - активные';

  @override
  String get navIconsInactive => 'Иконки навигации - неактивные';

  @override
  String get displayIconsActive => 'Иконки нижнего ряда - активные';

  @override
  String get displayIconsInactive => 'Иконки нижнего ряда - неактивные';

  @override
  String get controlElements => 'Элементы управления';

  @override
  String get brightness => 'Яркость';

  @override
  String get contrast => 'Контраст';

  @override
  String get widgetIconsText => 'Иконки/текст виджетов';

  @override
  String get buttonIconsText => 'Иконки/текст кнопок';

  @override
  String get mainText => 'Основной текст';

  @override
  String get sliderActive => 'Слайдер - активная часть';

  @override
  String get sliderInactive => 'Слайдер - неактивная часть';

  @override
  String get playlistDeleteButton => 'Кнопка удаления трека (в плейлисте)';

  @override
  String get startEnd => '1         2';

  @override
  String get background => 'Фон экрана';

  @override
  String get divider => 'Разделитель';

  @override
  String get topBar => 'Верхняя панель';

  @override
  String get jog => 'Джог';

  @override
  String get pickColor => 'Выберите цвет';

  @override
  String get ok => 'OK';

  @override
  String get jogResolution => 'Разрешение джога';

  @override
  String get secondsPerRevolution => 'сек/оборот';

  @override
  String get minSeekSpeed => 'Скорость перемотки (мин.)';

  @override
  String get maxSeekSpeed => 'Скорость перемотки (макс.)';

  @override
  String get playbackButtonType => 'Тип кнопок управления воспроизведением';

  @override
  String get standard => 'Стандартный';

  @override
  String get extended => 'Расширенный';

  @override
  String get precise => 'Точный';

  @override
  String get playbackSpeedRange => 'Диапазон скорости воспроизведения';

  @override
  String get min => 'Мин';

  @override
  String get max => 'Макс';

  @override
  String get timeFormatTitle => 'Формат отображения времени';

  @override
  String get timeFormatMmss => 'MM:SS';

  @override
  String get timeFormatMmss2digitMillis => 'MM:SS:MM';

  @override
  String get timeFormatMmss3digitMillis => 'MM:SS:MMM';

  @override
  String get autoHoursHint =>
      'Часы отображаются автоматически, если трек длиннее 1 часа.';

  @override
  String get widgetTrackTitle => 'Название трека';

  @override
  String get widgetPositionGroup => 'Блок позиции и маркеров';

  @override
  String get widgetPlaybackButtons => 'Кнопки управления';

  @override
  String get widgetJog => 'Jog и кнопки';

  @override
  String get widgetSpeedSlider => 'Слайдер скорости';

  @override
  String get widgetSilenceBar => 'Панель тишины';

  @override
  String get transparencyLabel => 'Прозрачность';

  @override
  String get themeWord => 'Тема';

  @override
  String get savedWord => 'сохранена';

  @override
  String get resetWord => 'сброшена';

  @override
  String get themeStandard => 'Стандартная';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeCustom => 'Пользовательская';

  @override
  String get msPerSec => 'мс/сек';

  @override
  String get noTrack => 'Нет трека';

  @override
  String get helpMenu => 'Справка';

  @override
  String get aboutApp => 'О приложении';

  @override
  String get widgets => 'Виджеты';

  @override
  String get playlistHelpTitle => 'Плейлист';

  @override
  String get licenses => 'Лицензии';

  @override
  String get copyrightText => '© 2025 Flitein. Все права защищены.';

  @override
  String get transitionBlockTitle => 'Анимация переходов';

  @override
  String get transitionTypeSlide => 'Слайд';

  @override
  String get transitionTypeFade => 'Затухание';

  @override
  String get transitionTypeScale => 'Масштаб';

  @override
  String get transitionTypeNone => 'Без анимации';

  @override
  String get helpTopBarTitle => 'Меню навигации';

  @override
  String get helpTopBarLogoBack =>
      'Логотип приложения. При переходе на подменю настроек или помощи на этом месте появляется стрелка \"назад\", возвращающая на соответствующее корневое меню.';

  @override
  String get helpTopBarHome =>
      'Кнопка перехода на домашний экран. Здесь размещаются все главные виджеты для управления проигрывателем.';

  @override
  String get helpTopBarFolderPlaylist =>
      'Кнопка перехода на папочный плейлист. Здесь пользователь может запускать воспроизведение треков непосредственно из выбранной папки на внутреннем или внешнем носителе устройства. Удобство этого плейлиста заключается в том, что не требуется предварительное создание списка воспроизведения, а также можно быстро найти необходимые аудиофайлы.';

  @override
  String get helpTopBarManualPlaylist =>
      'Кнопка перехода на ручной плейлист. Здесь пользователь может добавить в плейлист только необходимые треки. Треки могут располагаться в разных папках и даже на разных носителях. В данном плейлисте можно менять порядок воспроизведения простым перетаскиванием трека, добавлять один и тот же трек неограниченное количество раз, удалять треки по одному или все сразу.';

  @override
  String get helpTopBarSettings =>
      'Кнопка перехода в меню \"настройки\". В этом меню доступны такие настройки, как язык интерфейса, темы, виджеты и др.';

  @override
  String get helpTopBarHelp => 'Кнопка перехода в меню \"помощь\".';

  @override
  String get helpTopBarEdit =>
      'Кнопка активации режима редактирования расположения виджетов на домашнем экране. В этом режиме можно добавлять или удалять виджеты, менять их расположение простым перетаскиванием, настраивая таким образом интерфейс домашнего экрана наиболее удобным образом.';

  @override
  String get helpTopBarDescription =>
      'Данное меню всегда располагается в верхней части приложения. Вся навигация осуществляется посредством нажатия на соответствующие кнопки-иконки. В меню \"настроки\" и \"помощь\" имеются также пункты подменю. Для возврата из подменю в корневое меню необходимо нажать повторно на соответствующую иконку панели или стрелку назад верхнего или системного меню.';

  @override
  String get helpGeneralControlsTitle => 'Контрольная панель';

  @override
  String get helpGeneralControlsSchowSilenceControlBar =>
      'Кнопка \"показать\"/\"скрыть\" виджет управления прыжками на начала фраз.';

  @override
  String get helpGeneralControlsSchowPlayback =>
      'Кнопка \"показать\"/\"скрыть\" виджет кнопок управления воспроизведением.';

  @override
  String get helpGeneralControlsSchowJog =>
      'Кнопка \"показать\"/\"скрыть\" виджет \"джог\".';

  @override
  String get helpGeneralControlsSchowSpeedSlider =>
      'Кнопка \"показать\"/\"скрыть\" виджет управления скоростью воспроизведения.';

  @override
  String get helpGeneralControlsPlaybackMode =>
      'Кнопка переключения режима воспроизведения. Повторные нажатия переключают режим воспроизведения: -> \"1 трек 1 раз\" -> \"1 трек циклично\" -> \"плейлист 1 раз\" -> \"плейлист циклично\" -> \"случайный порядок\" ->. В случае, если активирован режим воспроизведения отрезка при помощи кнопки (7), выделенного маркерами, доступны только два режима: -> \"1 раз\" -> \"циклично\" ->.';

  @override
  String get helpGeneralControlsSchowMarkers =>
      'Кнопка \"показать\"/\"скрыть\" маркеры выделения отрезка трека. Сам факт отображения маркеров не активирует режим воспроизведения отрезка трека автоматически. Для активации необходимо нажать на кнопку (7).';

  @override
  String get helpGeneralControlsActivatePlayBetweenMarkers =>
      'Кнопка \"активации\"/\"деактивации\" режима воспроизведения отрезка, выделенного при помощи маркеров. Данный отрезок будет воспроизводиться либо один раз, либо по циклу, в зависимости от выбранного режима при помощи кнопки (5). Если маркеры установлены некорректно, т.е. на одном месте или за пределами трека, режим не будет активирован.';

  @override
  String get helpGeneralControlsDescription =>
      'Примечание. Кнопки \"показать\"/\"скрыть\" виджет служат для временного отключения ненужных виджетов, даже если они добавлены в режиме редактирования (см. раздел \"меню навигации\"), если приходится часто переключаться между разными задачами, например таких как обыное прослушивание музыки и работа с текстом или упражнения на аудирование, где требуются дополнительные инструменты для работы с аудиоинформацией.';

  @override
  String get helpProgressSliderTitle => 'Полоса прогресса';

  @override
  String get helpProgressSliderMinusButtons =>
      'Кнопки тонкой подстройки позиции маркеров. Нажатие и удержание соответствующей кнопки изменяет позицию маркера с возрастающей скоростью.';

  @override
  String get helpProgressSliderPosition =>
      'Текущая позиция трека в *часах:минутах:секундах:**миллисекундах.';

  @override
  String get helpProgressSliderMarkerA =>
      'Маркер начала воспроизведения отрезка (если находится левее нижнего маркера). Двойной тап по шкале маркера устанавливает маркер автоматически напротив курсора воспроизведения.';

  @override
  String get helpProgressSliderPlayHead =>
      'Курсор воспроизведения / бегунок позиции трека. Позволяет визуально оценить текущую позицию трека и грубо установить новую позицию трека.';

  @override
  String get helpProgressSliderMarkerB =>
      'Маркер конца воспроизведения отрезка (если находится правее верхнего маркера). Двойной тап по шкале маркера устанавливает маркер автоматически напротив курсора воспроизведения.';

  @override
  String get helpProgressSliderDuration =>
      'Оставшееся время трека /**длительность трека в *часах:минутах:секундах:**миллисекундах.';

  @override
  String get helpProgressSliderPlusButtons =>
      'Кнопки тонкой подстройки позиции маркеров. Нажатие и удержание соответствующей кнопки изменяет позицию маркера с возрастающей скоростью.';

  @override
  String get helpProgressSliderDescription =>
      '*появляется автоматически, если длительность трека превышает 60 минут.\n**вид отображения настраивается в меню \"Настройки/Таймкод\".\nМаркеры отображаются только если они активированы на контрольной панели при помощи кнопки (6). Порядок установки маркеров не имеет значения.';

  @override
  String get helpPlaybackStandardTitle =>
      'Стандартное управление\nвоспроизведением';

  @override
  String get helpPlaybackExtendedTitle =>
      'Расширенное управление\nвоспроизведением';

  @override
  String get helpPlaybackPreciseTitle => 'Точное управление\nвоспроизведением';

  @override
  String get helpPlaybackPrevTrack =>
      'Кнопка переключения на предыдущий трек / начало трека или отрезка, в зависимости от режима воспроизведения.';

  @override
  String get helpPlaybackJumpBack30 => 'Кнопка прыжка на 30 секунд назад.';

  @override
  String get helpPlaybackJumpBack5 => 'Кнопка прыжка на 5 секунд назад.';

  @override
  String get helpPlaybackRewind =>
      'Кнопка перемотки назад. При нажатии и удержании кнопки скорость перемотки возрастает.';

  @override
  String get helpPlaybackPlayPause =>
      'Кнопка \"воспроизведение\" / \"пауза\". Запускает или останавливает трек.';

  @override
  String get helpPlaybackFastForward =>
      'Кнопка перемотки вперед. При нажатии и удержании кнопки скорость перемотки возрастает.';

  @override
  String get helpPlaybackJumpForward5 => 'Кнопка прыжка на 5 секунд вперед.';

  @override
  String get helpPlaybackJumpForward30 => 'Кнопка прыжка на 30 секунд вперед.';

  @override
  String get helpPlaybackNextTrack =>
      'Кнопка переключения на следующий трек / конец трека или отрезка, в зависимости от режима воспроизведения.';

  @override
  String get helpPlaybackStandardDescription =>
      'Данный виджет служит для упрощенного управления воспроизведением, если не требуется решать специфические задачи.';

  @override
  String get helpPlaybackExtendedDescription =>
      'Данный виджет позволяет грубо или более точно искать необходимый участок трека, если не требуются особая точность.';

  @override
  String get helpPlaybackPreciseDescription =>
      'Данный виджет предоставляет возможность как грубого, так и очень точного поиска необходимого участка трека.';

  @override
  String get helpJogTitle => 'Джог';

  @override
  String get helpJogPrevTrack =>
      'Кнопка переключения на предыдущий трек / начало трека или отрезка, в зависимости от режима воспроизведения.';

  @override
  String get helpJogRewind =>
      'Кнопка перемотки назад. Скорость перематывания зависит от области нажатия на кнопку. В нижней части скорость перематывания медленная, а в верхней - быстрая. При этом можно скользить по кнопке, скорость перематывания будет изменяться. Пределы скорости перематывания настраиваются в меню \"Настройки/Джог\".';

  @override
  String get helpJogPlayPauseKnob =>
      'Джог. Позволяет запускать и останавливать трек, а также точно устанавливать текущую позицию трека вращением ручки в соответствующую сторону. Вращение по часовой стрелке изменяет позицию в положительную сторону, против часовой - в отрицательную. По умолчанию один оборот ручки джога изменяет позицию на 5 секунд. Это время (разрешение джога) можно изменять в меню \"Настройки/Джог\".';

  @override
  String get helpJogFastForward =>
      'Кнопка перемотки вперед. Работает аналогично (2).';

  @override
  String get helpJogNextTrack =>
      'Кнопка переключения на следующий трек / конец трека или отрезка, в зависимости от режима воспроизведения.';

  @override
  String get helpJogDescription =>
      'Данный виджет служит для решения задач с точным позиционированием, например быстрым поиском начала фраз, особенно с короткими фразами, когда нужно многократно прослушать какой-то фрагмент или просто установить курсор воспроизведения на необходимую позицию с миллисекундной точностью.';

  @override
  String get helpSpeedSliderTitle => 'Регулятор скорости воспроизведения';

  @override
  String get helpSpeedSliderMinusButton =>
      'Кнопка уменьшения скорости воспроизведения с шагом 0.1x (10%).';

  @override
  String get helpSpeedSliderThumb =>
      'Бегунок слайдера скорости воспроизведения. Позволяет быстро установить необходимую скорость. Двойной тап по шкале слайдера скорости устанавливает автоматически обычную скорость 1x.';

  @override
  String get helpSpeedSliderPlusButton =>
      'Кнопка увеличения скорости воспроизведения с шагом 0.1x (10%).';

  @override
  String get helpSpeedSliderDescription =>
      'Примечание. Пределы установки скорости настраиваются в меню \"Настройки/Воспроизведение\".';

  @override
  String get helpSilenceControlBarTitle =>
      'Виджет управления прыжками\nна начало фразы';

  @override
  String get helpSilenceControlBarJumpPrevPhrase =>
      'Кнопка прыжка на начало предыдущей фразы.';

  @override
  String get helpSilenceControlBarPCMLevel =>
      'Индикатор уровня аудиосигнала. Во время воспроизведения трека показывает уровень аудиосигнала в реальном времени. Он помогает правильно настроить порог определения тишины.';

  @override
  String get helpSilenceControlBarThumb =>
      'Бегунок настройки порога определения тишины. От его положения зависит, какой уровень сигнала аудио будет считаться началом фразы. Если в аудиофайле отсутствует шумовой фон, есть смысл устанавливать меньшие значения порога. При этом кнопки прыжков смогут более детально искать фразы. Если же шумовой фон значительный, следует увеличить значение порога, иначе отдельные фразы могут быть не найдены. Порог следует подбирать опытным путем. Рекомендуется начинать со средних значений.';

  @override
  String get helpSilenceControlBarJumpNextPhrase =>
      'Кнопка прыжка на начало следующей фразы.';

  @override
  String get helpSilenceControlBarDescription =>
      'Виджет служит для удобной навигации по фразам в аудиофайле. Хорошо подходит для детального прослушивания интервью, аудиокниг, диалогов (например при изучении иностранных языков).\nПримечание. После переключения трека или изменения положения бегунка на нем короткое время может отображаться вращающийся индикатор, сообщающий о процессе анализа аудиофайла. В это время функционал кнопок прыжков на начала фраз может быть неточным.';

  @override
  String get helpManualPlaylistTitle => 'Плейлист';

  @override
  String get helpManualPlaylistOpen =>
      'Кнопка открытия проводника для добавления треков в плейлист.';

  @override
  String get helpManualPlaylistClear => 'Кнопка очистки всего плейлиста.';

  @override
  String get helpManualPlaylistSearch =>
      'Панель для поиска трека по фрагменту из названия. Позволяет быстро найти желаемый трек в списке.';

  @override
  String get helpManualPlaylistDrag =>
      'Ручка для перемещения трека на другое место в списке. Служит для изменения порядка следования треков в плейлисте. Если потянуть ручку у желаемого трека вверх или вниз, данный трек \"высвободится\" из своего слота и его можно будет поместить на новое место.';

  @override
  String get helpManualPlaylistFilename =>
      'Название аудиофайла с расширением. Нажатие и удержание пальца на треке вызывает окно с некоторой информацией о файле и аудиоданных.';

  @override
  String get helpManualPlaylistNumber =>
      'Номер трека в плейлисте, длительность трека и расширение/формат аудиофайла.';

  @override
  String get helpManualPlaylistDelete => 'Кнопка удаления трека из плейлиста.';

  @override
  String get helpManualPlaylistDescription =>
      'Примечания.\n-Строка активного трека в плейлисте, который воспроизводится или стоит на паузе, подсвечивается фоном.\n-Тап по другому треку в плейлисте запускает его воспроизведение автоматически.\n-В данном случае изображен ручной плейлист. Функционал папочного плейлиста полностью совпадает, за исключением того, что воспроизведение трека запускается прямо из выбранной папки, порядок треков нельзя менять, удаление треков также невозможно.\n-Активным становится автоматически тот плейлист, в котором выбрали трек для воспроизведения.';

  @override
  String get iapRemoveAdsTitle => 'Отключить рекламу';

  @override
  String get iapRemoveAdsDescription =>
      'Вы можете полностью убрать всю рекламу, совершив однократную покупку. Это поддержит развитие ListenMe Player и сделает использование приложения ещё удобнее.';

  @override
  String iapRemoveAdsButton(Object price) {
    return 'Убрать рекламу — $price';
  }

  @override
  String get iapRestorePurchaseButton => 'Восстановить покупку';

  @override
  String get iapAdsRemovedMessage =>
      'Спасибо за покупку ListenMe Player!\n\nРеклама отключена. Вы используете полную версию.';

  @override
  String get iapNotFound => 'Покупка не найдена.';

  @override
  String get iapRestored => 'Покупка восстановлена.';

  @override
  String get iapAlreadyOwned => 'Вы уже приобрели полную версию.';

  @override
  String get iapShopUnavailable => 'Магазин недоступен.';

  @override
  String get iapProductNotFound => 'Товар не найден.';

  @override
  String get iapThankYou => 'Спасибо за покупку!';

  @override
  String get iapError => 'Покупка не удалась. Попробуйте ещё раз.';

  @override
  String get iapCancelled => 'Покупка отменена.';

  @override
  String get iapPending => 'Ожидание подтверждения оплаты...';

  @override
  String get iapRestoreStarted => 'Восстановление покупок начато';

  @override
  String get fileInfo => 'Информация о файле';

  @override
  String get fileName => 'Имя';

  @override
  String get filePath => 'Путь';

  @override
  String get fileSize => 'Размер';

  @override
  String get fileFormat => 'Формат';

  @override
  String get fileCodec => 'Кодек';

  @override
  String get fileSampleFormat => 'Формат сэмплов';

  @override
  String get fileBitDepth => 'Битность';

  @override
  String get fileDuration => 'Длительность';

  @override
  String get fileBitrate => 'Битрейт';

  @override
  String get fileChannels => 'Каналы';

  @override
  String get fileSampleRate => 'Частота дискретизации';

  @override
  String get fileBitrateType => 'Тип битрейта';

  @override
  String get fileStartOffset => 'Стартовое смещение';

  @override
  String get fileTagsSection => '--- Теги ---';

  @override
  String get fileNoTags => 'Нет тегов';

  @override
  String get mono => 'Моно';

  @override
  String get stereo => 'Стерео';

  @override
  String get mb => 'МБ';

  @override
  String get kbps => 'кбит/с';

  @override
  String get khz => 'кГц';

  @override
  String get vbr => 'VBR';

  @override
  String get cbr => 'CBR';

  @override
  String get close => 'Закрыть';

  @override
  String get fileTagTitle => 'Название';

  @override
  String get fileTagArtist => 'Исполнитель';

  @override
  String get fileTagAlbum => 'Альбом';

  @override
  String get fileTagAlbumArtist => 'Альбомный исполнитель';

  @override
  String get fileTagGenre => 'Жанр';

  @override
  String get fileTagTrack => 'Трек';

  @override
  String get fileTagComposer => 'Композитор';

  @override
  String get fileTagYear => 'Год';

  @override
  String get fileTagDate => 'Дата';

  @override
  String playlistRemovedTracks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файлов удалены из плейлиста (отсутствуют на устройстве).',
      many: '$count файлов удалены из плейлиста (отсутствуют на устройстве).',
      few: '$count файла удалены из плейлиста (отсутствуют на устройстве).',
      one: '$count файл удалён из плейлиста (отсутствует на устройстве).',
      zero: 'Ничего не удалено',
    );
    return '$_temp0';
  }

  @override
  String folderRemovedTracks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файлов удалены из списка папки (их нет в папке).',
      many: '$count файлов удалены из списка папки (их нет в папке).',
      few: '$count файла удалены из списка папки (их нет в папке).',
      one: '$count файл удалён из списка папки (его нет в папке).',
      zero: 'Нет удалённых файлов',
    );
    return '$_temp0';
  }

  @override
  String folderAddedTracks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'В папке найдено $count новых файлов.',
      many: 'В папке найдено $count новых файлов.',
      few: 'В папке найдено $count новых файла.',
      one: 'В папке найден $count новый файл.',
      zero: 'Нет новых файлов',
    );
    return '$_temp0';
  }

  @override
  String get noFilePermission => 'Нет разрешения на доступ к файлам.';

  @override
  String get audioMetadataError => 'Не удалось получить метаданные аудиофайла.';

  @override
  String get tempFiles => 'Временные файлы';

  @override
  String get tempFilesDeleteWav => 'Удалить временные WAV-файлы';

  @override
  String get tempFilesDeleteWavDesc =>
      'Удалить сгенерированные wav-копии аудиофайлов из кэша приложения.';

  @override
  String get tempFilesDeleteSuccess => 'Временные wav-файлы удалены.';

  @override
  String get tempFilesDeleteConfirm =>
      'Вы действительно хотите удалить все временные wav-файлы? Это действие нельзя отменить.';

  @override
  String get tempFilesNone => 'Нет временных файлов для удаления.';

  @override
  String get equalizer => 'Эквалайзер';

  @override
  String get enableEqualizer => 'Вкл/Выкл';

  @override
  String get preset => 'Пресет';

  @override
  String get presetFlat => 'По умолчанию';

  @override
  String get presetRock => 'Рок';

  @override
  String get presetPop => 'Поп';

  @override
  String get presetJazz => 'Джаз';

  @override
  String get presetClassical => 'Классика';

  @override
  String get presetManual => 'Вручную';

  @override
  String get resetBands => 'Сброс';

  @override
  String get equalizerPlayToActivate =>
      'Для активации эквалайзера запустите трек';

  @override
  String get uriCacheResetTitle => 'Сбросить кэш папок и УРИ';

  @override
  String get uriCacheResetDesc =>
      'Это действие удалит все запомненные списки файлов и папок для плейлистов, а также последние открытые папки. После сброса список файлов будет загружен заново.';

  @override
  String get uriCacheResetButton => 'Сбросить кэш папок';

  @override
  String get uriCacheResetSuccess => 'Кэш папок успешно сброшен.';

  @override
  String get uriCacheResetConfirmTitle => 'Сбросить кэш?';

  @override
  String get uriCacheResetConfirmDesc =>
      'Это действие удалит все кэшированные списки файлов и папок. Продолжить?';

  @override
  String get tempFilesRetentionDaysTitle => 'Дни хранения кэша';

  @override
  String get tempFilesRetentionDaysUnit => 'дней';

  @override
  String get tempFilesMaxSizeTitle => 'Максимальный размер кэша';

  @override
  String get tempFilesMaxSizeUnit => 'МБ';

  @override
  String get tempFilesClearButton => 'Очистить кэш';

  @override
  String get tempFilesCacheCleared => 'Кэш очищен';

  @override
  String get tempFilesInfoText =>
      'Временные файлы используются для воспроизведения и анализа аудио, поскольку прямой доступ к файлам ограничен политикой безопасности Google Play. Рекомендуется устанавливать умеренный размер кэша, чтобы снизить износ накопителя.';

  @override
  String get tempFilesTitle => 'Временные файлы';

  @override
  String get cacheUsed => 'Занято в кэше';

  @override
  String get calculatingCacheSize => 'Рассчитываем размер кэша...';

  @override
  String get refresh => 'Обновить';

  @override
  String get pleaseWait => 'Пожалуйста, подождите...';
}
