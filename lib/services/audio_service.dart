import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playSiren() async {
    try {
      // Play siren from Flutter asset
      await _player.setAsset('assets/audio/siren.mp3');
      await _player.setVolume(1.0);
      await _player.play();
    } catch (e) {
      print('Error playing siren: $e');
    }
  }

  Future<void> playAdhan() async {
    try {
      // Play adhan from Flutter asset
      await _player.setAsset('assets/audio/azan.mp3');
      await _player.setVolume(1.0);
      await _player.play();
    } catch (e) {
      print('Error playing adhan: $e');
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
