// Bölüm 4.2 / Bölüm 5.3 — Timer servisi
// State machine: idle → resting → exercising → resting → ... → completed

import 'dart:async';
import '../models/exercise.dart';
import '../models/workout_settings.dart';
import 'audio_service.dart';

enum TimerState {
  idle,
  resting,
  setResting,
  exercising,
  paused,
  completed,
}

typedef TimerCallback = void Function();

class TimerService {
  final AudioService _audioService;

  TimerState _state = TimerState.idle;
  List<Exercise> _exercises = [];
  WorkoutSettings _settings = WorkoutSettings.defaults();

  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  TimerState _pausedState = TimerState.idle;

  Timer? _ticker;
  TimerCallback? onTick;
  TimerCallback? onStateChange;
  TimerCallback? onComplete;

  // ─── GETTERLAR ───
  TimerState get state => _state;
  int get currentExerciseIndex => _currentExerciseIndex;
  int get currentSet => _currentSet;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  int get totalSets => _settings.sets;
  bool get isLastFiveSeconds => _remainingSeconds <= 5 && _remainingSeconds > 0;

  Exercise? get currentExercise {
    if (_exercises.isEmpty || _currentExerciseIndex >= _exercises.length) {
      return null;
    }
    return _exercises[_currentExerciseIndex];
  }

  Exercise? get nextExercise {
    final nextIndex = _currentExerciseIndex + 1;
    if (nextIndex >= _exercises.length) return null;
    return _exercises[nextIndex];
  }

  double get progress {
    if (_totalSeconds == 0) return 0;
    return (_totalSeconds - _remainingSeconds) / _totalSeconds;
  }

  TimerService({required AudioService audioService})
      : _audioService = audioService;

  void startWorkout(List<Exercise> exercises, WorkoutSettings settings) {
    _exercises = exercises;
    _settings = settings;
    _currentExerciseIndex = 0;
    _currentSet = 1;
    _startResting();
  }

  void pause() {
    if (_state == TimerState.exercising ||
        _state == TimerState.resting ||
        _state == TimerState.setResting) {
      _pausedState = _state;
      _state = TimerState.paused;
      _ticker?.cancel();
      _phaseClock.stop(); // saniyenin kesri korunur
      _audioService.pauseAll();
      onStateChange?.call();
    }
  }

  void resume() {
    if (_state == TimerState.paused) {
      _state = _pausedState;
      _audioService.resumeAll();
      onStateChange?.call();
      _phaseClock.start(); // kaldığı milisaniyeden devam
      _runTicker();
    }
  }

  void skip() {
    _ticker?.cancel();
    // Atlamada çalan geri sayım sesi yeni faza taşmasın
    _audioService.stopAll();
    // Duraklatılmışken atlanırsa duraklatılan fazdan devam ederek atla
    if (_state == TimerState.paused) {
      _state = _pausedState;
    }
    if (_state == TimerState.exercising) {
      _advanceAfterExercise();
    } else if (_state == TimerState.resting ||
        _state == TimerState.setResting) {
      _startExercising();
    }
  }

  void reset() {
    _ticker?.cancel();
    _phaseClock
      ..stop()
      ..reset();
    _phaseId++;
    _audioService.stopAll();
    _state = TimerState.idle;
    _currentExerciseIndex = 0;
    _currentSet = 1;
    _remainingSeconds = 0;
    _totalSeconds = 0;
    onStateChange?.call();
  }

  void dispose() {
    _ticker?.cancel();
  }

  // ─── ÖZEL YARDIMCI METOTLAR ───

  void _startResting() {
    _state = TimerState.resting;
    _remainingSeconds = _settings.restDuration;
    _totalSeconds = _settings.restDuration;
    onStateChange?.call();
    _announceUpcoming(isSetRest: false);
    _startTicker();
  }

  void _startSetResting() {
    _state = TimerState.setResting;
    _remainingSeconds = _settings.setBreakDuration;
    _totalSeconds = _settings.setBreakDuration;
    onStateChange?.call();
    _announceUpcoming(isSetRest: true);
    _startTicker();
  }

  // ─── SESLİ YÖNLENDİRME (TTS) ───
  // Referans akış: dinlenme başında sıradaki egzersiz anons edilir, bitişte
  // tamamlandı anonsu yapılır. Geri sayım sesleri (bip, "10", 5-4-3-2-1) TTS
  // değil, sayaç tick'lerinde tetiklenen kliplerdir — bkz. _playCountdownClips.

  bool get _isTr => _settings.language == 'tr';

  /// "Egzersiz Açıklaması" anahtarı → egzersiz anonsları
  void _speak(String text) {
    if (!_settings.soundEnabled) return;
    _audioService.speak(text);
  }

  void _announceUpcoming({required bool isSetRest}) {
    final exercise = currentExercise;
    if (exercise == null) return;
    final name = exercise.getName(_settings.language);
    if (isSetRest) {
      _speak('Set $_currentSet. $name.'); // "Set" TR ve EN'de aynı
    } else {
      final n = _currentExerciseIndex + 1;
      _speak(_isTr ? 'Egzersiz $n. $name.' : 'Exercise $n. $name.');
    }
  }

