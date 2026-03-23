import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/recovery_content.dart';
import '../../../core/models/database_models.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/services/preferences_service.dart';
import '../../../widgets/confetti_overlay.dart';
import '../widgets/milestone_badge.dart';
import '../widgets/milestone_share_card.dart';

/// Full-screen celebration shown when a user earns a time milestone.
///
/// Displays confetti, an animated day counter, the milestone badge, and
/// share / continue actions.
class MilestoneCelebrationScreen extends StatefulWidget {
  const MilestoneCelebrationScreen({
    super.key,
    required this.achievement,
  });

  final Achievement achievement;

  @override
  State<MilestoneCelebrationScreen> createState() =>
      _MilestoneCelebrationScreenState();
}

class _MilestoneCelebrationScreenState
    extends State<MilestoneCelebrationScreen> {
  final _confettiController = ConfettiController();
  final _repaintKey = GlobalKey();
  final _log = LoggerService();

  TimeMilestoneContent? get _content {
    return _firstWhereOrNull(
      timeMilestones,
      (m) => 'milestone_${m.days}' == widget.achievement.achievementKey,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.fire();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _onShare() async {
    final content = _content;
    if (content == null) return;

    try {
      final xFile = await MilestoneShareCard.capture(_repaintKey);
      if (xFile != null) {
        await SharePlus.instance.share(ShareParams(
          files: [xFile],
          text: '${content.title} — ${content.message}\n'
              '${AppStoreLinks.shareUrl}',
        ));
      } else {
        // Fallback to text-only share
        await SharePlus.instance.share(ShareParams(
          text: '${content.emoji} ${content.title}\n'
              '${content.message}\n'
              '${AppStoreLinks.shareUrl}',
        ));
      }
    } catch (e) {
      _log.warning('Milestone share failed: $e');
      // Fallback to text-only share
      try {
        await SharePlus.instance.share(ShareParams(
          text: '${content.emoji} ${content.title}\n'
              '${content.message}\n'
              '${AppStoreLinks.shareUrl}',
        ));
      } catch (_) {
        // Share cancelled or unavailable — nothing to do
      }
    }
  }

  Future<void> _onDismiss() async {
    try {
      await PreferencesService()
          .markMilestoneCelebrationShown(widget.achievement.achievementKey);
      await DatabaseService()
          .markAchievementViewed(widget.achievement.id);
    } catch (e) {
      _log.warning('Failed to mark celebration viewed: $e');
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    final emoji = content?.emoji ?? '🎉';
    final title = content?.title ?? 'Milestone';
    final message = content?.message ?? 'Keep going, one day at a time.';
    final days = content?.days ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: ConfettiOverlay(
        controller: _confettiController,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Badge
                MilestoneBadge(emoji: emoji, size: 140),
                const SizedBox(height: 24),

                // Animated day counter
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: days),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => Text(
                    '$value',
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Text(
                  days == 1 ? 'Day' : 'Days',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 16,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 3),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _onShare,
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF59E0B),
                          side: const BorderSide(color: Color(0xFFF59E0B)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: _onDismiss,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),

      // Off-screen share card for PNG capture
      bottomSheet: Offstage(
        child: RepaintBoundary(
          key: _repaintKey,
          child: MilestoneShareCard(
            emoji: emoji,
            title: title,
            message: message,
          ),
        ),
      ),
    );
  }
}

/// Null-safe version of [Iterable.firstWhere].
T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}
