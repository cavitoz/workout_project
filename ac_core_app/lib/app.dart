// Bölüm 6.3 — MaterialApp.router ile GoRouter ve tema bağlantısı
// EasyLocalization ile çok dilli destek entegrasyonu

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/app_theme.dart';
import 'config/app_router.dart';

class AcCoreApp extends StatelessWidget {
  const AcCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inter fontunu Google Fonts üzerinden tema'ya entegre et
    final interTheme = AppTheme.darkTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(AppTheme.darkTheme.textTheme),
    );

    return MaterialApp.router(
      title: 'AC CORE',
      debugShowCheckedModeBanner: false,
      theme: interTheme,
      // EasyLocalization entegrasyonu
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // GoRouter entegrasyonu
      routerConfig: appRouter,
    );
  }
}
