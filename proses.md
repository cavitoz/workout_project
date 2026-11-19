# Test Sonuçları ve Yapılanlar — 2026-04-12 (3. Tur)

## Test 1 — Egzersizler Sıralı Atlamıyor ✅ ÇÖZÜLDÜ

**Sorun:** Her egzersiz geçişinde hep LATERAL KALDIRMA'ya dönüyordu.

**Kök Neden:** `_hasLoadedForCurrentPhase` bayrağı `true` olarak kalıyordu — hiç `false`'a sıfırlanmıyordu. Bu yüzden ilk rest'ten sonra hiçbir video yükleme tetiklenemiyordu; `_videoController` hep ilk egzersizde kalıyordu.

**Yapılan:** `_onTimerStateChanged()` içinde egzersiz başlayınca `_hasLoadedForCurrentPhase = false` yapıldı. Böylece her egzersizin ardından gelen rest, bir sonraki egzersizin videosunu yükleyebiliyor.

---

## Test 2 — İlk Dinlenmede Video Görünmüyor + Ses Senkronu ✅ ÇÖZÜLDÜ

**Sorun:** Başlangıç dinlenme ekranında "Hazırlanıyor..." yazıyordu. Video ve ses senkronize gitmiyordu.

**Video Fix:** `_loadNextVideo()` tamamlanınca video artık hem dinlenme hem egzersiz sırasında hemen aktif ediliyor. Dinlenme sırasında dark overlay altında oynar; egzersiz başlayınca overlay kalkar, video zaten hazır.

**Ses Fix:** Android'de ses başlatma ~500ms gecikiyor. `_remainingSeconds == 4` tetiklemesi yerine `== 5` yapıldı. Ses bir tick erken başlıyor, ekrandaki 4-3-2-1 geri sayımıyla senkronize bitiyor.

---

## Build — 2026-04-12 (3. Tur)

```
flutter build apk --release --target-platform android-arm64 → ✅ 135.1MB
```

**Değiştirilen dosyalar:**
- `lib/screens/workout/workout_player_screen.dart`
- `lib/services/timer_service.dart`

---

# Test Sonuçları ve Yapılanlar — 2026-04-12 (2. Tur)

## Test 1 — Video Donma ✅ ÇÖZÜLDÜ (Yeniden yazıldı)

**Sorun:** "Video Yükleniyor..." ekranı takılı kalıyordu — önceki preload yaklaşımı yanlıştı.

**Kök Neden:** Önceki kodda video yükleme hem build callback'i hem listener üzerinden tetikleniyordu. Race condition oluşuyor, `_isVideoLoading` bayrağı kilitleniyor, video hiç yüklenemiyordu.

**Yapılan:** `workout_player_screen.dart` tamamen yeniden yazıldı:
- Build tabanlı video yükleme **kaldırıldı**
- Tüm video yönetimi `_onTimerStateChanged()` listener'a taşındı
- **Akış:** Rest başlar → `currentExercise.videoPath` için `_loadNextVideo()` başlatılır (arka plan) → Egzersiz başlar → `_activateNextVideo()` ile anında geçiş
- Race condition durumu için: video henüz yüklenmediyse `_loadNextVideo` tamamlanınca otomatik aktif eder
- Listener ÖNCE ekleniyor, antrenman SONRA başlatılıyor (ilk state değişimi yakalanıyor)

---

## Test 2 — Ses Dosyaları ✅ ÇÖZÜLDÜ (Tamamlandı)

**Sorun:** Beep, "Dinlen", "Başla" sesleri hâlâ çalıyordu.

**Kök Neden:** `timer_service.dart` içinde `playBeep()`, `playRest()`, `playStart()` çağrıları kaldırılmamıştı.

**Yapılan:**
- `audio_service.dart`: `playBeep`, `playStart`, `playRest` metodları tamamen kaldırıldı. Sadece `playExerciseCountdown()` kaldı.
- `timer_service.dart`: Tüm ses çağrıları kaldırıldı. Yalnızca: rest/setResting durumunda `remainingSeconds == 4` olduğunda `playExerciseCountdown()` tetikleniyor.

---

## Test 3 — H Bar Grafiği ✅ Önceden Çözüldü

Değişiklik yapılmadı.

---

## Test 4a — Barfiks & Şınav Aynı Görsel ✅ VİDEO KISMI ÇÖZÜLDÜ

**Sorun:** push-up.mp4 aslında pull-up.mp4'ün kopyasıydı (1498701 byte, aynı dosya).

