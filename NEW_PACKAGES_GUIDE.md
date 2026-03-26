# New Packages Setup Guide

This guide explains the newly added packages and how to use them effectively.

**Example Code Location:** All example files are in `docs/examples/`

---

## 📦 **New Runtime Packages**

### **1. Dio (`dio: ^5.4.0`)**
**Purpose:** Advanced HTTP client with interceptors, better error handling, and request cancellation.

**When to use:** Replace `http` package for complex API calls, especially for Supabase sync operations.

**Example:**
```dart
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 30),
));

// Add interceptors for logging, auth tokens, etc.
dio.interceptors.add(LogInterceptor(
  request: true,
  requestBody: true,
  responseBody: true,
));

// Make requests
try {
  final response = await dio.get('/users/123');
  print(response.data);
} on DioException catch (e) {
  print('Error: ${e.message}');
}
```

**Migration from `http`:**
```dart
// Old (http package)
final response = await http.get(Uri.parse(url));

// New (Dio)
final response = await dio.get(url);
```

---

### **2. Lottie (`lottie: ^3.1.0`)**
**Purpose:** Render After Effects animations as JSON files.

**When to use:** Celebration animations for milestones, achievements, sobriety counters.

**Setup:**
1. Download Lottie JSON files from [LottieFiles](https://lottiefiles.com/)
2. Add to `assets/animations/`
3. Update `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/animations/
```

**Example:**
```dart
import 'package:lottie/lottie.dart';

// Simple animation
Lottie.asset('assets/animations/celebration.json')

// With controller for repeat
Lottie.asset(
  'assets/animations/success.json',
  repeat: true,
  reverse: true,
  width: 200,
  height: 200,
)
```

**Use Cases:**
- ✅ Sobriety milestone celebrations
- ✅ Step completion animations
- ✅ Loading states
- ✅ Success feedback after journal entry

---

### **3. Flutter Staggered Animations (`flutter_staggered_animations: ^1.1.1`)**
**Purpose:** Easy staggered animations for lists and grids.

**When to use:** Animate list items as they appear (journal entries, meeting lists).

**Example:**
```dart
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

AnimationListBuilder(
  itemCount: journals.length,
  itemBuilder: (context, index) {
    return JournalCard(journal: journals[index]);
  },
  animationDuration: const Duration(milliseconds: 800),
  animationDelay: (index) => Duration(milliseconds: index * 100),
)
```

**Use Cases:**
- Journal list entries
- Meeting finder results
- Step cards
- Challenge lists

---

### **4. Haptic Feedback (`haptic_feedback: ^0.3.0`)**
**Purpose:** Trigger device vibration for tactile feedback.

**When to use:** Crisis button, check-in confirmations, milestone celebrations.

**Example:**
```dart
import 'package:haptic_feedback/haptic_feedback.dart';

// Light tap (subtle)
HapticFeedback.lightImpact();

// Medium tap (noticeable)
HapticFeedback.mediumImpact();

// Heavy tap (strong)
HapticFeedback.heavyImpact();

// Success pattern
HapticFeedback.success();

// Error pattern
HapticFeedback.error();

// Selection (for pickers)
HapticFeedback.selectionClick();
```

**Use Cases:**
- Emergency/SOS button press
- Craving slider interactions
- Mood rating selections
- Achievement unlocks
- Timer completions

---

## 🧪 **New Testing Packages**

### **1. Mocktail (`mocktail: ^1.0.4`)**
**Purpose:** Modern mocking library (simpler than Mockito, no code generation needed).

**When to use:** For new tests instead of `mockito`.

**Example:**
```dart
import 'package:mocktail/mocktail.dart';

// Create mock
class MockDatabaseService extends Mock implements DatabaseService {}

// In test
final mockDb = MockDatabaseService();
when(() => mockDb.getJournalEntry(any())).thenAnswer(
  (_) async => testEntry,
);

// Verify
verify(() => mockDb.saveJournalEntry(any())).called(1);
```

**Advantages over Mockito:**
- No `build_runner` needed
- Cleaner syntax
- Type-safe
- Faster tests

---

### **2. Golden Toolkit (`golden_toolkit: ^0.15.0`)**
**Purpose:** Visual regression testing with golden files.

**When to use:** Ensure UI components don't change unexpectedly.

**Example:**
```dart
import 'package:golden_toolkit/golden_toolkit.dart';

testWidgets('JournalCard matches golden', (tester) async {
  await tester.pumpDeviceBuilder(
    DeviceBuilder(
      () => JournalCard(journal: testJournal),
    ),
  );
  
  await screenMatchesGolden(tester, 'journal_card');
});
```

**Generate goldens:**
```bash
flutter test --update-goldens
```

---

### **3. Integration Test (`integration_test`)**
**Purpose:** End-to-end testing on real devices.

**When to use:** Test complete user flows (onboarding → login → journal entry).

**Setup:**
1. Create `integration_test/app_test.dart`
2. Run: `flutter test integration_test/app_test.dart`

**Example:**
```dart
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full app flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Tap through onboarding
    await tester.tap(find.byType(GetStartedButton));
    await tester.pumpAndSettle();
    
    // Verify home screen
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
```

---

## 🔨 **Code Generation Packages**

### **1. Freezed (`freezed: ^2.4.7`)**
**Purpose:** Generate immutable models with union types.

**When to use:** Complex state management, sealed classes.

**Example:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_state.freezed.dart';

@freezed
class UserState with _$UserState {
  const factory UserState.initial() = Initial;
  const factory UserState.loading() = Loading;
  const factory UserState.authenticated(User user) = Authenticated;
  const factory UserState.error(String message) = Error;
}

// Usage
state.when(
  initial: () => Text('Welcome'),
  loading: () => CircularProgressIndicator(),
  authenticated: (user) => Text('Hello ${user.name}'),
  error: (msg) => Text('Error: $msg'),
)
```

**Run codegen:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### **2. JSON Serializable (`json_serializable: ^6.7.1`)**
**Purpose:** Auto-generate JSON serialization code.

**When to use:** API models, data transfer objects.

**Example:**
```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final DateTime createdAt;

  User({required this.id, required this.name, required this.createdAt});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

**Run codegen:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📋 **Linting Enhancements**

### **Very Good Analysis (`very_good_analysis: ^6.0.0`)**
**Purpose:** Stricter lint rules from Very Good Ventures.

**Enable in `analysis_options.yaml`:**
```yaml
include: package:very_good_analysis/analysis_options.yaml
```

**What it adds:**
- Prefer `const` constructors
- Avoid `print()` statements
- Require documentation comments
- Enforce exhaustive enum checks
- Better null safety rules

---

## 🎯 **Recommended Next Steps**

1. **Install VS Code extensions** when prompted
2. **Try Dio** for your next API call
3. **Add a Lottie animation** for milestone celebrations
4. **Write a golden test** for a critical widget
5. **Enable very_good_analysis** if you want stricter linting

---

## 📝 **Commands Reference**

```bash
# Install dependencies
flutter pub get

# Run code generation (freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Update golden files
flutter test --update-goldens

# Run integration tests
flutter test integration_test/

# Analyze code
flutter analyze

# Check for outdated packages
flutter pub outdated
```

---

## ⚠️ **Important Notes**

- **Golden Toolkit is discontinued** but still works. Consider migrating to `golden_files` in the future.
- **Freezed and json_serializable** require running `build_runner` after changes.
- **Integration tests** require a physical device or emulator.
- **Haptic feedback** won't work on web or desktop platforms.

---

**Questions?** Check individual package documentation:
- [Dio Docs](https://pub.dev/packages/dio)
- [Lottie Docs](https://pub.dev/packages/lottie)
- [Mocktail Docs](https://pub.dev/packages/mocktail)
- [Freezed Docs](https://pub.dev/packages/freezed)
