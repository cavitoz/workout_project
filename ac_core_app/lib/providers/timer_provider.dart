// Bölüm 5.3 — Timer provider
// TimerService'i wrap eder, UI'ın dinleyeceği state'leri tutar

import 'package:flutter/foundation.dart';
import '../models/exercise.dart';
import '../models/workout_settings.dart';
import '../services/timer_service.dart';
import '../services/audio_service.dart';

class TimerProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  late final TimerService _timerService;

  TimerProvider() {
    _timerService = TimerService(audioService: _audioService);

    // Timer callback'leri bağla
    _timerService.onTick = () => notifyListeners();
    _timerService.onStateChange = () => notifyListeners();
    _timerService.onComplete = () => notifyListeners();
  }

  // ─── GETTER'LAR ───
  TimerState get timerState => _timerService.state;
  int get currentExerciseIndex => _timerService.currentExerciseIndex;
  int get currentSet => _timerService.currentSet;
  int get totalSets => _timerService.totalSets;
  int get remainingSeconds => _timerService.remainingSeconds;
  double get progress => _timerService.progress;
  Exercise? get currentExercise => _timerService.currentExercise;
  Exercise? get nextExercise => _timerService.nextExercise;
  bool get isLastFiveSeconds => _timerService.isLastFiveSeconds;
  bool get isPlaying =>
      timerState == TimerState.exercising ||
      timerState == TimerState.resting ||
      timerState == TimerState.setResting;
  bool get isPaused => timerState == TimerState.paused;
  bool get isCompleted => timerState == TimerState.completed;
  bool get isResting =>
      timerState == TimerState.resting || timerState == TimerState.setResting;
  bool get isSetResting => timerState == TimerState.setResting;
  bool get isExercising => timerState == TimerState.exercising;

  /// Ses kapalı mı?
  bool get isMuted => _audioService.isMuted;

  /// Antrenmanı başlat
  /// TTS dili ilk anonstan önce ayarlanır (sonraki çağrılarda önbellekten döner).
  Future<void> startWorkout(
      List<Exercise> exercises, WorkoutSettings settings) async {
    // Ses anahtarları ayrı ayrı TimerService içinde uygulanır (referanstaki gibi):
    // soundEnabled = "Egzersiz Açıklaması" (TTS anonsları),
    // countdownVoice = "Geri Sayım Sesi" (5-4-3-2-1 + son 10 sn).
    _audioService.setMuted(false);
    await _audioService.setVoiceLanguage(settings.language);
    // Geri sayım kliplerini sayaç başlamadan yükle (ilk tetiklemede gecikme olmasın)
    await _audioService.preloadClips();
    _timerService.startWorkout(exercises, settings);
  }

  /// Duraklat
  void pause() {
    _timerService.pause();
  }

  /// Devam et
  void resume() {
    _timerService.resume();
  }

  /// Duraklat/Devam toggle
  void togglePause() {
    if (isPaused) {
      resume();
    } else {
      pause();
    }
  }

  /// Sonraki egzersize atla
  void skip() {
    _timerService.skip();
  }

  /// Sıfırla
  void reset() {
    _timerService.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    _timerService.dispose();
    _audioService.dispose();
    super.dispose();
  }
}
