import 'package:flutter/material.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_utils.dart';
import '../../../widgets/app_form_field.dart';
import '../../../widgets/loading_state.dart';

/// Inventory screen - Step 10 daily inventory with persistence
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _resentfulController = TextEditingController();
  final _selfishController = TextEditingController();
  final _dishonestController = TextEditingController();
  final _afraidController = TextEditingController();
  final _harmedController = TextEditingController();
  final _kindController = TextEditingController();
  final _reflectionController = TextEditingController();

  // Yes/No questions
  bool? _wasResentful;
  bool? _wasSelfish;
  bool? _wasDishonest;
  bool? _wasAfraid;
  bool? _harmedAnyone;
  bool? _showedKindness;

  // Mood and craving
  int? _moodRating;
  int? _cravingLevel;

  bool _isLoading = true;
  bool _isSaving = false;
  DailyInventory? _existingInventory;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  @override
  void dispose() {
    _resentfulController.dispose();
    _selfishController.dispose();
    _dishonestController.dispose();
    _afraidController.dispose();
    _harmedController.dispose();
    _kindController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);
    try {
      final userId = AppStateService.instance.currentUserId;
      final database = DatabaseService();
      final inventory = await database.getTodayInventory(userId: userId);
      
      if (mounted) {
        if (inventory != null) {
          _existingInventory = inventory;
          _resentfulController.text = inventory.resentfulAbout ?? '';
          _selfishController.text = inventory.selfishAbout ?? '';
          _dishonestController.text = inventory.dishonestAbout ?? '';
          _afraidController.text = inventory.afraidOf ?? '';
          _harmedController.text = inventory.harmedWho ?? '';
          _kindController.text = inventory.kindAndLoving ?? '';
          _reflectionController.text = inventory.reflection ?? '';
          _wasResentful = inventory.wasResentful;
          _wasSelfish = inventory.wasSelfish;
          _wasDishonest = inventory.wasDishonest;
          _wasAfraid = inventory.wasAfraid;
          _harmedAnyone = inventory.harmedAnyone;
          _showedKindness = inventory.showedKindness;
          _moodRating = inventory.moodRating;
          _cravingLevel = inventory.cravingLevel;
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load inventory: $e')),
        );
      }
    }
  }

  Future<void> _saveInventory() async {
    setState(() => _isSaving = true);
    try {
      final userId = AppStateService.instance.currentUserId;
      if (userId == null) {
        throw StateError('No user logged in');
      }

      final database = DatabaseService();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final inventory = DailyInventory(
        id: _existingInventory?.id ?? '',
        userId: userId,
        inventoryDate: today,
        resentfulAbout: _resentfulController.text.trim(),
        selfishAbout: _selfishController.text.trim(),
        dishonestAbout: _dishonestController.text.trim(),
        afraidOf: _afraidController.text.trim(),
        harmedWho: _harmedController.text.trim(),
        kindAndLoving: _kindController.text.trim(),
        wasResentful: _wasResentful,
        wasSelfish: _wasSelfish,
        wasDishonest: _wasDishonest,
        wasAfraid: _wasAfraid,
        harmedAnyone: _harmedAnyone,
        showedKindness: _showedKindness,
        reflection: _reflectionController.text.trim(),
        moodRating: _moodRating,
        cravingLevel: _cravingLevel,
        createdAt: _existingInventory?.createdAt ?? now,
        updatedAt: now,
      );

      await database.saveInventory(inventory);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inventory saved! ✓'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Inventory'),
        backgroundColor: AppColors.background,
        actions: [
          if (!_isLoading)
            Semantics(
              label: 'Save inventory',
              button: true,
              child: IconButton(
                icon: _isSaving
                    ? const SizedBox(
                        width: AppSpacing.iconMd,
                        height: AppSpacing.iconMd,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                onPressed: _isSaving ? null : _saveInventory,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const LoadingState(message: 'Loading inventory...')
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: AppSpacing.iconSm,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            AppUtils.formatDate(DateTime.now()),
                            style: AppTypography.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Section 1: Quick check-in
                    Text('Quick Check-in', style: AppTypography.headlineSmall),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Briefly note where these showed up today',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    AppFormField(
                      label: 'Today I was resentful about:',
                      controller: _resentfulController,
                      maxLines: 2,
                      hintText: 'Who or what made you resentful?',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppFormField(
                      label: 'Today I was selfish about:',
                      controller: _selfishController,
                      maxLines: 2,
                      hintText: 'Where were you self-centered?',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppFormField(
                      label: 'Today I was dishonest about:',
                      controller: _dishonestController,
                      maxLines: 2,
                      hintText: 'Where were you dishonest?',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppFormField(
                      label: 'Today I was afraid of:',
                      controller: _afraidController,
                      maxLines: 2,
                      hintText: 'What fears came up today?',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppFormField(
                      label: 'Today I harmed:',
                      controller: _harmedController,
                      maxLines: 2,
                      hintText: 'Did you harm anyone? How?',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppFormField(
                      label: 'Today I was kind and loving:',
                      controller: _kindController,
                      maxLines: 2,
                      hintText: 'Where did you show kindness?',
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Section 2: Yes/No questions
                    Text('Step 10 Questions', style: AppTypography.headlineSmall),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Answer honestly - this is for you',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    _YesNoQuestion(
                      question: 'Was I resentful today?',
                      value: _wasResentful,
                      onChanged: (v) => setState(() => _wasResentful = v),
                    ),
                    _YesNoQuestion(
                      question: 'Was I selfish today?',
                      value: _wasSelfish,
                      onChanged: (v) => setState(() => _wasSelfish = v),
                    ),
                    _YesNoQuestion(
                      question: 'Was I dishonest today?',
                      value: _wasDishonest,
                      onChanged: (v) => setState(() => _wasDishonest = v),
                    ),
                    _YesNoQuestion(
                      question: 'Was I afraid today?',
                      value: _wasAfraid,
                      onChanged: (v) => setState(() => _wasAfraid = v),
                    ),
                    _YesNoQuestion(
                      question: 'Did I harm anyone today?',
                      value: _harmedAnyone,
                      onChanged: (v) => setState(() => _harmedAnyone = v),
                    ),
                    _YesNoQuestion(
                      question: 'Did I show kindness today?',
                      value: _showedKindness,
                      onChanged: (v) => setState(() => _showedKindness = v),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Section 3: Mood and craving
                    Text('How are you doing?', style: AppTypography.headlineSmall),
                    const SizedBox(height: AppSpacing.lg),

                    _MoodRating(
                      value: _moodRating,
                      onChanged: (v) => setState(() => _moodRating = v),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _CravingLevel(
                      value: _cravingLevel,
                      onChanged: (v) => setState(() => _cravingLevel = v),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveInventory,
                        child: Text(_isSaving ? 'Saving...' : 'Save Inventory'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
      ),
    );
  }
}

class _YesNoQuestion extends StatelessWidget {
  final String question;
  final bool? value;
  final ValueChanged<bool?> onChanged;

  const _YesNoQuestion({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: value == true ? null : () => onChanged(true),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: value == true ? AppColors.success : null,
                      foregroundColor: value == true ? AppColors.textOnDark : null,
                      side: BorderSide(
                        color: value == true ? AppColors.success : AppColors.border,
                      ),
                    ),
                    child: const Text('Yes'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton(
                    onPressed: value == false ? null : () => onChanged(false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: value == false ? AppColors.textMuted : null,
                      foregroundColor: value == false ? AppColors.textOnDark : null,
                      side: BorderSide(
                        color: value == false ? AppColors.textMuted : AppColors.border,
                      ),
                    ),
                    child: const Text('No'),
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

class _MoodRating extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const _MoodRating({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mood Rating (1-5)', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final rating = index + 1;
                final isSelected = value == rating;
                return GestureDetector(
                  onTap: () => onChanged(isSelected ? null : rating),
                  child: Container(
                    width: AppSpacing.xl,
                    height: AppSpacing.xl,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryAmber : AppColors.surfaceCard,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryAmber : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$rating',
                        style: AppTypography.titleMedium.copyWith(
                          color: isSelected ? AppColors.textOnDark : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Low', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                Text('High', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CravingLevel extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const _CravingLevel({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Craving Level (0-10)', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Slider(
              value: (value ?? 0).toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: value?.toString() ?? 'None',
              onChanged: (v) => onChanged(v.toInt()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('None', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                Text('Urgent', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
