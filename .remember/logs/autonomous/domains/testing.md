# Testing Patterns — Steps to Recovery

## Framework

**`flutter_test`** + **`mockito`** (no `mockito` codegen/build_runner)

## Running Tests

```powershell
.\tool\flutterw.ps1 test                                      # All tests
.\tool\flutterw.ps1 test test/database_service_test.dart      # Single file
.\tool\flutterw.ps1 test --coverage                          # With coverage
.\tool\flutterw.ps1 test --coverage && genhtml coverage/lcov.info --output=coverage/html  # HTML report
```

## Test File Organization

```
test/
├── core/
│   ├── services/
│   │   ├── connectivity_service_test.dart
│   │   ├── database_service_test.dart
│   │   ├── encryption_service_test.dart
│   │   ├── notification_service_test.dart
│   │   ├── preferences_service_test.dart
│   │   └── ai_service_test.dart
│   └── utils/
├── features/
│   ├── auth/
│   ├── journal/
│   ├── steps/
│   └── crisis_screens_test.dart
├── navigation/
│   └── router_feature_shell_test.dart
├── widgets/
├── integration/
│   └── app_flow_test.dart
└── test_helpers.dart  # Shared test utilities
```

## Test Setup Pattern

### test_helpers.dart
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Initialize mocked storage
Future<void> prepareTestState() async {
  SharedPreferences.setMockInitialValues({});
  // Initialize services with mocks
}

// Create authenticated user state
Future<void> createSignedInUser() async {
  await AppStateService.instance.signUp(
    email: 'test@example.com',
    password: 'password123',
  );
}
```

### Usage in Test Files
```dart
import 'package:flutter_test/flutter_test.dart';
import 'test_helpers.dart';

void main() {
  setUp(() async {
    await prepareTestState();
  });

  test('should do something', () async {
    await createSignedInUser();
    // Test logic
  });
}
```

## Unit Test Patterns

### Service Test Pattern
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([DatabaseService, EncryptionService])
void main() {
  late MyService service;
  late MockDatabaseService mockDatabase;
  late MockEncryptionService mockEncryption;

  setUp(() {
    mockDatabase = MockDatabaseService();
    mockEncryption = MockEncryptionService();
    service = MyService(
      database: mockDatabase,
      encryption: mockEncryption,
    );
  });

  test('should save data when valid', () async {
    // Arrange
    when(mockDatabase.insert(any, any)).thenAnswer((_) async => 1);
    
    // Act
    await service.saveData(testData);
    
    // Assert
    verify(mockDatabase.insert(any, testData)).called(1);
  });
}
```

### Fake Pattern for Platform Channels
**DO NOT use Mockito mocks for platform-channel dependencies** — write custom `_Fake*` classes:

```dart
// Good: Custom fake for platform-dependent service
class _FakeConnectivityService extends ConnectivityService {
  late _FakeConnectivity _fake;
  
  void injectFake(_FakeConnectivity fake) => _fake = fake;
  
  @override
  Future<bool> get isConnected async => _fake.isConnected;
  
  @override
  Stream<bool> get connectivityStream => _fake.streamController.stream;
}

class _FakeConnectivity {
  bool isConnected = true;
  final streamController = StreamController<bool>.broadcast();
  
  void emitConnectionChange(bool connected) {
    streamController.add(connected);
  }
}

// Usage in test
void main() {
  late _FakeConnectivityService service;
  late _FakeConnectivity fakeConnectivity;

  setUp(() {
    fakeConnectivity = _FakeConnectivity();
    service = _FakeConnectivityService();
    service.injectFake(fakeConnectivity);
  });

  test('should emit true when connected', () async {
    // Arrange
    fakeConnectivity.isConnected = true;
    
    // Act & Assert
    expect(await service.isConnected, true);
  });
}
```

## Widget Test Patterns

### Basic Widget Test
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_to_recovery/widgets/action_card.dart';

