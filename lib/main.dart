import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/services/encryption_service.dart';
import 'core/services/database_service.dart';
import 'core/services/logger_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/preferences_service.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize all services
  await _initializeServices();

  runApp(const StepsToRecoveryApp());
}

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

    // Initialize connectivity monitoring
    await ConnectivityService().initialize();
    logger.debug('Connectivity service initialized');

    // Initialize notifications
    await NotificationService().initialize();
    await NotificationService().requestPermissions();
    logger.debug('Notification service initialized');

    // AI service is initialized on-demand
    logger.debug('AI service ready');

    logger.info('All services initialized successfully');
  } catch (e, stackTrace) {
    logger.error('Failed to initialize services', error: e, stackTrace: stackTrace);
    // Continue anyway - app can function with limited services
  }
}

class StepsToRecoveryApp extends StatelessWidget {
  const StepsToRecoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Steps to Recovery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        // Ensure text scale factor is reasonable
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
