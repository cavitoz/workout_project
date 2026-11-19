// Bölüm 4.4 — ChallengeProgress modeli
// Hive typeId: 3 — 8 haftalık ilerleme takibi

import 'package:hive/hive.dart';

part 'challenge_progress.g.dart';

/// 8 haftalık challenge ilerleme modeli
@HiveType(typeId: 3)
class ChallengeProgress extends HiveObject {
  @HiveField(0)
  DateTime startDate; // Challenge başlangıç tarihi

  @HiveField(1)
  Map<int, int> weeklyPoints; // hafta_no (1-8) → toplam puan

  @HiveField(2)
  int totalTrophies; // Kazanılan kupa sayısı

  @HiveField(3)
  int totalPoints; // Toplam puan

  ChallengeProgress({
    required this.startDate,
    required this.weeklyPoints,
    required this.totalTrophies,
    required this.totalPoints,
  });

  /// Boş challenge başlat
  factory ChallengeProgress.empty() => ChallengeProgress(
        startDate: DateTime.now(),
        weeklyPoints: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0},
        totalTrophies: 0,
        totalPoints: 0,
      );

  /// Challenge başladı mı? Referansta başlangıç tarihi uygulamanın kurulduğu an
  /// değil, İLK antrenmanın tamamlandığı andır. Hiç puan yoksa başlamamış sayılır.
  /// (Hive şeması değişmesin diye ayrı alan yerine puanlardan türetilir.)
  bool get hasStarted =>
      totalPoints > 0 || weeklyPoints.values.any((p) => p > 0);

  /// 8 hafta (56 gün) doldu mu? Dolduysa sonraki antrenman yeni challenge başlatır.
  bool get isExpired =>
      hasStarted && DateTime.now().difference(startDate).inDays >= 56;

  /// Başlangıçtan bu yana geçen hafta sayısı (1-8)
  int getCurrentWeek() {
    final daysDiff = DateTime.now().difference(startDate).inDays;
    final week = (daysDiff ~/ 7) + 1;
    return week.clamp(1, 8);
  }

  /// Belirtilen haftanın puanını döndür
  int getWeekPoints(int week) {
    return weeklyPoints[week] ?? 0;
  }

  /// Hafta hedefi tamamlandı mı? (100 puan)
  bool isWeekComplete(int week) {
    return getWeekPoints(week) >= 100;
  }
}
