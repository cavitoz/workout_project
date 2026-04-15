// Bölüm 11.1 — Material Design 3 Renk Token Sistemi
// AC CORE tasarım sistemi: koyu lacivert zemin, turuncu vurgu, glassmorphism

import 'package:flutter/material.dart';

class AppTheme {
  // ─── CORE BRAND COLORS ───
  static const Color primary = Color(0xFFFFB59D); // Ana birincil (açık turuncu)
  static const Color primaryContainer =
      Color(0xFFFF6B35); // Butonlar, aktif badge, timer çizgisi
  static const Color onPrimary = Color(0xFF5D1900); // Primary üstü metin
  static const Color onPrimaryContainer =
      Color(0xFF5F1900); // PrimaryContainer üstü metin
  static const Color onPrimaryFixed =
      Color(0xFF390C00); // Sabit primary üstü (koyu metin)

  // ─── SECONDARY (Mavi tonları — dinlenme, bilgi) ───
  static const Color secondary = Color(0xFFA4C9FF); // İkincil vurgu (mavi)
  static const Color secondaryContainer =
      Color(0xFF0073CE); // İkincil kart arka planı
  static const Color onSecondary = Color(0xFF00315D);
  static const Color onSecondaryContainer = Color(0xFFF7F8FF);

  // ─── TERTIARY (Yeşil tonları — başarı, tamamlama) ───
  static const Color tertiary = Color(0xFF78DC77); // Yeşil vurgu
  static const Color tertiaryContainer =
      Color(0xFF4AAD4E); // Başarı kartı arka planı
  static const Color onTertiary = Color(0xFF00390A);
  static const Color onTertiaryContainer = Color(0xFF003A0B);

  // ─── SURFACE & BACKGROUND ───
  static const Color background = Color(0xFF0A141E); // Ana arka plan (en koyu)
  static const Color surface = Color(0xFF0A141E); // Surface = background
  static const Color surfaceDim = Color(0xFF0A141E);
  static const Color surfaceBright = Color(0xFF303A45);
  static const Color surfaceContainerLowest =
      Color(0xFF050F19); // En koyu container
  static const Color surfaceContainerLow =
      Color(0xFF121C27); // Video alanı arka planı
  static const Color surfaceContainer =
      Color(0xFF17202B); // Kart arka planı
  static const Color surfaceContainerHigh =
      Color(0xFF212B35); // Yükseltilmiş kart
  static const Color surfaceContainerHighest =
      Color(0xFF2C3641); // Timer arka plan çizgisi
  static const Color surfaceVariant =
      Color(0xFF2C3641); // Profil avatar arka planı

  // ─── TEXT & ICON COLORS ───
  static const Color onBackground =
      Color(0xFFD9E3F2); // Ana metin (açık beyaz-mavi)
  static const Color onSurface =
      Color(0xFFD9E3F2); // Surface üstü metin
  static const Color onSurfaceVariant =
      Color(0xFFE1BFB5); // İkincil metin (sıcak gri)
  static const Color inverseSurface = Color(0xFFD9E3F2);
  static const Color inverseOnSurface = Color(0xFF27313C);
  static const Color inversePrimary = Color(0xFFAB3500);

  // ─── OUTLINE & BORDERS ───
  static const Color outline = Color(0xFFA98A80); // Ana border
  static const Color outlineVariant =
      Color(0xFF594139); // Hafif border (buton çerçeve)

  // ─── ERROR ───
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // ─── CUSTOM BRAND TOKENS (Stitch dışı, özel) ───
  static const Color timerGlow =
      Color(0x99FF6B35); // Timer drop-shadow glow (%60)
  static const Color navBarBg =
      Color(0x992C3641); // Alt nav blur arka planı (%60)
  static const Color navBarActive = Color(0xFFFF6B35); // Aktif tab rengi
  static const Color navBarInactive =
      Color(0xFF6B7280); // Pasif tab (gray-500)
  static const Color navBarHover = Color(0xFFFFB59D); // Hover tab

  // ─── YILDIZ (ZORLUK SEVİYESİ) RENKLERİ ───
  static const Color starEasy = Color(0xFF3B82F6); // Mavi yıldız
  static const Color starMedium = Color(0xFFEF4444); // Kırmızı yıldız
  static const Color starHard = Color(0xFFF59E0B); // Amber yıldız
  static const Color starExtreme = Color(0xFFFACC15); // Sarı yıldız
  static const Color starCustom = Color(0xFF9CA3AF); // Gri yıldız

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
          onInverseSurface: inverseOnSurface,
          inversePrimary: inversePrimary,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xCC0A141E), // #0A141E %80
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: primaryContainer),
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.5,
            color: primaryContainer,
          ),
        ),
      );
}