**Yapılan:**
- `VIDEOS/PUSH-UP.mp4` (1116010 byte — doğru dosya) → `assets/videos/exercises/push-up.mp4` olarak kopyalandı.
- Şınav videosu artık doğru hareketi gösteriyor.

**⚠️ Eksik:** `PHOTOS/PUSH-UP.png` kaynak klasöründe yok. push-up.png görseli hâlâ pull-up.png'nin kopyası. Düzeltmek için `PHOTOS` klasörüne **PUSH-UP.png** dosyası eklemen gerekiyor.

---

## Test 4b — Barfiks Video Bozuk (Codec Sorunu) ✅ FALLBACK EKLENDI

**Sorun:** Barfiks (pull-up) videosu kılavuzda diagonal çizgilerle bozuk görünüyordu — codec uyumsuzluğu.

**Yapılan:** `instructions_screen.dart`'taki `_ExerciseVideoDialog` güncellendi:
- Video initialize başarısız olursa controller dispose ediliyor
- Hata durumunda egzersizin görsel (imagePath) gösteriliyor
- Video yüklenirken CircularProgressIndicator, başarısızsa görsel, başarılıysa video

---

## Test 5 — Set Arası Dinlenme Ayarlanabilir ✅ ÇÖZÜLDÜ

**Sorun:** Set dinlenmesi sabit 60 saniyeydi, ayarlardan değiştirilemiyordu.

**Yapılan:**
- `WorkoutSettings` modeline `setBreakDuration` alanı eklendi (HiveField 6)
- `workout_settings.g.dart` manuel güncellendi (yeni alan, geriye dönük uyumlu default=60)
- `SettingsProvider`: `setBreakDuration` getter + `setSetBreakDuration()` metodu eklendi
- `settings_screen.dart`: "Set Arası Dinlenme" dropdown eklendi (30/60/90/120 sn)
- `app_constants.dart`: `defaultSetRestDuration = 60`, `setRestDurationOptions = [30, 60, 90, 120]` eklendi
- `timer_service.dart`: `_startSetResting()` artık `_settings.setBreakDuration` kullanıyor

---

## Test 6 — Barfiks Video Netliği

Codec sorunundan kaynaklı — kılavuzda fallback (görsel) gösterilecek. Egzersiz sırasındaki oynatmada `BoxFit.cover` aktif.

---

## Build Durumu

```
flutter build apk --release --target-platform android-arm64 → ✅ 135MB
```

**Değiştirilen dosyalar:**
- `lib/services/audio_service.dart`
- `lib/services/timer_service.dart`
- `lib/providers/settings_provider.dart`
- `lib/providers/timer_provider.dart`
- `lib/screens/workout/workout_player_screen.dart`
- `lib/screens/instructions/instructions_screen.dart`
- `lib/screens/settings/settings_screen.dart`
- `lib/models/workout_settings.dart`
- `lib/models/workout_settings.g.dart`
- `lib/config/app_constants.dart`
- `assets/videos/exercises/push-up.mp4` (doğru dosya ile değiştirildi)

**⚠️ Kullanıcı aksiyonu gerekli:**
- `PHOTOS/PUSH-UP.png` dosyasını ekle → push-up ve pull-up görselleri ayrışacak

---

## Referans Uygulama Analizi (REA) — Oynatıcı Kararlılığı (2026-11-19)

Referans: Adrian James Bootcamp (`com.adrianjamesnutrition.bootcamp`, native Android/Java). APK telefondan çekildi, JADX ile `WorkoutExerciseActivity` + `hourglass` (sayaç) incelendi. Kod/görsel kopyalanmadı; yalnızca davranış örnek alındı.

**Referansın çalışma mantığı (özet):**
- Her faz için ayrı sayaç: hazırlık/dinlenme (varsayılan 15 sn) → 1 sn ara → egzersiz (varsayılan 30 sn) → 1 sn ara → sonraki egzersizin hazırlığı.
- Sonraki egzersizin videosu hazırlık fazı başında yüklenir, dinlenme boyunca döngüde oynar.
- Sesler saniye değerine bağlı tetiklenir (egzersizde 10'da "son 10", 5'te "5-4-3-2-1 dinlen").
- Duraklatmada sayaç + video + ses **duraklatılır** (durdurulmaz), devamda kaldığı yerden sürer.
- Uygulama arka plana geçince (`onPause`) otomatik duraklatır; otomatik devam yok.
- Geri tuşu: önce duraklatır, sonra çıkış onayı sorar.

