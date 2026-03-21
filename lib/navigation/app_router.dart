import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../core/models/database_models.dart';
import '../core/services/app_state_service.dart';
import '../core/services/database_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../features/home/screens/morning_intention_screen.dart';
import '../features/home/screens/evening_pulse_screen.dart';
import '../features/journal/screens/journal_editor_screen.dart';
import 'package:steps_recovery_flutter/features/steps/screens/steps_overview_screen.dart';
import '../features/steps/screens/step_detail_screen.dart';
import '../features/steps/screens/step_review_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/crisis/screens/emergency_screen.dart';
import '../features/crisis/screens/before_you_use_screen.dart';
import '../features/craving_surf/screens/craving_surf_screen.dart';
import '../features/progress/screens/progress_dashboard_screen.dart';
import '../features/gratitude/screens/gratitude_screen.dart';
import '../features/inventory/screens/inventory_screen.dart';
import '../features/safety_plan/screens/safety_plan_screen.dart';
import '../features/ai_companion/screens/companion_chat_screen.dart';
import '../features/readings/screens/daily_reading_screen.dart';
import '../features/emergency/screens/danger_zone_screen.dart';
import '../features/sponsor/screens/sponsor_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/profile/screens/settings_screen.dart';
import '../features/profile/screens/ai_settings_screen.dart';
import '../features/profile/screens/security_settings_screen.dart';
import 'shell_screen.dart';

