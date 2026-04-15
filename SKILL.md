---
name: fitness-workout-app
description: >
  Flutter ile cross-platform (Android & iOS) egzersiz/fitness mobil uygulaması geliştirme skill'i.
  Kullanıcı kendi egzersiz videolarını (mp4) ve görsellerini (png) yükleyerek, zamanlayıcı tabanlı
  antrenman sistemi, sesli geri sayım, challenge/ilerleme takibi ve çoklu dil desteği (TR/EN) içeren
  tam kapsamlı bir fitness uygulaması oluşturur. Bu skill'i şu durumlarda kullan: fitness app, egzersiz
  uygulaması, workout timer app, antrenman uygulaması, exercise app geliştirme, Flutter mobil uygulama
  oluşturma isteklerinde. Kullanıcı "egzersiz uygulaması yap", "workout app", "fitness app",
  "antrenman zamanlayıcı" gibi ifadeler kullandığında tetiklenir.
---

# AC CORE — Fitness Workout App — Flutter Geliştirme Skill'i

## 1. PROJE GENEL BAKIŞ

Bu skill, Flutter framework kullanarak Android ve iOS platformlarında çalışan bir egzersiz/fitness
uygulaması geliştirmek için kapsamlı bir rehberdir. Uygulama, kullanıcının kendi egzersiz videolarını
ve görsellerini kullanarak zamanlayıcı tabanlı antrenman yapmasını sağlar.

### 1.1 Temel Özellikler
- Egzersiz video oynatma (mp4) ve kapak görselleri (png)
- Ayarlanabilir zamanlayıcı: egzersiz süresi, dinlenme süresi, set sayısı
- Sesli geri sayım (son 5 saniye) — Türkçe ve İngilizce
- Challenge/ilerleme takip sistemi (haftalık bar grafiği)
- Çoklu dil desteği (varsayılan: Türkçe, ikinci dil: İngilizce)
- Tamamen offline çalışma — üyelik/hesap gerektirmez
- Lokal veritabanı ile ilerleme kaydı

---

## 2. TEKNOLOJİ STACK

### 2.1 Framework & Dil
```
Framework: Flutter 3.x (stable channel)
Dil: Dart 3.x
Minimum SDK: Android API 24 (Android 7.0) / iOS 14.0
```

### 2.2 Temel Paketler

```yaml
# pubspec.yaml bağımlılıkları
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  provider: ^6.1.2              # veya riverpod: ^2.5.1

  # Lokal Veritabanı
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Video Oynatma
  video_player: ^2.8.7
  chewie: ^1.8.5                # video_player üzerine UI wrapper

  # Ses/Audio
  audioplayers: ^6.1.0          # Geri sayım sesleri için
  flutter_tts: ^4.0.2           # Text-to-speech alternatifi (opsiyonel)

  # UI Bileşenleri
  circular_countdown_timer: ^0.2.3  # Dairesel geri sayım
  percent_indicator: ^4.2.3     # İlerleme barları
  fl_chart: ^0.69.0             # Challenge bar grafikleri

  # Navigasyon
  go_router: ^14.2.7

  # Yerelleştirme
  intl: ^0.19.0
  easy_localization: ^3.0.7

  # Diğer
  shared_preferences: ^2.3.2    # Basit ayar saklama
  path_provider: ^2.1.4         # Dosya yolları
  wakelock_plus: ^1.2.8         # Egzersiz sırasında ekran açık

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.12
  flutter_launcher_icons: ^0.14.1
  flutter_native_splash: ^2.4.1
```

### 2.3 Neden Flutter?
- Tek kod tabanı → Android + iOS
- Native performans (Skia rendering engine)
- Video oynatma ve ses desteği güçlü
- Hive ile hızlı lokal veritabanı
- Hot reload ile hızlı geliştirme
- Geniş paket ekosistemi

---

## 3. PROJE YAPISI

```
lib/
├── main.dart
├── app.dart
│
├── config/
│   ├── app_theme.dart              # Tema ve renkler
│   ├── app_constants.dart          # Sabit değerler
│   ├── app_router.dart             # Navigasyon rotaları
│   └── localization/
│       ├── app_localizations.dart
│       ├── tr.json                 # Türkçe çeviriler
│       └── en.json                 # İngilizce çeviriler
│
├── models/
│   ├── exercise.dart               # Egzersiz modeli
│   ├── workout.dart                # Antrenman modeli (egzersiz listesi)
│   ├── workout_settings.dart       # Ayarlar modeli
│   ├── challenge_progress.dart     # İlerleme modeli
│   └── exercise_category.dart      # Kategori modeli
│
├── providers/
│   ├── settings_provider.dart      # Ayar yönetimi
│   ├── workout_provider.dart       # Antrenman state yönetimi
│   ├── timer_provider.dart         # Zamanlayıcı state
│   ├── challenge_provider.dart     # Challenge ilerleme
│   └── language_provider.dart      # Dil ayarları
│
├── services/
│   ├── database_service.dart       # Hive veritabanı işlemleri
│   ├── audio_service.dart          # Ses yönetimi (geri sayım sesleri)
│   ├── timer_service.dart          # Zamanlayıcı mantığı
│   └── notification_service.dart   # Bildirim servisi (opsiyonel)
│
├── screens/
│   ├── home/
│   │   └── home_screen.dart        # Ana ekran (Workouts listesi)
│   ├── workout/
│   │   ├── workout_list_screen.dart     # Egzersiz kategorileri
│   │   ├── exercise_grid_screen.dart    # Egzersiz sıralama grid
│   │   ├── workout_player_screen.dart   # Egzersiz oynatıcı (timer + video)
│   │   └── workout_complete_screen.dart # Tamamlama ekranı
│   ├── instructions/
│   │   ├── instructions_screen.dart     # Anleitungen/Kılavuz listesi
│   │   └── exercise_detail_screen.dart  # Egzersiz detay (video + açıklama)
│   ├── challenge/
│   │   └── challenge_screen.dart        # Challenge bar grafiği
│   ├── settings/
│   │   └── settings_screen.dart         # Ayarlar
│   └── menu/
│       └── side_menu_screen.dart        # Yan menü
│
├── widgets/
│   ├── countdown_circle.dart       # Dairesel geri sayım widget'ı
│   ├── exercise_card.dart          # Egzersiz kartı
│   ├── workout_card.dart           # Antrenman kartı
│   ├── challenge_bar_chart.dart    # Challenge bar grafiği
│   ├── exercise_video_player.dart  # Video oynatıcı widget
│   ├── rest_overlay.dart           # Dinlenme overlay'i
│   ├── bottom_nav_bar.dart         # Alt navigasyon barı
│   └── settings_dropdown.dart      # Ayar dropdown widget
│
└── utils/
    ├── app_colors.dart
    ├── app_text_styles.dart
    └── helpers.dart

assets/
├── images/
│   ├── cover/                      # Kapak fotoğrafları (png)
│   │   └── KAPAK_PHOTO.png
│   └── exercises/                  # Egzersiz görselleri (png)
│       ├── LATERALBICEPSTRICEPSPLANK.png
│       ├── BACK_FLYPEC_FLYLEG_RAISE.png
│       ├── DB_ROWSHOULDER_PRESSRUSSIAN_TWIST.png
│       └── BARFIKSSINAVCRUNCH.png
├── videos/
│   └── exercises/                  # Egzersiz videoları (mp4)
│       ├── lateral.mp4
│       ├── biceps_curl.mp4
│       └── ...
├── audio/
│   ├── tr/                         # Türkçe sesler
│   │   ├── bes.mp3
│   │   ├── dort.mp3
│   │   ├── uc.mp3
│   │   ├── iki.mp3
│   │   ├── bir.mp3
│   │   ├── basla.mp3
│   │   ├── dinlen.mp3
│   │   └── beep.mp3
│   └── en/                         # İngilizce sesler
│       ├── five.mp3
│       ├── four.mp3
│       ├── three.mp3
│       ├── two.mp3
│       ├── one.mp3
│       ├── start.mp3
│       ├── rest.mp3
│       └── beep.mp3
├── fonts/                          # Özel fontlar (opsiyonel)
└── translations/
    ├── tr.json
    └── en.json
```

