import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// AI Companion Chat screen
class CompanionChatScreen extends StatefulWidget {
  const CompanionChatScreen({super.key});

  @override
  State<CompanionChatScreen> createState() => _CompanionChatScreenState();
}

class _CompanionChatScreenState extends State<CompanionChatScreen> {
  final _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      content: 'Hi! I\'m your recovery companion. How are you feeling today?',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Companion'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatBubble(message: message);
              },
            ),
          ),
          
          // Quick actions
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
                    label: 'I\'m struggling',
                    onTap: () => _sendMessage('I\'m struggling'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _QuickActionChip(
                    label: 'Feeling grateful',
                    onTap: () => _sendMessage('I\'m feeling grateful'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _QuickActionChip(
                    label: 'Step help',
                    onTap: () => _sendMessage('I need help with my steps'),
                  ),
                ],
              ),
            ),
          ),
          
          // Input area
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
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage([String? text]) {
    final messageText = text ?? _messageController.text;
    if (messageText.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        content: messageText,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();

      // Simulate AI response
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(
              content: 'Thank you for sharing. Tell me more about how you\'re feeling.',
              isUser: false,
              timestamp: DateTime.now(),
            ));
          });
        }
      });
    });
  }
}

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
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
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: AppSpacing.quint,
              height: AppSpacing.quint,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                ),
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
                color: isUser
                    ? AppColors.primaryAmber
                    : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Text(
                message.content,
                style: AppTypography.bodyMedium.copyWith(
                  color: isUser
                      ? AppColors.textOnDark
                      : AppColors.textPrimary,
                ),
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

  const _QuickActionChip({
    required this.label,
    required this.onTap,
  });

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
        child: Text(
          label,
          style: AppTypography.labelMedium,
        ),
      ),
    );
  }
}