/// Main app router using GoRouter
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/bootstrap',
    refreshListenable: AppStateService.instance,
    redirect: (context, state) {
      final service = AppStateService.instance;
      final location = state.uri.path;
      final isBootstrap = location == '/bootstrap';
      final isAuthRoute =
          location == AppRoutes.onboarding ||
          location == AppRoutes.login ||
          location == AppRoutes.signup;

      if (!service.isReady) {
        return isBootstrap ? null : '/bootstrap';
      }

      if (isBootstrap) {
        if (!service.onboardingComplete) {
          return AppRoutes.onboarding;
        }
        if (!service.isAuthenticated) {
          return AppRoutes.login;
        }
        return AppRoutes.home;
      }

      if (!service.onboardingComplete) {
        return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;
      }

      if (!service.isAuthenticated) {
        return isAuthRoute ? null : AppRoutes.login;
      }

      if (isAuthRoute || location == '/') {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/bootstrap',
        name: 'bootstrap',
        builder: (context, state) => const _BootstrapScreen(),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          // Home tab
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              child: _HomeScreen(key: state.pageKey),
            ),
            routes: [
              GoRoute(
                path: 'morning-intention',
                name: 'morningIntention',
                builder: (context, state) => const MorningIntentionScreen(),
              ),
              GoRoute(
                path: 'evening-pulse',
                name: 'eveningPulse',
                builder: (context, state) => const EveningPulseScreen(),
              ),
              GoRoute(
                path: 'emergency',
                name: 'emergency',
                builder: (context, state) => const EmergencyScreen(),
              ),
              GoRoute(
                path: 'daily-reading',
                name: 'dailyReading',
                builder: (context, state) => const DailyReadingScreen(),
              ),
              GoRoute(
                path: 'progress',
                name: 'progress',
                builder: (context, state) => const ProgressDashboardScreen(),
              ),
              GoRoute(
                path: 'craving-surf',
                name: 'cravingSurf',
                builder: (context, state) => const CravingSurfScreen(),
              ),
              GoRoute(
                path: 'gratitude',
                name: 'gratitude',
                builder: (context, state) => const GratitudeScreen(),
              ),
              GoRoute(
                path: 'inventory',
                name: 'inventory',
                builder: (context, state) => const InventoryScreen(),
              ),
              GoRoute(
                path: 'safety-plan',
                name: 'safetyPlan',
                builder: (context, state) => const SafetyPlanScreen(),
              ),
              GoRoute(
                path: 'companion-chat',
                name: 'companionChat',
                builder: (context, state) => const CompanionChatScreen(),
              ),
              GoRoute(
                path: 'danger-zone',
                name: 'dangerZone',
                builder: (context, state) => const DangerZoneScreen(),
              ),
              GoRoute(
                path: 'before-you-use',
                name: 'beforeYouUse',
                builder: (context, state) => const BeforeYouUseScreen(),
              ),
            ],
          ),

          // Journal tab
          GoRoute(
            path: AppRoutes.journal,
            name: 'journal',
            pageBuilder: (context, state) => NoTransitionPage(
              child: _JournalListScreen(key: state.pageKey),
            ),
            routes: [
              GoRoute(
                path: 'editor',
                name: 'journalEditor',
                builder: (context, state) {
                  final entryId = state.uri.queryParameters['entryId'];
                  final mode = state.uri.queryParameters['mode'] == 'edit'
                      ? CreateEditMode.edit
                      : CreateEditMode.create;
                  return JournalEditorScreen(
                    entryId: entryId,
                    mode: mode,
                  );
                },
              ),
            ],
          ),

          // Steps tab
          GoRoute(
            path: AppRoutes.steps,
            name: 'steps',
            pageBuilder: (context, state) => NoTransitionPage(
              child: StepsOverviewScreen(key: state.pageKey),
            ),
            routes: [
              GoRoute(
                path: 'detail',
                name: 'stepDetail',
                builder: (context, state) {
                  final stepNumber = int.parse(
                    state.uri.queryParameters['stepNumber'] ?? '1',
                  );
                  final initialQuestion = state.uri.queryParameters['question'];
                  return StepDetailScreen(
                    stepNumber: stepNumber,
                    initialQuestion: initialQuestion != null
                        ? int.parse(initialQuestion)
                        : null,
                  );
                },
              ),
              GoRoute(
                path: 'review',
                name: 'stepReview',
                builder: (context, state) {
                  final stepNumber = int.parse(
                    state.uri.queryParameters['stepNumber'] ?? '1',
                  );
                  return StepReviewScreen(stepNumber: stepNumber);
                },
              ),
            ],
          ),

          // Meetings tab
          GoRoute(
            path: AppRoutes.meetings,
            name: 'meetings',
            pageBuilder: (context, state) => NoTransitionPage(
              child: _MeetingFinderScreen(key: state.pageKey),
            ),
            routes: [
              GoRoute(
                path: 'detail',
                name: 'meetingDetail',
                builder: (context, state) {
                  final meetingId = state.uri.queryParameters['meetingId'] ?? '';
                  return _MeetingDetailScreen(meetingId: meetingId);
                },
              ),
              GoRoute(
                path: 'favorites',
                name: 'favoriteMeetings',
                builder: (context, state) => const _FavoriteMeetingsScreen(),
              ),
            ],
          ),

          // Profile tab
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) => NoTransitionPage(
              child: ProfileScreen(key: state.pageKey),
            ),
            routes: [
              GoRoute(
                path: 'sponsor',
                name: 'sponsor',
                builder: (context, state) => const SponsorScreen(),
              ),
              GoRoute(
                path: 'settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: 'ai-settings',
                name: 'aiSettings',
                builder: (context, state) => const AiSettingsScreen(),
              ),
              GoRoute(
                path: 'security',
                name: 'securitySettings',
                builder: (context, state) => const SecuritySettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
}

class _BootstrapScreen extends StatefulWidget {
  const _BootstrapScreen();

  @override
  State<_BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<_BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    AppStateService.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primaryAmber),
            SizedBox(height: 16),
            Text('Loading Steps to Recovery'),
          ],
        ),
      ),
    );
  }
}

