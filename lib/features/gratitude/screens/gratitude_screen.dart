import 'package:flutter/material.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/animated_list_item.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_state.dart';

/// Gratitude screen - Gratitude journal with persistence and streak tracking
class GratitudeScreen extends StatefulWidget {
  const GratitudeScreen({super.key});

  @override
  State<GratitudeScreen> createState() => _GratitudeScreenState();
}

class _GratitudeScreenState extends State<GratitudeScreen> {
  final _entryController = TextEditingController();
  final _focusNode = FocusNode();
  List<GratitudeEntry> _entries = [];
  int _streak = 0;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    try {
      final userId = AppStateService.instance.currentUserId;
      final database = DatabaseService();
      final entries = await database.getGratitudeEntries(userId: userId);
      final streak = await database.getGratitudeStreak(userId: userId);
      if (mounted) {
        setState(() {
          _entries = entries;
          _streak = streak;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load entries: $e')),
        );
      }
    }
  }

  Future<void> _addEntry() async {
    final content = _entryController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final userId = AppStateService.instance.currentUserId;
      if (userId == null) {
        throw StateError('No user logged in');
      }

      final database = DatabaseService();
      final entry = GratitudeEntry(
        id: '',
        userId: userId,
        content: content,
        createdAt: DateTime.now(),
      );

      await database.saveGratitudeEntry(entry);
      
      if (mounted) {
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gratitude saved! 🙏'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Reload entries and streak
        await _loadEntries();
        _entryController.clear();
        _focusNode.requestFocus();
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

  Future<void> _deleteEntry(String id) async {
    try {
      final database = DatabaseService();
      await database.deleteGratitudeEntry(id);
      if (mounted) {
        await _loadEntries();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gratitude'),
        backgroundColor: AppColors.background,
        actions: [
          if (_streak > 0)
            Container(
              margin: const EdgeInsets.only(right: AppSpacing.md),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryAmber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: AppColors.primaryAmber,
                    size: AppSpacing.iconSm,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '$_streak day${_streak == 1 ? '' : 's'}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primaryAmber,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const LoadingState(message: 'Loading gratitude...')
            : Column(
                children: [
                  // Input area
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _entryController,
                            focusNode: _focusNode,
                            style: AppTypography.bodyMedium,
                            decoration: const InputDecoration(
                              hintText: 'I am grateful for...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            maxLines: 2,
                            onSubmitted: (_) => _addEntry(),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Semantics(
                          label: 'Add gratitude entry',
                          button: true,
                          child: IconButton(
                            icon: _isSaving
                                ? const SizedBox(
                                    width: AppSpacing.iconMd,
                                    height: AppSpacing.iconMd,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.add_circle),
                            color: AppColors.primaryAmber,
                            iconSize: AppSpacing.iconLg,
                            onPressed: _isSaving ? null : _addEntry,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Entries list
                  Expanded(
                    child: _entries.isEmpty
                        ? const EmptyState(
                            icon: Icons.favorite_border,
                            title: 'No gratitude entries yet',
                            message: 'Start by adding something you\'re grateful for',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            itemCount: _entries.length,
                            itemBuilder: (context, index) {
                              return AnimatedListItem(
                                index: index,
                                child: _GratitudeEntry(
                                  entry: _entries[index],
                                  onDelete: () => _deleteEntry(_entries[index].id),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GratitudeEntry extends StatelessWidget {
  final GratitudeEntry entry;
  final VoidCallback onDelete;

  const _GratitudeEntry({
    required this.entry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(
              Icons.favorite,
              color: AppColors.primaryAmber,
              size: AppSpacing.iconMd,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.content,
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatDate(entry.createdAt),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              label: 'Delete gratitude entry',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.delete_outline),
                iconSize: AppSpacing.iconSm,
                color: AppColors.textMuted,
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);
    final diff = today.difference(entryDate).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}
