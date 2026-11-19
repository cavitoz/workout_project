// Bölüm 6.2 / Bölüm 11.3.6 — Alt navigasyon barı
// 5 tab, glassmorphism arka plan, turuncu aktif tab

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';
import '../utils/app_text_styles.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 80 + bottomPadding,
      decoration: const BoxDecoration(
        // Bölüm 11.3.6: rounded-t-[24px], arka plan %60 blur
        color: AppTheme.navBarBg,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          // 0 -4px 24px rgba(255,107,53,0.08)
          BoxShadow(
            color: Color(0x14FF6B35),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          children: [
            _NavItem(
                icon: Icons.fitness_center,
                label: 'ANTRENMAN',
                isActive: currentIndex == 0,
                onTap: () => context.go('/')),
            _NavItem(
                icon: Icons.play_circle_outline,
                label: 'EGZERSİZ',
                isActive: currentIndex == 1,
                onTap: () => context.go('/exercises')),
            _NavItem(
                icon: Icons.emoji_events_outlined,
                label: 'CHALLENGE',
                isActive: currentIndex == 2,
                onTap: () => context.go('/challenge')),
            _NavItem(
                icon: Icons.notifications_outlined,
                label: 'BİLDİRİM',
                isActive: currentIndex == 3,
                onTap: () => context.go('/notifications')),
            _NavItem(
                icon: Icons.menu,
                label: 'MENÜ',
                isActive: currentIndex == 4,
                onTap: () => context.go('/more')),
          ],
        ),
      ),
    );
  }

  /// Rota yolunu sekme indexine çevir
  int _locationToIndex(String location) {
    if (location == '/') return 0;
    if (location.startsWith('/exercises')) return 1;
    if (location.startsWith('/challenge')) return 2;
    if (location.startsWith('/notifications')) return 3;
    if (location.startsWith('/more') || location.startsWith('/settings')) {
      return 4;
    }
    return 0;
  }
}

/// Tek bir navigasyon tab item'ı
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.navBarActive : AppTheme.navBarInactive;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: isActive
              ? BoxDecoration(
                  // Aktif tab: glassmorphism vurgu
                  color: const Color(0x0DFFFFFF), // white/5%
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33FF6B35), // inset glow
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ],
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.navLabel.copyWith(color: color),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