class _FavoriteMeetingsScreen extends StatelessWidget {
  const _FavoriteMeetingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Meetings'),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 72,
              color: AppColors.primaryAmber,
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Star meetings from the Meetings tab to build this list.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.meetings),
              child: const Text('Browse meetings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DatabaseService(),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Today'),
            backgroundColor: AppColors.background,
          ),
          body: FutureBuilder<Map<String, int>>(
            future: DatabaseService().getStats(),
            builder: (context, snapshot) {
              final stats = snapshot.data ?? const <String, int>{};
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _HeroCard(
                    title: 'Welcome back',
                    subtitle: 'Continue your recovery plan from where you left off.',
                    accent: AppColors.primaryAmber,
                  ),
                  const SizedBox(height: 16),
                  _DashboardRow(
                    primaryLabel: 'Check-ins',
                    primaryValue: '${stats['checkIns'] ?? 0}',
                    secondaryLabel: 'Meetings',
                    secondaryValue: '${stats['meetings'] ?? 0}',
                  ),
                  const SizedBox(height: 16),
                  _ActionGrid(
                    actions: [
                      _HomeAction(
                        icon: Icons.wb_sunny_outlined,
                        label: 'Morning',
                        onTap: () => context.go('/home/morning-intention'),
                      ),
                      _HomeAction(
                        icon: Icons.nights_stay_outlined,
                        label: 'Evening',
                        onTap: () => context.go('/home/evening-pulse'),
                      ),
                      _HomeAction(
                        icon: Icons.book_outlined,
                        label: 'Journal',
                        onTap: () => context.go('/journal'),
                      ),
                      _HomeAction(
                        icon: Icons.people_outline,
                        label: 'Meetings',
                        onTap: () => context.go('/meetings'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Recovery tools', style: AppTypography.headlineSmall),
                  const SizedBox(height: 12),
                  _QuickLink(
                    title: 'Progress',
                    subtitle: 'Track streaks, milestones, and check-in trends.',
                    onTap: () => context.go('/home/progress'),
                  ),
                  _QuickLink(
                    title: 'Safety plan',
                    subtitle: 'Keep your coping steps ready offline.',
                    onTap: () => context.go('/home/safety-plan'),
                  ),
                  _QuickLink(
                    title: 'Companion chat',
                    subtitle: 'Open the AI companion when you need support.',
                    onTap: () => context.go('/home/companion-chat'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _JournalListScreen extends StatelessWidget {
  const _JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/journal/editor?mode=create'),
          ),
        ],
      ),
      body: FutureBuilder<List<JournalEntry>>(
        future: DatabaseService().getJournalEntries(),
        builder: (context, snapshot) {
          final entries = snapshot.data ?? const <JournalEntry>[];
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book_outlined, size: 64, color: AppColors.primaryAmber),
                  const SizedBox(height: 16),
                  Text('No journal entries yet', style: AppTypography.headlineSmall),
                  const SizedBox(height: 8),
                  const Text('Write your first entry to get started.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/journal/editor?mode=create'),
                    child: const Text('New entry'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: entries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                child: ListTile(
                  title: Text(entry.title),
                  subtitle: Text(entry.content),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/journal/editor?mode=edit&entryId=${entry.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MeetingFinderScreen extends StatelessWidget {
  const _MeetingFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetings'),
        backgroundColor: AppColors.background,
      ),
      body: FutureBuilder<List<Meeting>>(
        future: DatabaseService().getMeetings(),
        builder: (context, snapshot) {
          final meetings = snapshot.data ?? const <Meeting>[];
          if (meetings.isEmpty) {
            return const Center(child: Text('No meetings available'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: meetings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final meeting = meetings[index];
              return Card(
                child: ListTile(
                  title: Text(meeting.name),
                  subtitle: Text('${meeting.location}\n${meeting.meetingType}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(
                    '/meetings/detail?meetingId=${meeting.id}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MeetingDetailScreen extends StatelessWidget {
  final String meetingId;

  const _MeetingDetailScreen({required this.meetingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting detail'),
        backgroundColor: AppColors.background,
      ),
      body: FutureBuilder<List<Meeting>>(
        future: DatabaseService().getMeetings(),
        builder: (context, snapshot) {
          final meetings = snapshot.data ?? const <Meeting>[];
          final meeting = meetings.firstWhere(
            (item) => item.id == meetingId,
            orElse: () => const Meeting(
              id: 'missing',
              name: 'Meeting not found',
              location: '',
              meetingType: 'in-person',
            ),
          );

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meeting.name, style: AppTypography.headlineMedium),
                const SizedBox(height: 8),
                Text(meeting.location, style: AppTypography.bodyMedium),
                const SizedBox(height: 8),
                Text('Type: ${meeting.meetingType}'),
                if (meeting.address != null) ...[
                  const SizedBox(height: 8),
                  Text('Address: ${meeting.address}'),
                ],
                if (meeting.notes != null) ...[
                  const SizedBox(height: 16),
                  Text(meeting.notes!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.headlineMedium),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}

class _DashboardRow extends StatelessWidget {
  final String primaryLabel;
  final String primaryValue;
  final String secondaryLabel;
  final String secondaryValue;

  const _DashboardRow({
    required this.primaryLabel,
    required this.primaryValue,
    required this.secondaryLabel,
    required this.secondaryValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatTile(label: primaryLabel, value: primaryValue)),
        const SizedBox(width: 12),
        Expanded(child: _StatTile(label: secondaryLabel, value: secondaryValue)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value, style: AppTypography.headlineMedium),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final List<_HomeAction> actions;

  const _ActionGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions
          .map(
            (action) => SizedBox(
              width: (MediaQuery.of(context).size.width - 60) / 2,
              child: action,
            ),
          )
          .toList(),
    );
  }
}

class _HomeAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryAmber),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickLink({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