---

## 4. VERİ MODELLERİ

### 4.1 Exercise (Egzersiz)
```dart
@HiveType(typeId: 0)
class Exercise extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nameTr;            // Türkçe isim

  @HiveField(2)
  final String nameEn;            // İngilizce isim

  @HiveField(3)
  final String descriptionTr;     // Türkçe açıklama

  @HiveField(4)
  final String descriptionEn;     // İngilizce açıklama

  @HiveField(5)
  final String imagePath;         // Kapak görseli yolu

  @HiveField(6)
  final String videoPath;         // Egzersiz videosu yolu

  @HiveField(7)
  final ExerciseDifficulty difficulty; // kolay/orta/zor

  @HiveField(8)
  final String category;          // Kategori (Kol, Bacak, Karın, vb.)

  @HiveField(9)
  final int points;               // Kazanılan puan
}

enum ExerciseDifficulty { easy, medium, hard }
```

### 4.2 Workout (Antrenman Programı)
```dart
@HiveType(typeId: 1)
class Workout extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nameTr;

  @HiveField(2)
  final String nameEn;

  @HiveField(3)
  final List<String> exerciseIds;   // Egzersiz ID listesi

  @HiveField(4)
  final WorkoutDifficulty difficulty;

  @HiveField(5)
  final int totalPoints;

  @HiveField(6)
  final String iconColor;           // Yıldız rengi (mavi/kırmızı/sarı)
}
```

### 4.3 WorkoutSettings (Ayarlar)
```dart
@HiveType(typeId: 2)
class WorkoutSettings extends HiveObject {
  @HiveField(0)
  int exerciseDuration;     // 30, 40, 50, 60 saniye

  @HiveField(1)
  int restDuration;         // 15, 20, 25, 30 saniye

  @HiveField(2)
  int sets;                 // 1, 2, 3, 4

  @HiveField(3)
  bool soundEnabled;        // Ses efektleri açık/kapalı

  @HiveField(4)
  bool countdownVoice;      // Sesli geri sayım açık/kapalı

  @HiveField(5)
  String language;          // 'tr' veya 'en'

  // Varsayılan değerler
  factory WorkoutSettings.defaults() => WorkoutSettings(
    exerciseDuration: 30,
    restDuration: 15,
    sets: 1,
    soundEnabled: true,
    countdownVoice: true,
    language: 'tr',
  );
}
```

### 4.4 ChallengeProgress (İlerleme)
```dart
@HiveType(typeId: 3)
class ChallengeProgress extends HiveObject {
  @HiveField(0)
  final DateTime startDate;

  @HiveField(1)
  final Map<int, int> weeklyPoints;  // hafta_no → toplam puan

  @HiveField(2)
  int totalTrophies;

  @HiveField(3)
  int totalPoints;

  // 8 haftalık challenge yapısı, her hafta max 100 puan
}
```

---

## 5. TEMEL EKRANLAR VE İŞ MANTIKLARI

### 5.1 Ana Ekran — Workout Listesi
**Referans Görsel:** `example_app_workouts.jpg`

Ekranda farklı zorluk seviyelerinde antrenman kartları listelenir:
- Kolay Antrenman (mavi yıldız) — 5 dakika, 6 puan
- Orta Antrenman (kırmızı yıldız) — 5 dakika, 12 puan
- Zor Antrenman (turuncu yıldız) — 5 dakika, 18 puan
- Ekstra Zor Antrenman (sarı yıldız) — 15 dakika, 36 puan
- Bireysel Antrenman (gri yıldız) — 1-15 dakika, kullanıcı seçer

Her karta tıklanınca → Egzersiz Sıralama Grid ekranına geçiş.

### 5.2 Egzersiz Sıralama Grid
**Referans Görsel:** `example_app_exercise_routine.jpg`

Seçilen antrenmanın egzersizleri 2'li grid olarak gösterilir:
- Her kart: numara, egzersiz görseli, isim, puan
- "Karıştır" butonu ile sıralama rastgele değiştirilebilir
- Alt barda "X Puan Kazan >" butonu → Egzersiz oynatıcıya geçiş

### 5.3 Egzersiz Oynatıcı (ANA EKRAN — EN KRİTİK)
**Referans Görsel:** `example_app_WORKOUT_POZITION.jpg`, `example_app_WORKOUT_START_POZITION.jpg`

Bu ekran uygulamanın kalbidir. İş akışı:

```
┌─────────────────────────────────────────────┐
│  BAŞLANGIÇ                                   │
│  ↓                                           │
│  [DİNLENME GERİ SAYIMI] — ayarlardaki süre  │
│  Son 5 saniye: sesli geri sayım              │
│  "5...4...3...2...1...BAŞLA!"                │
│  ↓                                           │
│  [EGZERSİZ ÇALIŞIYOR] — ayarlardaki süre    │
│  Video loop olarak oynar                     │
│  Dairesel timer geri sayar                   │
│  Üstte: egzersiz adı + "X / Y" sayacı       │
│  Son 5 saniye: sesli geri sayım              │
│  ↓                                           │
│  [DİNLENME] — "DİNLEN!" sesi                │
│  ↓                                           │
│  Sonraki egzersiz → tekrar üstten           │
│  ↓                                           │
│  Tüm egzersizler bitti = 1 SET tamamlandı   │
│  ↓                                           │
│  Set sayısı kadar tekrar                     │
│  ↓                                           │
│  [TAMAMLANDI] — Challenge güncelle           │
└─────────────────────────────────────────────┘
```

