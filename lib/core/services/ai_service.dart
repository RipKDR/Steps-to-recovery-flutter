import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app_config.dart';
import '../models/database_models.dart';

abstract class CompanionResponder {
  bool get isCloudAvailable;

  Future<String> respond({
    required String message,
    required String userId,
    List<ChatMessage>? conversationHistory,
    List<String>? recoveryContext,
  });
}

/// AI service for chat and memory extraction
class AiService implements CompanionResponder {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  final String _apiKey = AppConfig.resolvedGoogleAiApiKey;

  bool get isEnabled =>
      _apiKey.isNotEmpty || AppConfig.aiChatEdgeFunctionUrl.isNotEmpty;
  bool get _useEdgeFunction => AppConfig.aiChatEdgeFunctionUrl.isNotEmpty;
  @override
  bool get isCloudAvailable => isEnabled;

  @override
  Future<String> respond({
    required String message,
    required String userId,
    List<ChatMessage>? conversationHistory,
    List<String>? recoveryContext,
  }) {
    return chat(
      message: message,
      userId: userId,
      conversationHistory: conversationHistory,
      recoveryContext: recoveryContext,
    );
  }

  /// Send a message to the AI and get a response
  Future<String> chat({
    required String message,
    required String userId,
    List<ChatMessage>? conversationHistory,
    List<String>? recoveryContext,
  }) async {
    if (!isEnabled) {
      return 'AI companion is not configured. Please add your API key in settings.';
    }

    try {
      if (_useEdgeFunction) {
        return await _chatViaEdgeFunction(
          message: message,
          conversationHistory: conversationHistory,
          recoveryContext: recoveryContext,
        );
      }

      final prompt = buildChatPrompt(
        message: message,
        conversationHistory: conversationHistory,
        recoveryContext: recoveryContext,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/models/gemini-pro:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 1024},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            'I\'m here for you. Tell me more about how you\'re feeling.';
      } else {
        debugPrint('AI API error: ${response.statusCode} - ${response.body}');
        return 'I\'m having trouble connecting right now. Please know that I\'m here for you when I\'m back online.';
      }
    } catch (e) {
      debugPrint('AI service error: $e');
      return 'Something went wrong. Please try again later.';
    }
  }

  @visibleForTesting
  String buildChatPrompt({
    required String message,
    List<ChatMessage>? conversationHistory,
    List<String>? recoveryContext,
  }) {
    final buffer = StringBuffer()
      ..writeln('Role and goal')
      ..writeln(
        'You are a recovery companion for a privacy-first 12-step app. '
        'Be warm, calm, practical, and non-judgmental.',
      )
      ..writeln()
      ..writeln('Safety rules')
      ..writeln(
        '- Do not claim to be a therapist, sponsor, clinician, or emergency service.',
      )
      ..writeln(
        '- If the user suggests imminent self-harm, overdose, or unsafe relapse risk, tell them to contact emergency or crisis support immediately and keep the rest of the answer short.',
      )
      ..writeln(
        '- Prefer concrete, local next steps such as sponsor contact, meetings, breathing, journaling, or safety-plan actions.',
      )
      ..writeln()
      ..writeln('Conversation context')
      ..writeln(_buildConversationContext(conversationHistory))
      ..writeln()
      ..writeln('Recovery context')
      ..writeln(_buildRecoveryContext(recoveryContext))
      ..writeln()
      ..writeln('User message')
      ..writeln(message.trim())
      ..writeln()
      ..writeln('Response contract')
      ..writeln('- Start with one sentence of empathy.')
      ..writeln('- Give 2-4 concrete next steps.')
      ..writeln('- Reference sponsor, meeting, or program context when useful.')
      ..writeln('- Keep the answer under 170 words.')
      ..writeln(
        '- If information is missing, say what is missing briefly and continue with the safest useful guidance.',
      );

    return buffer.toString().trim();
  }

  String _buildConversationContext(List<ChatMessage>? history) {
    if (history == null || history.isEmpty) {
      return 'No prior conversation provided.';
    }

    final recentMessages = history.length > 8
        ? history.sublist(history.length - 8)
        : history;
    final buffer = StringBuffer();

    for (final msg in recentMessages) {
      buffer.writeln('${msg.isUser ? "User" : "Assistant"}: ${msg.content}');
    }

    return buffer.toString().trim();
  }

  String _buildRecoveryContext(List<String>? recoveryContext) {
    if (recoveryContext == null || recoveryContext.isEmpty) {
      return 'No extra recovery context provided.';
    }

    return recoveryContext
        .where((item) => item.trim().isNotEmpty)
        .map((item) => '- ${item.trim()}')
        .join('\n');
  }

  /// Route chat through Supabase Edge Function (API key stays server-side).
  Future<String> _chatViaEdgeFunction({
    required String message,
    List<ChatMessage>? conversationHistory,
    List<String>? recoveryContext,
  }) async {
    final history = conversationHistory
            ?.map((m) => {
                  'role': m.isUser ? 'User' : 'Assistant',
                  'content': m.content,
                })
            .toList() ??
        [];

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Add Supabase auth token if available
    try {
      final token =
          Supabase.instance.client.auth.currentSession?.accessToken;
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Supabase not initialized — send without auth
    }

    final response = await http.post(
      Uri.parse(AppConfig.aiChatEdgeFunctionUrl),
      headers: headers,
      body: jsonEncode({
        'message': message.trim(),
        'conversationHistory': history,
        'recoveryContext': recoveryContext ?? [],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'] as String? ??
          'I\'m here for you. Tell me more about how you\'re feeling.';
    }

    debugPrint(
        'Edge function error: ${response.statusCode} - ${response.body}');
    return 'I\'m having trouble connecting right now. Please know that I\'m here for you when I\'m back online.';
  }

  /// Detect if a message indicates crisis
  bool detectCrisis(String message) {
    final crisisKeywords = [
      'suicide',
      'kill myself',
      'end it all',
      'give up',
      'can\'t go on',
      'want to die',
      'use again',
      'relapse',
      'overdose',
      'hurt myself',
      'self harm',
    ];

    final lowerMessage = message.toLowerCase();
    return crisisKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  /// Extract memories from journal/check-in for AI context
  List<String> extractMemories({String? journalEntry, DailyCheckIn? checkIn}) {
    final memories = <String>[];

    if (journalEntry != null && journalEntry.isNotEmpty) {
      // Extract key themes (simplified - in production use NLP)
      if (journalEntry.toLowerCase().contains('grateful')) {
        memories.add('User expressed gratitude');
      }
      if (journalEntry.toLowerCase().contains('struggling')) {
        memories.add('User is struggling');
      }
      if (journalEntry.toLowerCase().contains('meeting')) {
        memories.add('User attended a meeting');
      }
    }

    if (checkIn != null) {
      if (checkIn.mood != null && checkIn.mood! <= 2) {
        memories.add('User reported low mood (${checkIn.mood})');
      }
      if (checkIn.craving != null && checkIn.craving! >= 7) {
        memories.add('User reported high craving (${checkIn.craving})');
      }
    }

    return memories;
  }

  /// Get step work guidance
  Future<String> getStepGuidance({
    required int stepNumber,
    String? question,
  }) async {
    if (!isEnabled) {
      return 'AI is not configured. Please work through the step questions on your own or with your sponsor.';
    }

    try {
      final prompt =
          '''
You are helping someone work through Step $stepNumber of the 12-step program.

${question != null ? 'Question: $question' : 'Provide general guidance for Step $stepNumber.'}

Offer thoughtful, encouraging guidance that helps them reflect deeply on this step.
Keep the response focused and practical.
''';

      final response = await http.post(
        Uri.parse('$_baseUrl/models/gemini-pro:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            'Keep working through the questions. Take your time with this step.';
      }
    } catch (e) {
      debugPrint('Step guidance error: $e');
    }

    return 'Take your time with Step $stepNumber. Consider discussing with your sponsor.';
  }

  /// Get coping strategies for cravings
  Future<String> getCopingStrategies({required int cravingLevel}) async {
    final strategies = [
      'Take 10 deep breaths. Focus on breathing in slowly through your nose, out through your mouth.',
      'Call your sponsor or a trusted friend in recovery.',
      'Go for a walk. Physical movement can help reset your mind.',
      'Remember: cravings are like waves. They build, peak, and pass. This will pass.',
      'Play the tape forward. What happens after you use? Is it worth it?',
      'Attend a meeting today. You don\'t have to do this alone.',
      'Write down what you\'re feeling. Sometimes putting it on paper helps.',
      'Wait 15 minutes. Do something else. The urge will weaken.',
    ];

    if (cravingLevel >= 8) {
      return '''
This is a strong craving. Here are immediate steps:

1. ${strategies[0]}
2. ${strategies[1]}
3. ${strategies[4]}

Remember: You don't have to use today. Just get through this moment.
''';
    }

    return '''
Here are some strategies that might help:

• ${strategies[cravingLevel % strategies.length]}
• ${strategies[(cravingLevel + 1) % strategies.length]}
• ${strategies[(cravingLevel + 2) % strategies.length]}

You've handled cravings before. You can do it again.
''';
  }
}
