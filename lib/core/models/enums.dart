/// Sync status for database records
enum SyncStatus {
  pending,
  synced,
  error;

  String get value {
    switch (this) {
      case SyncStatus.pending:
        return 'pending';
      case SyncStatus.synced:
        return 'synced';
      case SyncStatus.error:
        return 'error';
    }
  }

  static SyncStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return SyncStatus.pending;
      case 'synced':
        return SyncStatus.synced;
      case 'error':
        return SyncStatus.error;
      default:
        return SyncStatus.pending;
    }
  }
}

/// Type of daily check-in
enum CheckInType {
  morning,
  evening;

  String get value {
    switch (this) {
      case CheckInType.morning:
        return 'morning';
      case CheckInType.evening:
        return 'evening';
    }
  }

  String get displayName {
    switch (this) {
      case CheckInType.morning:
        return 'Morning Intention';
      case CheckInType.evening:
        return 'Evening Pulse';
    }
  }

  static CheckInType fromString(String value) {
    switch (value) {
      case 'morning':
        return CheckInType.morning;
      case 'evening':
        return CheckInType.evening;
      default:
        return CheckInType.morning;
    }
  }
}

/// Achievement types
enum AchievementType {
  milestone,
  streak,
  stepCompletion;

  String get value {
    switch (this) {
      case AchievementType.milestone:
        return 'milestone';
      case AchievementType.streak:
        return 'streak';
      case AchievementType.stepCompletion:
        return 'step_completion';
    }
  }

  static AchievementType fromString(String value) {
    switch (value) {
      case 'milestone':
        return AchievementType.milestone;
      case 'streak':
        return AchievementType.streak;
      case 'step_completion':
        return AchievementType.stepCompletion;
      default:
        return AchievementType.milestone;
    }
  }
}

/// Sync operation types
enum SyncOperation {
  insert,
  update,
  delete;

  String get value {
    switch (this) {
      case SyncOperation.insert:
        return 'insert';
      case SyncOperation.update:
        return 'update';
      case SyncOperation.delete:
        return 'delete';
    }
  }

  static SyncOperation fromString(String value) {
    switch (value) {
      case 'insert':
        return SyncOperation.insert;
      case 'update':
        return SyncOperation.update;
      case 'delete':
        return SyncOperation.delete;
      default:
        return SyncOperation.insert;
    }
  }
}

/// Step progress status
enum StepStatus {
  notStarted,
  inProgress,
  completed;

  String get value {
    switch (this) {
      case StepStatus.notStarted:
        return 'not_started';
      case StepStatus.inProgress:
        return 'in_progress';
      case StepStatus.completed:
        return 'completed';
    }
  }

  String get displayName {
    switch (this) {
      case StepStatus.notStarted:
        return 'Not Started';
      case StepStatus.inProgress:
        return 'In Progress';
      case StepStatus.completed:
        return 'Completed';
    }
  }

  static StepStatus fromString(String value) {
    switch (value) {
      case 'not_started':
        return StepStatus.notStarted;
      case 'in_progress':
        return StepStatus.inProgress;
      case 'completed':
        return StepStatus.completed;
      default:
        return StepStatus.notStarted;
    }
  }
}
