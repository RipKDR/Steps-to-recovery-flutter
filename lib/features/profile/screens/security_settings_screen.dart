import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  Future<void> _resetApp(BuildContext context) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset app data?'),
        content: const Text('This clears local session data and returns the app to onboarding.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (shouldReset != true) {
      return;
    }

    await AppStateService.instance.resetLocalData();
    if (context.mounted) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStateService.instance,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Security'),
            backgroundColor: AppColors.background,
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                'Session',
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline, color: AppColors.primaryAmber),
                title: Text(AppStateService.instance.userLabel),
                subtitle: Text(AppStateService.instance.email ?? 'Signed in locally'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Biometric lock'),
                subtitle: const Text('Require device unlock for recovery data'),
                value: AppStateService.instance.biometricEnabled,
                onChanged: (value) => AppStateService.instance.setBiometricEnabled(value),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Actions',
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () async {
                  await AppStateService.instance.signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceInteractive,
                  foregroundColor: AppColors.textPrimary,
                ),
                child: const Text('Sign out'),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () => _resetApp(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
                child: const Text('Reset local data'),
              ),
            ],
          ),
        );
      },
    );
  }
}
