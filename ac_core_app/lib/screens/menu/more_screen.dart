// Bölüm 5.7 / Bölüm 13 — Daha Fazla / Menü Ekranı
// Dikey menü listesi: hızlı başlat, sorumluluk, hatırlatıcılar, ayarlar, toggleler, badges

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/challenge_provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Başlık
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Text(
                    'Daha Fazla',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Menü listesi
            Expanded(
              child: Consumer2<SettingsProvider, ChallengeProvider>(
                builder: (context, settings, challenge, _) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    children: [
                      // Hızlı Başlat
                      _MenuItem(
                        icon: Icons.timer_outlined,
                        label: 'Hızlı Başlat',
                        onTap: () => context.go('/'),
                      ),
                      _divider(),
                      // Sorumluluk Reddi
                      _MenuItem(
                        icon: Icons.info_outline,
                        label: 'Sorumluluk Reddi',
                        onTap: () => _showDisclaimer(context),
                      ),
                      _divider(),
                      // Hatırlatıcılar
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Hatırlatıcılar',
                        onTap: () => context.go('/notifications'),
                      ),
                      _divider(),
                      // Ayarlar
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Ayarlar',
                        onTap: () => context.go('/settings'),
                      ),
                      _divider(),
                      // Ses Efektleri — toggle
                      _ToggleMenuItem(
                        icon: Icons.music_note_outlined,
                        label: 'Ses Efektleri',
                        value: settings.soundEnabled,
                        onChanged: (val) => settings.setSoundEnabled(val),
                      ),
                      _divider(),
                      // Bildirimler — toggle
                      _ToggleMenuItem(
                        icon: Icons.notifications_none,
                        label: 'Bildirimler',
                        value: true,
                        onChanged: (val) {},
                      ),
                      _divider(),
                      // Challenge Kupası — badge
                      _BadgeMenuItem(
                        icon: Icons.emoji_events_outlined,
                        label: 'Challenge Kupası',
                        badgeValue: '${challenge.totalTrophies}',
                        badgeColor: AppTheme.primaryContainer,
                      ),
                      _divider(),
                      // Toplam Puan — badge
                      _BadgeMenuItem(
                        icon: Icons.bar_chart,
                        label: 'Toplam Puan',
                        badgeValue: '${challenge.totalPoints}',
                        badgeColor: AppTheme.primaryContainer,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Satırlar arası ince ayırıcı çizgi
  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0x0FFFFFFF), // white/6%
    );
  }

  /// Sorumluluk reddi dialogu
  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerHigh,
        title: const Text(
          'Sorumluluk Reddi',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Bu uygulama genel fitness amaçlıdır. Egzersiz programına başlamadan önce doktorunuza danışın. Ciddi sağlık sorunlarınız varsa egzersiz yapmadan önce tıbbi tavsiye alın. Uygulama geliştiricisi herhangi bir yaralanmadan sorumlu değildir.',
          style: TextStyle(
            fontFamily: 'Inter',
            color: AppTheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anladım',
                style: TextStyle(color: AppTheme.primaryContainer)),
          ),
        ],
      ),
    );
  }
}

/// Normal menü öğesi (chevron ile)
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Icon(icon, color: AppTheme.onSurfaceVariant, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppTheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Toggle switch menü öğesi
class _ToggleMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const _ToggleMenuItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.onSurfaceVariant, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryContainer,
            activeTrackColor:
                AppTheme.primaryContainer.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0x33FFFFFF),
          ),
        ],
      ),
    );
  }
}

/// Badge menü öğesi (turuncu sayı rozeti)
class _BadgeMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String badgeValue;
  final Color badgeColor;

  const _BadgeMenuItem({
    required this.icon,
    required this.label,
    required this.badgeValue,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.onSurfaceVariant, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              badgeValue,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.onPrimaryFixed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
