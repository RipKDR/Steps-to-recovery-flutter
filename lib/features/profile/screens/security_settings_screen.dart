import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await BiometricService().isAvailable();
    if (mounted) {
      setState(() => _biometricAvailable = available);
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // Verify hardware works before enabling
      final result = await BiometricService().authenticate(
        reason: 'Confirm biometrics to enable app lock',
      );
      if (result != BiometricResult.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometric authentication failed')),
          );
        }
        return;
      }
    }
    await AppStateService.instance.setBiometricEnabled(value);
  }

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
                subtitle: Text(
                  _biometricAvailable
                      ? 'Require device unlock for recovery data'
                      : 'Biometric authentication is not available on this device',
                ),
                value: AppStateService.instance.biometricEnabled,
                onChanged: _biometricAvailable ? _toggleBiometric : null,
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
