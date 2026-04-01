import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/milestone_service.dart';
import '../../../core/services/preferences_service.dart';
import '../../milestone/screens/milestone_celebration_screen.dart';
import '../../milestone/widgets/milestone_share_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/achievement_share_utils.dart';
import '../../../widgets/glass_card.dart';

const bool _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');

/// Home dashboard with dynamic sobriety, check-ins, and quick actions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.showCelebration = true, this.sharePlus});

  /// Whether to trigger the milestone celebration dialog on first load.
  final bool showCelebration;

  /// Override for testing — inject a [SharePlus.custom] instance.
  /// Production code leaves this null and uses [SharePlus.instance].
  @visibleForTesting
  final SharePlus? sharePlus;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repaintKey = GlobalKey();
  late Future<_HomeSnapshot> _snapshotFuture;
  bool _showShareCard = false;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = _loadSnapshot();
    if (widget.showCelebration) {
      _snapshotFuture.then((data) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          final achievement = await MilestoneService().shouldShowCelebration(
            data.unreadShareableMilestones,
          );
          if (achievement != null && mounted) {
            await showGeneralDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.transparent,
              pageBuilder: (ctx, _, _) =>
                  MilestoneCelebrationScreen(achievement: achievement),
            );
          }
        });
      });
    }
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
          body: Stack(
            children: [
              // Ambient radial glow top-right (amber at 3% opacity)
              Positioned(
                top: -100,
                right: -50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryAmber.withValues(alpha: 0.03),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              CustomScrollView(
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
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.1, end: 0, duration: 600.ms),
                        const SizedBox(height: AppSpacing.lg),
                        Semantics(
                          sortKey: const OrdinalSortKey(2),
                          child: _SupportStrip(snapshot: data),
                        )
                            .animate(delay: 150.ms)
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.1, end: 0),
                        const SizedBox(height: AppSpacing.xl),
                        Semantics(
                          sortKey: const OrdinalSortKey(3),
                          child: _QuickActions(snapshot: data),
                        ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
                        const SizedBox(height: AppSpacing.xxl),
                        Semantics(
                          sortKey: const OrdinalSortKey(4),
                          header: true,
                          child: Text(
                            'Today',
                            style: AppTypography.headlineSmall,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Semantics(
                          sortKey: const OrdinalSortKey(5),
                          child: _CheckInCards(snapshot: data),
                        )
                            .animate(delay: 350.ms)
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.1, end: 0),
                      ]),
                    ),
                  ),
                ],
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
          // Off-screen share card for PNG capture.
          bottomSheet: Offstage(
            offstage: !_showShareCard,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.004,
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: Builder(
                    builder: (_) {
                      final shareContent = data.featuredShareContent;
                      if (shareContent == null) return const SizedBox.shrink();
                      // Extract achievement phrase or emojis if necessary, default 🎉
                      return MilestoneShareCard(
                        emoji: '🎉',
                        title: shareContent.milestoneTitle,
                        message: shareContent.shareText,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<_HomeSnapshot> _loadSnapshot() async {
    // Use batch method for better performance - single DB access instead of 6+ calls
    final database = DatabaseService();
    final snapshot = await database.getHomeSnapshot();

    final currentUser = snapshot['user'] as UserProfile?;
    final morning = snapshot['morningCheckIn'] as DailyCheckIn?;
    final evening = snapshot['eveningCheckIn'] as DailyCheckIn?;
    final sponsor = snapshot['sponsor'] as Contact?;
    final achievements = snapshot['achievements'] as List<Achievement>;
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

    XFile? shareFile;
    if (_repaintKey.currentContext != null) {
      shareFile = await _captureShareCard();
    }

    final result = await (widget.sharePlus ?? SharePlus.instance).share(
      ShareParams(
        files: shareFile != null ? [shareFile] : null,
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

  Future<XFile?> _captureShareCard() async {
    if (_isFlutterTest ||
        WidgetsBinding.instance.runtimeType
            .toString()
            .contains('TestWidgetsFlutterBinding')) {
      return null;
    }
    if (!mounted || _repaintKey.currentContext == null) {
      return null;
    }
    setState(() {
      _showShareCard = true;
    });
    await WidgetsBinding.instance.endOfFrame;
    XFile? shareFile;
    try {
      shareFile = await MilestoneShareCard.capture(_repaintKey);
    } finally {
      if (mounted) {
        setState(() {
          _showShareCard = false;
        });
      }
    }
    return shareFile;
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

// ---------------------------------------------------------------------------
// Breathing glow animation — pulses behind the day count
// ---------------------------------------------------------------------------

class _BreathingGlow extends StatefulWidget {
  const _BreathingGlow();

  @override
  State<_BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<_BreathingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!reduceMotion) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: child,
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryAmber.withValues(alpha: 0.08),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sobriety hero card
// ---------------------------------------------------------------------------

class _SobrietyCard extends StatelessWidget {
  const _SobrietyCard({
    required this.snapshot,
    required this.onShareMilestone,
  });

  final _HomeSnapshot snapshot;
  final Future<void> Function()? onShareMilestone;

  @override
  Widget build(BuildContext context) {
    final user = snapshot.user;
    final soberLabel =
        user == null ? 'Recovery starts now' : user.sobrietyMilestone;
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
        child: Stack(
          children: [
            // Breathing glow positioned behind the day count
            Positioned(
              top: 0,
              left: 0,
              child: const _BreathingGlow(),
            ),
            // Foreground content
            Column(
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
                    label:
                        'Share milestone: ${snapshot.featuredShareContent!.buttonLabel}',
                    child: OutlinedButton.icon(
                      onPressed: onShareMilestone == null
                          ? null
                          : () async {
                              await HapticFeedback.lightImpact();
                              await onShareMilestone?.call();
                            },
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
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms);
  }
}

// ---------------------------------------------------------------------------
// Support strip
// ---------------------------------------------------------------------------

class _SupportStrip extends StatelessWidget {
  const _SupportStrip({required this.snapshot});

  final _HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Support info. Sponsor: ${snapshot.sponsor?.name ?? 'Not added'}. Program: ${AppStateService.instance.programType ?? 'Not set'}',
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
                value: AppStateService.instance.programType ??
                    'Choose in settings',
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

// ---------------------------------------------------------------------------
// Quick actions — premium 2x4 grid
// ---------------------------------------------------------------------------

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.snapshot});

  final _HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionDef(
        icon: Icons.self_improvement,
        label: 'Step Work',
        semanticLabel: 'Navigate to step work',
        onTap: () => context.go(AppRoutes.steps),
      ),
      _ActionDef(
        icon: Icons.edit_note,
        label: 'Journal',
        semanticLabel: 'Navigate to journal',
        onTap: () => context.go(AppRoutes.journal),
      ),
      _ActionDef(
        icon: Icons.favorite,
        label: 'Gratitude',
        semanticLabel: 'Navigate to gratitude entries',
        onTap: () => context.push('/home/gratitude'),
      ),
      _ActionDef(
        icon: Icons.menu_book_outlined,
        label: 'Reading',
        semanticLabel: 'Navigate to daily reading',
        onTap: () => context.push('/home/daily-reading'),
      ),
      _ActionDef(
        icon: Icons.people_alt_outlined,
        label: 'Meetings',
        semanticLabel: 'Navigate to meetings',
        onTap: () => context.go(AppRoutes.meetings),
      ),
      _ActionDef(
        icon: Icons.self_improvement,
        label: 'Mindfulness',
        semanticLabel: 'Navigate to mindfulness library',
        onTap: () => context.push('/mindfulness'),
      ),
      _ActionDef(
        icon: Icons.smart_toy,
        label: 'AI Companion',
        semanticLabel: 'Chat with AI sponsor companion',
        onTap: () => context.push('/home/companion-chat'),
      ),
      _ActionDef(
        icon: Icons.crisis_alert,
        label: 'Emergency',
        semanticLabel: 'Navigate to emergency crisis support',
        onTap: () => context.push('/home/emergency'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTypography.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 2.8,
          children: List.generate(actions.length, (index) {
            final action = actions[index];
            return _ActionTile(
              icon: action.icon,
              label: action.label,
              semanticLabel: action.semanticLabel,
              onTap: action.onTap,
              animationIndex: index,
            );
          }),
        ),
      ],
    );
  }
}

class _ActionDef {
  const _ActionDef({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String semanticLabel;
  final VoidCallback onTap;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    required this.animationIndex,
  });

  final IconData icon;
  final String label;
  final String semanticLabel;
  final VoidCallback onTap;
  final int animationIndex;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: () async {
          await HapticFeedback.lightImpact();
          onTap();
        },
        child: GlassCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, size: 28, color: AppColors.primaryAmber),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(
          delay: Duration(milliseconds: animationIndex * 80),
        )
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }
}

// ---------------------------------------------------------------------------
// Check-in cards
// ---------------------------------------------------------------------------

class _CheckInCards extends StatelessWidget {
  const _CheckInCards({required this.snapshot});

  final _HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CheckInCard(
          title: 'Morning Intention',
          subtitle:
              snapshot.morningCheckIn?.intention?.trim().isNotEmpty == true
                  ? snapshot.morningCheckIn!.intention!
                  : 'Set your intention for the day',
          icon: Icons.wb_sunny_outlined,
          isComplete: snapshot.morningCheckIn != null,
          onTap: () => context.push('/home/morning-intention'),
        ),
        const SizedBox(height: AppSpacing.md),
        _CheckInCard(
          title: 'Evening Pulse',
          subtitle:
              snapshot.eveningCheckIn?.reflection?.trim().isNotEmpty == true
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
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusStandard),
          child: Container(
            decoration: isComplete
                ? BoxDecoration(
                    border: const Border(
                      left: BorderSide(
                        color: AppColors.success,
                        width: 3,
                      ),
                    ),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusStandard),
                  )
                : null,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusStandard),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAmber.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
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
                                child: Text(
                                  title,
                                  style: AppTypography.titleMedium,
                                ),
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
                      child: Icon(
                        Icons.chevron_right,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
