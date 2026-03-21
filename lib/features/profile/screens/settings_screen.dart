import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_utils.dart';

typedef ReminderTimePicker =
    Future<TimeOfDay?> Function(BuildContext context, TimeOfDay initialTime);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.pickReminderTime});

  final ReminderTimePicker? pickReminderTime;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<void> _loadFuture;
  final _displayNameController = TextEditingController();
  final _programTypeController = TextEditingController();
  DateTime? _sobrietyDate;
  String _morningReminderTime = '08:00';
  String _eveningReminderTime = '20:00';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadFuture = _syncFromState();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _programTypeController.dispose();
    super.dispose();
  }

  Future<void> _syncFromState() async {
    await AppStateService.instance.initialize();
    final state = AppStateService.instance;
    if (!mounted) {
      return;
    }

    _displayNameController.text = state.displayName ?? '';
    _programTypeController.text = state.programType ?? '';
    _morningReminderTime = state.morningReminderTime;
    _eveningReminderTime = state.eveningReminderTime;
    _sobrietyDate = state.sobrietyDate;
  }

  Future<void> _pickSobrietyDate() async {
    final initial =
        _sobrietyDate ?? DateTime.now().subtract(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: initial.isAfter(DateTime.now()) ? DateTime.now() : initial,
    );
    if (picked != null) {
      setState(() {
        _sobrietyDate = picked;
      });
    }
  }

  Future<void> _pickReminderTime({required bool isMorning}) async {
    final currentValue = isMorning
        ? _morningReminderTime
        : _eveningReminderTime;
    final initialTime = AppUtils.parseTime(currentValue);
    final picked =
        await (widget.pickReminderTime ??
            ((BuildContext context, TimeOfDay initialTime) {
              return showTimePicker(context: context, initialTime: initialTime);
            }))(context, initialTime);

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      final formatted = AppUtils.formatTimeOfDay(picked);
      if (isMorning) {
        _morningReminderTime = formatted;
      } else {
        _eveningReminderTime = formatted;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await AppStateService.instance.updateDisplayName(
        _displayNameController.text,
      );
      await AppStateService.instance.updateProgramType(
        _programTypeController.text,
      );
      await AppStateService.instance.updateSobrietyDate(_sobrietyDate);
      await AppStateService.instance.setMorningReminderTime(
        _morningReminderTime,
      );
      await AppStateService.instance.setEveningReminderTime(
        _eveningReminderTime,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Settings saved')));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryAmber),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: AppColors.background,
          ),
          body: AnimatedBuilder(
            animation: AppStateService.instance,
            builder: (context, _) {
              final remindersEnabled =
                  AppStateService.instance.notificationsEnabled;
              final reminderAccentColor = remindersEnabled
                  ? AppColors.primaryAmber
                  : Theme.of(context).disabledColor;

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text('Account', style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _programTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Program type',
                      prefixIcon: Icon(Icons.groups_outlined),
                      hintText: 'AA, NA, CA...',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.primaryAmber,
                    ),
                    title: const Text('Sobriety date'),
                    subtitle: Text(
                      _sobrietyDate == null
                          ? 'Not set'
                          : _sobrietyDate!.toIso8601String().split('T').first,
                    ),
                    trailing: TextButton(
                      onPressed: _pickSobrietyDate,
                      child: const Text('Pick'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Reminders', style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.md),
                  ListTile(
                    key: const Key('settings-morning-reminder'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.wb_sunny_outlined,
                      color: reminderAccentColor,
                    ),
                    title: const Text('Morning reminder'),
                    subtitle: Text(
                      remindersEnabled
                          ? _morningReminderTime
                          : 'Enable notifications to edit',
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: remindersEnabled
                          ? null
                          : Theme.of(context).disabledColor,
                    ),
                    onTap: remindersEnabled
                        ? () => _pickReminderTime(isMorning: true)
                        : null,
                  ),
                  ListTile(
                    key: const Key('settings-evening-reminder'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.nightlight_outlined,
                      color: reminderAccentColor,
                    ),
                    title: const Text('Evening reminder'),
                    subtitle: Text(
                      remindersEnabled
                          ? _eveningReminderTime
                          : 'Enable notifications to edit',
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: remindersEnabled
                          ? null
                          : Theme.of(context).disabledColor,
                    ),
                    onTap: remindersEnabled
                        ? () => _pickReminderTime(isMorning: false)
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Privacy', style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Notifications enabled'),
                    value: AppStateService.instance.notificationsEnabled,
                    onChanged: (value) =>
                        AppStateService.instance.setNotificationsEnabled(value),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.psychology_outlined,
                      color: AppColors.primaryAmber,
                    ),
                    title: const Text('AI companion settings'),
                    subtitle: const Text('Configure recovery support behavior'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/profile/ai-settings'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.security_outlined,
                      color: AppColors.primaryAmber,
                    ),
                    title: const Text('Security settings'),
                    subtitle: const Text('Session and biometric lock'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/profile/security'),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Saving...' : 'Save changes'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
