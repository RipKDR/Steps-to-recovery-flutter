import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

const String kRecoveryPeriodicSyncTask = 'recovery.periodic_sync';

@pragma('vm:entry-point')
void recoverySyncDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('[workmanager] task=$task input=$inputData');
    // v7 scaffold: background isolate wiring is in place.
    // A production implementation would bootstrap minimal storage + API client here
    // and perform a bounded sync attempt.
    return Future.value(true);
  });
}

class BackgroundSyncService {
  Future<void> initialize() async {
    await Workmanager().initialize(
      recoverySyncDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      'recovery-periodic-sync',
      kRecoveryPeriodicSyncTask,
      frequency: const Duration(hours: 6),
      initialDelay: const Duration(minutes: 20),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
    );
  }
}
