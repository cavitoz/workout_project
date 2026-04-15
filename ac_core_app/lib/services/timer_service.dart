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
  bool get isLastFiveSeconds =>
      _remainingSeconds <= 5 && _remainingSeconds > 0;

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
      _audioService.stopAll();
      onStateChange?.call();
    }
  }

  void resume() {
    if (_state == TimerState.paused) {
      _state = _pausedState;
      onStateChange?.call();
      _startTicker();
    }
  }

  void skip() {
    _ticker?.cancel();
    if (_state == TimerState.exercising) {
      _advanceToNextExercise();
    } else if (_state == TimerState.resting ||
        _state == TimerState.setResting) {
      _startExercising();
    }
  }

  void reset() {
    _ticker?.cancel();
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
    _startTicker();
  }

  void _startSetResting() {
    _state = TimerState.setResting;
    _remainingSeconds = _settings.setBreakDuration;
    _totalSeconds = _settings.setBreakDuration;
    onStateChange?.call();
    _startTicker();
  }

  void _startExercising() {
    _state = TimerState.exercising;
    _remainingSeconds = _settings.exerciseDuration;
    _totalSeconds = _settings.exerciseDuration;
    onStateChange?.call();
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _onTick();
    });
  }

  void _onTick() {
    if (_remainingSeconds <= 0) {
      _ticker?.cancel();
      _handleTimerEnd();
      return;
    }

    _remainingSeconds--;

    // Dinlenme bitişinde egzersiz sayaç sesini çal
    // Android audio latency (~500ms) için 5'te tetiklenir → ses UI ile senkronize gider
    if ((_state == TimerState.resting || _state == TimerState.setResting) &&
        _remainingSeconds == 5 &&
        _settings.countdownVoice) {
      _audioService.playExerciseCountdown();
    }

    onTick?.call();
  }

  void _handleTimerEnd() {
    if (_state == TimerState.resting || _state == TimerState.setResting) {
      _startExercising();
    } else if (_state == TimerState.exercising) {
      _advanceToNextExercise();
    }
  }

  void _advanceToNextExercise() {
    _currentExerciseIndex++;

    if (_currentExerciseIndex >= _exercises.length) {
      _currentExerciseIndex = 0;
      _currentSet++;

      if (_currentSet > _settings.sets) {
        _state = TimerState.completed;
        onStateChange?.call();
        onComplete?.call();
      } else {
        // Setler arası uzun dinlenme (ayarlardan)
        _startSetResting();
      }
    } else {
      // Egzersizler arası kısa dinlenme
      _startResting();
    }
  }
}
