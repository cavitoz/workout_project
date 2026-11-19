// Bölüm 5.2 / Bölüm 8 — Egzersiz Sıralama Grid Ekranı
// 2 sütun grid, karıştır butonu, "X Puan Kazan" alt butonu

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../providers/workout_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/exercise.dart';
import '../../utils/helpers.dart';
import '../../utils/navigation.dart';

class ExerciseGridScreen extends StatefulWidget {
  final String workoutId;

  const ExerciseGridScreen({super.key, required this.workoutId});

  @override
  State<ExerciseGridScreen> createState() => _ExerciseGridScreenState();
}

class _ExerciseGridScreenState extends State<ExerciseGridScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().selectWorkout(widget.workoutId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WorkoutProvider, SettingsProvider>(
      builder: (context, workoutProvider, settingsProvider, _) {
        final workout = workoutProvider.activeWorkout;
        final exercises = workoutProvider.activeExercises;
        final language = settingsProvider.language;

        if (workout == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryContainer,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: Column(
            children: [
              // Üst bar
              _buildHeader(context, workout.getName(language), workoutProvider),
              // Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    return _ExerciseCard(
                      exercise: exercises[index],
                      index: index,
                      language: language,
                    );
                  },
                ),
              ),
              // Alt buton
              _buildStartButton(context, workout.totalPoints, workout.id),
            ],
          ),
        );
      },
    );
  }

  /// Üst başlık barı
  Widget _buildHeader(
      BuildContext context, String workoutName, WorkoutProvider provider) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 16,
        bottom: 8,
      ),
      color: AppTheme.background,
      child: Row(
        children: [
          // Geri butonu
          IconButton(
            onPressed: () => context.popOrGo('/'),
            icon:
                const Icon(Icons.arrow_back, color: AppTheme.primaryContainer),
          ),
          // Başlık
          const Expanded(
            child: Text(
              'Egzersiz Sırası',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Karıştır butonu
          TextButton.icon(
            onPressed: () => provider.shuffleExercises(),
            icon: const Icon(Icons.shuffle,
                color: AppTheme.primaryContainer, size: 18),
            label: const Text(
              'Karıştır',
              style: TextStyle(
                color: AppTheme.primaryContainer,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Alt "X Puan Kazan" butonu
  Widget _buildStartButton(BuildContext context, int points, String workoutId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: GestureDetector(
        onTap: () => context.push('/workout/$workoutId/play'),
        child: Container(
          height: 56,
          width: double.infinity,
          decoration:
              orangeGradientDecoration(borderRadius: AppConstants.radiusMedium),
          child: Center(
            child: Text(
              '$points Puan Kazan ›',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Egzersiz kart widget'ı — görsel arka plan + gradient overlay
class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final String language;

  const _ExerciseCard({
    required this.exercise,
    required this.index,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Arka plan: egzersiz görseli
          Image.asset(
            exercise.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppTheme.surfaceContainer,
              child: const Icon(Icons.fitness_center,
                  color: AppTheme.onSurfaceVariant, size: 40),
            ),
          ),
          // Gradient overlay (alttan siyah %60)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x99000000),
                ],
              ),
            ),
          ),
          // Sol üst: sıra numarası
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x80000000),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Alt: egzersiz adı + puan
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    exercise.getName(language).toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Color(0xAA000000),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${exercise.points} Puan',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xBBFFFFFF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
