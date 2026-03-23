import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/achievement_share_utils.dart';

/// Home dashboard with dynamic sobriety, check-ins, and quick actions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = _loadSnapshot();
    AppStateService.instance.addListener(_refreshSnapshot);
    DatabaseService().addListener(_refreshSnapshot);
  }

  @override
  void dispose() {
    AppStateService.instance.removeListener(_refreshSnapshot);
    DatabaseService().removeListener(_refreshSnapshot);
    super.dispose();
  }

  void _refreshSnapshot() {
    if (!mounted) {
      return;
    }
    setState(() {
      _snapshotFuture = _loadSnapshot();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HomeSnapshot>(
      future: _snapshotFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryAmber),
            ),
          );
        }

        final data = snapshot.data ?? const _HomeSnapshot.empty();

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: AppColors.background,
                title: Semantics(
                  sortKey: const OrdinalSortKey(0),
                  header: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Steps to Recovery',
                        style: AppTypography.headlineMedium,
                      ),
                      Text(
                        'Welcome back, ${AppStateService.instance.userLabel}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.bar_chart_outlined),
                    tooltip: 'View progress dashboard',
                    onPressed: () => context.push('/home/progress'),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Semantics(
                      sortKey: const OrdinalSortKey(1),
                      child: _SobrietyCard(
                        snapshot: data,
                        onShareMilestone: data.featuredShareContent == null
                            ? null
                            : () => _shareMilestone(context, data),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Semantics(
                      sortKey: const OrdinalSortKey(2),
                      child: _SupportStrip(snapshot: data),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Semantics(
                      sortKey: const OrdinalSortKey(3),
                      child: _QuickActions(snapshot: data),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Semantics(
                      sortKey: const OrdinalSortKey(4),
                      header: true,
                      child: Text('Today', style: AppTypography.headlineSmall),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Semantics(
                      sortKey: const OrdinalSortKey(5),
                      child: _CheckInCards(snapshot: data),
                    ),
                  ]),
                ),
              ),
            ],
          ),
          floatingActionButton: Semantics(
            sortKey: const OrdinalSortKey(6),
            button: true,
            label: 'Create a new journal entry',
            child: FloatingActionButton.extended(
              onPressed: () => context.push('/journal/editor?mode=create'),
              icon: const Icon(Icons.add),
              label: const Text('Quick Journal'),
              backgroundColor: AppColors.primaryAmber,
              foregroundColor: AppColors.textOnDark,
            ),
          ),
        );
      },
    );
  }

  Future<_HomeSnapshot> _loadSnapshot() async {
    final database = DatabaseService();
    final currentUser = await database.getCurrentUser();
    final morning = await database.getTodayCheckIn(CheckInType.morning);
    final evening = await database.getTodayCheckIn(CheckInType.evening);
    final sponsor = await database.getSponsor(database.activeUserId ?? '');
    final achievements = await database.getAchievements(isViewed: false);
    final unreadShareableMilestones =
        sortShareableMilestoneAchievements(achievements);
    final featuredAchievement = unreadShareableMilestones.isEmpty
        ? null
        : unreadShareableMilestones.first;

    return _HomeSnapshot(
      user: currentUser,
      morningCheckIn: morning,
      eveningCheckIn: evening,
      sponsor: sponsor,
      unreadAchievements: achievements.length,
      unreadShareableMilestones: unreadShareableMilestones,
      featuredShareContent: featuredAchievement == null
          ? null
          : milestoneShareContentForAchievement(featuredAchievement),
    );
  }

  Future<void> _shareMilestone(
    BuildContext context,
    _HomeSnapshot snapshot,
  ) async {
    final featuredAchievement = snapshot.featuredShareAchievement;
    final shareContent = snapshot.featuredShareContent;
    if (featuredAchievement == null || shareContent == null) {
      return;
    }

    final preferences = PreferencesService();
    final logger = LoggerService();
    await preferences.incrementAchievementShareTapped();
    logger.info(
      'event=achievement_share_tapped achievementKey=${featuredAchievement.achievementKey}',
    );

    final result = await SharePlus.instance.share(
      ShareParams(
        text: shareContent.shareText,
        subject: shareContent.shareSubject,
      ),
    );

    if (!context.mounted) {
      return;
    }

    switch (result.status) {
      case ShareResultStatus.success:
        await preferences.incrementAchievementShareCompleted();
        logger.info(
          'event=achievement_share_completed achievementKey=${featuredAchievement.achievementKey}',
        );
        final database = DatabaseService();
        for (final achievement in snapshot.unreadShareableMilestones) {
          await database.markAchievementViewed(achievement.id);
        }
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${shareContent.milestoneTitle} shared.')),
        );
        return;
      case ShareResultStatus.dismissed:
        logger.info(
          'event=achievement_share_dismissed achievementKey=${featuredAchievement.achievementKey}',
        );
        return;
      case ShareResultStatus.unavailable:
        logger.warning(
          'event=achievement_share_unavailable achievementKey=${featuredAchievement.achievementKey}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sharing is not available on this device.'),
          ),
        );
        return;
    }
  }
}

class _HomeSnapshot {
  const _HomeSnapshot({
    required this.user,
    required this.morningCheckIn,
    required this.eveningCheckIn,
    required this.sponsor,
    required this.unreadAchievements,
    required this.unreadShareableMilestones,
    required this.featuredShareContent,
  });

  const _HomeSnapshot.empty()
      : user = null,
        morningCheckIn = null,
        eveningCheckIn = null,
        sponsor = null,
        unreadAchievements = 0,
        unreadShareableMilestones = const <Achievement>[],
        featuredShareContent = null;

