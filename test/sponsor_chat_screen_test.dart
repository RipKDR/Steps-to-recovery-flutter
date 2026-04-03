// test/sponsor_chat_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steps_recovery_flutter/core/models/sponsor_models.dart';
import 'package:steps_recovery_flutter/core/services/sponsor_service.dart';
import 'package:steps_recovery_flutter/features/ai_companion/screens/sponsor_chat_screen.dart';

/// A fake SponsorResponder that returns controlled responses.
/// Implements the SponsorResponder interface (defined in sponsor_service.dart).
class _FakeSponsorResponder implements SponsorResponder {
  _FakeSponsorResponder({this.response = 'I hear you.'});

  final String response;

  @override
  bool get hasIdentity => true;

  @override
  SponsorIdentity? get identity => SponsorIdentity(
    name: 'Rex',
    vibe: SponsorVibe.warm,
    createdAt: DateTime(2026, 3, 1),
  );

  @override
  SponsorStage get stage => SponsorStage.building;

  @override
  bool get isCloudAvailable => false;

  @override
  List<SponsorMemory> get longTermMemory => [];

  @override
  Future<String> respond({
    required String message,
    required String userId,
    List<ChatMessage>? conversationHistory,
    List<String>? recoveryContext,
    bool? isOnline,
  }) async => response;

  @override
  Future<void> digestSession() async {}

  @override
  Future<void> bumpEngagement({
    int checkInDays = 0,
    int chatDays = 0,
    int journalDays = 0,
  }) async {}

  @override
  Future<void> addSessionMemory(SponsorMemory memory) async {}

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  // Badge system (Phase 7)
  @override
  bool get hasPendingMessage => false;

  @override
  String? get pendingMessagePreview => null;

  @override
  void clearPendingMessage() {}

  // Feature hooks (Phase 7)
  @override
  Future<void> onCheckInCompleted({required int mood, required int craving}) async {}

  @override
  Future<void> onJournalSaved({required int wordCount}) async {}

  @override
  Future<void> onMilestoneReached(int days) async {}

  @override
  Future<void> onChallengeCompleted(String challengeName) async {}

  @override
  Future<void> onReturnFromSilence(int daysSilent) async {}
}

void main() {
  testWidgets('renders sponsor name in app bar', (tester) async {
    final fakeService = _FakeSponsorResponder(response: 'I hear you.');
    await tester.pumpWidget(MaterialApp(
      home: SponsorChatScreen(responder: fakeService),
    ));
    expect(find.text('Rex'), findsOneWidget);
    expect(find.text('Building'), findsOneWidget);
  });

  testWidgets('sends message and shows response', (tester) async {
    final fake = _FakeSponsorResponder(response: 'That sounds hard.');
    await tester.pumpWidget(MaterialApp(
      home: SponsorChatScreen(responder: fake),
    ));
    await tester.enterText(find.byType(TextField), 'Hello Rex');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump(); // starts async
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Hello Rex'), findsOneWidget);
  });

  testWidgets('shows 988 chip when crisis keyword sent', (tester) async {
    final fake = _FakeSponsorResponder(response: 'I am here.');
    await tester.pumpWidget(MaterialApp(
      routes: {'/emergency': (_) => const Scaffold()},
      home: SponsorChatScreen(responder: fake),
    ));
    await tester.enterText(find.byType(TextField), 'I want to kill myself');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();
    expect(find.textContaining('988'), findsOneWidget);
  });
}
