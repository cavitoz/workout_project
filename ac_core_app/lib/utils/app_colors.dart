// Bölüm 11.1 — Özel renk token'ları
// Yıldız renkleri, timer glow ve navbar için özel sabitler

import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class AppColors {
  // Zorluk seviyesi yıldız renkleri
  static const Color starEasy = AppTheme.starEasy;
  static const Color starMedium = AppTheme.starMedium;
  static const Color starHard = AppTheme.starHard;
  static const Color starExtreme = AppTheme.starExtreme;
  static const Color starCustom = AppTheme.starCustom;

  // Timer glow efekti
  static const Color timerGlow = AppTheme.timerGlow;

  // Navbar renkleri
  static const Color navBarBg = AppTheme.navBarBg;
  static const Color navBarActive = AppTheme.navBarActive;
  static const Color navBarInactive = AppTheme.navBarInactive;
  static const Color navBarHover = AppTheme.navBarHover;

  // Egzersiz bandı renkleri
  static const Color exerciseBand = Color(0xFFFF6B35); // primaryContainer
  static const Color restBand = Color(0xFF4AAD4E); // tertiaryContainer

  // Glassmorphism efektleri
  static const Color glassWhite = Color(0x0DFFFFFF); // white/5%
  static const Color glassBorder = Color(0x1AFFFFFF); // white/10%
  static const Color glassBorderLight = Color(0x33FFFFFF); // white/20%
}
