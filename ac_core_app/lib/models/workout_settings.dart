// Bölüm 4.3 — WorkoutSettings modeli
// Hive typeId: 2 — Kullanıcı ayarları

import 'package:hive/hive.dart';
import '../config/app_constants.dart';

part 'workout_settings.g.dart';

/// Kullanıcı egzersiz ve ses ayarları
@HiveType(typeId: 2)
class WorkoutSettings extends HiveObject {
  @HiveField(0)
  int exerciseDuration; // 30, 40, 50, 60 saniye

  @HiveField(1)
  int restDuration; // 15, 20, 25, 30 saniye

  @HiveField(2)
  int sets; // 1, 2, 3, 4

  @HiveField(3)
  bool soundEnabled; // Ses efektleri açık/kapalı

  @HiveField(4)
  bool countdownVoice; // Sesli geri sayım açık/kapalı

  @HiveField(5)
  String language; // 'tr' veya 'en'

  @HiveField(6)
  int setBreakDuration; // 30, 60, 90, 120 saniye (setler arası dinlenme)

  WorkoutSettings({
    required this.exerciseDuration,
    required this.restDuration,
    required this.sets,
    required this.soundEnabled,
    required this.countdownVoice,
    required this.language,
    required this.setBreakDuration,
  });

  /// Varsayılan ayarlar (Bölüm 2.4)
  factory WorkoutSettings.defaults() => WorkoutSettings(
        exerciseDuration: AppConstants.defaultExerciseDuration,
        restDuration: AppConstants.defaultRestDuration,
        sets: AppConstants.defaultSets,
        soundEnabled: true,
        countdownVoice: true,
        language: AppConstants.defaultLanguage,
        setBreakDuration: AppConstants.defaultSetRestDuration,
      );
}