**Bizde eksik olan / kararsızlık yaratanlar ve yapılan düzeltmeler:**
| Sorun | Düzeltme |
|---|---|
| Duraklatmada geri sayım sesi tamamen durduruluyordu → devamda ses kayboluyor, sayaçla senkron bozuluyordu | `AudioService.pauseAll()/resumeAll()` eklendi; `TimerService.pause/resume` artık sesi duraklatıp sürdürüyor |
| Uygulama arka plana geçince sayaç çalışmaya devam ediyor, video duruyordu | Oynatıcıya `WidgetsBindingObserver` eklendi; arka planda otomatik duraklatma |
| Sistem geri tuşuyla çıkınca global `TimerProvider` sayacı ve sesi arka planda çalmaya devam ediyordu | `PopScope` + çıkış onay diyaloğu; `dispose`'da sayaç sıfırlanıyor |
| Tamamlanınca `addPoints` her build'de tekrar çağrılabiliyordu (puan katlanması) | `_completionHandled` bayrağı ile tek seferlik |
| Duraklatılmışken "atla" hiçbir şey yapmıyordu; dinlenmede atlanınca geri sayım sesi yeni faza taşıyordu | `skip()` duraklatılmış fazdan devam ederek atlıyor ve çalan sesi durduruyor |
| `reset()` sesi kesmiyordu | `reset()` içinde `stopAll()` |

**Değiştirilen dosyalar:** `lib/services/audio_service.dart`, `lib/services/timer_service.dart`, `lib/screens/workout/workout_player_screen.dart`

`flutter analyze` → yeni sorun yok.

### Sesli Yönlendirme — flutter_tts (2026-11-19)

Referans APK'daki ses kayıtları telif/marka nedeniyle **kullanılmadı**. Bunun yerine cihazın TTS motoru (`flutter_tts 4.2.5`) ile dosyasız, TR/EN sesli yönlendirme eklendi.

| An | TR | EN |
|---|---|---|
| Dinlenme başı | "Egzersiz 3. Şınav." | "Exercise 3. Push-up." |
| Set dinlenmesi başı | "Set 2. Şınav." | "Set 2. Push-up." |
| Egzersizde 10 sn kala (egzersiz > 15 sn ise) | "Son on saniye" | "Last ten seconds" |
| Antrenman sonu | "Antrenman tamamlandı. Harika iş çıkardın!" | "Workout complete. Great job!" |

- "5-4-3-2-1" mp3 geri sayımı değişmedi (senkron ayarı korundu).
- Ayarlardaki **ses kapalı** → hepsi susar; **sesli geri sayım kapalı** → TTS anonsları da susar.
- Cihazda seçili dilin TTS paketi yoksa anonslar sessizce atlanır, uygulama etkilenmez.
- Duraklatmada TTS kesilir (Android'de TTS kaldığı yerden sürdürülemez); mp3 geri sayım ise duraklatılıp sürdürülür.

**Değiştirilen dosyalar:** `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml` (TTS_SERVICE queries), `lib/services/audio_service.dart`, `lib/services/timer_service.dart`, `lib/providers/timer_provider.dart`

### Ayarlar ve Challenge — Referansa Uyum (2026-11-19)

**Referans ayarları (SettingActivity):** Egzersiz süresi 30 sn (30/40/50/60), Aralık süresi 15 sn (15/20/25/30), "Exercise Description" açık, "Exercise Countdown" açık. **Set ayarı yok** — her antrenman tek tur. Reset → 30/15 + iki anahtar açık.

**Referans challenge (ChallengeFragment):** 8 hafta × 7 gün. Başlangıç = ilk tamamlanan antrenmanın tarihi. Haftalık hedef 100 puan (≥100 → kalp dolar), puan 100'de kesilmez. Puanlar: Kolay 6, Orta 12, Zor 18, Elit 36, Özel = egzersiz puanları toplamı. 8. hafta hedefi tutunca challenge tamamlanır ve yeni challenge başlar.

| Konu | Önce | Şimdi |
|---|---|---|
| Varsayılan set | 3 | **1** (referans gibi tek tur; ayarlardan artırılabilir) |
| "Egzersiz Açıklaması" anahtarı | Tüm sesleri kapatıyordu | Sadece TTS egzersiz anonslarını kapatır |
| "Geri Sayım Sesi" anahtarı | Geri sayım + anonslar | 5-4-3-2-1 mp3 + "son on saniye" |
| Ayarları sıfırla | Dili de TR'ye çeviriyordu | Süreler/set/sesler varsayılana döner, dil korunur |
| Challenge başlangıcı | Uygulamanın ilk açıldığı an | İlk tamamlanan antrenman |
| Haftalık puan | 100'de kesiliyordu | Gerçek toplam tutulur (grafik 100'de sınırlı) |
| Kupa | **Hiç artmıyordu** (kontrol, puan yazıldıktan sonra yapılıyordu) | Hafta hedefine ilk ulaşıldığında +1 |
| 8 hafta sonrası | 8. haftaya sonsuza kadar puan ekleniyordu | 56 gün dolunca sonraki antrenman yeni challenge başlatır; toplam puan/kupa korunur |
| Challenge ekranı başlangıç | Kurulum tarihi | Başlamadıysa "İlk antrenmanla başlar" |

