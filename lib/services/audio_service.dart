import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> playSound(String assetPath) async {
    await _player.stop();
    _isPlaying = true;
    await _player.play(AssetSource(assetPath));
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
    });
  }

  Future<void> previewSound(int soundIndex) async {
    String file;
    switch (soundIndex) {
      case 1: file = 'sounds/azan_fajr.mp3'; break;
      case 2: file = 'sounds/azan_normal.mp3'; break;
      case 3: file = 'sounds/notification_islamic.mp3'; break;
      default: return;
    }
    await playSound(file);
    Future.delayed(const Duration(seconds: 3), () {
      stop();
    });
  }

  Future<void> playAzan(int soundIndex) async {
    String file;
    switch (soundIndex) {
      case 1: file = 'sounds/azan_fajr.mp3'; break;
      case 2: file = 'sounds/azan_normal.mp3'; break;
      default: return;
    }
    await _player.stop();
    _isPlaying = true;
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource(file));
  }

  Future<void> stop() async {
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.release);
    _isPlaying = false;
  }

  void dispose() {
    _player.dispose();
  }
}
