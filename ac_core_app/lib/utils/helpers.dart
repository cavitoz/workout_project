// Yardımcı fonksiyonlar

import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class Helpers {
  /// Zorluk rengini Color olarak döndür
  static Color difficultyColorFromHex(String hex) {
    final cleanHex = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleanHex', radix: 16));
  }

  /// Saniye → "MM:SS" formatına çevir
  static String formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Dakika → "X dk" formatı
  static String formatMinutes(int minutes) {
    return '$minutes dk';
  }
}

/// Glassmorphism kart dekorasyonu
BoxDecoration glassDecoration({
  double borderRadius = 12,
  Color? borderColor,
}) {
  return BoxDecoration(
    color: const Color(0x1AFFFFFF), // white/10%
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(
      color: borderColor ?? const Color(0x1AFFFFFF),
      width: 1,
    ),
  );
}

/// Turuncu gradyan dekorasyon (buton, bant)
BoxDecoration orangeGradientDecoration({double borderRadius = 12}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.circular(borderRadius),
  );
}

/// Zorluk rengi için Color
Color starColor(String difficulty) {
  switch (difficulty.toLowerCase()) {
    case 'easy':
      return AppTheme.starEasy;
    case 'medium':
      return AppTheme.starMedium;
    case 'hard':
      return AppTheme.starHard;
    case 'extreme':
      return AppTheme.starExtreme;
    case 'custom':
      return AppTheme.starCustom;
    default:
      return AppTheme.starCustom;
  }
}
