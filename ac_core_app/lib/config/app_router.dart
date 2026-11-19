// Bölüm 6.1 — GoRouter navigasyon yapılandırması
// 5 ana sekme + workout oynatıcı rotaları

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/instructions/instructions_screen.dart';
import '../screens/challenge/challenge_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/menu/more_screen.dart';
import '../screens/workout/exercise_grid_screen.dart';
import '../screens/workout/workout_player_screen.dart';
import '../screens/workout/workout_complete_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../widgets/bottom_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // Splash ekranı
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    // Shell route — alt navigasyon barı ile
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        // 1. Ana Ekran — Antrenmanlar
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        // 2. Egzersizler / Kılavuzlar
        GoRoute(
          path: '/exercises',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: InstructionsScreen(),
          ),
        ),
        // 3. Challenge
        GoRoute(
          path: '/challenge',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ChallengeScreen(),
          ),
        ),
        // 4. Bildirimler
        GoRoute(
          path: '/notifications',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: NotificationsScreen(),
          ),
        ),
        // 5. Daha Fazla
        GoRoute(
          path: '/more',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MoreScreen(),
          ),
        ),
        // Ayarlar (More'dan açılır, shell içinde)
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        // Egzersiz grid (workout/:id)
        GoRoute(
          path: '/workout/:id',
          builder: (context, state) {
            final workoutId = state.pathParameters['id']!;
            return ExerciseGridScreen(workoutId: workoutId);
          },
        ),
      ],
    ),
    // Tam ekran — bottom navbar GİZLİ (shell dışında)
    GoRoute(
      path: '/workout/:id/play',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final workoutId = state.pathParameters['id']!;
        return WorkoutPlayerScreen(workoutId: workoutId);
      },
    ),
    // Tamamlama ekranı — tam ekran (/complete: /workout/complete rotasıyla çakışmayı önler)
    GoRoute(
      path: '/complete',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final points = extra?['points'] as int? ?? 0;
        final workoutName = extra?['workoutName'] as String? ?? '';
        return WorkoutCompleteScreen(points: points, workoutName: workoutName);
      },
    ),
  ],
);

/// Ana shell widget — bottom navbar ile ekranları wrap eder
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  /// Android geri tuşu: shell içinde push edilmiş sayfa (egzersiz listesi,
  /// ayarlar) varsa GoRouter onu kapatır. Yoksa ve ana sayfa dışındaki bir
  /// sekmedeysek önce ana sayfaya dönülür; ana sayfadaysak uygulama kapanır.
  @override
  Widget build(BuildContext context) {
    final isHome = GoRouterState.of(context).uri.path == '/';
    return PopScope(
      canPop: isHome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/');
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: const BottomNavBar(),
      ),
    );
  }
}
