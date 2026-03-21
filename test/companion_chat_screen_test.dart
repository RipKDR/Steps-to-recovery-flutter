import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:steps_recovery_flutter/core/models/database_models.dart';
import 'package:steps_recovery_flutter/core/services/ai_service.dart';
import 'package:steps_recovery_flutter/core/services/app_state_service.dart';
import 'package:steps_recovery_flutter/features/ai_companion/screens/companion_chat_screen.dart';

import 'test_helpers.dart';

void main() {
  testWidgets(
    'companion chat uses the configured cloud responder before local fallback',
    (tester) async {
      await createSignedInUser();
      await AppStateService.instance.setAiProxyEnabled(true);
      final responder = _FakeCompanionResponder();

      await tester.pumpWidget(
        MaterialApp(home: CompanionChatScreen(responder: responder)),
      );
      await _pumpChat(tester);

      await tester.enterText(
        find.byType(TextField),
        'I need help with my sponsor',
      );
      await tester.tap(find.byIcon(Icons.send));
      await _pumpChat(tester);

      expect(responder.calls, 1);
      expect(responder.lastMessage, 'I need help with my sponsor');
      expect(find.text('Cloud guidance response'), findsOneWidget);
    },
  );
}

class _FakeCompanionResponder implements CompanionResponder {
  int calls = 0;
  String? lastMessage;

  @override
  bool get isCloudAvailable => true;

  @override
  Future<String> respond({
    required String message,
    required String userId,
    List<ChatMessage>? conversationHistory,
    List<String>? recoveryContext,
  }) async {
    calls += 1;
    lastMessage = message;
    return 'Cloud guidance response';
  }
}

Future<void> _pumpChat(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}
