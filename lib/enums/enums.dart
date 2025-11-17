enum PlaybackMode {
  singleOnce, // Один трек до конца
  singleLoop, // Один трек по кругу
  playlistOnce, // Весь плейлист один раз
  playlistLoop, // Весь плейлист по циклу
  shuffle, // Случайное воспроизведение
}




enum PlayerSection {
  homeBottomControls,
  trackTitle,
  progressSlider,
  playback,
  jogWheel,
  speedSlider,
  silenceControlBar,
  gradientDivider,
}

enum PlaybackButtonStyle {
  standard,
  extended,
  precise,
}

enum TimeDisplayStyle {
  mmss,
  mmss2digitMillis,
  mmss3digitMillis,
}

enum SecondaryTimeType {
  remaining,
  totalDuration
}


enum PlaylistSource {
  manual,
  folder
}


