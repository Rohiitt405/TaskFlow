import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioPlayer? _audioPlayer;

  Future<void> play(String assetPath) async {
    try {
      final audioPlayer = _audioPlayer ??= AudioPlayer();
      await audioPlayer.play(AssetSource(assetPath));
    } catch (_) {
      // Audio playback is optional and may fail in tests or unsupported environments.
    }
  }

  void dispose() {
    _audioPlayer?.dispose();
  }
}
