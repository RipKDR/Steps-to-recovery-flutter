import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/recovery_content.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// AI Companion Chat screen
class CompanionChatScreen extends StatefulWidget {
  const CompanionChatScreen({super.key, CompanionResponder? responder})
    : responder = responder ?? const _DefaultCompanionResponder();

  final CompanionResponder responder;

  @override
  State<CompanionChatScreen> createState() => _CompanionChatScreenState();
}

class _CompanionChatScreenState extends State<CompanionChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  final List<ChatMessage> _messages = <ChatMessage>[];

  ChatConversation? _conversation;
  String? _currentUserId;
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final database = DatabaseService();
    await database.initialize();
    final currentUser = await database.getCurrentUser();

    if (currentUser == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    var conversations = await database.getChatConversations(
      userId: currentUser.id,
    );
    ChatConversation conversation;
    if (conversations.isNotEmpty) {
      conversation = conversations.first;
    } else {
      conversation = await database.saveChatConversation(
        ChatConversation(
          id: '',
          userId: currentUser.id,
          title: 'Recovery companion',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    var messages = await database.getChatMessages(
      conversationId: conversation.id,
    );
    if (messages.isEmpty) {
      await database.saveChatMessage(
        ChatMessage(
          id: '',
          conversationId: conversation.id,
          userId: currentUser.id,
          content: _initialGreeting(),
          isUser: false,
          createdAt: DateTime.now(),
        ),
      );
      messages = await database.getChatMessages(
        conversationId: conversation.id,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _conversation = conversation;
      _currentUserId = currentUser.id;
      _messages
        ..clear()
        ..addAll(messages);
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _refreshMessages() async {
    final conversation = _conversation;
    if (conversation == null) {
      return;
    }
    final messages = await DatabaseService().getChatMessages(
      conversationId: conversation.id,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _messages
        ..clear()
        ..addAll(messages);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _sendMessage([String? text]) async {
    if (_isLoading || _isSending) {
      return;
    }

    final messageText = (text ?? _messageController.text).trim();
    if (messageText.isEmpty) {
      return;
    }

    final userId = _currentUserId;
    final conversation = _conversation;
    if (userId == null || conversation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to use the companion chat.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    final database = DatabaseService();
    await database.saveChatMessage(
      ChatMessage(
        id: '',
        conversationId: conversation.id,
        userId: userId,
        content: messageText,
        isUser: true,
        createdAt: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }

    _messageController.clear();
    await _refreshMessages();

    final response = await _buildResponse(messageText);
    if (!mounted) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));

    await database.saveChatMessage(
      ChatMessage(
        id: '',
        conversationId: conversation.id,
        userId: userId,
        content: response,
        isUser: false,
        createdAt: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSending = false;
    });

    await _refreshMessages();
  }

  Future<String> _buildResponse(String messageText) async {
    if (_shouldUseCloudResponder) {
      try {
        final response = await widget.responder.respond(
          message: messageText,
          userId: _currentUserId!,
          conversationHistory: List<ChatMessage>.from(_messages),
          recoveryContext: await _buildRecoveryContext(),
        );
        if (response.trim().isNotEmpty) {
          return response.trim();
        }
      } catch (_) {
        // Fall back to the local responder so the chat remains available offline.
      }
    }

    return _buildLocalResponse(messageText);
  }

  bool get _shouldUseCloudResponder =>
      AppStateService.instance.aiProxyEnabled &&
      _currentUserId != null &&
      widget.responder.isCloudAvailable;

  bool get _cloudGuidanceConfigured =>
      AppStateService.instance.aiProxyEnabled &&
      widget.responder.isCloudAvailable;

  Future<List<String>> _buildRecoveryContext() async {
    final context = <String>[];
    final appState = AppStateService.instance;

    if (appState.displayName != null &&
        appState.displayName!.trim().isNotEmpty) {
      context.add('User display name: ${appState.displayName!.trim()}');
    }
    if (appState.programType != null &&
        appState.programType!.trim().isNotEmpty) {
      context.add('Program: ${appState.programType!.trim()}');
    }
    if (appState.sobrietyDate != null) {
      context.add('Sobriety summary: ${appState.sobrietySummary}');
    }

    final sponsor = _currentUserId == null
        ? null
        : await DatabaseService().getSponsor(_currentUserId!);
    if (sponsor != null) {
      context.add('Sponsor: ${sponsor.name} (${sponsor.phoneNumber})');
    }

    final nextMeeting = await _getNextMeeting();
    if (nextMeeting != null) {
      context.add(
        'Next meeting: ${nextMeeting.name} at ${_formatMeetingTime(nextMeeting.dateTime)}',
      );
    }

    return context;
  }

  Future<String> _buildLocalResponse(String messageText) async {
    final lower = messageText.toLowerCase();
    final database = DatabaseService();
    final sponsor = _currentUserId == null
        ? null
        : await database.getSponsor(_currentUserId!);
    final nextMeeting = await _getNextMeeting();

    if (_containsAny(lower, const [
      'suicide',
      'kill myself',
      'end my life',
      'overdose',
      'hurt myself',
      'not safe',
      'self harm',
    ])) {
      final crisisLine = _crisisLine('988 Suicide & Crisis Lifeline');
      final emergencyLine = _crisisLine('Emergency');
      return [
        'I am staying local with you right now.',
        'If you are in immediate danger, call $emergencyLine or $crisisLine now.',
        'Move to a safer place, put distance between you and anything you could use, and contact someone you trust.',
      ].join(' ');
    }

    if (_containsAny(lower, const [
      'craving',
      'urge',
      'want to use',
      'drink',
      'use',
      'relapse',
      'high',
    ])) {
      final supportText = sponsor == null
          ? 'call a trusted support person'
          : 'call ${sponsor.name} at ${sponsor.phoneNumber}';
      final meetingText = nextMeeting == null
          ? 'open your safety plan and use one grounding action'
          : 'go to ${nextMeeting.name} at ${_formatMeetingTime(nextMeeting.dateTime)}';
      return [
        'This is a craving moment, so keep it simple and local.',
        'Breathe, drink water, and do one thing from your safety plan.',
        'Then $supportText and $meetingText instead of staying alone with it.',
      ].join(' ');
    }

    if (_containsAny(lower, const [
      'sponsor',
      'meeting',
      'support',
      'help',
      'lonely',
    ])) {
      if (sponsor != null) {
        return [
          'Reach out to ${sponsor.name} at ${sponsor.phoneNumber}.',
          if (sponsor.email != null && sponsor.email!.trim().isNotEmpty)
            'You also have ${sponsor.email} saved locally.',
          if (nextMeeting != null)
            'Your next meeting is ${nextMeeting.name} at ${_formatMeetingTime(nextMeeting.dateTime)}.',
          'If you need something immediate, open your safety plan from the main app.',
        ].join(' ');
      }
      return [
        'You do not have a sponsor saved yet, so use the local tools you already have.',
        if (nextMeeting != null)
          'A meeting is coming up soon: ${nextMeeting.name} at ${_formatMeetingTime(nextMeeting.dateTime)}.',
        'Open the Safety Plan and use the first contact or coping step that feels easiest.',
      ].join(' ');
    }

    if (_containsAny(lower, const [
      'step',
      'inventory',
      'resentment',
      'amends',
      'character',
    ])) {
      return [
        'Take the next step, not the whole program.',
        'Write one honest answer, review what you already know, and stop when you need to.',
        'If it helps, use the Journal or Steps tab to keep the work organized locally.',
      ].join(' ');
    }

    if (_containsAny(lower, const [
      'grateful',
      'gratitude',
      'good day',
      'wins',
    ])) {
      return [
        'Keep that momentum going.',
        'Write down three things that are working, then protect them with one concrete action today.',
      ].join(' ');
    }

    return [
      'I am here with a local-only response path, so no network is required.',
      'Tell me what feels hardest right now, and I will help you turn it into one small next action.',
    ].join(' ');
  }

  Future<Meeting?> _getNextMeeting() async {
    final now = DateTime.now();
    final meetings = await DatabaseService().getMeetings();
    for (final meeting in meetings) {
      final dateTime = meeting.dateTime;
      if (dateTime != null && !dateTime.isBefore(now)) {
        return meeting;
      }
    }
    return meetings.isNotEmpty ? meetings.first : null;
  }

  bool _containsAny(String source, List<String> keywords) {
    for (final keyword in keywords) {
      if (source.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  String _initialGreeting() {
    if (_cloudGuidanceConfigured) {
      return 'Cloud recovery guidance is available, and a local fallback stays ready if you lose connectivity. What is going on today?';
    }
    if (AppStateService.instance.aiProxyEnabled) {
      return 'Cloud support is enabled in settings, but this device is currently using the local fallback path. What is going on today?';
    }
    return 'Local recovery support is active. No network is required for responses. What is going on today?';
  }

  String _crisisLine(String title) {
    final resource = crisisResources.firstWhere(
      (item) =>
          item.title.toLowerCase().contains(title.toLowerCase()) ||
          item.phone == title,
      orElse: () => crisisResources.firstWhere(
        (item) => item.isEmergency,
        orElse: () => crisisResources.first,
      ),
    );
    return '${resource.title} (${resource.phone})';
  }

  String _formatMeetingTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'an unscheduled time';
    }
    return DateFormat('EEE, MMM d • h:mm a').format(dateTime);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStateService.instance,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('AI Companion'),
            backgroundColor: AppColors.background,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _shouldUseCloudResponder
                            ? 'Cloud guidance is active, with local fallback kept ready.'
                            : AppStateService.instance.aiProxyEnabled
                            ? 'Cloud proxy is enabled, but local fallback is handling responses until cloud access is configured.'
                            : 'Local-only support is active.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryAmber,
                  ),
                )
              : _currentUserId == null || _conversation == null
              ? _SignedOutState(
                  onSignInHint: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Sign in to start a local companion chat.',
                        ),
                      ),
                    );
                  },
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.offline_bolt,
                              color: AppColors.primaryAmber,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                _shouldUseCloudResponder
                                    ? 'Cloud guidance is active for richer responses, and local recovery guidance remains available if cloud support drops.'
                                    : AppStateService.instance.aiProxyEnabled
                                    ? 'Cloud support is enabled, but this chat is using the local fallback until cloud access is configured.'
                                    : 'Local-only guidance is active. No external API is required for these responses.',
                                style: AppTypography.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _ChatBubble(message: message);
                        },
                      ),
                    ),
                    if (_isSending)
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: LinearProgressIndicator(
                          minHeight: 2,
                          backgroundColor: AppColors.surfaceInteractive,
                          color: AppColors.primaryAmber,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _QuickActionChip(
                              label: 'I am struggling',
                              onTap: () => _sendMessage('I am struggling'),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _QuickActionChip(
                              label: 'Need a meeting',
                              onTap: () => _sendMessage('I need a meeting'),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _QuickActionChip(
                              label: 'Help with steps',
                              onTap: () =>
                                  _sendMessage('I need help with my steps'),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _QuickActionChip(
                              label: 'Safety plan',
                              onTap: () =>
                                  _sendMessage('I need my safety plan'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                          top: BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: AppTypography.bodyMedium,
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              maxLines: 4,
                              minLines: 1,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          IconButton(
                            icon: const Icon(Icons.send),
                            color: AppColors.primaryAmber,
                            onPressed: _isSending ? null : _sendMessage,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _DefaultCompanionResponder implements CompanionResponder {
  const _DefaultCompanionResponder();

  @override
  bool get isCloudAvailable => AiService().isCloudAvailable;

  @override
  Future<String> respond({
    required String message,
    required String userId,
    List<ChatMessage>? conversationHistory,
    List<String>? recoveryContext,
  }) {
    return AiService().respond(
      message: message,
      userId: userId,
      conversationHistory: conversationHistory,
      recoveryContext: recoveryContext,
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: AppSpacing.quint,
              height: AppSpacing.quint,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                size: AppSpacing.iconMd,
                color: AppColors.textOnDark,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primaryAmber : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isUser
                          ? AppColors.textOnDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    DateFormat.jm().format(message.createdAt),
                    style: AppTypography.labelSmall.copyWith(
                      color: isUser
                          ? AppColors.textOnDark.withValues(alpha: 0.7)
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceInteractive,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label, style: AppTypography.labelMedium),
      ),
    );
  }
}

class _SignedOutState extends StatelessWidget {
  final VoidCallback onSignInHint;

  const _SignedOutState({required this.onSignInHint});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: AppSpacing.sext,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Sign in to use the companion',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Conversations are stored locally for the active user only.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: onSignInHint,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
