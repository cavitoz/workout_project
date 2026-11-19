// Bölüm 5.4 / Bölüm 11 — Kılavuzlar / Egzersizler Ekranı
// Filtre tabları + dikey egzersiz kartları listesi

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../config/app_theme.dart';
import '../../models/exercise.dart';
import '../../providers/settings_provider.dart';
import '../../services/database_service.dart';

class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  String _selectedFilter = 'all'; // all, easy, medium, hard
  List<Exercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    setState(() {
      _exercises = DatabaseService.getAllExercises();
    });
  }

  /// Filtre tablarına göre egzersizleri filtrele
  List<Exercise> get _filteredExercises {
    if (_selectedFilter == 'all') return _exercises;
    final diffMap = {
      'easy': ExerciseDifficulty.easy,
      'medium': ExerciseDifficulty.medium,
      'hard': ExerciseDifficulty.hard,
    };
    return _exercises
        .where((e) => e.difficulty == diffMap[_selectedFilter])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterTabs(),
            const SizedBox(height: 8),
            Expanded(
              child: _buildExerciseList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Text(
            'Egzersiz Kılavuzu',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Filtre tabları: Tümü / Kolay / Orta / Zor
  Widget _buildFilterTabs() {
    final tabs = [
      {'key': 'all', 'label': 'Tümü'},
      {'key': 'easy', 'label': 'Kolay'},
      {'key': 'medium', 'label': 'Orta'},
      {'key': 'hard', 'label': 'Zor'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final isActive = _selectedFilter == tab['key'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedFilter = tab['key']!);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.primaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isActive
                          ? AppTheme.primaryContainer
                          : const Color(0x33FFFFFF),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tab['label']!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppTheme.onPrimaryFixed
                          : AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Egzersiz kartları listesi
  Widget _buildExerciseList() {
    final exercises = _filteredExercises;
    final language = context.read<SettingsProvider>().language;

    if (exercises.isEmpty) {
      return const Center(
        child: Text(
          'Egzersiz bulunamadı',
          style: TextStyle(color: AppTheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        return _ExerciseListCard(
          exercise: exercises[index],
          language: language,
        );
      },
    );
  }
}

/// Egzersiz liste kart widget'ı (200px yükseklik)
class _ExerciseListCard extends StatelessWidget {
  final Exercise exercise;
  final String language;

  const _ExerciseListCard({
    required this.exercise,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Arka plan görseli
            Image.asset(
              exercise.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppTheme.surfaceContainer,
              ),
            ),
            // Gradient overlay (alttan %70 siyah)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xB3000000),
                  ],
                ),
              ),
            ),
            // Egzersiz adı (orta)
            Center(
              child: Text(
                exercise.getName(language),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Color(0xAA000000),
                      blurRadius: 10,
                    )
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Sağ üst: bilgi butonu
            Positioned(
              top: 12,
              right: 60,
              child: _GlassCircleButton(
                icon: Icons.info_outline,
                size: 36,
                onTap: () {
                  _showExerciseInfo(context, exercise, language);
                },
              ),
            ),
            // Sağ üst: play butonu
            Positioned(
              top: 12,
              right: 12,
              child: _GlassCircleButton(
                icon: Icons.play_arrow,
                size: 44,
                iconColor: AppTheme.primaryContainer,
                onTap: () {
                  _showVideoDialog(context, exercise);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoDialog(BuildContext context, Exercise exercise) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => _ExerciseVideoDialog(exercise: exercise),
    );
  }

  void _showExerciseInfo(
      BuildContext context, Exercise exercise, String language) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerHigh,
        title: Text(
          exercise.getName(language),
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          exercise.getDescription(language),
          style: const TextStyle(
            fontFamily: 'Inter',
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Kapat',
              style: TextStyle(color: AppTheme.primaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// Egzersiz video dialog widget'ı
class _ExerciseVideoDialog extends StatefulWidget {
  final Exercise exercise;

  const _ExerciseVideoDialog({required this.exercise});

  @override
  State<_ExerciseVideoDialog> createState() => _ExerciseVideoDialogState();
}

class _ExerciseVideoDialogState extends State<_ExerciseVideoDialog> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.asset(widget.exercise.videoPath);
    _controller = controller;
    try {
      await controller.initialize();
      controller.setLooping(true);
      controller.play();
      if (mounted) setState(() => _isInitialized = true);
    } catch (_) {
      // Video yüklenemedi — görsel fallback gösterilecek
      _controller = null;
      await controller.dispose();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.read<SettingsProvider>().language;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Video
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0xFF0A0A0F)),
                  if (_isInitialized && _controller != null)
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    )
                  else if (_controller == null && !_isInitialized)
                    // Video yüklenemedi → görsel göster
                    Image.asset(
                      widget.exercise.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.surfaceContainer,
                        child: const Center(
                          child: Icon(Icons.fitness_center,
                              size: 48, color: AppTheme.primaryContainer),
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryContainer,
                        strokeWidth: 2,
                      ),
                    ),
                  // Egzersiz adı overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xCC000000)],
                        ),
                      ),
                      child: Text(
                        widget.exercise.getName(language),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Kapat butonu
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'Kapat',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onPrimaryFixed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Glassmorphism daire butonu
class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? iconColor;
  final VoidCallback onTap;

  const _GlassCircleButton({
    required this.icon,
    required this.size,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x1AFFFFFF),
          border: Border.all(
            color: const Color(0x33FFFFFF),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}
