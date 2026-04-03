import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/steps/screens/steps_overview_screen.dart';

import '../core/constants/app_constants.dart';
import '../core/models/database_models.dart';
import '../core/services/app_state_service.dart';
import '../core/services/database_service.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/services/logger_service.dart';
import '../core/services/sponsor_service.dart';
import '../core/theme/app_colors.dart';
import '../features/ai_companion/screens/sponsor_chat_screen.dart';
import '../features/ai_companion/screens/sponsor_intro_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/craving_surf/screens/craving_surf_screen.dart';
import '../features/crisis/screens/before_you_use_screen.dart';
import '../features/crisis/screens/emergency_screen.dart';
import '../features/crisis/screens/grounding_exercises_screen.dart';
import '../features/emergency/screens/danger_zone_screen.dart';
import '../features/gratitude/screens/gratitude_screen.dart';
import '../features/home/screens/evening_pulse_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/morning_intention_screen.dart';
import '../features/inventory/screens/inventory_screen.dart';
import '../features/journal/screens/journal_editor_screen.dart';
import '../features/journal/screens/journal_list_screen.dart';
import '../features/meetings/screens/meeting_detail_screen.dart';
import '../features/meetings/screens/meeting_finder_screen.dart';
import '../features/meetings/screens/meetings_stats_screen.dart';
import '../features/mindfulness/screens/mindfulness_library_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/profile/screens/ai_settings_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/security_settings_screen.dart';
import '../features/profile/screens/settings_screen.dart';
import '../features/progress/screens/progress_dashboard_screen.dart';
import '../features/readings/screens/daily_reading_screen.dart';
import '../features/safety_plan/screens/safety_plan_screen.dart';
import '../features/sponsor/screens/sponsor_screen.dart';
import '../features/steps/screens/step_detail_screen.dart';
import '../features/steps/screens/step_review_screen.dart';
import '../widgets/empty_state.dart';
import 'shell_screen.dart';

/// Main app router using GoRouter
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.bootstrap,
    redirect: (context, state) {
      try {
        final service = AppStateService.instance;
        final sponsor = SponsorService.instance;
        final location = state.uri.path;
        final isBootstrap = location == AppRoutes.bootstrap;
        final isAuthRoute =
            location == AppRoutes.onboarding ||
            location == AppRoutes.login ||
            location == AppRoutes.signup;
        final isSponsorIntro = location == AppRoutes.sponsorIntro;

        if (!service.isReady) {
          return isBootstrap ? null : AppRoutes.bootstrap;
        }

        if (isBootstrap) {
          if (!service.onboardingComplete) return AppRoutes.onboarding;
          if (!service.isAuthenticated) return AppRoutes.login;
          if (!sponsor.hasIdentity) return AppRoutes.sponsorIntro;
          return AppRoutes.home;
        }

        if (!service.onboardingComplete) {
          return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;
        }

        if (!service.isAuthenticated) {
          return isAuthRoute ? null : AppRoutes.login;
        }

        // After auth: gate on sponsor identity
        if (!sponsor.hasIdentity) {
          return isSponsorIntro ? null : '/sponsor-intro';
        }

        if (isAuthRoute || isSponsorIntro || location == '/') {
          return AppRoutes.home;
        }

        return null;
      } catch (e, stackTrace) {
        // CRITICAL: Router redirect must never crash the app
        LoggerService().error(
          'Router redirect failed',
          error: e,
          stackTrace: stackTrace,
        );

        // Return safe fallback - bootstrap will re-evaluate
        return AppRoutes.bootstrap;
      }
    },
    refreshListenable: Listenable.merge([
      AppStateService.instance,
      SponsorService.instance,
    ]),
    routes: [
      GoRoute(
        path: AppRoutes.bootstrap,
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
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // NEW: Sponsor intro (post-auth gate — outside ShellRoute)
      GoRoute(
        path: AppRoutes.sponsorIntro,
        name: 'sponsorIntro',
        builder: (context, state) =>
            SponsorIntroScreen(onComplete: () => context.go(AppRoutes.home)),
      ),

      // Mindfulness Library (top-level)
      GoRoute(
        path: AppRoutes.mindfulness,
        name: 'mindfulness',
        builder: (context, state) => const MindfulnessLibraryScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          // Home tab
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: HomeScreen(key: state.pageKey)),
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
                builder: (context, state) => const SponsorChatScreen(),
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
              GoRoute(
                path: 'grounding-exercises',
                name: 'groundingExercises',
                builder: (context, state) => const GroundingExercisesScreen(),
              ),
            ],
          ),

          // Journal tab
          GoRoute(
            path: AppRoutes.journal,
            name: 'journal',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: JournalListScreen(key: state.pageKey)),
            routes: [
              GoRoute(
                path: 'editor',
                name: 'journalEditor',
                builder: (context, state) {
                  final entryId = state.uri.queryParameters['entryId'];
                  final mode = state.uri.queryParameters['mode'] == 'edit'
                      ? CreateEditMode.edit
                      : CreateEditMode.create;
                  return JournalEditorScreen(entryId: entryId, mode: mode);
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
              child: MeetingFinderScreen(key: state.pageKey),
            ),
            routes: [
              GoRoute(
                path: 'detail',
                name: 'meetingDetail',
                builder: (context, state) {
                  final meetingId =
                      state.uri.queryParameters['meetingId'] ?? '';
                  return MeetingDetailScreen(meetingId: meetingId);
                },
              ),
              GoRoute(
                path: 'favorites',
                name: 'favoriteMeetings',
                builder: (context, state) => const _FavoriteMeetingsScreen(),
              ),
              GoRoute(
                path: 'stats',
                name: 'meetingsStats',
                builder: (context, state) => const MeetingsStatsScreen(),
              ),
            ],
          ),

          // Profile tab
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: ProfileScreen(key: state.pageKey)),
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
      body: Center(child: Text('Page not found: ${state.uri.path}')),
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

class _FavoriteMeetingsScreen extends StatefulWidget {
  const _FavoriteMeetingsScreen();

  @override
  State<_FavoriteMeetingsScreen> createState() =>
      _FavoriteMeetingsScreenState();
}

class _FavoriteMeetingsScreenState extends State<_FavoriteMeetingsScreen> {
  late Future<List<Meeting>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = DatabaseService().getMeetings(isFavorite: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Meetings'),
        backgroundColor: AppColors.background,
      ),
      body: FutureBuilder<List<Meeting>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryAmber),
            );
          }

          final favorites = snapshot.data ?? const <Meeting>[];
          if (favorites.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: 'No favorites yet',
              message:
                  'Star meetings from the Meetings tab to build this list.',
              actionLabel: 'Browse meetings',
              onAction: () => context.go(AppRoutes.meetings),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final meeting = favorites[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                child: ListTile(
                  leading: const Icon(
                    Icons.favorite,
                    color: AppColors.primaryAmber,
                  ),
                  title: Text(meeting.name, style: AppTypography.titleSmall),
                  subtitle: Text(
                    meeting.location,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  trailing: Text(
                    meeting.meetingType,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onTap: () => context.push(
                    '${AppRoutes.meetingDetail}?meetingId=${Uri.encodeComponent(meeting.id)}',
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