⚠️ Mevcut kurulumlarda kayıtlı set değeri (3) otomatik değişmez → Ayarlar'da **Varsayılana Sıfırla**.

**Değiştirilen dosyalar:** `lib/config/app_constants.dart`, `lib/providers/settings_provider.dart`, `lib/providers/timer_provider.dart`, `lib/services/timer_service.dart`, `lib/models/challenge_progress.dart`, `lib/providers/challenge_provider.dart`, `lib/screens/challenge/challenge_screen.dart`

### Geri Sayım Senkronu + Navigasyon (2026-11-19)

**Senkron sorununun kök nedeni:** `egzersizsayac_trimmed.mp3` 36 sn'lik tek parça kayıt (dinlenme 5-4-3-2-1 + egzersiz boyunca bip + son 5-4-3-2-1). İçindeki bip'ler 1,000 sn değil **~1,045 sn** arayla → 30 sn'de ses sayacın ~1 sn gerisine düşüyordu; 40/50/60 sn egzersizde hiç uymuyordu. Ayrıca `Timer.periodic(1 sn)` gecikmeleri birikiyordu.

**Çözüm (referans uygulamadaki gibi tick'e bağlı sesler):**
- Kayıt ffmpeg ile saniye kliplerine bölündü → `assets/audio/countdown/` (prep, beep, ten, n5…n1, end — WAV).
- Dinlenme 5 sn kala `prep`; egzersizde her saniye `beep`, 10'da `ten`, 5…1'de sesli sayı, 0'da `end`.
- Klipler antrenman başında önceden yüklenir, düşük gecikmeli (SoundPool) çalınır.
- Sayaç motoru Stopwatch tabanlı: gerçek geçen süreden tick üretir → kayma birikmez; duraklatmada saniyenin kesri korunur.
- TTS "Son on saniye" kaldırıldı (klipte zaten "10" sesi var, çift ses olmasın).

**Navigasyon (go → push):** Ekranlar `context.go()` ile açılıp `context.pop()` ile kapatılıyordu → yığın boş, geri tuşu uygulamayı kapatıyor / "nothing to pop" hatası.
| Geçiş | Şimdi |
|---|---|
| Ana sayfa → Egzersiz listesi | `push`; geri → ana sayfa |
| Egzersiz listesi → Oynatıcı | `push`; çıkış onayı → egzersiz listesine döner |
| Oynatıcı → Tamamlandı | `go` (oynatıcıya geri dönülemez) |
| Tamamlandı ekranında geri tuşu | Ana sayfa |
| Daha Fazla → Ayarlar | `push`; geri → Daha Fazla |
| Ana sayfa dışı sekmede geri tuşu | Ana sayfaya döner; ana sayfada uygulamadan çıkar |
| Yığında sayfa yoksa (güvenlik) | `popOrGo()` mantıklı üst ekrana gider |

**Değiştirilen/eklenen:** `assets/audio/countdown/*.wav`, `pubspec.yaml`, `lib/services/audio_service.dart`, `lib/services/timer_service.dart`, `lib/providers/timer_provider.dart`, `lib/utils/navigation.dart` (yeni), `lib/config/app_router.dart`, `lib/screens/home/home_screen.dart`, `lib/screens/workout/exercise_grid_screen.dart`, `lib/screens/workout/workout_player_screen.dart`, `lib/screens/workout/workout_complete_screen.dart`, `lib/screens/menu/more_screen.dart`, `lib/screens/settings/settings_screen.dart`
