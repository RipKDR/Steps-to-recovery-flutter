import 'package:flutter/material.dart';

import '../../../core/models/database_models.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Journal editor for encrypted local journal entries.
class JournalEditorScreen extends StatefulWidget {
  const JournalEditorScreen({
    super.key,
    this.entryId,
    this.mode = CreateEditMode.create,
  });

  final String? entryId;
  final CreateEditMode mode;

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

enum CreateEditMode { create, edit }

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _customTagController = TextEditingController();
  final Set<String> _selectedTags = <String>{};
  bool _isFavorite = false;
  bool _saving = false;
  JournalEntry? _existingEntry;
  late final Future<void> _loadFuture;

  static const List<String> _suggestedTags = <String>[
    'Gratitude',
    'Reflection',
    'Step Work',
    'Meeting',
    'Craving',
  ];

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadExisting();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    if (widget.mode != CreateEditMode.edit || widget.entryId == null) {
      return;
    }

    final entry = await DatabaseService().getJournalEntryById(widget.entryId!);
    if (entry == null || !mounted) {
      return;
    }

    _existingEntry = entry;
    _titleController.text = entry.title;
    _contentController.text = entry.content;
    _isFavorite = entry.isFavorite;
    _selectedTags
      ..clear()
      ..addAll(entry.tags);
  }

  Future<void> _saveEntry() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and entry text are required.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await DatabaseService().saveJournalEntry(
        JournalEntry(
          id: _existingEntry?.id ?? '',
          userId: DatabaseService().activeUserId ?? '',
          title: title,
          content: content,
          tags: _selectedTags.toList()..sort(),
          isFavorite: _isFavorite,
          syncStatus: SyncStatus.pending,
          createdAt: _existingEntry?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _addCustomTag() {
    final tag = _customTagController.text.trim();
    if (tag.isEmpty) {
      return;
    }

    setState(() {
      _selectedTags.add(tag);
      _customTagController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mode == CreateEditMode.edit;

    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(isEdit ? 'Edit Entry' : 'New Entry'),
            backgroundColor: AppColors.background,
            actions: [
              IconButton(
                tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
                icon: Icon(_isFavorite ? Icons.star : Icons.star_border),
                onPressed: () => setState(() => _isFavorite = !_isFavorite),
              ),
              IconButton(
                tooltip: 'Save entry',
                icon: const Icon(Icons.save),
                onPressed: _saving ? null : _saveEntry,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: AppSpacing.iconSm,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _formatDate(_existingEntry?.updatedAt ?? DateTime.now()),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: _contentController,
                  style: AppTypography.bodyMedium,
                  decoration: const InputDecoration(
                    hintText: 'Write your thoughts...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: null,
                  minLines: 12,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Tags', style: AppTypography.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _suggestedTags
                      .map(
                        (tag) => _TagChip(
                          label: tag,
                          isSelected: _selectedTags.contains(tag),
                          onTap: () {
                            setState(() {
                              if (!_selectedTags.remove(tag)) {
                                _selectedTags.add(tag);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                if (_selectedTags.difference(_suggestedTags.toSet()).isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _selectedTags
                        .difference(_suggestedTags.toSet())
                        .map(
                          (tag) => _TagChip(
                            label: tag,
                            isSelected: true,
                            onTap: () => setState(() => _selectedTags.remove(tag)),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customTagController,
                        decoration: const InputDecoration(
                          hintText: 'Add custom tag',
                        ),
                        onSubmitted: (_) => _addCustomTag(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: _addCustomTag,
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: ElevatedButton(
              onPressed: _saving ? null : _saveEntry,
              child: Text(_saving ? 'Saving...' : 'Save'),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label, ${isSelected ? 'selected' : 'not selected'}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryAmber.withValues(alpha: 0.2)
                : AppColors.surfaceInteractive,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(
              color: isSelected ? AppColors.primaryAmber : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isSelected ? AppColors.primaryAmber : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
