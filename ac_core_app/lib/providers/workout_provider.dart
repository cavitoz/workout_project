// Bölüm 5.2 — Antrenman provider
// Antrenman listesini yönetir, aktif workout seçimini tutar

import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../services/database_service.dart';

class WorkoutProvider extends ChangeNotifier {
  List<Workout> _workouts = [];
  Workout? _activeWorkout;
  List<Exercise> _activeExercises = [];
  bool _isShuffled = false;

  List<Workout> get workouts => _workouts;
  Workout? get activeWorkout => _activeWorkout;
  List<Exercise> get activeExercises => _activeExercises;
  bool get isShuffled => _isShuffled;

  /// Hive'dan tüm antrenmanları yükle
  Future<void> loadWorkouts() async {
    _workouts = DatabaseService.getAllWorkouts();
    notifyListeners();
  }

  /// Aktif antrenmanı seç ve egzersizlerini yükle
  void selectWorkout(String workoutId) {
    _activeWorkout = DatabaseService.getWorkoutById(workoutId);
    _isShuffled = false;

    if (_activeWorkout != null) {
      _activeExercises = _activeWorkout!.exerciseIds
          .map((id) => DatabaseService.getExerciseById(id))
          .where((e) => e != null)
          .cast<Exercise>()
          .toList();
    }

    notifyListeners();
  }

  /// Egzersiz sırasını karıştır (Shuffle butonu)
  void shuffleExercises() {
    _activeExercises.shuffle();
    _isShuffled = true;
    notifyListeners();
  }

  /// Sıralamayı orijinaline sıfırla
  void resetOrder() {
    if (_activeWorkout != null) {
      _activeExercises = _activeWorkout!.exerciseIds
          .map((id) => DatabaseService.getExerciseById(id))
          .where((e) => e != null)
          .cast<Exercise>()
          .toList();
    }
    _isShuffled = false;
    notifyListeners();
  }

  /// Zorluk seviyesine göre yıldız rengi
  static String getDifficultyColor(WorkoutDifficulty difficulty) {
    switch (difficulty) {
      case WorkoutDifficulty.easy:
        return '#3B82F6';
      case WorkoutDifficulty.medium:
        return '#EF4444';
      case WorkoutDifficulty.hard:
        return '#F59E0B';
      case WorkoutDifficulty.extreme:
        return '#FACC15';
      case WorkoutDifficulty.custom:
        return '#9CA3AF';
    }
  }
}
