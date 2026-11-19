// Bölüm 7 — Hive veritabanı servisi
// Bölüm 3.4 — Seed data: PHOTOS ve VIDEOS klasörlerindeki dosyalardan egzersiz verileri

import 'package:hive_flutter/hive_flutter.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_settings.dart';
import '../models/challenge_progress.dart';
import '../config/app_constants.dart';

class DatabaseService {
  /// Hive'ı başlat ve tüm adapter'ları kaydet
  static Future<void> initDatabase() async {
    await Hive.initFlutter();

    // Adapter kayıtları
    Hive.registerAdapter(ExerciseDifficultyAdapter());
    Hive.registerAdapter(ExerciseAdapter());
    Hive.registerAdapter(WorkoutDifficultyAdapter());
    Hive.registerAdapter(WorkoutAdapter());
    Hive.registerAdapter(WorkoutSettingsAdapter());
    Hive.registerAdapter(ChallengeProgressAdapter());

    // Box'ları aç
    await Hive.openBox<Exercise>(AppConstants.exercisesBox);
    await Hive.openBox<Workout>(AppConstants.workoutsBox);
    await Hive.openBox<WorkoutSettings>(AppConstants.settingsBox);
    await Hive.openBox<ChallengeProgress>(AppConstants.challengeBox);

    await _migrateSettings();
  }

  /// Kayıtlı ayarları yeni varsayılanlara taşı.
  /// Kullanıcının değiştirmediği (eski varsayılan `sets = 1`) kurulumlar
  /// yeni varsayılan olan 3 sete / 1 dk set arası dinlenmeye yükseltilir.
  static Future<void> _migrateSettings() async {
    final settingsBox = Hive.box<WorkoutSettings>(AppConstants.settingsBox);
    final existing = settingsBox.get('settings');
    if (existing != null && existing.sets == 1) {
      existing.sets = AppConstants.defaultSets;
      existing.setBreakDuration = AppConstants.defaultSetRestDuration;
      await existing.save();
    }
  }

  /// İlk çalıştırmada varsayılan verileri yükle
  static Future<void> seedInitialData() async {
    final exerciseBox = Hive.box<Exercise>(AppConstants.exercisesBox);
    final workoutBox = Hive.box<Workout>(AppConstants.workoutsBox);
    final settingsBox = Hive.box<WorkoutSettings>(AppConstants.settingsBox);
    final challengeBox = Hive.box<ChallengeProgress>(AppConstants.challengeBox);

    // Egzersiz/antrenman seed verisi güncellendiyse yeniden yükle:
    // - BARFIKS (pull_up) egzersizi kaldırıldı
    // - Dambıl Row sağ/sol olarak ikiye ayrıldı (dumbell_row → dumbell_row_right/left)
    final needsReseed = exerciseBox.isEmpty ||
        exerciseBox.containsKey('pull_up') ||
        exerciseBox.containsKey('dumbell_row');

    if (needsReseed) {
      // ─── EGZERSİZ VERİLERİ ───
      await exerciseBox.clear();
      for (final exercise in _buildExercises()) {
        await exerciseBox.put(exercise.id, exercise);
      }

      // ─── ANTRENMAN PROGRAMLARI ───
      await workoutBox.clear();
      for (final workout in _buildWorkouts()) {
        await workoutBox.put(workout.id, workout);
      }
    }

    // ─── VARSAYILAN AYARLAR ───
    if (settingsBox.isEmpty) {
      await settingsBox.put('settings', WorkoutSettings.defaults());
    }

    // ─── BOŞ CHALLENGE ───
    if (challengeBox.isEmpty) {
      await challengeBox.put('progress', ChallengeProgress.empty());
    }
  }

  /// Tüm egzersizleri döndür
  static List<Exercise> getAllExercises() {
    return Hive.box<Exercise>(AppConstants.exercisesBox).values.toList();
  }

  /// ID'ye göre egzersiz bul
  static Exercise? getExerciseById(String id) {
    return Hive.box<Exercise>(AppConstants.exercisesBox).get(id);
  }

  /// Tüm antrenmanları döndür
  static List<Workout> getAllWorkouts() {
    return Hive.box<Workout>(AppConstants.workoutsBox).values.toList();
  }

