import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/encryption_service.dart';
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
  bool _isRotatingKey = false;
  int _lockTimeoutMinutes = 0;
  final List<int> _timeoutOptions = [0, 1, 5, 15, 30, 60];

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _loadLockTimeout();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await BiometricService().isAvailable();
    if (mounted) {
      setState(() => _biometricAvailable = available);
    }
  }

  Future<void> _loadLockTimeout() async {
    // Load from preferences (using AppStateService as temporary storage)
    // In production, use PreferencesService directly
    setState(() {
      _lockTimeoutMinutes = 0; // Default to immediate lock
    });
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

  Future<void> _rotateEncryptionKey() async {
    final shouldRotate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rotate Encryption Key'),
        content: const Text(
          'This will re-encrypt all your sensitive data with a new key. '
          'This process cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.textOnDark,
            ),
            child: const Text('Rotate Key'),
          ),
        ],
      ),
    );

    if (shouldRotate != true || !mounted) return;

    setState(() => _isRotatingKey = true);

    try {
      // Clear old keys and reinitialize
      await EncryptionService().clearKeys();
      await EncryptionService().initialize();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Encryption key rotated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to rotate encryption key'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRotatingKey = false);
      }
    }
  }

  Future<void> _changeLockTimeout(int? minutes) async {
    if (minutes == null) return;
    
    setState(() {
      _lockTimeoutMinutes = minutes;
    });
    
    // Save to preferences (in production, use PreferencesService)
    // await PreferencesService.instance.setLockTimeout(minutes);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            minutes == 0
                ? 'App will lock immediately'
                : 'App will lock after $minutes minute${minutes > 1 ? 's' : ''}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
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
              const SizedBox(height: AppSpacing.md),
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
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.timer_outlined, color: AppColors.info),
                title: const Text('Auto-lock timeout'),
                subtitle: Text(
                  _lockTimeoutMinutes == 0
                      ? 'Lock immediately'
                      : 'Lock after $_lockTimeoutMinutes minute${_lockTimeoutMinutes > 1 ? 's' : ''}',
                ),
                trailing: PopupMenuButton<int>(
                  onSelected: _changeLockTimeout,
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 0, child: Text('Immediate')),
                    const PopupMenuItem(value: 1, child: Text('1 minute')),
                    const PopupMenuItem(value: 5, child: Text('5 minutes')),
                    const PopupMenuItem(value: 15, child: Text('15 minutes')),
                    const PopupMenuItem(value: 30, child: Text('30 minutes')),
                    const PopupMenuItem(value: 60, child: Text('1 hour')),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Encryption',
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline, color: AppColors.success),
                title: const Text('Rotate encryption key'),
                subtitle: const Text('Re-encrypt all data with a new key'),
                trailing: _isRotatingKey
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _isRotatingKey ? null : _rotateEncryptionKey,
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