  void _announceComplete() {
    _speak(_isTr
        ? 'Antrenman tamamlandı. Harika iş çıkardın!'
        : 'Workout complete. Great job!');
  }

  void _startExercising() {
    _state = TimerState.exercising;
    _remainingSeconds = _settings.exerciseDuration;
    _totalSeconds = _settings.exerciseDuration;
    onStateChange?.call();
    _startTicker();
  }

  // ─── SAYAÇ MOTORU ───
  // Eski motor Timer.periodic(1 sn) idi: her tick birkaç ms geç gelir, video
  // yüklenirken UI thread meşgulse onlarca ms; gecikme birikir ve ses ile sayaç
  // ayrışırdı. Yeni motor fazın gerçek geçen süresini Stopwatch ile ölçer ve
  // "kaç saniye doldu" hesabıyla tick üretir → kayma birikmez. Duraklatmada
  // Stopwatch durur, saniyenin kesri kaybolmaz.

  final Stopwatch _phaseClock = Stopwatch();
  int _ticksDone = 0;
  int _phaseId = 0; // faz değiştiğinde eski fazın tick döngüsünü keser

  /// Yeni faz başlangıcı: saati sıfırla ve tick'lemeye başla
  void _startTicker() {
    _phaseId++;
    _phaseClock
      ..reset()
      ..start();
    _ticksDone = 0;
    _runTicker();
  }

  void _runTicker() {
    _ticker?.cancel();
    // 50 ms'de bir kontrol: tick'ler en fazla ~50 ms sapmayla, birikmeden gelir
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) => _pump());
  }

  void _pump() {
    final phase = _phaseId;
    final due = _phaseClock.elapsedMilliseconds ~/ 1000;
    // UI thread uzun süre bloke olduysa kaçırılan tick'ler sırayla işlenir
    while (_ticksDone < due && phase == _phaseId && _isRunning) {
      _ticksDone++;
      _onTick();
    }
  }

  bool get _isRunning =>
      _state == TimerState.exercising ||
      _state == TimerState.resting ||
      _state == TimerState.setResting;

  void _onTick() {
    if (_remainingSeconds <= 0) {
      _ticker?.cancel();
      _handleTimerEnd();
      return;
    }

    _remainingSeconds--;
    _playCountdownClips();
    onTick?.call();
  }

  /// Referans uygulamadaki gibi sesler tick'e bağlı ("Geri Sayım Sesi" anahtarı):
  /// - Dinlenme: 5 sn kala hazırlık geri sayımı (5-4-3-2-1 + başla)
  /// - Egzersiz: her saniye bip, 10 sn kala "10", son 5 sn sesli 5-4-3-2-1,
  ///   0'da bitiş sesi. Egzersiz süresi 30/40/50/60 fark etmeksizin çalışır.
  void _playCountdownClips() {
    if (!_settings.countdownVoice) return;
    final r = _remainingSeconds;

    if (_state == TimerState.resting || _state == TimerState.setResting) {
      if (r == 5) _audioService.playClip(CountdownClip.prep);
      return;
    }

    if (_state != TimerState.exercising) return;
    switch (r) {
      case 10:
        _audioService.playClip(CountdownClip.ten);
      case 5:
        _audioService.playClip(CountdownClip.n5);
      case 4:
        _audioService.playClip(CountdownClip.n4);
      case 3:
        _audioService.playClip(CountdownClip.n3);
      case 2:
        _audioService.playClip(CountdownClip.n2);
      case 1:
        _audioService.playClip(CountdownClip.n1);
      case 0:
        _audioService.playClip(CountdownClip.end);
      default:
        _audioService.playClip(CountdownClip.beep);
    }
  }

  void _handleTimerEnd() {
    if (_state == TimerState.resting || _state == TimerState.setResting) {
      _startExercising();
    } else if (_state == TimerState.exercising) {
      _advanceAfterExercise();
    }
  }

  /// Egzersiz süresi bittiğinde ne olacağını belirler.
  /// Set döngüsü egzersiz BAZINDA döner:
  /// - Bu egzersizin daha seti varsa → setler arası dinlenme, sonra AYNI egzersizin
  ///   bir sonraki seti çalışılır.
  /// - Egzersizin tüm setleri tamamlandıysa → set sayacı sıfırlanır ve bir sonraki
  ///   egzersize geçilir (kısa dinlenme ile). Egzersiz kalmadıysa antrenman biter.
  void _advanceAfterExercise() {
    if (_currentSet < _settings.sets) {
      // Aynı egzersizin sonraki seti — önce setler arası uzun dinlenme
      _currentSet++;
      _startSetResting();
    } else {
      // Bu egzersizin tüm setleri bitti — sonraki egzersize geç
      _currentSet = 1;
      _currentExerciseIndex++;

      if (_currentExerciseIndex >= _exercises.length) {
        _state = TimerState.completed;
        _announceComplete();
        onStateChange?.call();
        onComplete?.call();
      } else {
        // Egzersizler arası kısa dinlenme
        _startResting();
      }
    }
  }
}
