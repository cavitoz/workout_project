// Bölüm 4.1 — Exercise modeli
// Hive typeId: 0 — Egzersiz varlığı

import 'package:hive/hive.dart';

part 'exercise.g.dart';

/// Egzersiz zorluk seviyeleri
@HiveType(typeId: 10)
enum ExerciseDifficulty {
  @HiveField(0)
  easy,
  @HiveField(1)
  medium,
  @HiveField(2)
  hard,
}

/// Egzersiz modeli — video, görsel, açıklama ve puan içerir
@HiveType(typeId: 0)
class Exercise extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nameTr; // Türkçe isim

  @HiveField(2)
  final String nameEn; // İngilizce isim

  @HiveField(3)
  final String descriptionTr; // Türkçe açıklama

  @HiveField(4)
  final String descriptionEn; // İngilizce açıklama

  @HiveField(5)
  final String imagePath; // Kapak görseli asset yolu

  @HiveField(6)
  final String videoPath; // Egzersiz videosu asset yolu

  @HiveField(7)
  final ExerciseDifficulty difficulty; // kolay/orta/zor

  @HiveField(8)
  final String category; // Kategori adı

  @HiveField(9)
  final int points; // Kazanılan puan

  Exercise({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.imagePath,
    required this.videoPath,
    required this.difficulty,
    required this.category,
    required this.points,
  });

  /// Dile göre egzersiz adını döndür
  String getName(String language) {
    return language == 'tr' ? nameTr : nameEn;
  }

  /// Dile göre açıklamayı döndür
  String getDescription(String language) {
    return language == 'tr' ? descriptionTr : descriptionEn;
  }
}
