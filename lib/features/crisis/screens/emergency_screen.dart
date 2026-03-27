import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/permissions_service.dart';
import '../../../core/services/logger_service.dart';

/// Emergency screen - Immediate crisis support
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Emergency'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.danger,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Warning message
              Semantics(
                liveRegion: true,
                label:
                    'If you are in immediate danger, call emergency services first.',
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.danger),
                  ),
                  child: Row(
                    children: [
                      Semantics(
                        excludeSemantics: true,
                        child: const Icon(
                          Icons.warning,
                          color: AppColors.danger,
                          size: AppSpacing.iconLg,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'If you are in immediate danger, call emergency services first.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Safe Dial - Quick emergency contacts
              const _SafeDial(),
              const SizedBox(height: AppSpacing.xl),

              // Emergency contacts
              Semantics(
                header: true,
                child: Text(
                  'Emergency Hotlines',
                  style: AppTypography.headlineMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              _EmergencyButton(
                label: '988 Suicide & Crisis Lifeline',
                icon: Icons.phone,
                color: AppColors.success,
                semanticLabel: 'Call 988 Suicide and Crisis Lifeline',
                onTap: () => _launchPhone('988'),
              ),
              const SizedBox(height: AppSpacing.md),

              _EmergencyButton(
                label: 'SAMHSA Helpline',
                icon: Icons.phone,
                color: AppColors.info,
                semanticLabel: 'Call SAMHSA Helpline at 1-800-662-4357',
                onTap: () => _launchPhone('18006624357'),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Crisis tools
              Semantics(
                header: true,
                child: Text(
                  'Crisis Tools',
                  style: AppTypography.headlineMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              _CrisisToolCard(
                title: 'Grounding Exercises',
                description: '5-4-3-2-1 technique, breathing, body scan',
                icon: Icons.self_improvement,
                onTap: () {
                  context.push('/grounding-exercises');
                },
              ),
              const SizedBox(height: AppSpacing.md),

              _CrisisToolCard(
                title: 'Before You Use',
                description: '5-minute intervention when craving hits',
                icon: Icons.timer,
                onTap: () {
                  context.push('/before-you-use');
                },
              ),
              const SizedBox(height: AppSpacing.md),

              _CrisisToolCard(
                title: 'Craving Surf',
                description: 'Guided breathing exercise',
                icon: Icons.waves,
                onTap: () {
                  context.push('/home/craving-surf');
                },
              ),
              const SizedBox(height: AppSpacing.md),

              _CrisisToolCard(
                title: 'Danger Zone',
                description: 'Manage risky contacts',
                icon: Icons.dangerous,
                onTap: () {
                  context.push('/home/danger-zone');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}

class _EmergencyButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? semanticLabel;

  const _EmergencyButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: AppColors.textOnDark,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
          ),
        ),
      ),
    );
  }
}

/// Safe Dial - Quick access to emergency contacts
class _SafeDial extends StatelessWidget {
  const _SafeDial();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.phone_in_talk, color: AppColors.primaryAmber),
              const SizedBox(width: AppSpacing.sm),
              Text('Safe Dial', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Quick access to your support network',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SafeDialButton(
                label: 'Sponsor',
                icon: Icons.person,
                onTap: () {
                  // In production, load from DatabaseService contacts
                  _launchPhone('5551234567');
                },
              ),
              _SafeDialButton(
                label: 'Friend',
                icon: Icons.people,
                onTap: () {
                  // In production, load from DatabaseService contacts
                  _launchPhone('5559876543');
                },
              ),
              _SafeDialButton(
                label: '988',
                icon: Icons.emergency,
                color: AppColors.success,
                onTap: () => _launchPhone('988'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    try {
      // Request phone permission
      final permissionsService = PermissionsService();
      final hasPermission = await permissionsService.requestPhonePermission();

      if (!hasPermission) {
        LoggerService().warning('Phone permission denied');
        return;
      }

      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e, stackTrace) {
      LoggerService().error(
        'Failed to launch phone',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}

class _SafeDialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SafeDialButton({
    required this.label,
    required this.icon,
    this.color = AppColors.primaryAmber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CrisisToolCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _CrisisToolCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $description',
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.danger,
                    size: AppSpacing.iconLg,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const ExcludeSemantics(
                  child: Icon(Icons.chevron_right, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
