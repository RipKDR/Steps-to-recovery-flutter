# Dart Patterns — Steps to Recovery

## Language Version

**Dart 3.11.4** with full null safety and modern features

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Variables | `lowerCamelCase` | `currentUser`, `sobrietyDate` |
| Methods | `lowerCamelCase` | `calculateDaysSobriety()`, `encryptData()` |
| Parameters | `lowerCamelCase` | `required String userId` |
| Classes | `UpperCamelCase` | `JournalEntry`, `SponsorContact` |
| Enums | `UpperCamelCase` | `StepStatus`, `MoodLevel` |
| Enum values | `lowerCamelCase` | `completed`, `inProgress` |
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_RETRY_ATTEMPTS`, `API_TIMEOUT` |
| Files | `snake_case` | `journal_entry.dart`, `database_service.dart` |
| Libraries | `snake_case` | `database_service`, `app_constants` |

## Null Safety Patterns

### Required Parameters
```dart
// Good: Explicit required
class JournalEntry {
  final String id;
  final DateTime timestamp;
  
  JournalEntry({
    required this.id,
    required this.timestamp,
  });
}
```

### Nullable Types
```dart
// Good: Explicit nullable
String? _optionalNote;
void updateNote(String? note) => _optionalNote = note;
```

### Null-Aware Operators
```dart
// Good: Use null-aware operators
final userName = user?.displayName ?? 'Anonymous';
final steps = completedSteps?.where((s) => s.isDone).toList() ?? [];
```

## Modern Dart 3 Features

### Records (Dart 3.0+)
```dart
// Good: Use records for multiple returns
(String, int) getUserStats(String userId) {
  return ('John Doe', 30);
}

final (name, days) = getUserStats('123');
```

### Patterns (Dart 3.0+)
```dart
// Good: Use pattern matching
switch (stepStatus) {
  case StepStatus.notStarted:
    return 'Not started';
  case StepStatus.inProgress:
    return 'In progress';
  case StepStatus.completed:
    return 'Completed';
}

// Or with if-case
if (user case User(isPremium: true)) {
  showPremiumFeatures();
}
```

### Sealed Classes (Dart 3.0+)
```dart
// Good: Sealed class for state management
sealed class RecoveryState {}

class RecoveryStateInitial extends RecoveryState {}
class RecoveryStateActive extends RecoveryState {
  final int daysSobriety;
  RecoveryStateActive(this.daysSobriety);
}
class RecoveryStateRelapsed extends RecoveryState {}
```

### Extension Types (Dart 3.3+)
```dart
// Good: Type-safe wrappers
extension type UserId(String value) {
  bool isValid() => value.length >= 36; // UUID length
}

extension type SobrietyDays(int value) {
  bool isMilestone() => value % 30 == 0;
}
```

## Async/Await Patterns

### Good: Clean async chain
```dart
Future<JournalEntry> saveJournalEntry(JournalEntry entry) async {
  await loggerService.info('Saving journal entry');
  final encrypted = encryptionService.encrypt(entry.content);
  return await databaseService.createJournal(entry.copyWith(content: encrypted));
}
```

### Good: Error handling
```dart
Future<void> syncData() async {
  try {
    await syncService.syncNow();
  } on SyncException catch (e) {
    loggerService.error('Sync failed', error: e, stackTrace: e.stackTrace);
    rethrow;
  } catch (e, st) {
    loggerService.error('Unexpected error', error: e, stackTrace: st);
    throw;
  }
}
```

### Avoid: Nested futures
```dart
// Bad: Nested callbacks
Future<void> fetchData() {
  return http.get(url).then((response) {
    return json.decode(response.body).then((data) {
      return process(data);
    });
  });
}

// Good: Async/await
Future<void> fetchData() async {
  final response = await http.get(url);
  final data = json.decode(response.body);
  return process(data);
}
```

## Generics Patterns

### Type-Safe Collections
```dart
// Good: Explicit types
final Map<String, List<JournalEntry>> _journalCache = {};
final Stream<RecoveryMilestone> get milestones => _milestonesController.stream;
```

### Generic Constraints
```dart
// Good: Constrained generics
class Cache<T extends Identifiable> {
  final Map<String, T> _cache = {};
  
  void add(T item) => _cache[item.id] = item;
  T? get(String id) => _cache[id];
}
```

## Mixins Pattern

```dart
// Good: Mixin for shared behavior
mixin Loggable {
  void log(String message) {
    LoggerService().info(message);
  }
}

class DatabaseService with Loggable {
  void createEntry(Map<String, dynamic> data) {
    log('Creating database entry');
    // ...
  }
}
```

## Common Pitfalls

### 1. Not Using `const` Constructors
```dart
// Bad: Runtime creation
Widget build(BuildContext context) {
  return Container(
    child: Text('Hello'),
  );
}

// Good: Compile-time constant
Widget build(BuildContext context) {
  return const Container(
    child: Text('Hello'),
  );
}
```

### 2. Ignoring `required` Keyword
```dart
// Bad: Unclear which params are mandatory
JournalEntry({this.id, this.timestamp, this.content});

// Good: Explicit required
JournalEntry({
  required this.id,
  required this.timestamp,
  required this.content,
});
```

### 3. Overusing `dynamic`
```dart
// Bad: Type-unsafe
void processData(dynamic data) { ... }

// Good: Explicit type
void processData(Map<String, dynamic> data) { ... }
```

### 4. Not Using Final/Const
```dart
// Bad: Mutable when immutable
var maxDays = 365;
String greeting = 'Hello';

// Good: Immutable when possible
const maxDays = 365;
const greeting = 'Hello';
```

## Extension Methods

```dart
// Good: Useful extensions
extension DateTimeExtension on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  String toRecoveryFormat() {
    return '$day/$month/$year';
  }
}

extension StringExtension on String {
  String capitalize() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
  }
}
```

---

**Last Updated:** 2026-03-27  
**Source:** `.remember/logs/autonomous/domains/dart.md`
