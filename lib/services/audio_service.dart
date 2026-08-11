import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  final AudioPlayer _musicPlayer = AudioPlayer();

  // Si tu canción es MP3, cambia este valor por: audio/music.mp3
  static const String musicAsset = 'audio/music.mp3';

  Future<void> playMusic() async {
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.35);
      await _musicPlayer.play(AssetSource(musicAsset));
    } catch (_) {
      // Si aún no colocas una canción válida, el juego sigue funcionando.
    }
  }

  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }

  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (_) {}
  }

  Future<void> resumeMusic() async {
    try {
      await _musicPlayer.resume();
    } catch (_) {}
  }
}
