import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/database_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Mood trend line chart widget
class MoodTrendChart extends StatelessWidget {
  final List<DailyCheckIn> checkIns;

  const MoodTrendChart({super.key, required this.checkIns});

  @override
  Widget build(BuildContext context) {
    final moodData = checkIns
        .where((checkIn) => checkIn.mood != null)
        .toList()
      ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));

    if (moodData.length < 2) {
      return _buildEmptyState('Not enough mood data yet');
    }

    // Take last 30 days of data
    final recentData = moodData.length > 30 ? moodData.sublist(moodData.length - 30) : moodData;

    final spots = <FlSpot>[];
    for (int i = 0; i < recentData.length; i++) {
      final checkIn = recentData[i];
      spots.add(FlSpot(i.toDouble(), checkIn.mood!.toDouble()));
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mood Trend (30 Days)', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() == 0) {
                          return const Text('30d ago');
                        }
                        if (value.toInt() == recentData.length - 1) {
                          return const Text('Today');
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (recentData.length - 1).toDouble(),
                minY: 0,
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primaryAmber,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primaryAmber,
                          strokeWidth: 2,
                          strokeColor: AppColors.background,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primaryAmber.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Scale: 1-5', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
              Text(
                'Avg: ${_calculateAverage(recentData.map((e) => e.mood!).toList()).toStringAsFixed(1)}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateAverage(List<int> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.mood_outline, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

/// Craving trend line chart widget
class CravingTrendChart extends StatelessWidget {
  final List<DailyCheckIn> checkIns;

  const CravingTrendChart({super.key, required this.checkIns});

  @override
  Widget build(BuildContext context) {
    final cravingData = checkIns
        .where((checkIn) => checkIn.craving != null)
        .toList()
      ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));

    if (cravingData.length < 2) {
      return _buildEmptyState('Not enough craving data yet');
    }

    // Take last 30 days of data
    final recentData = cravingData.length > 30 ? cravingData.sublist(cravingData.length - 30) : cravingData;

    final spots = <FlSpot>[];
    for (int i = 0; i < recentData.length; i++) {
      final checkIn = recentData[i];
      spots.add(FlSpot(i.toDouble(), checkIn.craving!.toDouble()));
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Craving Intensity (30 Days)', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 2,
                  verticalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() == 0) {
                          return const Text('30d ago');
                        }
                        if (value.toInt() == recentData.length - 1) {
                          return const Text('Today');
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (recentData.length - 1).toDouble(),
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.info,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.info,
                          strokeWidth: 2,
                          strokeColor: AppColors.background,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.info.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Scale: 0-10', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
              Text(
                'Avg: ${_calculateAverage(recentData.map((e) => e.craving!).toList()).toStringAsFixed(1)}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateAverage(List<int> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.water_drop_outline, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

/// Weekly heatmap showing check-in consistency
class CheckInHeatmap extends StatelessWidget {
  final List<DailyCheckIn> checkIns;

  const CheckInHeatmap({super.key, required this.checkIns});

  @override
  Widget build(BuildContext context) {
    // Build a map of date -> check-in count
    final checkInMap = <DateTime, int>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Go back 6 weeks (42 days)
    for (var i = 41; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final count = checkIns.where((checkIn) {
        final checkInDate = DateTime(checkIn.checkInDate.year, checkIn.checkInDate.month, checkIn.checkInDate.day);
        return checkInDate == date;
      }).length;
      checkInMap[date] = count;
    }

    final weeks = <List<DateTime>>[];
    var currentWeek = <DateTime>[];

    // Start from the first Monday
    var startDate = today.subtract(const Duration(days: 41));
    while (startDate.weekday != DateTime.monday) {
      startDate = startDate.add(const Duration(days: 1));
    }

    for (var i = 0; i < 42; i++) {
      final date = startDate.add(Duration(days: i));
      currentWeek.add(date);
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Check-in Consistency', style: AppTypography.titleMedium),
              Text('6 Weeks', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day labels
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildDayLabel('Mon'),
                  const SizedBox(height: 4),
                  _buildDayLabel('Wed'),
                  const SizedBox(height: 4),
                  _buildDayLabel('Fri'),
                  const SizedBox(height: 4),
                  _buildDayLabel('Sun'),
                ],
              ),
              const SizedBox(width: AppSpacing.sm),
              // Heatmap grid
              Column(
                children: weeks.map((week) {
                  return Row(
                    children: week.map((date) {
                      final count = checkInMap[date] ?? 0;
                      final color = _getColorForCount(count);
                      return Container(
                        margin: const EdgeInsets.all(2),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
              const SizedBox(width: AppSpacing.xs),
              _buildLegendBox(AppColors.border),
              const SizedBox(width: AppSpacing.xs),
              _buildLegendBox(AppColors.success.withValues(alpha: 0.3)),
              const SizedBox(width: AppSpacing.xs),
              _buildLegendBox(AppColors.success.withValues(alpha: 0.6)),
              const SizedBox(width: AppSpacing.xs),
              _buildLegendBox(AppColors.success),
              const SizedBox(width: AppSpacing.xs),
              Text('More', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabel(String text) {
    return SizedBox(
      height: 16,
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Color _getColorForCount(int count) {
    if (count == 0) return AppColors.border;
    if (count == 1) return AppColors.success.withValues(alpha: 0.3);
    if (count == 2) return AppColors.success.withValues(alpha: 0.6);
    return AppColors.success;
  }
}

/// Step progress radial chart
class StepProgressChart extends StatelessWidget {
  final List<StepProgress> stepProgress;

  const StepProgressChart({super.key, required this.stepProgress});

  @override
  Widget build(BuildContext context) {
    final completedSteps = stepProgress.where((s) => s.status == StepStatus.completed).length;
    final inProgressSteps = stepProgress.where((s) => s.status == StepStatus.inProgress).length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step Progress', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRadialIndicator(
                label: 'Completed',
                value: completedSteps.toDouble(),
                maxValue: 12,
                color: AppColors.success,
                icon: Icons.check_circle,
              ),
              _buildRadialIndicator(
                label: 'In Progress',
                value: inProgressSteps.toDouble(),
                maxValue: 12,
                color: AppColors.primaryAmber,
                icon: Icons.trending_up,
              ),
              _buildRadialIndicator(
                label: 'Not Started',
                value: (12 - completedSteps - inProgressSteps).toDouble(),
                maxValue: 12,
                color: AppColors.textMuted,
                icon: Icons.circle_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Step-by-step progress bars
          ...stepProgress.map((step) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text('Step ${step.stepNumber}', style: AppTypography.bodySmall),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: LinearProgressIndicator(
                        value: step.completionPercentage,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          step.status == StepStatus.completed
                              ? AppColors.success
                              : step.status == StepStatus.inProgress
                                  ? AppColors.primaryAmber
                                  : AppColors.border,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${(step.completionPercentage * 100).toInt()}%',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRadialIndicator({
    required String label,
    required double value,
    required double maxValue,
    required Color color,
    required IconData icon,
  }) {
    final percentage = value / maxValue;

    return Column(
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: 8,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
        Text(
          value.toInt().toString(),
          style: AppTypography.titleMedium.copyWith(color: color),
        ),
      ],
    );
  }
}
