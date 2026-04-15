// Bölüm 11.2 — Tipografi Sistemi
// Font: Inter, tüm ağırlıklar (400-900)

import 'package:flutter/material.dart';

class AppTextStyles {
  // ─── APP BAR / HEADER ───
  // Uygulama başlığı: italic, bold, turuncu
  static const TextStyle appTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.5,
    color: Color(0xFFFF6B35),
  );

  // ─── HEADLINES ───
  // Timer büyük sayı (72px, text-7xl)
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 72,
    fontWeight: FontWeight.w900,
    letterSpacing: -2.0,
    color: Colors.white,
  );

  // Dinlenme sayısı (30px, text-3xl)
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 30,
    fontWeight: FontWeight.w900,
    color: Color(0xFFA4C9FF),
  );

  // Bölüm başlığı (20px, text-xl)
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: Colors.white,
  );

  // ─── BODY & LABELS ───
  // Egzersiz bandı adı (18px, lg)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Color(0xFF390C00),
  );

  // Kart alt metin (14px, sm)
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: Color(0xFF390C00),
  );

  // Timer "Seconds" etiketi (12px, tracking-[0.2em])
  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    color: Color(0xFFE1BFB5),
  );

  // Alt navigasyon etiketleri (10px, tracking-widest)
  static const TextStyle navLabel = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
  );

  // Kart başlığı (bold, beyaz)
  static const TextStyle cardTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // Kart alt bilgi (küçük, gri)
  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Color(0xFF9CA3AF),
  );

  // Egzersiz adı üst bant UPPERCASE (22px)
  static const TextStyle exerciseName = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    shadows: [
      Shadow(
        color: Color(0xAA000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      )
    ],
  );
}
