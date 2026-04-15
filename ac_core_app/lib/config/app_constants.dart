// Bölüm 2.4 — Uygulama sabitleri
// Timer varsayılanları, border radius ve animasyon süreleri

class AppConstants {
  // ─── VARSAYILAN TIMER DEĞERLERİ ───
  static const int defaultExerciseDuration = 30; // saniye
  static const int defaultRestDuration = 15; // saniye
  static const int defaultSets = 1;
  static const int defaultSetRestDuration = 60; // saniye (setler arası)

  // ─── BORDER RADIUS SABİTLERİ ───
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 24.0;
  static const double radiusExtraLarge = 32.0;

  // ─── ANİMASYON SÜRELERİ (ms) ───
  static const int timerTransition = 350; // Timer geçiş animasyonu
  static const int scalePress = 200; // Buton basma animasyonu
  static const int videoHover = 700; // Video hover efekti

  // ─── DROPDOWN SEÇENEKLERİ ───
  static const List<int> exerciseDurationOptions = [30, 40, 50, 60]; // saniye
  static const List<int> restDurationOptions = [15, 20, 25, 30]; // saniye
  static const List<int> setsOptions = [1, 2, 3, 4];
  static const List<int> setRestDurationOptions = [30, 60, 90, 120]; // saniye (set arası)

  // ─── ANTRENMAN VERİLERİ ───
  // Ana ekrandaki 5 antrenman kartı
  static const int easyWorkoutPoints = 6;
  static const int mediumWorkoutPoints = 12;
  static const int hardWorkoutPoints = 18;
  static const int extremeWorkoutPoints = 36;

  // ─── CHALLENGE ───
  static const int totalWeeks = 8;
  static const int maxPointsPerWeek = 100;

  // ─── ASSET YOLLARI ───
  static const String audioTrPath = 'assets/audio/tr/';
  static const String audioEnPath = 'assets/audio/en/';
  static const String videosPath = 'assets/videos/exercises/';
  static const String imagesPath = 'assets/images/exercises/';
  static const String coverPath = 'assets/images/cover/';
  static const String translationsPath = 'assets/translations/';

  // ─── HIVE BOX İSİMLERİ ───
  static const String exercisesBox = 'exercises';
  static const String workoutsBox = 'workouts';
  static const String settingsBox = 'settings';
  static const String challengeBox = 'challenge';

  // ─── DİL SABİTLERİ ───
  static const String defaultLanguage = 'tr';
  static const List<String> supportedLanguages = ['tr', 'en'];
}
