import 'package:flutter/material.dart';

import 'app_config.dart';
import 'background_sync.dart';
import 'app_router.dart';
import 'local_store.dart';
import 'notification_service.dart';
import 'recovery_controller.dart';
import 'sync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final backgroundSync = BackgroundSyncService();
  await backgroundSync.initialize();
  await backgroundSync.registerPeriodicSync();

  runApp(const StepsRecoveryApp());
}

class StepsRecoveryApp extends StatefulWidget {
  const StepsRecoveryApp({super.key});

  @override
  State<StepsRecoveryApp> createState() => _StepsRecoveryAppState();
}

class _StepsRecoveryAppState extends State<StepsRecoveryApp> {
  late final RecoveryController _controller;

  @override
  void initState() {
    super.initState();
    final remote = AppConfig.hasRemoteSync
        ? RemoteRecoveryRepository(
            RecoveryApiClient(
              baseUrl: AppConfig.apiBaseUrl,
              authToken: AppConfig.apiAuthToken.isEmpty
                  ? null
                  : AppConfig.apiAuthToken,
            ),
          )
        : null;

    _controller = RecoveryController(
      store: LocalStore(),
      notifications: NotificationService(),
      remote: remote,
    );
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.loading) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            theme: _theme(),
          );
        }

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Steps to Recovery',
          theme: _theme(),
          routerConfig: buildRouter(_controller),
        );
      },
    );
  }

  ThemeData _theme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2B8CC4),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0B1B24),
      useMaterial3: true,
    );
  }
}
