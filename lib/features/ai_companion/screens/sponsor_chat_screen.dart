// lib/features/ai_companion/screens/sponsor_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/crisis_constants.dart';
import '../../../core/models/sponsor_models.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/services/sponsor_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import 'memory_transparency_screen.dart';

class SponsorChatScreen extends StatefulWidget {
  const SponsorChatScreen({super.key, SponsorResponder? responder})
      : _responder = responder;

  final SponsorResponder? _responder;

  @override
  State<SponsorChatScreen> createState() => _SponsorChatScreenState();
}

class _SponsorChatScreenState extends State<SponsorChatScreen>
    with WidgetsBindingObserver {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isSending = false;
  bool _isCrisisMode = false;

  SponsorResponder get _responder =>
      widget._responder ?? SponsorService.instance;

  String get _sponsorName => _responder.identity?.name ?? 'Your sponsor';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _responder.bumpEngagement(chatDays: 1);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _responder.digestSession();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _responder.digestSession();
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending) return;
    final isCrisis = CrisisConstants.detect(text);
    final userId = AppStateService.instance.currentUserId ?? '';
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().toIso8601String(),
        conversationId: '',
        userId: userId,
        content: text.trim(),
        isUser: true,
        createdAt: DateTime.now(),
      ));
      _isSending = true;
      _isCrisisMode = isCrisis;
    });
    _messageController.clear();
    _scrollToBottom();

    final response = await _responder.respond(
      message: text,
      userId: userId,
      conversationHistory: _messages,
    );

    setState(() {
      _messages.add(ChatMessage(
        id: '${DateTime.now().toIso8601String()}_r',
        conversationId: '',
        userId: userId,
        content: response,
        isUser: false,
        createdAt: DateTime.now(),
      ));
      _isSending = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stageName = switch (_responder.stage) {
      SponsorStage.new_ => 'New',
      SponsorStage.building => 'Building',
      SponsorStage.trusted => 'Trusted',
      SponsorStage.close => 'Close',
      SponsorStage.deep => 'Deep',
    };
    final initial =
        _sponsorName.isNotEmpty ? _sponsorName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryAmber,
              child: Text(
                initial,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_sponsorName, style: AppTypography.labelLarge),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryAmber,
                      ),
                    ),
                    Text(
                      stageName,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryAmber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            color: AppColors.textSecondary,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    MemoryTransparencyScreen(sponsorName: _sponsorName),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isLast = index == _messages.length - 1;
                final isCrisisMsg = isLast && !msg.isUser && _isCrisisMode;
                return _MessageBubble(
                  message: msg,
                  isCrisisMode: isCrisisMsg,
                  sponsorName: _sponsorName,
                );
              },
            ),
          ),
          if (_isCrisisMode)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: TextButton.icon(
                onPressed: () => context.push('/emergency'),
                icon: const Icon(Icons.phone, color: Colors.red),
                label: const Text(
                  '988 — Call or Text Now',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          // Quick chip: Share my week
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                _QuickChip(
                  label: 'Share my week',
                  onTap: () => _sendMessage(
                    'Share my week: check-in streak, mood trend, and any cravings since we last talked.',
                  ),
                ),
              ],
            ),
          ),
          _InputBar(
            controller: _messageController,
            isSending: _isSending,
            sponsorName: _sponsorName,
            onSend: () => _sendMessage(_messageController.text),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isCrisisMode,
    required this.sponsorName,
  });

  final ChatMessage message;
  final bool isCrisisMode;
  final String sponsorName;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Semantics(
      label: isUser ? 'Your message' : 'Message from $sponsorName',
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryAmber : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: isCrisisMode && !isUser
              ? Border.all(color: Colors.red.withValues(alpha: 0.5), width: 1)
              : null,
          boxShadow: isCrisisMode && !isUser
              ? [
                  BoxShadow(
                      color: Colors.red.withValues(alpha: 0.15),
                      blurRadius: 12)
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Text(
          message.content,
          style: AppTypography.bodyMedium.copyWith(
            color: isUser ? AppColors.background : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
        label: Text(
          label,
          style: AppTypography.labelSmall
              .copyWith(color: AppColors.primaryAmber),
        ),
        onPressed: onTap,
        backgroundColor: AppColors.primaryAmber.withValues(alpha: 0.08),
        side: BorderSide(
            color: AppColors.primaryAmber.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      );
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.sponsorName,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final String sponsorName;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: const Border(
              top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Talk to $sponsorName...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Semantics(
              label: 'Send message',
              button: true,
              child: SizedBox(
                width: AppSpacing.touchTargetComfortable,
                height: AppSpacing.touchTargetComfortable,
                child: IconButton(
                  onPressed: isSending ? null : onSend,
                  style: IconButton.styleFrom(
                    backgroundColor: isSending
                        ? AppColors.primaryAmber.withValues(alpha: 0.4)
                        : AppColors.primaryAmber,
                    shape: const CircleBorder(),
                  ),
                  icon: const Icon(Icons.send, color: Colors.black, size: 20),
                ),
              ),
            ),
          ],
        ),
      );
}
