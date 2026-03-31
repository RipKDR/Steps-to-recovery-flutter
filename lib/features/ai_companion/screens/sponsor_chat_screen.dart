// lib/features/ai_companion/screens/sponsor_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            height: 0.5,
            color: AppColors.primaryAmber.withValues(alpha: 0.3),
          ),
        ),
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
                Text(
                  _sponsorName,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primaryAmber,
                  ),
                ),
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
            tooltip: 'View details',
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
              itemCount: _messages.length + (_isSending ? 1 : 0),
              itemBuilder: (context, index) {
                // Typing indicator as last item while sending
                if (_isSending && index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: const Border(
                          left: BorderSide(
                              color: AppColors.primaryAmber, width: 2),
                        ),
                      ),
                      child: const _TypingIndicator(),
                    ),
                  ).animate().fadeIn(duration: 250.ms).slideY(
                      begin: 0.1, end: 0);
                }
                final msg = _messages[index];
                final isLastMessage = index == _messages.length - 1;
                final isCrisisMsg =
                    isLastMessage && !msg.isUser && _isCrisisMode;
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
      ).animate().fadeIn(duration: 400.ms),
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
      child: _buildBubble(isUser, context),
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Align _buildBubble(bool isUser, BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: isUser
            ? BoxDecoration(
                gradient: const LinearGradient(
                    colors: AppColors.primaryGradient),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryAmber.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border(
                  left: const BorderSide(
                      color: AppColors.primaryAmber, width: 2),
                  top: isCrisisMode
                      ? BorderSide(
                          color: AppColors.danger.withValues(alpha: 0.5),
                          width: 1)
                      : BorderSide.none,
                  right: isCrisisMode
                      ? BorderSide(
                          color: AppColors.danger.withValues(alpha: 0.5),
                          width: 1)
                      : BorderSide.none,
                  bottom: isCrisisMode
                      ? BorderSide(
                          color: AppColors.danger.withValues(alpha: 0.5),
                          width: 1)
                      : BorderSide.none,
                ),
                boxShadow: isCrisisMode
                    ? [
                        BoxShadow(
                          color: AppColors.danger.withValues(alpha: 0.15),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        child: Text(
          message.content,
          style: AppTypography.bodyMedium.copyWith(
            color:
                isUser ? AppColors.textOnDark : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    final reduceMotion =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
            .disableAnimations;

    _controllers = List.generate(3, (i) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      if (!reduceMotion) {
        Future.delayed(Duration(milliseconds: i * 150), () {
          if (mounted) {
            ctrl.repeat(reverse: true);
          }
        });
      }
      return ctrl;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (i) => AnimatedBuilder(
          animation: _controllers[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.textMuted
                  .withValues(alpha: 0.4 + _controllers[i].value * 0.6),
            ),
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
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
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
                onSubmitted: (_) {
                  HapticFeedback.lightImpact();
                  onSend();
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Semantics(
              label: 'Send message',
              button: true,
              child: GestureDetector(
                onTap: isSending
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onSend();
                      },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSending
                        ? AppColors.primaryAmber.withValues(alpha: 0.4)
                        : AppColors.primaryAmber,
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: AppColors.textOnDark,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
