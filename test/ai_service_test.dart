import 'package:flutter_test/flutter_test.dart';

import 'package:steps_recovery_flutter/core/models/database_models.dart';
import 'package:steps_recovery_flutter/core/services/ai_service.dart';

void main() {
  test(
    'buildChatPrompt creates a structured recovery prompt with context and response contract',
    () {
      final prompt = AiService().buildChatPrompt(
        message: 'I need help with cravings tonight.',
        conversationHistory: <ChatMessage>[
          ChatMessage(
            id: '1',
            conversationId: 'conversation-1',
            userId: 'user-1',
            content: 'I made it through a tough afternoon.',
            isUser: true,
            createdAt: DateTime(2026, 3, 21, 18),
          ),
        ],
        recoveryContext: const <String>[
          'Program: NA',
          'Sponsor: Alex (saved locally)',
          'Next meeting: Saturday 7:00 PM',
        ],
      );

      expect(prompt, contains('Role and goal'));
      expect(prompt, contains('Safety rules'));
      expect(prompt, contains('Conversation context'));
      expect(prompt, contains('Recovery context'));
      expect(prompt, contains('User message'));
      expect(prompt, contains('Response contract'));
      expect(prompt, contains('I need help with cravings tonight.'));
      expect(prompt, contains('Program: NA'));
      expect(prompt, contains('User: I made it through a tough afternoon.'));
    },
  );
}
