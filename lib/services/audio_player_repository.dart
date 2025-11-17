import 'package:just_audio/just_audio.dart';


class AudioPlayerRepository {
  static final AudioPlayerRepository _instance = AudioPlayerRepository._internal();
  factory AudioPlayerRepository() => _instance;
  AudioPlayerRepository._internal();

  final AudioPlayer player = AudioPlayer();

}