  /// ID'ye göre antrenman bul
  static Workout? getWorkoutById(String id) {
    return Hive.box<Workout>(AppConstants.workoutsBox).get(id);
  }

  /// Ayarları döndür
  static WorkoutSettings getSettings() {
    return Hive.box<WorkoutSettings>(AppConstants.settingsBox)
            .get('settings') ??
        WorkoutSettings.defaults();
  }

  /// Ayarları kaydet
  static Future<void> saveSettings(WorkoutSettings settings) async {
    await Hive.box<WorkoutSettings>(AppConstants.settingsBox)
        .put('settings', settings);
  }

  /// Challenge ilerlemesini döndür
  static ChallengeProgress getChallengeProgress() {
    return Hive.box<ChallengeProgress>(AppConstants.challengeBox)
            .get('progress') ??
        ChallengeProgress.empty();
  }

  /// Challenge ilerlemesini kaydet
  static Future<void> saveChallengeProgress(ChallengeProgress progress) async {
    await Hive.box<ChallengeProgress>(AppConstants.challengeBox)
        .put('progress', progress);
  }

  // ─── SEED DATA YARDIMCI FONKSİYONLARI ───

  /// 13 egzersiz için seed data oluştur
  /// Bölüm 6'daki kategorilere göre organize edildi
  static List<Exercise> _buildExercises() {
    return [
      // Kategori 1: LATERAL - BİCEPS - TRİCEPS - PLANK
      Exercise(
        id: 'lateral',
        nameTr: 'Lateral Kaldırma',
        nameEn: 'Lateral Raise',
        descriptionTr:
            'Ayakta durarak, kolları yanlara doğru omuz hizasına kadar kaldırın.',
        descriptionEn:
            'Standing upright, raise your arms to the sides to shoulder height.',
        imagePath: 'assets/images/exercises/lateral.png',
        videoPath: 'assets/videos/exercises/lateral.mp4',
        difficulty: ExerciseDifficulty.easy,
        category: 'lateral-biceps-triceps-plank',
        points: 2,
      ),
      Exercise(
        id: 'biceps_curl',
        nameTr: 'Biceps Curl',
        nameEn: 'Biceps Curl',
        descriptionTr: 'Dambılları tutarak dirseklerinizi bükerek kaldırın.',
        descriptionEn:
            'Holding dumbbells, curl your arms up by bending elbows.',
        imagePath: 'assets/images/exercises/biceps_curl.png',
        videoPath: 'assets/videos/exercises/biceps_curl.mp4',
        difficulty: ExerciseDifficulty.easy,
        category: 'lateral-biceps-triceps-plank',
        points: 2,
      ),
      Exercise(
        id: 'triceps',
        nameTr: 'Triceps',
        nameEn: 'Triceps Extension',
        descriptionTr:
            'Dambılı başın arkasında tutarak kolları yukarı doğru uzatın.',
        descriptionEn: 'Hold dumbbell behind head and extend arms upward.',
        imagePath: 'assets/images/exercises/triceps.png',
        videoPath: 'assets/videos/exercises/triceps.mp4',
        difficulty: ExerciseDifficulty.easy,
        category: 'lateral-biceps-triceps-plank',
        points: 2,
      ),
      Exercise(
        id: 'plank',
        nameTr: 'Plank',
        nameEn: 'Plank',
        descriptionTr:
            'Ön kol ve ayak parmakları üzerinde vücudu düz tutun. 30-60 saniye.',
        descriptionEn:
            'Hold body straight on forearms and toes. 30-60 seconds.',
        imagePath: 'assets/images/exercises/plank.png',
        videoPath: 'assets/videos/exercises/plank.mp4',
        difficulty: ExerciseDifficulty.medium,
        category: 'lateral-biceps-triceps-plank',
        points: 3,
      ),
      // Kategori 2: BACK FLY - PEC FLY - LEG RAISE
      Exercise(
        id: 'back_fly',
        nameTr: 'Arka Fly',
        nameEn: 'Back Fly',
        descriptionTr:
            'Öne eğilerek, kolları yanlara açın ve sırt kaslarını çalıştırın.',
        descriptionEn:
            'Lean forward, open arms to sides to work rear deltoids.',
        imagePath: 'assets/images/exercises/back_fly.png',
        videoPath: 'assets/videos/exercises/back_fly.mp4',
        difficulty: ExerciseDifficulty.medium,
        category: 'back-fly-pec-fly-leg-raise',
        points: 3,
      ),
      Exercise(
        id: 'pec_fly',
        nameTr: 'Göğüs Fly',
        nameEn: 'Pec Fly',
        descriptionTr:
            'Sırt üstü yatarak, kolları geniş tutup göğüs kaslarını sıkıştırın.',
        descriptionEn:
            'Lying on back, bring arms together to squeeze chest muscles.',
        imagePath: 'assets/images/exercises/pec_fly.png',
        videoPath: 'assets/videos/exercises/pec_fly.mp4',
        difficulty: ExerciseDifficulty.medium,
        category: 'back-fly-pec-fly-leg-raise',
        points: 3,
      ),
      Exercise(
        id: 'leg_raise',
        nameTr: 'Bacak Kaldırma',
        nameEn: 'Leg Raise',
        descriptionTr:
            'Sırt üstü yatarak, bacakları düz tutarak yukarı kaldırın.',
        descriptionEn: 'Lying on back, raise straight legs upward.',
        imagePath: 'assets/images/exercises/leg_raise.png',
        videoPath: 'assets/videos/exercises/leg_raise.mp4',
        difficulty: ExerciseDifficulty.medium,
        category: 'back-fly-pec-fly-leg-raise',
        points: 3,
      ),
      // Kategori 3: DB ROW - SHOULDER PRESS - RUSSIAN TWIST
      Exercise(
        id: 'dumbell_row_right',
        nameTr: 'Dambıl Row (Sağ)',
        nameEn: 'Dumbell Row (Right)',
        descriptionTr:
            'Öne eğilerek, dambılı sağ kolunuzla karın hizasına kadar çekin ve sırt kaslarını çalıştırın.',
        descriptionEn:
            'Bent over, pull the dumbbell with your right arm to waist height to work back muscles.',
        imagePath: 'assets/images/exercises/dumbell_row.png',
        videoPath: 'assets/videos/exercises/dumbell_row.mp4',
        difficulty: ExerciseDifficulty.hard,
        category: 'db-row-shoulder-press-russian-twist',
        points: 4,
      ),
      Exercise(
        id: 'dumbell_row_left',
        nameTr: 'Dambıl Row (Sol)',
        nameEn: 'Dumbell Row (Left)',
        descriptionTr:
            'Öne eğilerek, dambılı sol kolunuzla karın hizasına kadar çekin ve sırt kaslarını çalıştırın.',
        descriptionEn:
            'Bent over, pull the dumbbell with your left arm to waist height to work back muscles.',
        imagePath: 'assets/images/exercises/dumbell_row.png',
        videoPath: 'assets/videos/exercises/dumbell_row.mp4',
        difficulty: ExerciseDifficulty.hard,
        category: 'db-row-shoulder-press-russian-twist',
        points: 4,
      ),
      Exercise(
        id: 'shoulder_press',
        nameTr: 'Omuz Pres',
        nameEn: 'Shoulder Press',
        descriptionTr: 'Dambılları omuz hizasından yukarıya doğru itin.',
        descriptionEn: 'Press dumbbells from shoulder height upward overhead.',
        imagePath: 'assets/images/exercises/shoulder_press.png',
        videoPath: 'assets/videos/exercises/shoulder_press.mp4',
        difficulty: ExerciseDifficulty.hard,
        category: 'db-row-shoulder-press-russian-twist',
        points: 4,
      ),
      Exercise(
        id: 'russian_twist',
        nameTr: 'Russian Twist',
        nameEn: 'Russian Twist',
        descriptionTr:
            'Oturarak bacakları yerden kaldırıp gövdeyi sağa-sola döndürün.',
        descriptionEn:
            'Seated with legs raised, rotate torso from side to side.',
        imagePath: 'assets/images/exercises/russian_twist.png',
        videoPath: 'assets/videos/exercises/russian_twist.mp4',
        difficulty: ExerciseDifficulty.hard,
        category: 'db-row-shoulder-press-russian-twist',
        points: 4,
      ),
      // Kategori 4: ŞINAV - CRUNCH
      Exercise(
        id: 'push_up',
        nameTr: 'Şınav',
        nameEn: 'Push-Up',
        descriptionTr:
            'Yüzüstü pozisyonda, kolları büküp uzatarak göğüs kaslarını çalıştırın.',
        descriptionEn:
            'Face down position, bend and extend arms to work chest.',
        imagePath: 'assets/images/exercises/push-up.png',
        videoPath: 'assets/videos/exercises/push-up.mp4',
        difficulty: ExerciseDifficulty.medium,
        category: 'barfiks-sinav-crunch',
        points: 3,
      ),
      Exercise(
        id: 'crunch',
        nameTr: 'Crunch',
        nameEn: 'Crunch',
        descriptionTr:
            'Sırt üstü yatarak, karın kaslarını kullanarak üst gövdeyi kaldırın.',
        descriptionEn:
            'Lying on back, use abs to raise upper body off the ground.',
        imagePath: 'assets/images/exercises/crunch.png',
        videoPath: 'assets/videos/exercises/crunch.mp4',
        difficulty: ExerciseDifficulty.easy,
        category: 'barfiks-sinav-crunch',
        points: 2,
      ),
    ];
  }