**Ekran Düzeni (yukarıdan aşağıya):**
1. Üst bar: geri butonu + "X Dakika Antrenman" başlığı + paylaş butonu
2. Video oynatıcı alanı (ekranın üst yarısı)
3. Kırmızı bant: Egzersiz adı (sol) + "X / Y" (sağ)
4. Dairesel countdown timer (büyük, ortada)
5. Duraklat/Devam butonu (timer içinde)

**Zamanlayıcı Mantığı (timer_service.dart):**
```dart
class TimerService {
  // States: idle, countdown, exercising, resting, paused, completed
  // 
  // DİNLENME geri sayımı başlar (restDuration saniye)
  //   → Son 5 saniyede sesli geri sayım
  //   → 0'a ulaşınca "BAŞLA!" sesi + egzersize geç
  //
  // EGZERSİZ geri sayımı başlar (exerciseDuration saniye)
  //   → Video loop oynar
  //   → Son 5 saniyede sesli geri sayım
  //   → 0'a ulaşınca "DİNLEN!" sesi
  //   → currentExercise++
  //   → Son egzersiz değilse → DİNLENME'ye dön
  //   → Son egzersiz ise → currentSet++
  //     → Tüm setler bitmişse → TAMAMLANDI
  //     → Bitmemişse → ilk egzersize dön + DİNLENME
}
```

**Sesli Geri Sayım (audio_service.dart):**
```dart
class AudioService {
  // Dile göre ses dosyası seçimi
  // Türkçe: bes.mp3, dort.mp3, uc.mp3, iki.mp3, bir.mp3, basla.mp3, dinlen.mp3
  // İngilizce: five.mp3, four.mp3, three.mp3, two.mp3, one.mp3, start.mp3, rest.mp3
  //
  // Tetikleme noktaları:
  //   remaining == 5 → "beş/five"
  //   remaining == 4 → "dört/four"
  //   remaining == 3 → "üç/three"
  //   remaining == 2 → "iki/two"
  //   remaining == 1 → "bir/one"
  //   remaining == 0 && wasResting → "başla/start"
  //   remaining == 0 && wasExercising → "dinlen/rest"
}
```

### 5.4 Kılavuzlar / Anleitungen
**Referans Görsel:** `example_app_user_manuals.jpg`

Tüm egzersizlerin listelendiği ekran:
- Üstte filtre tabları: Tümü / Kolay / Orta / Zor
- Her kart: egzersiz görseli arka planda, isim, bilgi (i) butonu, play butonu
- Karta tıklanınca egzersiz detay ekranı (video + açıklama)

### 5.5 Challenge Ekranı
**Referans Görsel:** `example_app_WORKOUT_CHALLANGE.jpg`

8 haftalık ilerleme bar grafiği:
- X ekseni: Hafta 1-8
- Y ekseni: 0-100 puan
- Her haftanın üstünde kalp ikonu (hedef tamamlanınca dolu)
- Aktif hafta koyu renkli bar, gelecek haftalar açık gri
- Alt kısım: "Sıfırla" butonu + başlangıç tarihi
- Her antrenman tamamlandığında ilgili haftaya puan eklenir

### 5.6 Ayarlar Ekranı
**Referans Görsel:** `example_app_WORKOUT_SETTINGS.jpg`

**Antrenman Seçenekleri:**
- Egzersiz Süresi: Dropdown [30, 40, 50, 60] saniye — varsayılan: 30
- Dinlenme Süresi: Dropdown [15, 20, 25, 30] saniye — varsayılan: 15
- Set Sayısı: Dropdown [1, 2, 3, 4] — varsayılan: 1

**Ses Seçenekleri:**
- Egzersiz açıklaması: Toggle switch
- Geri sayım sesi: Toggle switch

**Dil Seçeneği:**
- Dil: Dropdown [Türkçe, English] — varsayılan: Türkçe

**Sıfırla butonu:** Tüm ayarları varsayılana döndür

### 5.7 Yan Menü / Daha Fazla
**Referans Görsel:** `example_app_SIDE_MENU.jpg`

Menü öğeleri:
- Başla (hızlı başlangıç)
- Sorumluluk Reddi
- Hatırlatıcılar
- Ayarlar
- Ses Efektleri (toggle)
- Bildirimler (toggle)
- Challenge Kupası sayısı
- Toplam Puan

