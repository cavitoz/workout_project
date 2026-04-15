// Antrenman tamamlama ekranı
// Kazanılan puanı gösterir, challenge'a ekler

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';

class WorkoutCompleteScreen extends StatelessWidget {
  final int points;
  final String workoutName;

  const WorkoutCompleteScreen({
    super.key,
    required this.points,
    required this.workoutName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Kutlama ikonu
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.tertiaryContainer.withValues(alpha: 0.2),
                  border: Border.all(
                    color: AppTheme.tertiary,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 60,
                  color: AppTheme.tertiary,
                ),
              ),
              const SizedBox(height: 32),
              // Başlık
              const Text(
                'Antrenman Tamamlandı! 🎉',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                workoutName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: AppTheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Puan kartı
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryContainer.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Kazanılan Puan',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '+$points',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Challenge'a git butonu
              GestureDetector(
                onTap: () => context.go('/challenge'),
                child: Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Color(0x66FF6B35), blurRadius: 24),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Challenge\'a Git',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onPrimaryFixed,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Ana sayfaya dön butonu
              GestureDetector(
                onTap: () => context.go('/'),
                child: Container(
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryContainer, width: 1),
                  ),
                  child: const Center(
                    child: Text(
                      'Ana Sayfaya Dön',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
