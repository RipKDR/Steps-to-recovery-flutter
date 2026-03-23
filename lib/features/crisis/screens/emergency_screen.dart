import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

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
              label: 'Warning: If you are in immediate danger, call emergency services first.',
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
            const SizedBox(height: AppSpacing.xxl),

            // Emergency contacts
            Semantics(
              header: true,
              child: Text(
                'Emergency Contacts',
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

            // Personal emergency contacts
            Semantics(
              header: true,
              child: Text(
                'Your Support Network',
                style: AppTypography.headlineMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            _ContactCard(
              name: 'Sponsor Name',
              role: 'Sponsor',
              phone: '(555) 123-4567',
              onTap: () => _launchPhone('5551234567'),
            ),
            const SizedBox(height: AppSpacing.md),

            _ContactCard(
              name: 'Support Friend',
              role: 'Emergency Contact',
              phone: '(555) 987-6543',
              onTap: () => _launchPhone('5559876543'),
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

class _ContactCard extends StatelessWidget {
  final String name;
  final String role;
  final String phone;
  final VoidCallback onTap;

  const _ContactCard({
    required this.name,
    required this.role,
    required this.phone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Call $name, $role, at $phone',
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: AppSpacing.quint,
                  height: AppSpacing.quint,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAmber.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primaryAmber,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        role,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  excludeSemantics: true,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                      Text(
                        title,
                        style: AppTypography.titleMedium,
                      ),
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
                ExcludeSemantics(
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
