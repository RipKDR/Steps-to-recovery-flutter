import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/recovery_content.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_utils.dart';

/// Daily Reading screen
class DailyReadingScreen extends StatefulWidget {
  const DailyReadingScreen({super.key});

  @override
  State<DailyReadingScreen> createState() => _DailyReadingScreenState();
}

class _DailyReadingScreenState extends State<DailyReadingScreen> {
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());

  void _previousDay() {
    setState(() {
      _selectedDate = DateUtils.dateOnly(
        _selectedDate.subtract(const Duration(days: 1)),
      );
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDate = DateUtils.dateOnly(
        _selectedDate.add(const Duration(days: 1)),
      );
    });
  }

  void _jumpToToday() {
    setState(() {
      _selectedDate = DateUtils.dateOnly(DateTime.now());
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = DateUtils.dateOnly(picked);
      });
    }
  }

  void _showLibraryReading(ReadingContent reading) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reading.title, style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  reading.source,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primaryAmber,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  reading.content,
                  style: AppTypography.bodyMedium.copyWith(height: 1.7),
                ),
                const SizedBox(height: AppSpacing.xl),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reading = readingForDate(_selectedDate);
    final common = commonReadings.where((item) => item.isCommonlyRead).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Reading'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            tooltip: 'Choose date',
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.primaryAmber,
                    size: AppSpacing.iconMd,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    AppUtils.formatDate(_selectedDate),
                    style: AppTypography.titleMedium,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _jumpToToday,
                    child: const Text('Today'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            // Reading title
            Text(reading.title, style: AppTypography.displaySmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Source: ${reading.source.toUpperCase()}',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primaryAmber,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Reading content
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reading.content,
                    style: AppTypography.bodyLarge.copyWith(
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            // Reflection prompt
            Text(
              'Reflection',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceInteractive,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Text(
                reading.reflectionPrompt,
                style: AppTypography.bodyMedium.copyWith(
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/journal/editor?mode=create');
                },
                icon: const Icon(Icons.edit),
                label: const Text('Write reflection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAmber,
                  foregroundColor: AppColors.textOnDark,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            Text(
              'Recovery Library',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 118,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: common.length,
                separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final item = common[index];
                  return SizedBox(
                    width: 220,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      onTap: () => _showLibraryReading(item),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.title,
                              style: AppTypography.titleMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item.category,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primaryAmber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previousDay,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _nextDay,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Next'),
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