  final UserProfile? user;
  final DailyCheckIn? morningCheckIn;
  final DailyCheckIn? eveningCheckIn;
  final Contact? sponsor;
  final int unreadAchievements;
  final List<Achievement> unreadShareableMilestones;
  final MilestoneShareContent? featuredShareContent;

  Achievement? get featuredShareAchievement {
    if (unreadShareableMilestones.isEmpty) {
      return null;
    }
    return unreadShareableMilestones.first;
  }
}

class _SobrietyCard extends StatelessWidget {
  const _SobrietyCard({
    required this.snapshot,
    required this.onShareMilestone,
  });

  final _HomeSnapshot snapshot;
  final VoidCallback? onShareMilestone;

  @override
  Widget build(BuildContext context) {
    final user = snapshot.user;
    final soberLabel = user == null ? 'Recovery starts now' : user.sobrietyMilestone;
    final days = AppStateService.instance.sobrietyDays;

    return Semantics(
      label: '$days days clean. $soberLabel',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clean Time',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textOnDark,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: days),
              duration: MediaQuery.of(context).disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Text(
                  '$value days',
                  style: AppTypography.displayLarge.copyWith(
                    color: AppColors.textOnDark,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              soberLabel,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textOnDark.withValues(alpha: 0.84),
              ),
            ),
            if (snapshot.unreadAchievements > 0) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                '${snapshot.unreadAchievements} new achievement${snapshot.unreadAchievements == 1 ? '' : 's'} waiting',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textOnDark,
                ),
              ),
            ],
            if (snapshot.featuredShareContent != null) ...[
              const SizedBox(height: AppSpacing.md),
              Semantics(
                button: true,
                label: 'Share milestone: ${snapshot.featuredShareContent!.buttonLabel}',
                child: OutlinedButton.icon(
                  onPressed: onShareMilestone,
                  icon: const Icon(Icons.share_outlined),
                  label: Text(snapshot.featuredShareContent!.buttonLabel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textOnDark,
                    side: BorderSide(
                      color: AppColors.textOnDark.withValues(alpha: 0.72),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SupportStrip extends StatelessWidget {
  const _SupportStrip({required this.snapshot});

  final _HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Support info. Sponsor: ${snapshot.sponsor?.name ?? 'Not added'}. Program: ${AppStateService.instance.programType ?? 'Not set'}',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: _InfoColumn(
                label: 'Sponsor',
                value: snapshot.sponsor?.name ?? 'Not added',
              ),
            ),
            Expanded(
              child: _InfoColumn(
                label: 'Program',
                value: AppStateService.instance.programType ?? 'Choose in settings',
              ),
            ),
            Semantics(
              button: true,
              label: 'Manage sponsor and support network',
              child: TextButton(
                onPressed: () => context.push(AppRoutes.sponsor),
                child: const Text('Manage'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTypography.titleMedium),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.snapshot});

  final _HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTypography.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _ActionButton(
              icon: Icons.self_improvement,
              label: 'Step Work',
              semanticLabel: 'Navigate to step work',
              onTap: () => context.go(AppRoutes.steps),
            ),
            _ActionButton(
              icon: Icons.edit_note,
              label: 'Journal',
              semanticLabel: 'Navigate to journal',
              onTap: () => context.go(AppRoutes.journal),
            ),
            _ActionButton(
              icon: Icons.favorite,
              label: 'Gratitude',
              semanticLabel: 'Navigate to gratitude entries',
              onTap: () => context.push('/home/gratitude'),
            ),
            _ActionButton(
              icon: Icons.menu_book_outlined,
              label: 'Reading',
              semanticLabel: 'Navigate to daily reading',
              onTap: () => context.push('/home/daily-reading'),
            ),
            _ActionButton(
              icon: Icons.people_alt_outlined,
              label: 'Meetings',
              semanticLabel: 'Navigate to meetings',
              onTap: () => context.go(AppRoutes.meetings),
            ),
            _ActionButton(
              icon: Icons.crisis_alert,
              label: 'Emergency',
              semanticLabel: 'Navigate to emergency crisis support',
              onTap: () => context.push('/home/emergency'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.touchTargetComfortable),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: AppSpacing.iconMd, color: AppColors.primaryAmber),
                const SizedBox(width: AppSpacing.sm),
                Text(label, style: AppTypography.labelMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckInCards extends StatelessWidget {
  const _CheckInCards({required this.snapshot});

  final _HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CheckInCard(
          title: 'Morning Intention',
          subtitle: snapshot.morningCheckIn?.intention?.trim().isNotEmpty == true
              ? snapshot.morningCheckIn!.intention!
              : 'Set your intention for the day',
          icon: Icons.wb_sunny_outlined,
          isComplete: snapshot.morningCheckIn != null,
          onTap: () => context.push('/home/morning-intention'),
        ),
        const SizedBox(height: AppSpacing.md),
        _CheckInCard(
          title: 'Evening Pulse',
          subtitle: snapshot.eveningCheckIn?.reflection?.trim().isNotEmpty == true
              ? snapshot.eveningCheckIn!.reflection!
              : 'Reflect on your day and log cravings',
          icon: Icons.nightlight_outlined,
          isComplete: snapshot.eveningCheckIn != null,
          onTap: () => context.push('/home/evening-pulse'),
        ),
      ],
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isComplete,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isComplete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. ${isComplete ? 'Completed' : 'Not completed'}. $subtitle',
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAmber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryAmber,
                    size: AppSpacing.iconLg,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(title, style: AppTypography.titleMedium),
                          ),
                          if (isComplete)
                            Semantics(
                              label: 'Completed',
                              child: const Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: AppSpacing.iconMd,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const ExcludeSemantics(
                  child: Icon(Icons.chevron_right, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
