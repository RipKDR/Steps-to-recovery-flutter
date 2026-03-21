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
    final existing = await DatabaseService().getTodayCheckIn(CheckInType.morning);
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
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How are you feeling this morning?',
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                _MoodSelector(
                  selectedMood: _selectedMood,
                  onMoodSelected: (mood) => setState(() => _selectedMood = mood),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'What is your intention for today?',
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _intentionController,
                  maxLines: 5,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Today, I intend to stay present by...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'This saves locally and updates your progress immediately, even offline.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: Text(_isSaving ? 'Saving...' : 'Save Intention'),
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

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({
    required this.selectedMood,
    required this.onMoodSelected,
  });

  final int selectedMood;
  final ValueChanged<int> onMoodSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List<Widget>.generate(5, (index) {
        final mood = index + 1;
        final isSelected = selectedMood == mood;

        return GestureDetector(
          onTap: () => onMoodSelected(mood),
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
                    color: isSelected ? AppColors.primaryAmber : AppColors.border,
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
              ),
            ],
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
