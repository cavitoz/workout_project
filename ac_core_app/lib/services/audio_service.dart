import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _countdownPlayer = AudioPlayer();

  bool _isMuted = false;

  AudioService() {
    AudioPlayer.global.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          isSpeakerphoneOn: true,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioMode: AndroidAudioMode.normal,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
    _countdownPlayer.setReleaseMode(ReleaseMode.stop);
  }

  bool get isMuted => _isMuted;
  void setMuted(bool muted) => _isMuted = muted;

  /// Dinlenme bitişi geri sayım sesi — son 4 saniyede çalınır
  /// egzersizsayac_trimmed.mp3 egzersiz başlangıcıyla senkronize
  void playExerciseCountdown() {
    if (_isMuted) return;
    _countdownPlayer.stop().catchError((_) {});
    _countdownPlayer
        .play(AssetSource('audio/egzersizsayac_trimmed.mp3'))
        .catchError((_) {});
  }

  /// Tüm sesleri durdur (pause anında)
  void stopAll() {
    _countdownPlayer.stop().catchError((_) {});
  }

  Future<void> dispose() async {
    await _countdownPlayer.dispose().catchError((_) {});
  }
}
