// lib/features/ai_companion/screens/memory_transparency_screen.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../core/models/database_models.dart';
import '../../../core/models/sponsor_models.dart';
import '../../../core/services/database_service.dart';
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

  late final Future<List<String>> _patternsFuture;

  @override
  void initState() {
    super.initState();
    _patternsFuture = _loadPatterns();
  }

  Future<void> _delete(String id) async {
    await _service.deleteMemory(id);
    if (mounted) setState(() {});
  }

  Future<List<String>> _loadPatterns() async {
    try {
      final db = DatabaseService();
      final checkIns = await db.getCheckIns(limit: 28);
      if (checkIns.length < 7) return [];

      final patterns = <String>[];
      final name = widget.sponsorName;

      // Hardest day bucket
      final dayBuckets = <int, List<int>>{};
      for (final c in checkIns) {
        if (c.craving == null) continue;
        final weekday = c.checkInDate.weekday;
        dayBuckets.putIfAbsent(weekday, () => []).add(c.craving!);
      }
      if (dayBuckets.isNotEmpty) {
        final hardestDay = dayBuckets.entries
            .map((e) => MapEntry(e.key, e.value.fold(0, (a, b) => a + b) / e.value.length))
            .reduce((a, b) => a.value > b.value ? a : b);
        const days = ['', 'Mondays', 'Tuesdays', 'Wednesdays', 'Thursdays', 'Fridays', 'Saturdays', 'Sundays'];
        if (hardestDay.value > 4) {
          patterns.add('$name has noticed that ${days[hardestDay.key]} tend to be harder for you.');
        }
      }

      // Mood-craving correlation
      final paired = checkIns
          .where((c) => c.mood != null && c.craving != null)
          .toList();
      if (paired.length >= 6) {
        final correlation = _moodCravingCorrelation(paired);
        if (correlation < -0.4) {
          patterns.add('When your mood drops, your cravings tend to rise. $name has seen this pattern.');
        }
      }

      // Streak observation
      final streak = checkIns.isNotEmpty
          ? _computeStreakFromCheckIns(checkIns)
          : 0;
      if (streak >= 7) {
        patterns.add('You\'ve checked in $streak days in a row. $name doesn\'t take that lightly.');
      }

      return patterns;
    } catch (_) {
      return [];
    }
  }

  double _moodCravingCorrelation(List<DailyCheckIn> checkIns) {
    final n = checkIns.length.toDouble();
    // Filter out nulls and extract values - these are guaranteed non-null from caller
    final moods = checkIns.map((c) => (c.mood ?? 0).toDouble()).toList();
    final cravings = checkIns.map((c) => (c.craving ?? 0).toDouble()).toList();
    final avgMood = moods.fold(0.0, (a, b) => a + b) / n;
    final avgCraving = cravings.fold(0.0, (a, b) => a + b) / n;
    double num = 0, denMood = 0, denCraving = 0;
    for (var i = 0; i < checkIns.length; i++) {
      final dm = moods[i] - avgMood;
      final dc = cravings[i] - avgCraving;
      num += dm * dc;
      denMood += dm * dm;
      denCraving += dc * dc;
    }
    final den = denMood * denCraving;
    if (den <= 0) return 0;
    return num / math.sqrt(den);
  }

  int _computeStreakFromCheckIns(List<DailyCheckIn> checkIns) {
    final sorted = checkIns.toList()
      ..sort((a, b) => b.checkInDate.compareTo(a.checkInDate));
    int streak = 0;
    DateTime expected = DateTime.now();
    for (final c in sorted) {
      if (expected.difference(c.checkInDate).inDays <= 1) {
        streak++;
        expected = c.checkInDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
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

          // What I've noticed - patterns section
          FutureBuilder<List<String>>(
            future: _patternsFuture,
            builder: (context, snapshot) {
              final patterns = snapshot.data ?? [];
              if (patterns.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.sm),
                    child: Text(
                      'What I\'ve noticed',
                      style: AppTypography.titleMedium.copyWith(color: AppColors.primaryAmber),
                    ),
                  ),
                  ...patterns.map((p) => Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle, size: 6, color: AppColors.primaryAmber),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: Text(p, style: AppTypography.bodyMedium)),
                      ],
                    ),
                  )),
                  const Divider(height: AppSpacing.xl),
                ],
              );
            },
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
                  Text(widget.memory.summary, style: AppTypography.bodyMedium),
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
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
