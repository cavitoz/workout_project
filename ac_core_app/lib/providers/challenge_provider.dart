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

  /// Mevcut haftaya puan ekle — referans kuralları:
  /// - Challenge ilk tamamlanan antrenmanla başlar (başlangıç tarihi o an).
  /// - 8 hafta × 7 gün; hafta, başlangıçtan geçen gün sayısıyla belirlenir.
  /// - Haftalık hedef 100 puan; puan 100'de kesilmez, gerçek toplam tutulur.
  /// - 8 hafta dolduktan sonraki ilk antrenman yeni bir challenge başlatır
  ///   (toplam puan ve kupalar ömür boyu istatistik olarak korunur).
  Future<void> addPoints(int points) async {
    if (points <= 0) return;

    if (!_progress.hasStarted || _progress.isExpired) {
      _progress.startDate = DateTime.now();
      _progress.weeklyPoints = {
        for (var w = 1; w <= AppConstants.totalWeeks; w++) w: 0,
      };
    }

    final week = _progress.getCurrentWeek();
    // Kupa kontrolü için eklemeden ÖNCEKİ durum alınmalı
    final wasComplete = _progress.isWeekComplete(week);

    _progress.weeklyPoints[week] = _progress.getWeekPoints(week) + points;
    _progress.totalPoints += points;

    // Hafta hedefine bu antrenmanla ulaşıldıysa kupa ekle (haftada bir kez)
    if (!wasComplete && _progress.isWeekComplete(week)) {
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
