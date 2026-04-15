// Bölüm 5.3 / Bölüm 9 — Egzersiz Oynatıcı Ekranı

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:math' as math;
import '../../config/app_theme.dart';
import '../../providers/timer_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/challenge_provider.dart';
import '../../models/exercise.dart';

class WorkoutPlayerScreen extends StatefulWidget {
  final String workoutId;

  const WorkoutPlayerScreen({super.key, required this.workoutId});

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  // Şu an görüntülenen video
  VideoPlayerController? _videoController;
  String? _currentVideoPath;

  // Yüklenmekte olan sonraki video
  VideoPlayerController? _nextVideoController;
  String? _nextVideoPath;

  // Durum bayrakları
  bool _wasTimerPaused = false;
  bool _hasLoadedForCurrentPhase = false; // Rest başlayınca video yükleme
  bool _hasActivatedVideo = false; // Egzersiz başlayınca video aktif etme

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Listener'ı ÖNCE ekle, sonra antrenmanı başlat
      context.read<TimerProvider>().addListener(_onTimerStateChanged);
      _initWorkout();
    });
  }

  void _initWorkout() {
    final workoutProvider = context.read<WorkoutProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final timerProvider = context.read<TimerProvider>();
    workoutProvider.selectWorkout(widget.workoutId);
    timerProvider.startWorkout(
      workoutProvider.activeExercises,
      settingsProvider.settings,
    );
  }

  /// Timer state değişimlerini dinle — video yönetimi burada
  void _onTimerStateChanged() {
    if (!mounted) return;
    final timerProvider = context.read<TimerProvider>();

    // Dinlenme başladığında → yaklaşan egzersiz videosunu yükle
    // currentExercise, dinlenme sırasında zaten bir sonraki egzersizi gösterir
    if (timerProvider.isResting && !_hasLoadedForCurrentPhase) {
      _hasLoadedForCurrentPhase = true;
      _hasActivatedVideo = false;
      final exercise = timerProvider.currentExercise;
      if (exercise != null) {
        _loadNextVideo(exercise.videoPath);
      }
    }

    // Egzersiz başladığında → video zaten yüklü/oynuyor; bir sonraki rest için sıfırla
    if (timerProvider.isExercising) {
      _hasLoadedForCurrentPhase = false; // ← bir sonraki dinlenme için sıfırla
      if (!_hasActivatedVideo) {
        _hasActivatedVideo = true;
        _activateNextVideo(shouldPlay: !timerProvider.isPaused);
      }
    }

    // Pause/play
    final isPaused = timerProvider.isPaused;
    if (isPaused != _wasTimerPaused) {
      _wasTimerPaused = isPaused;
      if (isPaused) {
        _videoController?.pause();
      } else {
        _videoController?.play();
      }
    }
  }

  /// Sonraki egzersiz videosunu arka planda yükle
  Future<void> _loadNextVideo(String videoPath) async {
    if (_nextVideoPath == videoPath) return; // Zaten yükleniyor
    _nextVideoPath = videoPath;

    final oldNext = _nextVideoController;
    _nextVideoController = null;
    await oldNext?.dispose();

    final controller = VideoPlayerController.asset(videoPath);
    try {
      await controller.initialize();
      controller.setLooping(true);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      if (_nextVideoPath == videoPath) {
        _nextVideoController = controller;

        if (mounted && _currentVideoPath != videoPath) {
          final timerProvider = context.read<TimerProvider>();
          // Dinlenme veya egzersiz — video yüklenir yüklenmez göster
          // Dinlenme sırasında dark overlay altında oynar
          _activateNextVideo(
            shouldPlay: timerProvider.isResting || !timerProvider.isPaused,
          );
        }
      } else {
        // Artık gerekli değil, dispose et
        await controller.dispose();
      }
    } catch (e) {
      if (_nextVideoPath == videoPath) _nextVideoPath = null;
      await controller.dispose();
    }
  }

  /// Yüklenen videoyu aktif controller olarak kullan
  void _activateNextVideo({required bool shouldPlay}) {
    if (_nextVideoController == null ||
        !_nextVideoController!.value.isInitialized) {
      // Henüz yüklenmedi — yüklenince _loadNextVideo içinde aktif edilecek
      return;
    }

    final old = _videoController;
    _videoController = _nextVideoController;
    _currentVideoPath = _nextVideoPath;
    _nextVideoController = null;
    _nextVideoPath = null;

    if (shouldPlay) _videoController?.play();

    old?.dispose();

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    if (mounted) {
      context.read<TimerProvider>().removeListener(_onTimerStateChanged);
    }
    _videoController?.dispose();
    _nextVideoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer3<TimerProvider, WorkoutProvider, SettingsProvider>(
        builder: (context, timerProvider, workoutProvider, settingsProvider, _) {
          // Tamamlandıysa yönlendir
          if (timerProvider.isCompleted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final workout = workoutProvider.activeWorkout;
              context.read<ChallengeProvider>().addPoints(
                    workout?.totalPoints ?? 0,
                  );
              context.go('/complete', extra: {
                'points': workout?.totalPoints ?? 0,
                'workoutName':
                    workout?.getName(settingsProvider.language) ?? '',
              });
            });
          }

          final exercise = timerProvider.currentExercise;
          final workout = workoutProvider.activeWorkout;
          final language = settingsProvider.language;

          return SafeArea(
            child: Column(
              children: [
                _buildHeader(context, workout?.durationMinutes ?? 5, language,
                    timerProvider),
                const SizedBox(height: 12),
                _buildVideoArea(timerProvider.isResting),
                const SizedBox(height: 12),
                _buildExerciseBand(
                  exercise,
                  timerProvider,
                  language,
                  workoutProvider.activeExercises.length,
                ),
                const SizedBox(height: 20),
                _buildCircularTimer(timerProvider),
                const SizedBox(height: 24),
                _buildControls(context, timerProvider),
                const SizedBox(height: 20),
                if (timerProvider.isExercising)
                  _buildRestCard(timerProvider, settingsProvider),
                if (timerProvider.isSetResting)
                  _buildSetRestCard(timerProvider, settingsProvider),
                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int durationMin, String language,
      TimerProvider timerProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.read<TimerProvider>().reset();
              context.pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: const Color(0x4DFFFFFF), width: 1),
              ),
              child: const Icon(Icons.arrow_back,
                  color: AppTheme.primaryContainer, size: 20),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$durationMin Dakika Antrenman',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (timerProvider.totalSets > 1)
                  Text(
                    'Set ${timerProvider.currentSet} / ${timerProvider.totalSets}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: const Color(0x4DFFFFFF), width: 1),
              ),
              child: const Icon(Icons.share_outlined,
                  color: AppTheme.onSurfaceVariant, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoArea(bool isResting) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: const Color(0xFF0A0A0F)),
              if (_videoController != null &&
                  _videoController!.value.isInitialized)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                )
              else
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 48,
                          color: AppTheme.primaryContainer
                              .withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hazırlanıyor...',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x99000000)],
                  ),
                ),
              ),
              if (isResting)
                Container(
                  color: const Color(0x66000000),
                  child: const Center(
                    child: Icon(Icons.self_improvement,
                        size: 64, color: Colors.white54),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseBand(Exercise? exercise, TimerProvider timerProvider,
      String language, int totalExercises) {
    final isSetResting = timerProvider.isSetResting;
    final isResting = timerProvider.isResting;

    Color bandColor;
    String bandText;

    if (isSetResting) {
      bandColor = const Color(0xFF7C3AED);
      bandText = language == 'tr' ? 'Set Dinlenmesi' : 'Set Rest';
    } else if (isResting) {
      bandColor = AppTheme.tertiaryContainer;
      bandText = language == 'tr' ? 'Dinlenme' : 'Rest';
    } else {
      bandColor = AppTheme.primaryContainer;
      bandText = exercise?.getName(language).toUpperCase() ?? '';
    }

    final badgeText = (!isResting)
        ? '${timerProvider.currentExerciseIndex + 1} / $totalExercises'
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: bandColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: bandColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                bandText,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onPrimaryFixed,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badgeText.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x33390C00),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.onPrimaryFixed,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularTimer(TimerProvider timerProvider) {
    final isSetResting = timerProvider.isSetResting;
    final isResting = timerProvider.isResting;
    final arcColor = isSetResting
        ? const Color(0xFF7C3AED)
        : isResting
            ? AppTheme.tertiary
            : AppTheme.primaryContainer;

    return GestureDetector(
      onTap: () => timerProvider.togglePause(),
      child: SizedBox(
        width: 170,
        height: 170,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(170, 170),
              painter: _CircularTimerPainter(
                progress: timerProvider.progress,
                arcColor: arcColor,
                bgColor: AppTheme.surfaceContainerHighest,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${timerProvider.remainingSeconds}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2.0,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'SANİYE',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  timerProvider.isPaused
                      ? Icons.play_arrow
                      : Icons.pause,
                  size: 20,
                  color: AppTheme.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, TimerProvider timerProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(icon: Icons.replay_10, size: 48, onTap: () {}),
        const SizedBox(width: 32),
        GestureDetector(
          onTap: () => timerProvider.togglePause(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryContainer,
              boxShadow: [
                BoxShadow(
                  color: Color(0x66FF6B35),
                  blurRadius: 32,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              timerProvider.isPaused ? Icons.play_arrow : Icons.pause,
              size: 36,
              color: AppTheme.onPrimaryFixed,
            ),
          ),
        ),
        const SizedBox(width: 32),
        _ControlButton(
            icon: Icons.skip_next,
            size: 48,
            onTap: () => timerProvider.skip()),
      ],
    );
  }

  Widget _buildRestCard(
      TimerProvider timerProvider, SettingsProvider settingsProvider) {
    final restSeconds = settingsProvider.restDuration;
    final language = settingsProvider.language;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.secondaryContainer.withValues(alpha: 0.2),
              AppTheme.secondary.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
              color: AppTheme.secondary.withValues(alpha: 0.1), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language == 'tr' ? 'YAKLAŞAN DİNLENME' : 'UPCOMING REST',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: AppTheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    language == 'tr' ? 'Aktif Dinlenme' : 'Active Recovery',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$restSeconds',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.secondary,
                  ),
                ),
                Text(
                  language == 'tr' ? 'sn' : 'sec',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRestCard(
      TimerProvider timerProvider, SettingsProvider settingsProvider) {
    final language = settingsProvider.language;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF7C3AED).withValues(alpha: 0.2),
              const Color(0xFF7C3AED).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
              width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language == 'tr' ? 'SET DİNLENMESİ' : 'SET REST',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    language == 'tr'
                        ? 'Sonraki set için hazırlan'
                        : 'Get ready for next set',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${timerProvider.remainingSeconds}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                Text(
                  language == 'tr' ? 'sn' : 'sec',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0x887C3AED),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color arcColor;
  final Color bgColor;

  _CircularTimerPainter({
    required this.progress,
    required this.arcColor,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bgColor
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * (1 - progress),
      false,
      Paint()
        ..color = arcColor
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CircularTimerPainter old) =>
      old.progress != progress || old.arcColor != arcColor;
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _ControlButton(
      {required this.icon, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: AppTheme.outlineVariant.withValues(alpha: 0.3),
              width: 1),
        ),
        child: Icon(icon, color: AppTheme.onSurfaceVariant, size: 24),
      ),
    );
  }
}
