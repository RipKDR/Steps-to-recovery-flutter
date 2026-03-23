import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/empty_state.dart';

/// Gratitude screen - Gratitude journal
class GratitudeScreen extends StatefulWidget {
  const GratitudeScreen({super.key});

  @override
  State<GratitudeScreen> createState() => _GratitudeScreenState();
}

class _GratitudeScreenState extends State<GratitudeScreen> {
  final _entryController = TextEditingController();
  final List<String> _entries = [];

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gratitude'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Column(
        children: [
          // Input area
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
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
                    style: AppTypography.bodyMedium,
                    decoration: const InputDecoration(
                      hintText: 'I am grateful for...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Semantics(
                  label: 'Add gratitude entry',
                  button: true,
                  child: IconButton(
                    icon: const Icon(Icons.add_circle),
                    color: AppColors.primaryAmber,
                    iconSize: AppSpacing.iconLg,
                    onPressed: _addEntry,
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
                      return _GratitudeEntry(
                        entry: _entries[index],
                        onDelete: () {
                          setState(() {
                            _entries.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      ),
    );
  }

  void _addEntry() {
    if (_entryController.text.isNotEmpty) {
      setState(() {
        _entries.insert(0, _entryController.text);
        _entryController.clear();
      });
    }
  }
}

class _GratitudeEntry extends StatelessWidget {
  final String entry;
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
              child: Text(
                entry,
                style: AppTypography.bodyMedium,
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
}
