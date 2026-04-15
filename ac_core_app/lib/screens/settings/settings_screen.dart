// Bölüm 5.6 / Bölüm 10 — Ayarlar Ekranı
// Egzersiz süresi, dinlenme, set, ses ve dil ayarları

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // ─── Antrenman Seçenekleri ───
                      _buildSectionTitle('Antrenman Seçenekleri'),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        context,
                        label: 'Egzersiz Süresi',
                        value: settings.exerciseDuration,
                        options: AppConstants.exerciseDurationOptions,
                        suffix: 'SN',
                        onChanged: (val) =>
                            settings.setExerciseDuration(val),
                      ),
                      const SizedBox(height: 10),
                      _buildDropdown(
                        context,
                        label: 'Dinlenme Süresi',
                        value: settings.restDuration,
                        options: AppConstants.restDurationOptions,
                        suffix: 'SN',
                        onChanged: (val) => settings.setRestDuration(val),
                      ),
                      const SizedBox(height: 10),
                      _buildDropdown(
                        context,
                        label: 'Set Sayısı',
                        value: settings.sets,
                        options: AppConstants.setsOptions,
                        suffix: '',
                        onChanged: (val) => settings.setSets(val),
                      ),
                      const SizedBox(height: 10),
                      _buildDropdown(
                        context,
                        label: 'Set Arası Dinlenme',
                        value: settings.setBreakDuration,
                        options: AppConstants.setRestDurationOptions,
                        suffix: 'SN',
                        onChanged: (val) => settings.setSetBreakDuration(val),
                      ),
                      const SizedBox(height: 24),
                      // ─── Ses Seçenekleri ───
                      _buildSectionTitle('Ses Seçenekleri'),
                      const SizedBox(height: 12),
                      _buildToggle(
                        label: 'Egzersiz Açıklaması',
                        value: settings.soundEnabled,
                        onChanged: (val) => settings.setSoundEnabled(val),
                      ),
                      const SizedBox(height: 8),
                      _buildToggle(
                        label: 'Geri Sayım Sesi',
                        value: settings.countdownVoice,
                        onChanged: (val) =>
                            settings.setCountdownVoice(val),
                      ),
                      const SizedBox(height: 24),
                      // ─── Dil ───
                      _buildSectionTitle('Dil'),
                      const SizedBox(height: 12),
                      _buildLanguageDropdown(context, settings),
                      const SizedBox(height: 32),
                      // ─── Sıfırla butonu ───
                      _buildResetButton(context, settings),
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

  /// Üst başlık
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back,
                color: AppTheme.primaryContainer),
          ),
          const Expanded(
            child: Text(
              'Ayarlar',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  /// Bölüm başlığı + turuncu çizgi
  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryContainer,
                AppTheme.primaryContainer.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Glassmorphism dropdown
  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required int value,
    required List<int> options,
    required String suffix,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 1,
        ),
      ),
      child: Row(
        children: [
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
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              dropdownColor: AppTheme.surfaceContainerHigh,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryContainer,
              ),
              items: options
                  .map((o) => DropdownMenuItem(
                        value: o,
                        child: Text('$o $suffix'),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Toggle switch
  Widget _buildToggle({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 1,
        ),
      ),
      child: Row(
        children: [
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

  /// Dil dropdown
  Widget _buildLanguageDropdown(
      BuildContext context, SettingsProvider settings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Uygulama Dili',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: settings.language,
              dropdownColor: AppTheme.surfaceContainerHigh,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryContainer,
              ),
              items: const [
                DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (val) async {
                if (val != null) {
                  await settings.setLanguage(val);
                  // EasyLocalization dil güncelleme
                  if (context.mounted) {
                    await context.setLocale(Locale(val));
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Sıfırla butonu
  Widget _buildResetButton(
      BuildContext context, SettingsProvider settings) {
    return OutlinedButton(
      onPressed: () => settings.resetToDefaults(),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppTheme.primaryContainer),
        foregroundColor: AppTheme.primaryContainer,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Sıfırla',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