  /// 5 antrenman programı için seed data
  /// Bölüm 5.1 — Ana ekrandaki 5 kart
  static List<Workout> _buildWorkouts() {
    return [
      // 1. Kolay Antrenman — mavi yıldız, 5dk, 6 puan
      Workout(
        id: 'easy',
        nameTr: 'Kolay Antrenman',
        nameEn: 'Easy Workout',
        exerciseIds: ['lateral', 'biceps_curl', 'triceps'],
        difficulty: WorkoutDifficulty.easy,
        totalPoints: 6,
        iconColor: '#3B82F6',
        durationMinutes: 5,
      ),
      // 2. Orta Antrenman — kırmızı yıldız, 5dk, 12 puan
      Workout(
        id: 'medium',
        nameTr: 'Orta Antrenman',
        nameEn: 'Medium Workout',
        exerciseIds: ['plank', 'back_fly', 'pec_fly', 'leg_raise'],
        difficulty: WorkoutDifficulty.medium,
        totalPoints: 12,
        iconColor: '#EF4444',
        durationMinutes: 5,
      ),
      // 3. Zor Antrenman — amber yıldız, 5dk, 18 puan
      Workout(
        id: 'hard',
        nameTr: 'Zor Antrenman',
        nameEn: 'Hard Workout',
        exerciseIds: [
          'dumbell_row_right',
          'dumbell_row_left',
          'shoulder_press',
          'russian_twist',
          'push_up',
          'crunch'
        ],
        difficulty: WorkoutDifficulty.hard,
        totalPoints: 18,
        iconColor: '#F59E0B',
        durationMinutes: 5,
      ),
      // 4. Ekstra Zor — sarı yıldız, 15dk, 36 puan
      Workout(
        id: 'extreme',
        nameTr: 'Ekstra Zor Antrenman',
        nameEn: 'Extreme Workout',
        exerciseIds: [
          'lateral',
          'biceps_curl',
          'triceps',
          'plank',
          'back_fly',
          'pec_fly',
          'leg_raise',
          'dumbell_row_right',
          'dumbell_row_left',
          'shoulder_press',
          'russian_twist',
          'push_up',
          'crunch'
        ],
        difficulty: WorkoutDifficulty.extreme,
        totalPoints: 36,
        iconColor: '#FACC15',
        durationMinutes: 15,
      ),
      // 5. Bireysel Antrenman — gri yıldız, 1-15dk, kullanıcı seçer
      Workout(
        id: 'custom',
        nameTr: 'Bireysel Antrenman',
        nameEn: 'Custom Workout',
        exerciseIds: [
          'lateral',
          'biceps_curl',
          'triceps',
          'plank',
          'back_fly',
          'pec_fly',
          'leg_raise'
        ],
        difficulty: WorkoutDifficulty.custom,
        totalPoints: 18,
        iconColor: '#9CA3AF',
        durationMinutes: 7,
      ),
    ];
  }
}
