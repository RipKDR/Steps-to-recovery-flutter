// lib/features/ai_companion/screens/memory_transparency_screen.dart
import 'package:flutter/material.dart';
import '../../../core/models/sponsor_models.dart';
import '../../../core/services/sponsor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class MemoryTransparencyScreen extends StatefulWidget {
  const MemoryTransparencyScreen({
    super.key,
    required this.sponsorName,
    SponsorService? sponsorService,
  }) : _service = sponsorService;

  final String sponsorName;
  final SponsorService? _service;

  @override
  State<MemoryTransparencyScreen> createState() =>
      _MemoryTransparencyScreenState();
}

class _MemoryTransparencyScreenState extends State<MemoryTransparencyScreen> {
  SponsorService get _service => widget._service ?? SponsorService.instance;

  static const _categoryLabels = {
    MemoryCategory.lifeContext: 'Life Context',
    MemoryCategory.recoveryPattern: 'Recovery Patterns',
    MemoryCategory.whatWorks: 'What Works For You',
    MemoryCategory.keyRelationship: 'Key Relationships',
    MemoryCategory.hardMoment: 'Hard Moments',
  };

  Future<void> _delete(String id) async {
    await _service.deleteMemory(id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final memories = _service.longTermMemory;

    // Group by category
    final grouped = <MemoryCategory, List<SponsorMemory>>{};
    for (final m in memories) {
      grouped.putIfAbsent(m.category, () => []).add(m);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.textSecondary),
        title: Text(widget.sponsorName, style: AppTypography.labelLarge),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What ${widget.sponsorName} knows\nabout you.',
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'You control this. Delete anything, anytime.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          if (memories.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Center(
                child: Text(
                  '${widget.sponsorName} is still learning.\nCome back after a few conversations.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else ...[
            ...MemoryCategory.values
                .where((c) => grouped.containsKey(c))
                .map(
                  (category) => _CategorySection(
                    label: _categoryLabels[category]!,
                    memories: grouped[category]!,
                    onDelete: _delete,
                  ),
                ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.label,
    required this.memories,
    required this.onDelete,
  });

  final String label;
  final List<SponsorMemory> memories;
  final Future<void> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.xl,
      AppSpacing.lg,
      AppSpacing.xl,
      0,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...memories.map((m) => _MemoryCard(memory: m, onDelete: onDelete)),
      ],
    ),
  );
}

class _MemoryCard extends StatefulWidget {
  const _MemoryCard({required this.memory, required this.onDelete});
  final SponsorMemory memory;
  final Future<void> Function(String id) onDelete;

  @override
  State<_MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<_MemoryCard> {
  bool _hiding = false;

  Future<void> _handleDelete() async {
    if (!mounted) return;
    // Trigger the fade-out animation first.
    setState(() => _hiding = true);
    // Then delete — the parent will rebuild and remove this card.
    // The AnimatedOpacity plays while the async delete completes.
    await widget.onDelete(widget.memory.id);
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: _hiding ? 0.0 : 1.0,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeIn,
    child: AnimatedSlide(
      offset: _hiding ? const Offset(0.3, 0) : Offset.zero,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.memory.summary,
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Learned ${_formatDate(widget.memory.createdAt)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: Colors.red.withValues(alpha: 0.5),
              onPressed: _handleDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    ),
  );

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    return 'Mar ${date.day}';
  }
}
