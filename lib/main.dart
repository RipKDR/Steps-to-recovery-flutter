import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';  // Sentry integration disabled

import 'core/theme/app_theme.dart';
import 'core/services/app_state_service.dart';
import 'core/services/encryption_service.dart';
import 'core/services/database_service.dart';
import 'core/services/logger_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/preferences_service.dart';
import 'core/services/sync_service.dart';
import 'core/services/biometric_service.dart';
import 'core/services/sponsor_service.dart';
import 'firebase_options.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = LoggerService();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    logger.error('Firebase initialization failed', error: e);
  }

  // Enable edge-to-edge display
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for edge-to-edge
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Register NUnit font for download (side effect: schedules async fetch).
  // Not called in tests (tests don't invoke main), so tests use system font fallback.
  GoogleFonts.nunito();

  // Initialize all services
  await _initializeServices();

  // Sentry integration is disabled for now.
  // Keep the app runner direct until the integration is restored.
  // if (AppConfig.sentryDsn.isNotEmpty) {
  //   await SentryFlutter.init((options) {
  //     options.dsn = AppConfig.sentryDsn;
  //     options.tracesSampleRate = 0.2;
  //     options.beforeSend = _scrubPii;
  //     options.beforeBreadcrumb = (breadcrumb, hint) {
  //       // Drop breadcrumbs that might contain user content
  //       if (breadcrumb?.category == 'console') return null;
  //       return breadcrumb;
  //     };
  //   }, appRunner: () => runApp(const StepsToRecoveryApp()));
  // } else {
  runApp(const StepsToRecoveryApp());
  // }
}

/// Strip PII from Sentry events — no recovery content, names, or journal text.
// SentryEvent? _scrubPii(SentryEvent event, Hint hint) {
//   // Remove user email/name (we only send anonymous device info)
//   final user = event.user;
//   if (user != null) {
//     user.email = null;
//     user.username = null;
//     user.name = null;
//     user.data = {};
//   }
//   return event;
// }

Future<void> _initializeServices() async {
  final logger = LoggerService();
  logger.info('Initializing services...');

  try {
    // Initialize preferences first (needed by other services)
    await PreferencesService().initialize();
    logger.debug('Preferences service initialized');

    // Initialize encryption service
    await EncryptionService().initialize();
    logger.debug('Encryption service initialized');

    // Initialize database
    await DatabaseService().initialize();
    logger.debug('Database service initialized');

    // Initialize auth and app shell state
    await AppStateService.instance.initialize();
    logger.debug('App state service initialized');

    // Initialize connectivity monitoring
    await ConnectivityService().initialize();
    logger.debug('Connectivity service initialized');

    // Initialize notifications
    await NotificationService().initialize();
    await AppStateService.instance.syncReminderPreferences();
    logger.debug('Notification service initialized');

    // Initialize Supabase sync (if configured via dart-defines)
    if (SyncService().isAvailable) {
      await SyncService().initialize();
      logger.debug('Sync service initialized');
    }

    // Initialize sponsor service
    await SponsorService.instance.initialize();
    logger.debug('Sponsor service initialized');

    // AI service is initialized on-demand
    logger.debug('AI service ready');

    logger.info('All services initialized successfully');
  } catch (e, stackTrace) {
    logger.error(
      'Failed to initialize services',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

class StepsToRecoveryApp extends StatefulWidget {
  const StepsToRecoveryApp({super.key});

  @override
  State<StepsToRecoveryApp> createState() => _StepsToRecoveryAppState();
}

class _StepsToRecoveryAppState extends State<StepsToRecoveryApp>
    with WidgetsBindingObserver {
  bool _locked = false;
  bool _prompting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      ConnectivityService().dispose();
    }
    if (state == AppLifecycleState.paused &&
        AppStateService.instance.biometricEnabled) {
      setState(() => _locked = true);
    }
    if (state == AppLifecycleState.resumed && _locked) {
      _promptBiometric();
    }
  }

  Future<void> _promptBiometric() async {
    if (_prompting) return;
    _prompting = true;
    try {
      if (!AppStateService.instance.biometricEnabled) {
        setState(() => _locked = false);
        return;
      }
      final result = await BiometricService().authenticate();
      if (result == BiometricResult.success) {
        setState(() => _locked = false);
      }
      // On failure the app stays locked — next resume will prompt again.
    } finally {
      _prompting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show opaque screen while awaiting biometric auth — content must not be visible.
    if (_locked) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AnimatedBuilder(
      animation: AppStateService.instance,
      builder: (context, _) {
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final effectiveBrightness =
            switch (AppStateService.instance.appThemeMode) {
              ThemeMode.dark => Brightness.dark,
              ThemeMode.light => Brightness.light,
              ThemeMode.system => platformBrightness,
            };
        final isDark = effectiveBrightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
          ),
        );
        return MaterialApp.router(
          title: 'Steps to Recovery',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: AppStateService.instance.appThemeMode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          routerConfig: AppRouter.router,
          builder: (context, child) {
            // Allow system text scaling up to 1.3x for accessibility
            // Recovery users may need larger text (vision issues, older adults)
            final systemScale = MediaQuery.of(context).textScaler.scale(1.0);
            final clampedScale = systemScale.clamp(1.0, 1.3);
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(clampedScale)),
              child: child!,
            );
          },
        );
      },
    );
  }
}
