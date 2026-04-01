import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/milestone_service.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/achievement_share_utils.dart';
import '../models/home_hub_models.dart';
import '../widgets/home_hub_inputs.dart';
import '../widgets/home_hub_sections.dart';
import '../../milestone/screens/milestone_celebration_screen.dart';
import '../../milestone/widgets/milestone_share_card.dart';

const bool _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.showCelebration = true});

  final bool showCelebration;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repaintKey = GlobalKey();
  final _morningIntentionController = TextEditingController();
  late Future<HomeHubSnapshot> _snapshotFuture;

  int _morningMood = 3;
  int _eveningMood = 3;
  int _eveningCraving = 0;
  bool _isSavingMorning = false;
  bool _isSavingEvening = false;
  bool _showShareCard = false;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = _loadSnapshot();
    _morningIntentionController.addListener(_handleMorningDraftChanged);
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
    _morningIntentionController.removeListener(_handleMorningDraftChanged);
    _morningIntentionController.dispose();
    super.dispose();
  }

  void _handleMorningDraftChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _refreshSnapshot() {
    if (!mounted) {
      return;
    }
    setState(() {
      _snapshotFuture = _loadSnapshot();
    });
  }

  Future<HomeHubSnapshot> _loadSnapshot() async {
    final snapshot = await DatabaseService().getHomeSnapshot();
    final achievements = snapshot['achievements'] as List<Achievement>;
    final unreadShareableMilestones = sortShareableMilestoneAchievements(
      achievements,
    );
    final featuredAchievement = unreadShareableMilestones.isEmpty
        ? null
        : unreadShareableMilestones.first;

    return HomeHubSnapshot(
      user: snapshot['user'] as UserProfile?,
      morningCheckIn: snapshot['morningCheckIn'] as DailyCheckIn?,
      eveningCheckIn: snapshot['eveningCheckIn'] as DailyCheckIn?,
      sponsor: snapshot['sponsor'] as Contact?,
      unreadAchievements: achievements.length,
      unreadShareableMilestones: unreadShareableMilestones,
      featuredShareContent: featuredAchievement == null
          ? null
          : milestoneShareContentForAchievement(featuredAchievement),
    );
  }

  Future<void> _saveMorning(HomeHubSnapshot snapshot) async {
    final intention = _morningIntentionController.text.trim();
    if (_isSavingMorning || intention.isEmpty) {
      return;
    }

    setState(() => _isSavingMorning = true);
    try {
      await DatabaseService().saveCheckIn(
        DailyCheckIn(
          id: '',
          userId: DatabaseService().activeUserId ?? '',
          checkInType: CheckInType.morning,
          checkInDate: DateTime.now(),
          intention: intention,
          mood: _morningMood,
          createdAt: snapshot.morningCheckIn?.createdAt ?? DateTime.now(),
          syncStatus: SyncStatus.pending,
        ),
      );
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      _refreshSnapshot();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Morning intention saved.')));
    } finally {
      if (mounted) {
        setState(() => _isSavingMorning = false);
      }
    }
  }

  Future<void> _saveEvening(HomeHubSnapshot snapshot) async {
    if (_isSavingEvening) {
      return;
    }

    setState(() => _isSavingEvening = true);
    try {
      await DatabaseService().saveCheckIn(
        DailyCheckIn(
          id: '',
          userId: DatabaseService().activeUserId ?? '',
          checkInType: CheckInType.evening,
          checkInDate: DateTime.now(),
          mood: _eveningMood,
          craving: _eveningCraving,
          reflection: snapshot.eveningCheckIn?.reflection,
          createdAt: snapshot.eveningCheckIn?.createdAt ?? DateTime.now(),
          syncStatus: SyncStatus.pending,
        ),
      );
      if (!mounted) return;
      _refreshSnapshot();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Evening pulse saved.')));
    } finally {
      if (mounted) {
        setState(() => _isSavingEvening = false);
      }
    }
  }

  Future<void> _shareMilestone(
    BuildContext context,
    HomeHubSnapshot snapshot,
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

    final result = await SharePlus.instance.share(
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
        for (final achievement in snapshot.unreadShareableMilestones) {
          await DatabaseService().markAchievementViewed(achievement.id);
        }
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${shareContent.milestoneTitle} shared.')),
        );
        _refreshSnapshot();
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
        WidgetsBinding.instance.runtimeType.toString().contains(
          'TestWidgetsFlutterBinding',
        )) {
      return null;
    }
    if (!mounted || _repaintKey.currentContext == null) {
      return null;
    }
    setState(() => _showShareCard = true);
    await WidgetsBinding.instance.endOfFrame;
    XFile? shareFile;
    try {
      shareFile = await MilestoneShareCard.capture(_repaintKey);
    } finally {
      if (mounted) {
        setState(() => _showShareCard = false);
      }
    }
    return shareFile;
  }

  void _showSupportSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.85;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('More support', style: AppTypography.headlineSmall),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Jump into the tools you use when you need extra support, reflection, or connection.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SupportSheetAction(
                      icon: Icons.edit_note_outlined,
                      title: 'Quick journal',
                      subtitle:
                          'Capture a thought without leaving the daily flow.',
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        context.push('/journal/editor?mode=create');
                      },
                    ),
                    SupportSheetAction(
                      icon: Icons.favorite_outline,
                      title: 'Gratitude',
                      subtitle:
                          'Add gratitude without opening the full evening screen.',
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        context.push('/home/gratitude');
                      },
                    ),
                    SupportSheetAction(
                      icon: Icons.menu_book_outlined,
                      title: 'Daily reading',
                      subtitle:
                          'Read today’s reflection or save a thought for later.',
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        context.push('/home/daily-reading');
                      },
                    ),
                    SupportSheetAction(
                      icon: Icons.people_alt_outlined,
                      title: 'Meetings',
                      subtitle: 'Find a meeting or revisit favorites.',
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        context.go(AppRoutes.meetings);
                      },
                    ),
                    SupportSheetAction(
                      icon: Icons.smart_toy_outlined,
                      title: 'AI companion',
                      subtitle:
                          'Talk through cravings, setbacks, or next steps.',
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        context.push('/home/companion-chat');
                      },
                    ),
                    SupportSheetAction(
                      icon: Icons.crisis_alert_outlined,
                      title: 'Emergency tools',
                      subtitle:
                          'Open crisis support, grounding, or danger-zone tools.',
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        context.push('/home/emergency');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HomeHubSnapshot>(
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

        final data = snapshot.data ?? const HomeHubSnapshot.empty();
        final recommendation = HomeActionRecommendation.fromSnapshot(data);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                backgroundColor: AppColors.background,
                title: Text('Today', style: AppTypography.headlineLarge),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.bar_chart_outlined),
                    tooltip: 'View progress dashboard',
                    onPressed: () => context.push('/home/progress'),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    RecoveryHeroCard(
                      semanticsKey: const Key('home-hero-semantics'),
                      snapshot: data,
                      recommendation: recommendation,
                      onShareMilestone: data.featuredShareContent == null
                          ? null
                          : () => _shareMilestone(context, data),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Semantics(
                      header: true,
                      child: Text(
                        "Today's path",
                        style: AppTypography.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      recommendation.sectionCopy,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildMorningCard(data, recommendation),
                    const SizedBox(height: AppSpacing.md),
                    _buildEveningCard(data, recommendation),
                    const SizedBox(height: AppSpacing.xl),
                    SupportSummaryPanel(
                      semanticsKey: const Key('home-support-summary-semantics'),
                      snapshot: data,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        key: const Key('home-more-support'),
                        onPressed: _showSupportSheet,
                        icon: const Icon(Icons.grid_view_rounded),
                        label: const Text('More support'),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
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

  Widget _buildMorningCard(
    HomeHubSnapshot data,
    HomeActionRecommendation recommendation,
  ) {
    return DailyActionCard(
      semanticsKey: const Key('home-morning-card-semantics'),
      title: 'Morning intention',
      description: 'Set the tone for the day with one clear intention.',
      icon: Icons.wb_sunny_outlined,
      status: recommendation.morningStatus,
      detail: data.morningCheckIn?.intention?.trim().isNotEmpty == true
          ? data.morningCheckIn!.intention!.trim()
          : 'Mood ${moodLabel(data.morningCheckIn?.mood ?? _morningMood)}',
      highlight: recommendation.morningStatus == DailyCardStatus.nextUp,
      onOpenFull: () => context.push('/home/morning-intention'),
      openButtonKey: const Key('home-open-morning-screen'),
      completeBody: data.morningCheckIn?.intention?.trim().isNotEmpty == true
          ? data.morningCheckIn!.intention!.trim()
          : 'Mood ${moodLabel(data.morningCheckIn?.mood ?? _morningMood)} saved for today.',
      incompleteBody: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          InlineMoodSelector(
            selectedMood: _morningMood,
            onChanged: (value) => setState(() => _morningMood = value),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            key: const Key('home-morning-intention-field'),
            controller: _morningIntentionController,
            minLines: 2,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Set a short intention',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  key: const Key('home-morning-save'),
                  onPressed:
                      _morningIntentionController.text.trim().isEmpty ||
                          _isSavingMorning
                      ? null
                      : () => _saveMorning(data),
                  child: Text(_isSavingMorning ? 'Saving...' : 'Save morning'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextButton(
                  key: const Key('home-open-morning-screen'),
                  onPressed: () => context.push('/home/morning-intention'),
                  child: const Text('Open full check-in'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEveningCard(
    HomeHubSnapshot data,
    HomeActionRecommendation recommendation,
  ) {
    return DailyActionCard(
      semanticsKey: const Key('home-evening-card-semantics'),
      title: 'Evening pulse',
      description: 'Log how the day felt before it gets away from you.',
      icon: Icons.nightlight_outlined,
      status: recommendation.eveningStatus,
      detail: data.eveningCheckIn?.reflection?.trim().isNotEmpty == true
          ? data.eveningCheckIn!.reflection!.trim()
          : 'Mood ${moodLabel(data.eveningCheckIn?.mood ?? _eveningMood)} • Craving ${data.eveningCheckIn?.craving ?? _eveningCraving}/10',
      highlight: recommendation.eveningStatus == DailyCardStatus.nextUp,
      onOpenFull: () => context.push('/home/evening-pulse'),
      openButtonKey: const Key('home-open-evening-screen'),
      completeBody:
          'Mood ${moodLabel(data.eveningCheckIn?.mood ?? _eveningMood)} • Craving ${data.eveningCheckIn?.craving ?? _eveningCraving}/10',
      incompleteBody: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          InlineMoodSelector(
            selectedMood: _eveningMood,
            onChanged: (value) => setState(() => _eveningMood = value),
          ),
          const SizedBox(height: AppSpacing.md),
          InlineCravingControl(
            value: _eveningCraving,
            onChanged: (value) => setState(() => _eveningCraving = value),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  key: const Key('home-evening-save'),
                  onPressed: _isSavingEvening ? null : () => _saveEvening(data),
                  child: Text(_isSavingEvening ? 'Saving...' : 'Save evening'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextButton(
                  key: const Key('home-open-evening-screen'),
                  onPressed: () => context.push('/home/evening-pulse'),
                  child: const Text('Open full check-in'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
