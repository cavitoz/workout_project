// Bildirimler Ekranı
// Antrenman hatırlatıcı saatleri ve günlük bildirim ayarları

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _notificationsEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  final List<bool> _activeDays = List.filled(7, true);

  final List<String> _dayNames = [
    'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'
  ];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      final hour = prefs.getInt('reminder_hour') ?? 8;
      final minute = prefs.getInt('reminder_minute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      for (int i = 0; i < 7; i++) {
        _activeDays[i] = prefs.getBool('day_$i') ?? true;
      }
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setInt('reminder_hour', _reminderTime.hour);
    await prefs.setInt('reminder_minute', _reminderTime.minute);
    for (int i = 0; i < 7; i++) {
      await prefs.setBool('day_$i', _activeDays[i]);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryContainer,
              onPrimary: AppTheme.onPrimaryFixed,
              surface: AppTheme.surfaceContainerHigh,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _reminderTime) {
      setState(() => _reminderTime = picked);
      _savePrefs();
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                children: [
                  const SizedBox(height: 8),
                  // Ana bildirim toggle
                  _buildMainToggle(),
                  const SizedBox(height: 24),
                  // Bildirimler kapalıysa diğerleri soluk görünür
                  AnimatedOpacity(
                    opacity: _notificationsEnabled ? 1.0 : 0.35,
                    duration: const Duration(milliseconds: 250),
                    child: IgnorePointer(
                      ignoring: !_notificationsEnabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Hatırlatma Saati'),
                          const SizedBox(height: 12),
                          _buildTimePicker(),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Günler'),
                          const SizedBox(height: 12),
                          _buildDaySelector(),
                          const SizedBox(height: 32),
                          _buildInfoCard(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Icon(Icons.notifications_outlined,
              color: AppTheme.primaryContainer, size: 24),
          SizedBox(width: 12),
          Text(
            'Bildirimler',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppTheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildMainToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _notificationsEnabled
              ? AppTheme.primaryContainer.withValues(alpha: 0.3)
              : const Color(0x1AFFFFFF),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _notificationsEnabled
                  ? AppTheme.primaryContainer.withValues(alpha: 0.15)
                  : AppTheme.surfaceContainerHigh,
            ),
            child: Icon(
              _notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off_outlined,
              color: _notificationsEnabled
                  ? AppTheme.primaryContainer
                  : AppTheme.onSurfaceVariant,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hatırlatıcılar',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _notificationsEnabled
                      ? 'Antrenman hatırlatıcıları açık'
                      : 'Antrenman hatırlatıcıları kapalı',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
              _savePrefs();
            },
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

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0x1AFFFFFF),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time,
                color: AppTheme.onSurfaceVariant, size: 20),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Hatırlatma saati',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _formatTime(_reminderTime),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryContainer,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final isActive = _activeDays[index];
          return GestureDetector(
            onTap: () {
              setState(() => _activeDays[index] = !isActive);
              _savePrefs();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? AppTheme.primaryContainer
                    : AppTheme.surfaceContainerHigh,
                border: Border.all(
                  color: isActive
                      ? AppTheme.primaryContainer
                      : const Color(0x1AFFFFFF),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  _dayNames[index],
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? AppTheme.onPrimaryFixed
                        : AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              color: AppTheme.secondary, size: 18),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ayarlar kaydedildi. Gerçek bildirimler için uygulamada bildirim izni gereklidir.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppTheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
