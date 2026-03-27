import 'package:workmanager/workmanager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app_config.dart';
import 'core/services/encryption_service.dart';
import 'core/services/database_service.dart';
import 'core/services/preferences_service.dart';
import 'core/services/sync_service.dart';
import 'core/services/logger_service.dart';

const String kRecoveryPeriodicSyncTask = 'recovery.periodic_sync';

@pragma('vm:entry-point')
void recoverySyncDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final logger = LoggerService();
    logger.debug('[workmanager] task=$task input=$inputData');

    if (!AppConfig.hasSupabase) {
      logger.debug('[workmanager] No Supabase configured — skipping sync');
      return true; // No remote configured — nothing to sync.
    }

    try {
      // Bootstrap minimal services in background isolate.
      await PreferencesService().initialize();
      await EncryptionService().initialize();
      await DatabaseService().initialize();
      await SyncService().initialize();
      await SyncService().syncAll();
      logger.debug('[workmanager] sync completed');
    } catch (e, stackTrace) {
      // Log error with full stack trace for debugging
      logger.error(
        '[workmanager] sync failed',
        error: e,
        stackTrace: stackTrace,
      );
      
      // If Sentry is configured, capture the error
      if (AppConfig.sentryDsn.isNotEmpty) {
        try {
          await Sentry.captureException(e, stackTrace: stackTrace);
        } catch (sentryError) {
          // Silent failure - Sentry is optional
          logger.debug('[workmanager] Failed to send to Sentry: $sentryError');
        }
      }
    }

    return true;
  });
}

class BackgroundSyncService {
  Future<void> initialize() async {
    await Workmanager().initialize(
      recoverySyncDispatcher,
    );
  }

  Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      'recovery-periodic-sync',
      kRecoveryPeriodicSyncTask,
      frequency: const Duration(hours: 6),
      initialDelay: const Duration(minutes: 20),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
    );
  }
}
