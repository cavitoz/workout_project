// Bölüm 5.1 — Ayarlar provider
// WorkoutSettings Hive'dan okur/yazar, dil değişimini yönetir

import 'package:flutter/foundation.dart';
import '../models/workout_settings.dart';
import '../services/database_service.dart';

class SettingsProvider extends ChangeNotifier {
  WorkoutSettings _settings = WorkoutSettings.defaults();

  WorkoutSettings get settings => _settings;
  int get exerciseDuration => _settings.exerciseDuration;
  int get restDuration => _settings.restDuration;
  int get sets => _settings.sets;
  bool get soundEnabled => _settings.soundEnabled;
  bool get countdownVoice => _settings.countdownVoice;
  String get language => _settings.language;
  int get setBreakDuration => _settings.setBreakDuration;

  /// Hive'dan ayarları yükle
  Future<void> loadSettings() async {
    _settings = DatabaseService.getSettings();
    notifyListeners();
  }

  /// Egzersiz süresi güncelle (30, 40, 50, 60 sn)
  Future<void> setExerciseDuration(int seconds) async {
    _settings.exerciseDuration = seconds;
    await _save();
  }

  /// Dinlenme süresi güncelle (15, 20, 25, 30 sn)
  Future<void> setRestDuration(int seconds) async {
    _settings.restDuration = seconds;
    await _save();
  }

  /// Set sayısı güncelle (1, 2, 3, 4)
  Future<void> setSets(int count) async {
    _settings.sets = count;
    await _save();
  }

  /// Ses efektleri açık/kapalı
  Future<void> setSoundEnabled(bool enabled) async {
    _settings.soundEnabled = enabled;
    await _save();
  }

  /// Geri sayım sesi açık/kapalı
  Future<void> setCountdownVoice(bool enabled) async {
    _settings.countdownVoice = enabled;
    await _save();
  }

  /// Dil güncelle ('tr' veya 'en')
  Future<void> setLanguage(String lang) async {
    _settings.language = lang;
    await _save();
  }

  /// Set arası dinlenme süresi güncelle (30, 60, 90, 120 sn)
  Future<void> setSetBreakDuration(int seconds) async {
    _settings.setBreakDuration = seconds;
    await _save();
  }

  /// Tüm ayarları varsayılana sıfırla
  Future<void> resetToDefaults() async {
    _settings.exerciseDuration = 30;
    _settings.restDuration = 15;
    _settings.sets = 1;
    _settings.soundEnabled = true;
    _settings.countdownVoice = true;
    _settings.language = 'tr';
    _settings.setBreakDuration = 60;
    await _save();
  }

  /// Hive'a kaydet ve UI'ı güncelle
  Future<void> _save() async {
    await DatabaseService.saveSettings(_settings);
    notifyListeners();
  }
}
