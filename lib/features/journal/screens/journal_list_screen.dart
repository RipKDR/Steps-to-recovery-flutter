import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Journal List screen - Browse and search journal entries
class JournalListScreen extends StatelessWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(label: 'All', isSelected: true),
                      const SizedBox(width: AppSpacing.sm),
                      _FilterChip(label: 'Favorites', isSelected: false),
                      const SizedBox(width: AppSpacing.sm),
                      _FilterChip(label: 'This Week', isSelected: false),
                      const SizedBox(width: AppSpacing.sm),
                      _FilterChip(label: 'This Month', isSelected: false),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Empty state or entries list
                _EmptyJournalState(onCreateEntry: () {
                  // Navigate to editor
                }),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to editor
        },
        backgroundColor: AppColors.primaryAmber,
        foregroundColor: AppColors.textOnDark,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryAmber
            : AppColors.surfaceInteractive,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: isSelected
              ? AppColors.textOnDark
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _EmptyJournalState extends StatelessWidget {
  final VoidCallback onCreateEntry;

  const _EmptyJournalState({required this.onCreateEntry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note,
            size: AppSpacing.sext,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No journal entries yet',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start writing your thoughts and reflections',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: onCreateEntry,
            icon: const Icon(Icons.add),
            label: const Text('Create Entry'),
          ),
        ],
      ),
    );
  }
}
