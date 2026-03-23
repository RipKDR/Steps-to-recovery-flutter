import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import 'app_config.dart';
import 'core/services/encryption_service.dart';
import 'core/services/database_service.dart';
import 'core/services/preferences_service.dart';
import 'core/services/sync_service.dart';

const String kRecoveryPeriodicSyncTask = 'recovery.periodic_sync';

@pragma('vm:entry-point')
void recoverySyncDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('[workmanager] task=$task input=$inputData');

    if (!AppConfig.hasSupabase) {
      return true; // No remote configured — nothing to sync.
    }

    try {
      // Bootstrap minimal services in background isolate.
      await PreferencesService().initialize();
      await EncryptionService().initialize();
      await DatabaseService().initialize();
      await SyncService().initialize();
      await SyncService().syncAll();
      debugPrint('[workmanager] sync completed');
    } catch (e) {
      debugPrint('[workmanager] sync error: $e');
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
