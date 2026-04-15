// Bölüm 5.4 — Challenge provider
// ChallengeProgress okur/yazar, haftalık puan ekler

import 'package:flutter/foundation.dart';
import '../models/challenge_progress.dart';
import '../services/database_service.dart';
import '../config/app_constants.dart';

class ChallengeProvider extends ChangeNotifier {
  ChallengeProgress _progress = ChallengeProgress.empty();

  ChallengeProgress get progress => _progress;
  int get totalPoints => _progress.totalPoints;
  int get totalTrophies => _progress.totalTrophies;
  int get currentWeek => _progress.getCurrentWeek();

  /// Hive'dan challenge ilerlemesini yükle
  Future<void> loadProgress() async {
    _progress = DatabaseService.getChallengeProgress();
    notifyListeners();
  }

  /// Mevcut haftaya puan ekle
  Future<void> addPoints(int points) async {
    final week = _progress.getCurrentWeek();
    final currentWeekPoints = _progress.getWeekPoints(week);
    final newPoints =
        (currentWeekPoints + points).clamp(0, AppConstants.maxPointsPerWeek);

    _progress.weeklyPoints[week] = newPoints;
    _progress.totalPoints += points;

    // Hafta hedefi tamamlandıysa kupa ekle
    if (!_progress.isWeekComplete(week) && newPoints >= 100) {
      _progress.totalTrophies++;
    }

    await DatabaseService.saveChallengeProgress(_progress);
    notifyListeners();
  }

  /// 8 haftalık verileri grafik için liste olarak döndür
  /// [0, 45, 100, 72, 0, 0, 0, 0] formatında
  List<double> getWeeklyData() {
    return List.generate(AppConstants.totalWeeks, (i) {
      return _progress.getWeekPoints(i + 1).toDouble();
    });
  }

  /// Challenge'ı sıfırla
  Future<void> resetChallenge() async {
    _progress = ChallengeProgress.empty();
    await DatabaseService.saveChallengeProgress(_progress);
    notifyListeners();
  }
}
