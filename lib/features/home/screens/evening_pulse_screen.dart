import 'package:flutter/material.dart';

import '../../../core/models/database_models.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Evening check-in with gratitude capture and craving tracking.
class EveningPulseScreen extends StatefulWidget {
  const EveningPulseScreen({super.key});

  @override
  State<EveningPulseScreen> createState() => _EveningPulseScreenState();
}

class _EveningPulseScreenState extends State<EveningPulseScreen> {
  final _reflectionController = TextEditingController();
  final _gratitudeController = TextEditingController();
  int _selectedMood = 3;
  int _selectedCraving = 0;
  bool _isSaving = false;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadExisting();
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    _gratitudeController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final existing = await DatabaseService().getTodayCheckIn(
      CheckInType.evening,
    );
    if (existing != null && mounted) {
      _reflectionController.text = existing.reflection ?? '';
      _selectedMood = existing.mood?.clamp(1, 5) ?? 3;
      _selectedCraving = existing.craving?.clamp(0, 10) ?? 0;
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await DatabaseService().saveCheckIn(
        DailyCheckIn(
          id: '',
          userId: DatabaseService().activeUserId ?? '',
          checkInType: CheckInType.evening,
          checkInDate: DateTime.now(),
          reflection: _reflectionController.text.trim(),
          mood: _selectedMood,
          craving: _selectedCraving,
          createdAt: DateTime.now(),
          syncStatus: SyncStatus.pending,
        ),
      );

      final gratitude = _gratitudeController.text.trim();
      if (gratitude.isNotEmpty) {
        await DatabaseService().saveGratitudeEntry(
          GratitudeEntry(
            id: '',
            userId: DatabaseService().activeUserId ?? '',
            content: gratitude,
            createdAt: DateTime.now(),
          ),
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Evening Pulse'),
            backgroundColor: AppColors.background,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wind down', style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Keep the first pass simple: mood, craving, then any extra reflection.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How was your day?',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _MoodSelector(
                        selectedMood: _selectedMood,
                        onMoodSelected: (mood) =>
                            setState(() => _selectedMood = mood),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Craving level', style: AppTypography.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      _CravingSlider(
                        value: _selectedCraving,
                        onChanged: (value) =>
                            setState(() => _selectedCraving = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: Text(_isSaving ? 'Saving...' : 'Save Reflection'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Optional reflection',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Use this space only if you want to capture gratitude or the shape of the day.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'What are you grateful for today?',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _gratitudeController,
                        maxLines: 2,
                        style: AppTypography.bodyMedium,
                        decoration: _fieldDecoration('I am grateful for...'),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Reflection on the day',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _reflectionController,
                        maxLines: 5,
                        style: AppTypography.bodyMedium,
                        decoration: _fieldDecoration(
                          'What helped? What needs support tomorrow?',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

InputDecoration _fieldDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
    filled: true,
    fillColor: AppColors.surfaceElevated,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusStandard),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusStandard),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusStandard),
      borderSide: const BorderSide(color: AppColors.primaryAmber),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: child,
    );
  }
}

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({
    required this.selectedMood,
    required this.onMoodSelected,
  });

  final int selectedMood;
  final ValueChanged<int> onMoodSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List<Widget>.generate(5, (index) {
        final mood = index + 1;
        final isSelected = selectedMood == mood;

        return SizedBox(
          width: 56,
          child: Semantics(
            button: true,
            label: 'Mood $mood',
            selected: isSelected,
            child: InkWell(
              onTap: () => onMoodSelected(mood),
              customBorder: const CircleBorder(),
              child: Column(
                children: [
                  Container(
                    width: AppSpacing.quint,
                    height: AppSpacing.quint,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryAmber
                          : AppColors.surfaceInteractive,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getMoodIcon(mood),
                      color: isSelected
                          ? AppColors.textOnDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$mood',
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected
                          ? AppColors.primaryAmber
                          : AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  IconData _getMoodIcon(int mood) {
    switch (mood) {
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied;
      case 5:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}

class _CravingSlider extends StatelessWidget {
  const _CravingSlider({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'None',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            Text(
              '$value',
              style: AppTypography.headlineMedium.copyWith(
                color: value > 7
                    ? AppColors.danger
                    : value > 4
                    ? AppColors.warning
                    : AppColors.success,
              ),
            ),
            Text(
              'Severe',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: AppColors.primaryAmber,
          onChanged: (nextValue) => onChanged(nextValue.round()),
        ),
      ],
    );
  }
}
