// AC CORE — Fitness Workout App
// main.dart — Uygulama giriş noktası
// Bölüm 3.5 — Hive başlatma ve seed çağrısı
// Bölüm 5.5 — MultiProvider kayıtları
// Bölüm 14.4 — EasyLocalization yapılandırması
// Bölüm 16.2 — Portrait-only kilitleme

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'services/database_service.dart';
import 'providers/settings_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/timer_provider.dart';
import 'providers/challenge_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bölüm 16.2: Portrait-only kilitleme
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Sistem UI rengi
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A141E),
  ));

  // Bölüm 3.5 — Hive veritabanını başlat ve seed data yükle
  await DatabaseService.initDatabase();
  await DatabaseService.seedInitialData();

  // EasyLocalization başlat (Bölüm 14.4)
  await EasyLocalization.ensureInitialized();

  runApp(
    // EasyLocalization wrap (Bölüm 14.4)
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      startLocale: const Locale('tr'),
      child: MultiProvider(
        providers: [
          // Bölüm 5.1 — Ayarlar provider
          ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
          // Bölüm 5.2 — Antrenman provider
          ChangeNotifierProvider(create: (_) => WorkoutProvider()..loadWorkouts()),
          // Bölüm 5.3 — Timer provider
          ChangeNotifierProvider(create: (_) => TimerProvider()),
          // Bölüm 5.4 — Challenge provider
          ChangeNotifierProvider(
              create: (_) => ChallengeProvider()..loadProgress()),
        ],
        child: const AcCoreApp(),
      ),
    ),
  );
}
