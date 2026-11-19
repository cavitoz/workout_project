// Bölüm 5.1 / Bölüm 7 — Ana Ekran (Antrenmanlar Listesi)
// Header + 5 antrenman kartı + glassmorphism tasarım

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/workout_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/workout.dart';
import '../../utils/helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Antrenmanları yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().loadWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildWorkoutList(context),
          ),
        ],
      ),
    );
  }

  /// Bölüm 11.3.1 — Üst header bar
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 24,
        right: 24,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xCC0A141E), // #0A141E %80
        boxShadow: [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sol: geri ikonu (dekoratif) + "AC CORE" başlığı
          const Icon(Icons.bolt, color: AppTheme.primaryContainer, size: 24),
          const SizedBox(width: 8),
          const Text(
            'AC CORE',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.5,
              color: AppTheme.primaryContainer,
            ),
          ),
          const Spacer(),
          // Sağ: profil avatar
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceVariant,
              image: DecorationImage(
                image: AssetImage('assets/images/cover/KAPAK_PHOTO.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Antrenman kartları listesi
  Widget _buildWorkoutList(BuildContext context) {
    return Consumer2<WorkoutProvider, SettingsProvider>(
      builder: (context, workoutProvider, settingsProvider, _) {
        final workouts = workoutProvider.workouts;
        final language = settingsProvider.language;

        if (workouts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryContainer,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            return _WorkoutCard(
              workout: workouts[index],
              language: language,
              onTap: () {
                workoutProvider.selectWorkout(workouts[index].id);
                context.push('/workout/${workouts[index].id}');
              },
            );
          },
        );
      },
    );
  }
}

/// Antrenman kartı widget'ı — glassmorphism tasarım
class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  final String language;
  final VoidCallback onTap;

  const _WorkoutCard({
    required this.workout,
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = Helpers.difficultyColorFromHex(workout.iconColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Glassmorphism: yarı saydam yüzey
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0x1AFFFFFF), // white/10%
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Sol: zorluk yıldızı (renkli daire 40px)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: starColor,
              ),
              child: const Center(
                child: Text(
                  '★',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Orta: başlık + alt yazı
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.getName(language),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${workout.durationMinutes} dk • ${workout.totalPoints} puan',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            // Sağ: chevron
            const Icon(
              Icons.chevron_right,
              color: AppTheme.onSurfaceVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
