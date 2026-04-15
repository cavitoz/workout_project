// Bölüm 4.2 — Workout modeli
// Hive typeId: 1 — Antrenman programı

import 'package:hive/hive.dart';

part 'workout.g.dart';

/// Antrenman zorluk seviyeleri
@HiveType(typeId: 11)
enum WorkoutDifficulty {
  @HiveField(0)
  easy,
  @HiveField(1)
  medium,
  @HiveField(2)
  hard,
  @HiveField(3)
  extreme,
  @HiveField(4)
  custom,
}

/// Antrenman modeli — egzersiz ID listesi ve zorluk içerir
@HiveType(typeId: 1)
class Workout extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nameTr;

  @HiveField(2)
  final String nameEn;

  @HiveField(3)
  final List<String> exerciseIds; // Egzersiz ID listesi

  @HiveField(4)
  final WorkoutDifficulty difficulty;

  @HiveField(5)
  final int totalPoints;

  @HiveField(6)
  final String iconColor; // Hex renk kodu (yıldız rengi)

  @HiveField(7)
  final int durationMinutes; // Tahmini süre (dakika)

  Workout({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.exerciseIds,
    required this.difficulty,
    required this.totalPoints,
    required this.iconColor,
    required this.durationMinutes,
  });

  /// Dile göre antrenman adını döndür
  String getName(String language) {
    return language == 'tr' ? nameTr : nameEn;
  }
}
