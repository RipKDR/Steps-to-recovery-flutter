import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Journal Editor screen - Create or edit journal entries
class JournalEditorScreen extends StatefulWidget {
  final String? entryId;
  final CreateEditMode mode;

  const JournalEditorScreen({
    super.key,
    this.entryId,
    this.mode = CreateEditMode.create,
  });

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

enum CreateEditMode { create, edit }

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isFavorite = false;
  List<String> _tags = [];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mode == CreateEditMode.edit;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Entry' : 'New Entry'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            TextField(
              controller: _titleController,
              style: AppTypography.headlineMedium,
              decoration: const InputDecoration(
                hintText: 'Entry title',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: AppSpacing.iconSm,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _formatDate(DateTime.now()),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Content field
            TextField(
              controller: _contentController,
              style: AppTypography.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'Write your thoughts...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: null,
              minLines: 10,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Tags
            Text(
              'Tags',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _TagChip(label: 'Gratitude', isSelected: false),
                _TagChip(label: 'Reflection', isSelected: false),
                _TagChip(label: 'Step Work', isSelected: false),
                _TagChip(label: 'Meeting', isSelected: false),
                _AddTagChip(),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Add attachment
                },
                icon: const Icon(Icons.attach_file),
                label: const Text('Attach'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveEntry,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveEntry() {
    // Save entry logic
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _TagChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryAmber.withOpacity(0.2)
            : AppColors.surfaceInteractive,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryAmber
              : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: isSelected
              ? AppColors.primaryAmber
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _AddTagChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Add new tag
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: AppSpacing.iconXs,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Add tag',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
