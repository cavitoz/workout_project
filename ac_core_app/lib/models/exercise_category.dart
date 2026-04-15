// Bölüm 6 — Egzersiz kategorileri
// 4 ana kategori: LATERAL-BİCEPS-TRİCEPS-PLANK, BACK FLY-PEC FLY-LEG RAISE,
// DB ROW-SHOULDER PRESS-RUSSIAN TWIST, BARFİKS-ŞINAV-CRUNCH

/// Egzersiz kategorisi veri sınıfı
class ExerciseCategory {
  final String id;
  final String nameTr;
  final String nameEn;
  final String imagePath; // Kategori kapak görseli
  final List<String> exerciseIds;

  const ExerciseCategory({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.imagePath,
    required this.exerciseIds,
  });

  String getName(String language) {
    return language == 'tr' ? nameTr : nameEn;
  }
}
