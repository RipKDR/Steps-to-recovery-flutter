import 'package:flutter/material.dart';

import '../../../core/models/database_models.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Morning check-in with overwrite-safe local persistence.
class MorningIntentionScreen extends StatefulWidget {
  const MorningIntentionScreen({super.key});

  @override
  State<MorningIntentionScreen> createState() => _MorningIntentionScreenState();
}

class _MorningIntentionScreenState extends State<MorningIntentionScreen> {
  final _intentionController = TextEditingController();
  int _selectedMood = 3;
  bool _isSaving = false;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadExisting();
  }

  @override
  void dispose() {
    _intentionController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final existing = await DatabaseService().getTodayCheckIn(
      CheckInType.morning,
    );
    if (existing == null || !mounted) {
      return;
    }

    _intentionController.text = existing.intention ?? '';
    _selectedMood = existing.mood?.clamp(1, 5) ?? 3;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await DatabaseService().saveCheckIn(
        DailyCheckIn(
          id: '',
          userId: DatabaseService().activeUserId ?? '',
          checkInType: CheckInType.morning,
          checkInDate: DateTime.now(),
          intention: _intentionController.text.trim(),
          mood: _selectedMood,
          createdAt: DateTime.now(),
          syncStatus: SyncStatus.pending,
        ),
      );

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
            title: const Text('Morning Intention'),
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
                Text('Set the tone', style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Notice your state, name one intention, and keep the rest simple.',
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
                        'How are you feeling this morning?',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _MoodSelector(
                        selectedMood: _selectedMood,
                        onMoodSelected: (mood) =>
                            setState(() => _selectedMood = mood),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'What is your intention for today?',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _intentionController,
                        maxLines: 3,
                        style: AppTypography.bodyMedium,
                        decoration: _fieldDecoration(
                          'Today, I intend to stay present by...',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: Text(_isSaving ? 'Saving...' : 'Save Intention'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    'This saves locally first, then syncs later if you have it enabled.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
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
            label: 'Mood ${_getMoodLabel(mood)}',
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
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryAmber
                            : AppColors.border,
                      ),
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
                    _getMoodLabel(mood),
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

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'Rough';
      case 2:
        return 'Okay';
      case 3:
        return 'Steady';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      default:
        return '';
    }
  }
}
