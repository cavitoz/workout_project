import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Geri sayım klipleri — eski 36 sn'lik tek parça `egzersizsayac_trimmed.mp3`
/// kaydından saniye saniye kesildi (assets/audio/countdown/).
///
/// Neden: tek parça kayıttaki bip'ler 1,000 sn değil ~1,045 sn arayla çalıyordu;
/// 30 sn'lik egzersizde ses sayacın ~1 sn gerisine düşüyor, 40/50/60 sn'de hiç
/// uymuyordu. Referans uygulama gibi her ses artık sayacın ilgili tick'inde
/// ayrı tetikleniyor → kayma birikemez, her egzersiz süresinde tam senkron.
enum CountdownClip { prep, beep, ten, n5, n4, n3, n2, n1, end }

class AudioService {
  // Her klip için ayrı, önceden yüklenmiş düşük gecikmeli (Android SoundPool)
  // oynatıcı: her tetiklemede dosya yeniden yüklenmez, gecikme sabit ve kısa.
  final Map<CountdownClip, AudioPlayer> _clips = {};
  bool _clipsReady = false;

  // "prep" (dinlenmenin son 5 sn'si) uzun klip — duraklat/devam için izlenir.
  final Stopwatch _prepClock = Stopwatch();
  static const _prepDuration = Duration(milliseconds: 5350);
  bool _prepPaused = false;

  // Sesli yönlendirme (egzersiz adı vb.) — cihazın TTS motoru.
  // Ses dosyası gerektirmez; dil ayarına göre TR/EN konuşur.
  final FlutterTts _tts = FlutterTts();
  String? _ttsLanguage;
  bool _ttsAvailable = true;

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
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
  }

  bool get isMuted => _isMuted;
  void setMuted(bool muted) => _isMuted = muted;

  /// Klipleri önceden yükle (antrenman başında bir kez). İlk tetiklemede
  /// yükleme gecikmesi olmasın diye sayaç başlamadan çağrılır.
  Future<void> preloadClips() async {
    if (_clipsReady) return;
    for (final clip in CountdownClip.values) {
      final player = AudioPlayer();
      try {
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setSource(AssetSource('audio/countdown/${clip.name}.wav'));
      } catch (_) {
        // Yüklenemeyen klip sessiz kalır; sayaç etkilenmez.
      }
      _clips[clip] = player;
    }
    _clipsReady = true;
  }

  /// Bir geri sayım klibini baştan çal. SoundPool'da bitmiş akış yeniden
  /// başlatılamadığı için önce stop() → resume() yeni akış açar.
  void playClip(CountdownClip clip) {
    if (_isMuted) return;
    final player = _clips[clip];
    if (player == null) return;
    if (clip == CountdownClip.prep) {
      _prepClock
        ..reset()
        ..start();
      _prepPaused = false;
    }
    player.stop().then((_) => player.resume()).catchError((_) {});
  }

  bool get _prepActive =>
      _prepClock.isRunning && _prepClock.elapsed < _prepDuration;

  /// TTS dilini ayarla ('tr' → tr-TR, diğerleri → en-US).
  /// Cihazda dil paketi yoksa sesli yönlendirme sessizce devre dışı kalır.
  Future<void> setVoiceLanguage(String language) async {
    final tag = language == 'tr' ? 'tr-TR' : 'en-US';
    if (_ttsLanguage == tag) return;
    _ttsLanguage = tag;
    try {
      final available = await _tts.isLanguageAvailable(tag);
      _ttsAvailable = available == true;
      if (!_ttsAvailable) return;
      await _tts.setLanguage(tag);
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (_) {
      _ttsAvailable = false;
    }
  }

  /// Metni seslendir. Önceki konuşmayı keser — yönlendirmeler üst üste binmez.
  void speak(String text) {
    if (_isMuted || !_ttsAvailable || text.isEmpty) return;
    _tts.stop().catchError((_) => null);
    _tts.speak(text).catchError((_) => null);
  }

  /// Tüm sesleri durdur (atlama / çıkış anında)
  void stopAll() {
    for (final p in _clips.values) {
      p.stop().catchError((_) {});
    }
    _prepClock
      ..stop()
      ..reset();
    _prepPaused = false;
    _tts.stop().catchError((_) => null);
  }

  /// Duraklat: çalmakta olan "prep" klibi kaldığı yerde bekler (sayaç da
  /// milisaniye hassasiyetle durduğu için devamda ikisi birlikte sürer).
  /// Kısa klipler (≤1 sn) zaten bitmiş/bitmek üzeredir, kesilir.
  void pauseAll() {
    if (_prepActive) {
      _clips[CountdownClip.prep]?.pause().catchError((_) {});
      _prepClock.stop();
      _prepPaused = true;
    }
    for (final e in _clips.entries) {
      if (e.key != CountdownClip.prep) e.value.stop().catchError((_) {});
    }
    // TTS Android'de kaldığı yerden sürdürülemez; kısa cümleler olduğu için kesilir
    _tts.stop().catchError((_) => null);
  }

  /// Duraklatılmış "prep" klibini kaldığı yerden sürdür.
  void resumeAll() {
    if (_isMuted || !_prepPaused) return;
    _prepPaused = false;
    _prepClock.start();
    _clips[CountdownClip.prep]?.resume().catchError((_) {});
  }

  Future<void> dispose() async {
    for (final p in _clips.values) {
      await p.dispose().catchError((_) {});
    }
    _clips.clear();
    _clipsReady = false;
    await _tts.stop().catchError((_) => null);
  }
}