void main() {
  testWidgets('ActionCard displays title', (tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionCard(
            title: 'Test Card',
            icon: Icons.star,
            onTap: () {},
          ),
        ),
      ),
    );

    // Act & Assert
    expect(find.text('Test Card'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}
```

### Widget Test with Mocked Services
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

@GenerateMocks([AppStateService])
void main() {
  testWidgets('HomeScreen shows user name', (tester) async {
    // Arrange
    final mockService = MockAppStateService();
    when(mockService.currentUser).thenReturn(User(name: 'John'));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: mockService,
        child: MaterialApp(home: HomeScreen()),
      ),
    );

    // Assert
    expect(find.text('John'), findsOneWidget);
  });
}
```

### Golden Test Pattern
```dart
import 'package:flutter_goldens/flutter_goldens.dart';

void main() {
  testWidgets('ActionCard matches golden', (tester) async {
    final card = ActionCard(
      title: 'Morning Intention',
      icon: Icons.sunny,
      onTap: () {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: card),
      ),
    );

    expect(
      find.byType(ActionCard),
      matchesGoldenFile('goldens/action_card.png'),
    );
  });
}
```

## Integration Test Patterns

### App Flow Test
```dart
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_to_recovery/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full onboarding flow', (tester) async {
    // Start app
    app.main();
    await tester.pumpAndSettle();

    // Navigate through onboarding
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(
      find.byType(TextFormField),
      'test@example.com',
    );
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Assert navigation to home
    expect(find.text('Morning Intention'), findsOneWidget);
  });
}
```

## Test Coverage Patterns

### What to Test

| Component | Test Type | Coverage Goal |
|-----------|-----------|---------------|
| Services | Unit tests | 90%+ |
| Models | Unit tests | 100% |
| Utilities | Unit tests | 90%+ |
| Screens | Widget tests | Critical paths |
| Widgets | Widget tests | Reusable components |
| Navigation | Widget tests | All routes |
| Flows | Integration tests | E2E critical paths |

### What NOT to Test

- Flutter framework code
- Third-party library internals
- UI pixel-perfect appearance (use golden tests sparingly)
- Private methods (test via public API)

## Common Pitfalls

### 1. Not Isolating Tests
```dart
// Bad: Tests depend on each other
test('should create user', () async { ... });
test('should use user from previous test', () async { ... });

// Good: Each test is independent
setUp(() async {
  await prepareTestState();
  await createSignedInUser();
});
```

### 2. Testing Implementation Instead of Behavior
```dart
// Bad: Testing internal state
expect(service._isLoading, true);

// Good: Testing observable behavior
expect(await service.loadData(), completes);
```

### 3. Not Using Async Properly
```dart
// Bad: Missing await
test('should load data', () async {
  service.loadData(); // Missing await!
  expect(service.data, isNotEmpty);
});

// Good: Proper async
test('should load data', () async {
  await service.loadData();
  expect(service.data, isNotEmpty);
});
```

### 4. Over-Mocking
```dart
// Bad: Mocking everything
@GenerateMocks([Service1, Service2, Service3, Service4, Service5])

// Good: Mock only dependencies
@GenerateMocks([DatabaseService, EncryptionService])
```

## Test Files Overview

| Test File | Coverage |
|-----------|----------|
| `connectivity_service_test.dart` | Connectivity monitoring with fake |
| `database_service_test.dart` | CRUD operations, encryption |
| `encryption_service_test.dart` | AES-256 encryption/decryption |
| `notification_service_test.dart` | Local notification scheduling |
| `preferences_service_test.dart` | SharedPreferences wrapper |
| `ai_service_test.dart` | Google AI integration |
| `crisis_screens_test.dart` | Emergency screen widgets |
| `router_feature_shell_test.dart` | Navigation routing |
| `app_flow_test.dart` | End-to-end app flows |

---

**Last Updated:** 2026-03-27  
**Source:** `.remember/logs/autonomous/domains/testing.md`