### 5.8 Alt Navigasyon Barı
5 sekme (Stitch tasarımına göre — Material Symbols Outlined ikonlar, UPPERCASE etiketler):
1. fitness_center → "ANTRENMANLAR" (aktif: #FF6B35 turuncu, glassmorphism vurgu)
2. play_circle → "EGZERSİZLER" (pasif: gray-500)
3. trophy → "CHALLENGE" (pasif: gray-500)
4. notifications → "BİLDİRİMLER" (pasif: gray-500, badge opsiyonel)
5. menu → "DAHA FAZLA" (pasif: gray-500)

---

## 6. EGZERSIZ KATEGORİLERİ VE İÇERİK

Projede yüklenmiş egzersiz görselleri 4 ana kategoriye ayrılıyor:

### Kategori 1: LATERAL - BİCEPS - TRİCEPS - PLANK
**Görsel:** `LATERALBICEPSTRICEPSPLANK.png`
- Lateral Raise (Yana Açış)
- Biceps Curl (Pazu)
- Triceps Extension (Arka Kol)
- Biceps Curl (Pazu) — tekrar
- Plank — 30-60 saniye

### Kategori 2: BACK FLY - PEC FLY - LEG RAISE
**Görsel:** `BACK_FLYPEC_FLYLEG_RAISE.png`
- Back Fly (Ters Fly)
- Pec Fly (Göğüs Sıkıştırma)
- Leg Raise (Bacak Kaldırma)

### Kategori 3: DB ROW - SHOULDER PRESS - RUSSIAN TWIST
**Görsel:** `DB_ROWSHOULDER_PRESSRUSSIAN_TWIST.png`
- DB Row (Dambıl Row)
- Shoulder Press (Omuz Pres)
- Russian Twist

### Kategori 4: BARFİKS - ŞINAV - CRUNCH
**Görsel:** `BARFIKSSINAVCRUNCH.png`
- Barfiks (Pull-up)
- Şınav (Push-up)
- Crunch (Mekik)

---

## 7. LOKAL VERİTABANI (Hive)

### 7.1 Box Yapısı
```dart
// main.dart → initHive()
await Hive.initFlutter();

// Adapter kayıtları
Hive.registerAdapter(ExerciseAdapter());
Hive.registerAdapter(WorkoutAdapter());
Hive.registerAdapter(WorkoutSettingsAdapter());
Hive.registerAdapter(ChallengeProgressAdapter());

// Box'ları aç
await Hive.openBox<Exercise>('exercises');
await Hive.openBox<Workout>('workouts');
await Hive.openBox<WorkoutSettings>('settings');
await Hive.openBox<ChallengeProgress>('challenge');
```

### 7.2 İlk Çalıştırma — Seed Data
Uygulama ilk açıldığında varsayılan egzersiz ve antrenman verilerini yükle:
```dart
class DatabaseService {
  Future<void> seedInitialData() async {
    final exerciseBox = Hive.box<Exercise>('exercises');
    if (exerciseBox.isEmpty) {
      // Tüm egzersizleri ekle
      // Tüm antrenman programlarını oluştur
      // Varsayılan ayarları kaydet
      // Boş challenge progress oluştur
    }
  }
}
```

---

## 8. GÜVENLİK ÖNERİLERİ

### 8.1 Uygulama Güvenliği
- **ProGuard/R8** (Android): Kod obfuscation aktif
- **App Transport Security** (iOS): Yalnızca HTTPS bağlantıları
- **Jailbreak/Root Detection**: Opsiyonel ama önerilen
- **Screenshot Prevention**: Egzersiz videolarını korumak için opsiyonel

### 8.2 Veri Güvenliği
- Hive veritabanı şifreleme: `Hive.openBox('name', encryptionCipher: HiveAesCipher(key))`
- Video/görsel dosyaları assets içinde paketli (APK/IPA içinde)
- Kullanıcı verisi sadece cihazda kalır (sunucu yok)

### 8.3 İzinler
```xml
<!-- Android: android/app/src/main/AndroidManifest.xml -->
<!-- Ekstra izin gerekmez — tamamen offline çalışır -->
<!-- Opsiyonel: bildirimler için -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<!-- Ekran açık tutma -->
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

---

## 9. ÇOK DİLLİ DESTEK (i18n)

### 9.1 Türkçe Çeviri Dosyası (tr.json)
```json
{
  "app_name": "AC CORE",
  "workouts": "Antrenmanlar",
  "exercises": "Egzersizler",
  "instructions": "Kılavuzlar",
  "challenge": "Challenge",
  "notifications": "Bildirimler",
  "more": "Daha Fazla",
  "settings": "Ayarlar",
  "training_options": "Antrenman Seçenekleri",
  "exercise_duration": "Egzersiz Süresi",
  "rest_duration": "Dinlenme Süresi",
  "sets": "Set Sayısı",
  "seconds": "SN",
  "audio_options": "Ses Seçenekleri",
  "exercise_explanation": "Egzersiz Açıklaması",
  "countdown_sound": "Geri Sayım Sesi",
  "reset": "Sıfırla",
  "start": "Başla",
  "rest": "Dinlen",
  "pause": "Duraklat",
  "resume": "Devam",
  "completed": "Tamamlandı",
  "easy_workout": "Kolay Antrenman",
  "medium_workout": "Orta Antrenman",
  "hard_workout": "Zor Antrenman",
  "extreme_workout": "Ekstra Zor Antrenman",
  "custom_workout": "Bireysel Antrenman",
  "minutes_routine": "{min} Dakika Rutin",
  "points": "{pts} Puan",
  "earn_points": "{pts} Puan Kazan",
  "exercise_order": "Egzersiz Sırası",
  "shuffle": "Karıştır",
  "of": "/",
  "week": "Hafta",
  "start_date": "Başlangıç Tarihi",
  "five": "Beş",
  "four": "Dört",
  "three": "Üç",
  "two": "İki",
  "one": "Bir",
  "all": "Tümü",
  "easy": "Kolay",
  "medium": "Orta",
  "hard": "Zor",
  "language": "Dil",
  "sound_effects": "Ses Efektleri",
  "reminders": "Hatırlatıcılar",
  "disclaimer": "Sorumluluk Reddi",
  "trophies": "Kupalar",
  "total_points": "Toplam Puan",
  "minute_training": "{min} Dakika Antrenman"
}
```

### 9.2 İngilizce Çeviri Dosyası (en.json)
```json
{
  "app_name": "AC CORE",
  "workouts": "Workouts",
  "exercises": "Exercises",
  "instructions": "Instructions",
  "challenge": "Challenge",
  "notifications": "Notifications",
  "more": "More",
  "settings": "Settings",
  "training_options": "Training Options",
  "exercise_duration": "Exercise Duration",
  "rest_duration": "Rest Duration",
  "sets": "Sets",
  "seconds": "S",
  "audio_options": "Audio Options",
  "exercise_explanation": "Exercise Explanation",
  "countdown_sound": "Countdown Sound",
  "reset": "Reset",
  "start": "Start",
  "rest": "Rest",
  "pause": "Pause",
  "resume": "Resume",
  "completed": "Completed",
  "easy_workout": "Easy Workout",
  "medium_workout": "Medium Workout",
  "hard_workout": "Hard Workout",
  "extreme_workout": "Extreme Workout",
  "custom_workout": "Custom Workout",
  "minutes_routine": "{min} Minute Routine",
  "points": "{pts} Points",
  "earn_points": "Earn {pts} Points",
  "exercise_order": "Exercise Order",
  "shuffle": "Shuffle",
  "of": "/",
  "week": "Week",
  "start_date": "Start Date",
  "five": "Five",
  "four": "Four",
  "three": "Three",
  "two": "Two",
  "one": "One",
  "all": "All",
  "easy": "Easy",
  "medium": "Medium",
  "hard": "Hard",
  "language": "Language",
  "sound_effects": "Sound Effects",
  "reminders": "Reminders",
  "disclaimer": "Disclaimer",
  "trophies": "Trophies",
  "total_points": "Total Points",
  "minute_training": "{min} Minute Training"
}
```

---

## 10. SES DOSYALARI HAZIRLIĞI

### 10.1 Ses Dosyası Gereksinimleri
Geri sayım seslendirmesi için 2 yöntem kullanılabilir:

**Yöntem A — Önceden Kaydedilmiş Ses Dosyaları (ÖNERİLEN):**
- Format: MP3 veya WAV
- Süre: Her ses dosyası 0.5-1 saniye
- Kalite: 44.1kHz, 128kbps yeterli
- Her dil için 8 dosya gerekli:
  - TR: bes.mp3, dort.mp3, uc.mp3, iki.mp3, bir.mp3, basla.mp3, dinlen.mp3, beep.mp3
  - EN: five.mp3, four.mp3, three.mp3, two.mp3, one.mp3, start.mp3, rest.mp3, beep.mp3

**Yöntem B — Text-to-Speech (TTS):**
- `flutter_tts` paketi ile cihazın TTS motorunu kullan
- Avantaj: ek ses dosyası gerekmez
- Dezavantaj: cihaza göre ses kalitesi değişir, gecikme olabilir

### 10.2 Ses Dosyası Oluşturma Araçları
- Google Cloud Text-to-Speech API
- Amazon Polly
- macOS `say` komutu
- Ücretsiz: ttsmp3.com, voicemaker.in

---

## 11. TASARIM REHBERİ — AC CORE (Stitch Tasarımı)

Uygulama adı: **AC CORE**
Tasarım dili: Dark cinematic fitness — koyu lacivert zemin, turuncu enerji vurgusu, glassmorphism kartlar, Material Design 3 token sistemi.

### 11.1 Material Design 3 Renk Token Sistemi

Stitch çıktısından alınan tam renk paleti. Flutter'da `ColorScheme` ile uygulanacak.

```dart
// lib/config/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // ─── CORE BRAND COLORS ───
  static const Color primary = Color(0xFFFFB59D);           // Ana birincil (açık turuncu)
  static const Color primaryContainer = Color(0xFFFF6B35);  // Butonlar, aktif badge, timer çizgisi
  static const Color onPrimary = Color(0xFF5D1900);         // Primary üstü metin
  static const Color onPrimaryContainer = Color(0xFF5F1900);// PrimaryContainer üstü metin
  static const Color onPrimaryFixed = Color(0xFF390C00);    // Sabit primary üstü (koyu metin)

  // ─── SECONDARY (Mavi tonları — dinlenme, bilgi) ───
  static const Color secondary = Color(0xFFA4C9FF);         // İkincil vurgu (mavi)
  static const Color secondaryContainer = Color(0xFF0073CE);// İkincil kart arka planı
  static const Color onSecondary = Color(0xFF00315D);
  static const Color onSecondaryContainer = Color(0xFFF7F8FF);

  // ─── TERTIARY (Yeşil tonları — başarı, tamamlama) ───
  static const Color tertiary = Color(0xFF78DC77);          // Yeşil vurgu
  static const Color tertiaryContainer = Color(0xFF4AAD4E); // Başarı kartı arka planı
  static const Color onTertiary = Color(0xFF00390A);
  static const Color onTertiaryContainer = Color(0xFF003A0B);

  // ─── SURFACE & BACKGROUND ───
  static const Color background = Color(0xFF0A141E);        // Ana arka plan (en koyu)
  static const Color surface = Color(0xFF0A141E);           // Surface = background
  static const Color surfaceDim = Color(0xFF0A141E);
  static const Color surfaceBright = Color(0xFF303A45);
  static const Color surfaceContainerLowest = Color(0xFF050F19); // En koyu container
  static const Color surfaceContainerLow = Color(0xFF121C27);    // Video alanı arka planı
  static const Color surfaceContainer = Color(0xFF17202B);       // Kart arka planı
  static const Color surfaceContainerHigh = Color(0xFF212B35);   // Yükseltilmiş kart
  static const Color surfaceContainerHighest = Color(0xFF2C3641);// Timer arka plan çizgisi
  static const Color surfaceVariant = Color(0xFF2C3641);         // Profil avatar arka planı

  // ─── TEXT & ICON COLORS ───
  static const Color onBackground = Color(0xFFD9E3F2);      // Ana metin (açık beyaz-mavi)
  static const Color onSurface = Color(0xFFD9E3F2);          // Surface üstü metin
  static const Color onSurfaceVariant = Color(0xFFE1BFB5);   // İkincil metin (sıcak gri)
  static const Color inverseSurface = Color(0xFFD9E3F2);
  static const Color inverseOnSurface = Color(0xFF27313C);
  static const Color inversePrimary = Color(0xFFAB3500);

  // ─── OUTLINE & BORDERS ───
  static const Color outline = Color(0xFFA98A80);            // Ana border
  static const Color outlineVariant = Color(0xFF594139);     // Hafif border (buton çerçeve)

  // ─── ERROR ───
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // ─── CUSTOM BRAND TOKENS (Stitch dışı, özel) ───
  static const Color timerGlow = Color(0x99FF6B35);          // Timer drop-shadow glow
  static const Color navBarBg = Color(0x992C3641);           // Alt nav blur arka planı (%60)
  static const Color navBarActive = Color(0xFFFF6B35);       // Aktif tab rengi
  static const Color navBarInactive = Color(0xFF6B7280);     // Pasif tab (gray-500)
  static const Color navBarHover = Color(0xFFFFB59D);        // Hover tab

  // ─── YILDIZ (ZORLUK SEVİYESİ) RENKLERİ ───
  static const Color starEasy = Color(0xFF3B82F6);           // Mavi yıldız
  static const Color starMedium = Color(0xFFEF4444);         // Kırmızı yıldız
  static const Color starHard = Color(0xFFF59E0B);           // Amber yıldız
  static const Color starExtreme = Color(0xFFFACC15);        // Sarı yıldız
  static const Color starCustom = Color(0xFF9CA3AF);         // Gri yıldız

  // ─── THEME DATA ───
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.dark(
      primary: primary,
      primaryContainer: primaryContainer,
      onPrimary: onPrimary,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      secondaryContainer: secondaryContainer,
      onSecondary: onSecondary,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiary: onTertiary,
      onTertiaryContainer: onTertiaryContainer,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      error: error,
      errorContainer: errorContainer,
      onError: onError,
      onErrorContainer: onErrorContainer,
      outline: outline,
      outlineVariant: outlineVariant,
      inverseSurface: inverseSurface,
      inverseOnSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    ),
    scaffoldBackgroundColor: background,
  );
}
```

### 11.2 Tipografi Sistemi

Font: **Inter** (Google Fonts) — tüm ağırlıklar: 400 (Regular), 600 (SemiBold), 700 (Bold), 800 (ExtraBold), 900 (Black).

```dart
// lib/config/app_text_styles.dart

