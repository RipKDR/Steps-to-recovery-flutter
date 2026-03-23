import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_utils.dart';
import '../../../widgets/app_form_field.dart';

/// Inventory screen - Step 10 daily inventory
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

  @override
  void dispose() {
    _resentfulController.dispose();
    _selfishController.dispose();
    _dishonestController.dispose();
    _afraidController.dispose();
    _harmedController.dispose();
    _kindController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Inventory'),
        backgroundColor: AppColors.background,
        actions: [
          Semantics(
            label: 'Save inventory',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveInventory,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
            const SizedBox(height: AppSpacing.xxl),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveInventory,
                child: const Text('Save Inventory'),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _saveInventory() {
    // Save inventory logic
    Navigator.pop(context);
  }
}
