import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/morning_intention_screen.dart';
import '../features/home/screens/evening_pulse_screen.dart';
import '../features/journal/screens/journal_list_screen.dart';
import '../features/journal/screens/journal_editor_screen.dart';
import '../features/steps/screens/steps_overview_screen.dart';
import '../features/steps/screens/step_detail_screen.dart';
import '../features/steps/screens/step_review_screen.dart';
import '../features/meetings/screens/meeting_finder_screen.dart';
import '../features/meetings/screens/meeting_detail_screen.dart';
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
import 'shell_screen.dart';

/// Main app router using GoRouter
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.onboarding,
    routes: [
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
              child: HomeScreen(key: state.pageKey),
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
              child: JournalListScreen(key: state.pageKey),
            ),
            routes: [
              GoRoute(
                path: 'editor',
                name: 'journalEditor',
                builder: (context, state) {
                  final entryId = state.uri.queryParameters['entryId'];
                  final mode = state.uri.queryParameters['mode'] ?? 'create';
                  return JournalEditorScreen(
                    entryId: entryId,
                    mode: mode as CreateEditMode,
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
              child: MeetingFinderScreen(key: state.pageKey),
            ),
            routes: [
              GoRoute(
                path: 'detail',
                name: 'meetingDetail',
                builder: (context, state) {
                  final meetingId = state.uri.queryParameters['meetingId'] ?? '';
                  return MeetingDetailScreen(meetingId: meetingId);
                },
              ),
              GoRoute(
                path: 'favorites',
                name: 'favoriteMeetings',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Favorite Meetings')),
                ),
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
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Settings')),
                ),
              ),
              GoRoute(
                path: 'ai-settings',
                name: 'aiSettings',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('AI Settings')),
                ),
              ),
              GoRoute(
                path: 'security',
                name: 'securitySettings',
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('Security Settings')),
                ),
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
