import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Journal list with local filtering and edit navigation.
class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  _JournalFilter _filter = _JournalFilter.all;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<JournalEntry>> _loadEntries() async {
    final entries = await DatabaseService().getJournalEntries(
      isFavorite: _filter == _JournalFilter.favorites ? true : null,
    );
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return entries;
    }
    return entries
        .where(
          (entry) =>
              entry.title.toLowerCase().contains(query) ||
              entry.content.toLowerCase().contains(query) ||
              entry.tags.any((tag) => tag.toLowerCase().contains(query)),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DatabaseService(),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Journal'),
            backgroundColor: AppColors.background,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search titles, content, or tags',
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: _filter == _JournalFilter.all,
                      onTap: () => setState(() => _filter = _JournalFilter.all),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterChip(
                      label: 'Favorites',
                      isSelected: _filter == _JournalFilter.favorites,
                      onTap: () => setState(() => _filter = _JournalFilter.favorites),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: FutureBuilder<List<JournalEntry>>(
                  future: _loadEntries(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryAmber),
                      );
                    }

                    final entries = snapshot.data ?? const <JournalEntry>[];
                    if (entries.isEmpty) {
                      return _EmptyJournalState(
                        onCreateEntry: () => context.push('${AppRoutes.journalEditor}?mode=create'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return _JournalCard(
                          entry: entry,
                          onTap: () {
                            context.push(
                              '${AppRoutes.journalEditor}?mode=edit&entryId=${entry.id}',
                            );
                          },
                          onToggleFavorite: () async {
                            await DatabaseService().saveJournalEntry(
                              entry.copyWith(isFavorite: !entry.isFavorite),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('${AppRoutes.journalEditor}?mode=create'),
            backgroundColor: AppColors.primaryAmber,
            foregroundColor: AppColors.textOnDark,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

enum _JournalFilter { all, favorites }

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAmber : AppColors.surfaceInteractive,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.textOnDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EmptyJournalState extends StatelessWidget {
  const _EmptyJournalState({required this.onCreateEntry});

  final VoidCallback onCreateEntry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_note,
              size: AppSpacing.sext,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'No journal entries yet',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Write a private reflection. Entries are encrypted before they are stored locally.',
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
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({
    required this.entry,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: AppTypography.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      entry.isFavorite ? Icons.star : Icons.star_border,
                      color: entry.isFavorite
                          ? AppColors.primaryAmber
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Text(
                entry.content,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: entry.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceInteractive,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(tag, style: AppTypography.labelSmall),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _formatDate(entry.updatedAt),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}