class AppTextStyles {
  // ─── APP BAR / HEADER ───
  static const TextStyle appTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w900,    // Black
    fontStyle: FontStyle.italic,
    letterSpacing: -0.5,            // tracking-tighter
    color: Color(0xFFFF6B35),       // Turuncu marka rengi
  );

  // ─── HEADLINES ───
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 72,                   // Timer büyük sayı (7xl)
    fontWeight: FontWeight.w900,
    letterSpacing: -2.0,            // tracking-tighter
    color: Colors.white,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 30,                   // Dinlenme sayısı (3xl)
    fontWeight: FontWeight.w900,
    color: Color(0xFFA4C9FF),       // secondary mavi
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,                   // Bölüm başlığı (xl)
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: Colors.white,
  );

  // ─── BODY & LABELS ───
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,                   // Egzersiz bandı adı (lg)
    fontWeight: FontWeight.w700,
    color: Color(0xFF390C00),       // on-primary-fixed (koyu)
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,                   // Kart alt metin (sm)
    fontWeight: FontWeight.w900,
    color: Color(0xFF390C00),
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,                   // Timer "Seconds" etiketi
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,             // tracking-[0.2em]
    color: Color(0xFFE1BFB5),       // on-surface-variant
  );

  static const TextStyle navLabel = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,                   // Alt navigasyon etiketleri
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,             // tracking-widest
  );
}
```

### 11.3 Stitch Komponent Detayları

Stitch çıktısından birebir alınan komponent spesifikasyonları:

#### 11.3.1 Üst Header Bar
```
Konum: fixed top, z-50
Yükseklik: 64px (h-16)
Arka plan: #0A141E / %80 opacity + backdrop-blur-xl
Gölge: 0 8px 32px rgba(0,0,0,0.3)
Padding: horizontal 24px (px-6)
Sol: ← geri ikonu (turuncu #FF6B35) + "AC CORE" başlığı
  - Başlık: 20px, black (w900), italic, letter-spacing -0.5px, turuncu
Sağ: bolt ikonu (turuncu) + profil avatar (32×32, rounded-full)
İkon tıklama: active:scale-95, transition 200ms
```

#### 11.3.2 Video Alanı
```
Genişlik: tam (w-full)
En-boy oranı: 16:9 (aspect-video)
Border-radius: 24px (rounded-[24px])
Arka plan: surfaceContainerLow (#121C27)
Görsel efekt: grayscale(%20), hover'da scale(1.05), transition 700ms
Gradient overlay: alttan yukarı — black/%60 → transparent
Play butonu (merkez):
  - Boyut: 64×64 (w-16 h-16)
  - Arka plan: white/%10 + backdrop-blur-md
  - Border: 1px white/%20
  - İkon: play_arrow, FILLED, 36px, beyaz
```

#### 11.3.3 Turuncu Egzersiz Bandı
```
Genişlik: tam
Arka plan: #FF6B35 düz
Padding: vertical 16px, horizontal 24px (py-4 px-6)
Border-radius: 12px (rounded-xl)
Gölge: 0 4px 20px rgba(255,107,53,0.3) — turuncu glow
Sol metin: egzersiz adı — UPPERCASE, font-headline, bold, 18px (text-lg)
  - Renk: #390C00 (on-primary-fixed — koyu kahve)
Sağ badge: "1 of 5"
  - Arka plan: #390C00/%20 (on-primary-fixed/%20)
  - Padding: 4px 12px (px-3 py-1)
  - Border-radius: full (pill)
  - Font: 14px, black (w900)
  - Renk: #390C00
```

#### 11.3.4 Dairesel Timer (ANA KOMPONENT)
```
SVG boyutu: 256×256 (w-64 h-64), md breakpoint'te 320×320 (md:w-80 md:h-80)

Arka plan halka:
  - Element: <circle>, r=110, cx/cy=128
  - Stroke: surfaceContainerHighest (#2C3641)
  - Stroke-width: 8px
  - Fill: transparent

Aktif ilerleme halkası:
  - Element: <circle>, r=110, cx/cy=128
  - Stroke: #FF6B35 (primaryContainer)
  - Stroke-width: 12px (arka plandan kalın)
  - Stroke-dasharray: 691 (2πr = 2×3.14159×110 ≈ 691)
  - Stroke-dashoffset: hesaplanır → 691 - (691 × yüzde / 100)
  - Stroke-linecap: round
  - Filter: drop-shadow(0 0 8px rgba(255,107,53,0.6)) — turuncu glow
  - Transform: rotate(-90deg), transform-origin: 50% 50%
  - Transition: stroke-dashoffset 0.35s

Merkez sayı:
  - Font: 72px (text-7xl), md'de 96px (md:text-8xl)
  - Weight: w900 (font-black)
  - Renk: beyaz (#FFFFFF)
  - Letter-spacing: -2px (tracking-tighter)

Alt etiket ("Seconds"):
  - Font: 12px, bold (w700)
  - UPPERCASE
  - Letter-spacing: 0.2em (tracking-[0.2em])
  - Renk: onSurfaceVariant (#E1BFB5)
  - Margin-top: -8px (-mt-2)

Kontrol butonları (timer altında, mt-32px):
  - Yan butonlar (replay_10, forward_10):
    - Boyut: 48×48 (w-12 h-12)
    - Border: 1px outlineVariant/%30
    - Rounded-full
    - İkon rengi: onSurfaceVariant
    - Active: scale(0.9)
  - Merkez buton (pause/play):
    - Boyut: 80×80 (w-20 h-20)
    - Arka plan: primaryContainer (#FF6B35)
    - Gölge: 0 0 32px rgba(255,107,53,0.4)
    - İkon: pause (FILLED), 36px, #390C00
    - Active: scale(0.95)
  - Butonlar arası gap: 32px (gap-8)
```

#### 11.3.5 Dinlenme Kartı (Upcoming Rest)
```
Border-radius: 32px (rounded-[32px])
Padding: 24px (p-6)
Arka plan: gradient → from secondaryContainer/%20 to secondary/%5
  + backdrop-blur-xl
  + border: 1px secondary/%10
Sol accent çizgi:
  - Konum: absolute, top-0 left-0
  - Genişlik: 4px (w-1), yükseklik: tam
  - Renk: secondary (#A4C9FF)
Üst etiket:
  - "UPCOMING REST" — 12px, black (w900), UPPERCASE
  - Letter-spacing: 0.1em (tracking-widest)
  - Renk: secondary (#A4C9FF)
Başlık:
  - "Active Recovery" — 20px (text-xl), bold, beyaz
  - Letter-spacing: -0.5px (tracking-tight)
Sağ sayı:
  - "60" — 30px (text-3xl), black (w900), secondary renk
  - "sec" — 14px (text-sm), bold, secondary/%80
İlerleme barı:
  - Yükseklik: 6px (h-1.5), tam genişlik
  - Arka plan: secondary/%10, rounded-full
  - Dolgu: secondary (#A4C9FF), rounded-full
```

#### 11.3.6 Alt Navigasyon Barı
```
Konum: fixed bottom, z-50
Yükseklik: 80px (h-20)
Border-radius: üst 24px (rounded-t-[24px])
Arka plan: #2C3641 / %60 opacity + backdrop-blur-2xl
Gölge: 0 -4px 24px rgba(255,107,53,0.08) — hafif turuncu glow yukarı
Padding: horizontal 16px, alt safe-area (pb-safe)
Düzen: flex, justify-around, items-center

Aktif tab:
  - Arka plan: white/%5 + gölge inset 0 0 8px rgba(255,107,53,0.2)
  - Border-radius: 12px (rounded-xl)
  - Padding: 4px 12px
  - İkon + label rengi: #FF6B35

Pasif tab:
  - İkon + label rengi: gray-500 (#6B7280)
  - Hover: #FFB59D (primary açık turuncu)
  - Transition: colors

Tab etiketleri:
  - Font: Inter, 10px, semibold (w600)
  - UPPERCASE
  - Letter-spacing: 0.1em (tracking-widest)
  - Margin-top: 4px

Tab listesi (5 adet):
  1. fitness_center → "ANTRENMANLAR"
  2. play_circle → "EGZERSİZLER"
  3. trophy → "CHALLENGE"
  4. notifications → "BİLDİRİMLER"
  5. menu → "DAHA FAZLA"
```

#### 11.3.7 İkon Sistemi
```
Kaynak: Google Material Symbols Outlined
CDN: https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined
Flutter paketi: material_symbols_icons (veya built-in Icons sınıfı)

Font variation settings:
  - FILL: 0 (outline), tıklanan/aktif durumda 1 (filled)
  - wght: 400 (varsayılan)
  - GRAD: 0
  - opsz: 24

Kullanılan ikonlar:
  - arrow_back: geri navigasyon
  - bolt: hızlı aksiyon / enerji
  - play_arrow (FILL:1): video oynat
  - pause (FILL:1): duraklat
  - replay_10: 10 saniye geri
  - forward_10: 10 saniye ileri
  - fitness_center: antrenmanlar sekmesi
  - play_circle: egzersizler sekmesi
  - trophy: challenge sekmesi
  - notifications: bildirimler sekmesi
  - menu: daha fazla sekmesi
  - shuffle: karıştır
  - settings: ayarlar
  - volume_up / volume_off: ses toggle
```

### 11.4 Layout & Spacing Kuralları

```
─── SAYFA YAPISI ───
Max genişlik: 448px (max-w-lg), ortalanmış
Üst padding: 80px (pt-20) — header altı
Alt padding: 112px (pb-28) — navbar üstü
Yatay padding: 16px (px-4)
Bölümler arası gap: 24px (gap-6)
Min yükseklik: 100vh (min-h-screen)

─── BORDER RADIUS SİSTEMİ ───
Küçük (buton, badge, pill): 4px / 8px / full (9999px)
Orta (kart, input, dropdown): 12px (rounded-xl)
Büyük (video, ana kart): 24px (rounded-[24px])
Ekstra büyük (dinlenme kartı, navbar): 32px (rounded-[32px])

─── GLASSMORPHISM FORMÜLÜ ───
Arka plan: rgba(baz_renk, 0.05-0.20)
Border: 1px solid rgba(255,255,255, 0.10-0.20)
Blur: backdrop-blur-md (12px) veya backdrop-blur-xl (24px) veya backdrop-blur-2xl (40px)
Gölge: iç glow için inset shadow kullanılabilir

─── GÖLGE SİSTEMİ ───
Header: 0 8px 32px rgba(0,0,0,0.3)
Timer buton: 0 0 32px rgba(255,107,53,0.4)
Turuncu bant: 0 4px 20px rgba(255,107,53,0.3)
Navbar: 0 -4px 24px rgba(255,107,53,0.08)
Timer çizgi: drop-shadow(0 0 8px rgba(255,107,53,0.6))
```

### 11.5 Animasyon & Geçiş Kuralları

```dart
// Stitch'ten alınan animasyon değerleri

// Timer ilerleme çizgisi
Duration: 350ms
Curve: Curves.easeInOut  // CSS: transition 0.35s

// Video hover scale
Duration: 700ms
Curve: Curves.easeOut
Scale: 1.0 → 1.05

// Buton tıklama (active state)
Duration: 200ms
Scale: 0.95 (ana buton), 0.90 (yan butonlar)

// Tab hover renk geçişi
Duration: 150ms (transition-colors)

// Sayfa geçişleri
Slide + Fade kombinasyonu
Duration: 300ms
Curve: Curves.easeInOutCubic
```

### 11.6 Flutter Widget Mapping (Stitch → Flutter)

```
Stitch HTML Element              →  Flutter Widget
─────────────────────────────────────────────────────
backdrop-blur + rgba bg          →  ClipRRect + BackdropFilter + Container
aspect-video                     →  AspectRatio(aspectRatio: 16/9)
rounded-[24px]                   →  BorderRadius.circular(24)
bg-gradient-to-t from-black/60   →  Container(decoration: BoxDecoration(gradient: LinearGradient))
SVG circle timer                 →  CustomPaint (CircularTimerPainter)
flex justify-around              →  Row(mainAxisAlignment: MainAxisAlignment.spaceAround)
fixed bottom z-50                →  Scaffold bottomNavigationBar veya Positioned
tracking-tighter                 →  TextStyle(letterSpacing: -0.5)
tracking-widest                  →  TextStyle(letterSpacing: 1.6)
font-black                       →  FontWeight.w900
active:scale-95                  →  GestureDetector + AnimatedScale
drop-shadow filter               →  BoxShadow veya CustomPaint ile filter
Material Symbols icon            →  Icon(Icons.xxx) veya material_symbols_icons paketi
```

---

## 12. CLAUDE CODE İÇİN ADIM ADIM GELİŞTİRME PROMPTU

Bu bölüm, Claude Code'da projeyi oluştururken kullanılacak prompt dizisini içerir.

### Aşama 1: Proje Kurulumu
```
Flutter projesi oluştur:
1. flutter create --org com.fitnessapp fitness_workout_app
2. pubspec.yaml'a tüm bağımlılıkları ekle (Bölüm 2.2'deki paketler)
3. Proje yapısını oluştur (Bölüm 3'teki klasör/dosya yapısı)
4. Hive veritabanını başlat ve adapter'ları kaydet
5. Çoklu dil desteğini yapılandır (easy_localization)
6. Asset klasörlerini oluştur ve pubspec.yaml'da tanımla
7. Android minimum SDK 24, iOS minimum 14.0 ayarla
```

### Aşama 2: Veri Katmanı
```
1. Tüm Hive model sınıflarını oluştur (Bölüm 4)
2. build_runner ile adapter'ları generate et
3. DatabaseService sınıfını oluştur
4. Seed data fonksiyonunu yaz (varsayılan egzersizler ve antrenmanlar)
5. WorkoutSettings defaults factory'sini implemente et
```

### Aşama 3: Servis Katmanı
```
1. AudioService: ses dosyası yükleme, oynatma, dil bazlı seçim
2. TimerService: geri sayım mantığı, state yönetimi
   - States: idle → countdown → exercising → resting → completed
   - Son 5 saniye tetikleme mekanizması
   - Pause/Resume desteği
3. NotificationService: opsiyonel hatırlatıcılar
```

### Aşama 4: State Management (Provider)
```
1. SettingsProvider: ayarları oku/yaz, dil değişikliği
2. WorkoutProvider: antrenman listesi, aktif antrenman
3. TimerProvider: zamanlayıcı state, ChangeNotifier
4. ChallengeProvider: puan hesaplama, haftalık güncelleme
5. LanguageProvider: dil değişikliği yönetimi
```

### Aşama 5: UI Ekranları
```
Öncelik sırasıyla:
1. BottomNavBar + AppShell (temel navigasyon)
2. HomeScreen (antrenman kartları listesi)
3. ExerciseGridScreen (egzersiz sıralama grid'i)
4. WorkoutPlayerScreen (timer + video — EN KRİTİK)
5. SettingsScreen (ayarlar)
6. InstructionsScreen (kılavuzlar)
7. ChallengeScreen (ilerleme grafiği)
8. SideMenuScreen (yan menü)
```

### Aşama 6: Egzersiz Oynatıcı (Detaylı)
```
WorkoutPlayerScreen implementasyonu:
1. Video oynatıcı (chewie) — loop modda
2. Egzersiz adı bandı (kırmızı, sola hizalı isim, sağda X/Y)
3. Dairesel countdown timer
   - Tam daire: beyaz çizgi, geri sayımla doluluk azalır
   - Ortada: büyük sayı (kalan saniye)
   - Altında: duraklat/devam ikonu
4. Timer iş akışı:
   a. Ekran açılır → dinlenme geri sayımı başlar
   b. Son 5 saniye → sesli: 5,4,3,2,1
   c. 0 olunca → "BAŞLA!" sesi + egzersiz timer başlar
   d. Video oynar, timer sayar
   e. Son 5 saniye → sesli: 5,4,3,2,1
   f. 0 olunca → "DİNLEN!" sesi + sonraki egzersize geç
   g. Son egzersiz bittiyse → set tamamlandı
   h. Set sayısı dolmadıysa → yeni set başla
   i. Tüm setler bitti → tamamlama ekranı + puan kaydet
5. Duraklat: timer durur, video durur
6. Wakelock: ekran kapanmasın
```

### Aşama 7: Challenge Sistemi
```
1. 8 haftalık bar grafiği (fl_chart)
2. Her antrenman tamamlandığında:
   - Antrenman puanını al
   - Mevcut haftayı hesapla (startDate'ten bugüne)
   - İlgili haftanın puanına ekle
3. Hafta 100 puana ulaşınca kalp ikonu dolu göster
4. Sıfırla butonu: tüm ilerlemeyi temizle, startDate güncelle
```

### Aşama 8: Test & Polish
```
1. Her ekranı Android emülatör ve iOS simülatörde test et
2. Video oynatma performansını kontrol et
3. Ses senkronizasyonunu doğrula
4. Timer doğruluğunu test et (1 saniyelik drift kontrolü)
5. Hive veri kalıcılığını test et (uygulama kapatıp aç)
6. Dil değişikliğinin tüm ekranlarda uygulandığını doğrula
7. Ekran döndürme desteği (portrait only önerilen)
8. Uygulama ikonu ve splash screen ekle
```

---

## 13. NOTLAR VE KISITLAMALAR

### 13.1 Bilinen Kısıtlamalar
- Video dosyaları APK/IPA boyutunu artırır — sıkıştırma önemli
- iOS'ta arka plan ses çalma ek yapılandırma gerektirir
- Hive büyük veri setleri için uygun değildir (bu proje için yeterli)

### 13.2 Performans İpuçları
- Videoları H.264 codec, 720p çözünürlükte sıkıştır
- Görselleri WebP formatına dönüştürmeyi düşün (Flutter destekler)
- Timer için `Timer.periodic` yerine `Ticker` kullan (daha doğru)
- Video preloading: sonraki egzersizin videosunu önceden yükle

### 13.3 Gelecek Geliştirmeler (V2)
- Kalori takibi
- Antrenman geçmişi
- Özel antrenman oluşturma
- Google Fit / Apple Health entegrasyonu
- Sosyal paylaşım
- Premium içerik (in-app purchase)

---

## 14. REFERANS GÖRSELLER

Proje klasöründeki referans dosyaları:

| Dosya | Açıklama |
|-------|----------|
| `example_app_workouts.jpg` | Ana ekran — Antrenman kartları listesi |
| `example_app_exercise_routine.jpg` | Egzersiz sıralama grid'i |
| `example_app_WORKOUT_START_POZITION.jpg` | Egzersiz oynatıcı — timer 12 |
| `example_app_WORKOUT_POZITION.jpg` | Egzersiz oynatıcı — timer 28 |
| `example_app_WORKOUT_SETTINGS.jpg` | Ayarlar ekranı |
| `example_app_user_manuals.jpg` | Kılavuzlar listesi |
| `example_app_WORKOUT_CHALLANGE.jpg` | Challenge bar grafiği |
| `example_app_SIDE_MENU.jpg` | Yan menü + Daha Fazla |
| `example_app_WORKOUT_FEATURES.jpg` | Egzersiz özellikleri |
| `KAPAK_PHOTO.png` | Kapak fotoğrafı |
| `LATERALBICEPSTRICEPSPLANK.png` | Kategori 1 egzersiz görseli |
| `BACK_FLYPEC_FLYLEG_RAISE.png` | Kategori 2 egzersiz görseli |
| `DB_ROWSHOULDER_PRESSRUSSIAN_TWIST.png` | Kategori 3 egzersiz görseli |
| `BARFIKSSINAVCRUNCH.png` | Kategori 4 egzersiz görseli |
