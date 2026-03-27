import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/app_utils.dart';
import '../../../widgets/loading_state.dart';
import '../../../widgets/settings_section.dart';

typedef ReminderTimePicker =
    Future<TimeOfDay?> Function(BuildContext context, TimeOfDay initialTime);

class _ThemeSelectorTile extends StatelessWidget {
  const _ThemeSelectorTile();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStateService.instance,
      builder: (context, _) {
        final current = AppStateService.instance.appThemeMode;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.brightness_auto_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                ],
                selected: {current},
                onSelectionChanged: (modes) =>
                    AppStateService.instance.setThemeMode(modes.first),
              ),
            ],
          ),
        );
      },
    );
  }
}

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
  bool _isTestingNotification = false;
  
  // Notification preferences
  bool _achievementNotificationsEnabled = true;
  bool _dailyReadingNotificationsEnabled = true;
  bool _stepRemindersEnabled = false;
  bool _meetingRemindersEnabled = false;

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

  Future<void> _testNotification() async {
    setState(() => _isTestingNotification = true);
    
    try {
      await NotificationService().showNotification(
        id: 9999,
        title: 'Test Notification',
        body: 'Your notification settings are working correctly! 🎉',
        channelId: 'reminders',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send test notification'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTestingNotification = false);
      }
    }
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
            body: LoadingState(message: 'Loading settings...'),
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
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  SettingsSection(
                    title: 'Account',
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        child: TextField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            labelText: 'Display name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        child: TextField(
                          controller: _programTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Program type',
                            prefixIcon: Icon(Icons.groups_outlined),
                            hintText: 'AA, NA, CA...',
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.primaryAmber,
                        ),
                        title: const Text('Sobriety date'),
                        subtitle: Text(
                          _sobrietyDate == null
                              ? 'Not set'
                              : AppUtils.formatDate(_sobrietyDate!),
                        ),
                        trailing: TextButton(
                          onPressed: _pickSobrietyDate,
                          child: const Text('Pick'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SettingsSection(
                    title: 'Reminders',
                    children: [
                      SwitchListTile(
                        title: const Text('Daily reminders'),
                        subtitle: const Text('Morning and evening check-ins'),
                        value: AppStateService.instance.notificationsEnabled,
                        onChanged: (value) =>
                            AppStateService.instance.setNotificationsEnabled(value),
                      ),
                      if (AppStateService.instance.notificationsEnabled) ...[
                        ListTile(
                          key: const Key('settings-morning-reminder'),
                          leading: const Icon(
                            Icons.wb_sunny_outlined,
                            color: AppColors.primaryAmber,
                          ),
                          title: const Text('Morning reminder'),
                          subtitle: Text(_morningReminderTime),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _pickReminderTime(isMorning: true),
                        ),
                        ListTile(
                          key: const Key('settings-evening-reminder'),
                          leading: const Icon(
                            Icons.nightlight_outlined,
                            color: AppColors.primaryAmber,
                          ),
                          title: const Text('Evening reminder'),
                          subtitle: Text(_eveningReminderTime),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _pickReminderTime(isMorning: false),
                        ),
                      ],
                      SwitchListTile(
                        title: const Text('Achievement notifications'),
                        subtitle: const Text('Celebrate milestones and wins'),
                        value: _achievementNotificationsEnabled,
                        onChanged: (value) {
                          setState(() => _achievementNotificationsEnabled = value);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Daily reading reminder'),
                        subtitle: const Text('Reflect on today\'s reading'),
                        value: _dailyReadingNotificationsEnabled,
                        onChanged: (value) {
                          setState(() => _dailyReadingNotificationsEnabled = value);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Step progress reminders'),
                        subtitle: const Text('Encouragement for step work'),
                        value: _stepRemindersEnabled,
                        onChanged: (value) {
                          setState(() => _stepRemindersEnabled = value);
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Meeting reminders (beta)'),
                        subtitle: const Text('Geofencing-based alerts near meeting locations'),
                        value: _meetingRemindersEnabled,
                        onChanged: (value) {
                          setState(() => _meetingRemindersEnabled = value);
                        },
                      ),
                      ListTile(
                        leading: _isTestingNotification
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(
                                Icons.notifications_active,
                                color: AppColors.success,
                              ),
                        title: const Text('Test notifications'),
                        subtitle: const Text('Send a test notification'),
                        onTap: _isTestingNotification ? null : _testNotification,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SettingsSection(
                    title: 'Privacy',
                    children: [
                      SwitchListTile(
                        title: const Text('Notifications enabled'),
                        value: AppStateService.instance.notificationsEnabled,
                        onChanged: (value) =>
                            AppStateService.instance.setNotificationsEnabled(value),
                      ),
                      ListTile(
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
                        leading: const Icon(
                          Icons.security_outlined,
                          color: AppColors.primaryAmber,
                        ),
                        title: const Text('Security settings'),
                        subtitle: const Text('Session and biometric lock'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/profile/security'),
                      ),
                      SwitchListTile(
                        title: const Text('Usage analytics'),
                        subtitle: const Text(
                          'Help improve the app (no recovery data shared)',
                        ),
                        value: !AnalyticsService().isOptedOut,
                        onChanged: (value) {
                          AnalyticsService().setOptOut(!value);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const SettingsSection(
                    title: 'Appearance',
                    children: [
                      _ThemeSelectorTile(),
                    ],
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
