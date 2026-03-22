import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Profile screen - User settings and account
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStateService.instance,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: AppColors.background,
          ),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Profile header
              Container(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  border: Border(
                    bottom: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: AppSpacing.sext,
                      height: AppSpacing.sext,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: AppSpacing.iconXxl,
                        color: AppColors.textOnDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      AppStateService.instance.userLabel,
                      style: AppTypography.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppStateService.instance.sobrietySummary,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primaryAmber,
                      ),
                    ),
                  ],
                ),
              ),

              // Settings sections
              _SettingsSection(
                title: 'Recovery',
                children: [
                  _SettingsTile(
                    icon: Icons.people,
                    title: 'Sponsor',
                    subtitle: 'Manage sponsor connection',
                    onTap: () {
                      context.push('/profile/sponsor');
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.shield,
                    title: 'Safety Plan',
                    subtitle: 'Create your personal safety plan',
                    onTap: () {
                      context.push('/home/safety-plan');
                    },
                  ),
                ],
              ),

              _SettingsSection(
                title: 'Preferences',
                children: [
                  _SettingsTile(
                    icon: Icons.notifications,
                    title: 'App settings',
                    subtitle: 'Edit reminders and profile preferences',
                    onTap: () {
                      context.push('/profile/settings');
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Notifications',
                    subtitle: 'Check-in reminders and alerts',
                    onTap: () {
                      context.push('/profile/settings');
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.psychology_outlined,
                    title: 'AI Companion',
                    subtitle: 'Configure AI settings',
                    onTap: () {
                      context.push('/profile/ai-settings');
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.lock,
                    title: 'Security',
                    subtitle: 'Biometric lock and privacy',
                    onTap: () {
                      context.push('/profile/security');
                    },
                  ),
                ],
              ),

              _SettingsSection(
                title: 'Support',
                children: [
                  _SettingsTile(
                    icon: Icons.help,
                    title: 'Help & FAQ',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.privacy_tip,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.description,
                    title: 'Terms of Service',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.group_add_outlined,
                    title: 'Invite Someone to Recovery',
                    subtitle: 'Share the app with someone who might need it',
                    onTap: () async {
                      await SharePlus.instance.share(ShareParams(
                        text:
                            'I use Steps to Recovery to stay accountable in my '
                            'sobriety. It\'s private, works offline, and '
                            'completely free. '
                            '${AppStoreLinks.shareUrl}',
                        subject: 'A recovery app worth trying',
                      ));
                    },
                  ),
                ],
              ),

              // Logout button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: OutlinedButton(
                  onPressed: () async {
                    await AppStateService.instance.signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Text('Log Out'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Text(
            title,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
        Container(
          color: AppColors.surfaceCard,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primaryAmber,
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textMuted,
      ),
      onTap: onTap,
    );
  }
}
