// Bölüm 5.5 / Bölüm 12 — Challenge Ekranı
// 8 haftalık bar grafik, kalp ikonları, sıfırla butonu

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../providers/challenge_provider.dart';
import 'package:intl/intl.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChallengeProvider>().loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer<ChallengeProvider>(
          builder: (context, challengeProvider, _) {
            final weeklyData = challengeProvider.getWeeklyData();
            final progress = challengeProvider.progress;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  const Text(
                    'Fitness Workout\nChallenge',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 2,
                    width: 60,
                    color: AppTheme.primaryContainer,
                  ),
                  const SizedBox(height: 24),
                  // Bar grafik
                  _buildBarChart(weeklyData),
                  const SizedBox(height: 16),
                  // Kalp ikonları
                  _buildHeartIcons(weeklyData),
                  const SizedBox(height: 24),
                  // İstatistikler
                  Row(
                    children: [
                      _StatCard(
                        label: 'Toplam Puan',
                        value: '${challengeProvider.totalPoints}',
                        icon: Icons.star,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Kupalar',
                        value: '${challengeProvider.totalTrophies}',
                        icon: Icons.emoji_events,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Başlangıç tarihi
                  Text(
                    progress.hasStarted
                        ? 'Başlangıç: ${DateFormat('dd.MM.yyyy').format(progress.startDate)}'
                        : 'Başlangıç: İlk antrenmanla başlar',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Sıfırla butonu
                  GestureDetector(
                    onTap: () => _confirmReset(context, challengeProvider),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0x33EF4444),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh,
                              color: Color(0xFFEF4444), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Challenge Sıfırla',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 8 haftalık bar grafik (fl_chart)
  Widget _buildBarChart(List<double> weeklyData) {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          maxY: AppConstants.maxPointsPerWeek.toDouble(),
          minY: 0,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  return Text(
                    'H${(value.toInt() + 1)}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(AppConstants.totalWeeks, (index) {
            final value = weeklyData[index];
            final hasData = value > 0;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  // Puan 100'ü geçebilir; çubuk grafiğin üstünden taşmasın
                  toY: value > 0
                      ? value.clamp(0, AppConstants.maxPointsPerWeek.toDouble())
                      : 4, // Minimum görünürlük
                  gradient: hasData
                      ? const LinearGradient(
                          colors: [
                            Color(0xFFFF6B35),
                            Color(0xFFFF8C5A),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        )
                      : null,
                  color: hasData ? null : const Color(0x0FFFFFFF),
                  width: 28,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: AppConstants.maxPointsPerWeek.toDouble(),
                    color: const Color(0x0FFFFFFF),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Hafta başlıkları üzerindeki kalp ikonları
  Widget _buildHeartIcons(List<double> weeklyData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(AppConstants.totalWeeks, (index) {
        final isComplete = weeklyData[index] >= 100;
        return Icon(
          isComplete ? Icons.favorite : Icons.favorite_border,
          color: isComplete ? Colors.red : AppTheme.onSurfaceVariant,
          size: 16,
        );
      }),
    );
  }

  /// Sıfırlama onay dialogu
  void _confirmReset(BuildContext context, ChallengeProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerHigh,
        title: const Text(
          'Challenge Sıfırla',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Tüm challenge ilerlemeniz silinecek. Emin misiniz?',
          style: TextStyle(
            fontFamily: 'Inter',
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal',
                style: TextStyle(color: AppTheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              provider.resetChallenge();
              Navigator.pop(ctx);
            },
            child: const Text('Sıfırla',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}

/// İstatistik kartı widget'ı
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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
          children: [
            Icon(icon, color: AppTheme.primaryContainer, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppTheme.onSurfaceVariant,
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
