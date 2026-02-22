import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models.dart';
import 'recovery_controller.dart';

Widget panel(Widget child) => Container(
  decoration: BoxDecoration(
    color: const Color(0xFF12313F),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0x1FFFFFFF)),
  ),
  padding: const EdgeInsets.all(16),
  child: child,
);

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.4,
            color: Colors.blueGrey.shade200,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.controller});
  final RecoveryController controller;

  @override
  Widget build(BuildContext context) {
    final d = controller.data;
    final completed = (d.morningDone ? 1 : 0) + (d.eveningDone ? 1 : 0);
    final progress = completed / 2;
    final nextAction = !d.morningDone
        ? ('Start morning intention', '/checkin')
        : !d.eveningDone
        ? ('Close with evening pulse', '/checkin')
        : ('Write a quick gratitude note', '/journal');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        Row(
          children: [
            const Text(
              'Steps to Recovery',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0x222B8CC4),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${d.streakDays}d',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'One next right move at a time.',
          style: TextStyle(color: Colors.blueGrey.shade200),
        ),
        const SizedBox(height: 16),
        _HeroProgressCard(
          streakDays: d.streakDays,
          progress: progress,
          completed: completed,
        ),
        const SizedBox(height: 12),
        SectionTitle(
          'Today focus',
          trailing: Text(
            'Keep it simple',
            style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        _ActionBanner(
          title: nextAction.$1,
          subtitle: 'Tap to continue',
          icon: Icons.play_circle_fill_rounded,
          onTap: () => context.go(nextAction.$2),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionMiniCard(
                icon: Icons.support_agent,
                title: 'Companion',
                subtitle: 'Talk it through',
                color: const Color(0xFF2B8CC4),
                onTap: () => context.go('/support'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionMiniCard(
                icon: Icons.warning_amber_rounded,
                title: 'Emergency',
                subtitle: 'Get help now',
                color: const Color(0xFFC13A4F),
                onTap: () => context.go('/support'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroProgressCard extends StatelessWidget {
  const _HeroProgressCard({
    required this.streakDays,
    required this.progress,
    required this.completed,
  });

  final int streakDays;
  final double progress;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF173F50), Color(0xFF1B2F57)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT STREAK',
                  style: TextStyle(
                    color: Colors.blueGrey.shade100,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$streakDays days',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Today progress: $completed/2 rituals complete',
                  style: TextStyle(color: Colors.blueGrey.shade100),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 82,
            height: 82,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBanner extends StatelessWidget {
  const _ActionBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF112A36),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0x222B8CC4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF7FC5EE)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.blueGrey.shade300,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _ActionMiniCard extends StatelessWidget {
  const _ActionMiniCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class CheckinPage extends StatelessWidget {
  const CheckinPage({super.key, required this.controller});
  final RecoveryController controller;

  @override
  Widget build(BuildContext context) {
    final d = controller.data;
    final completed = (d.morningDone ? 1 : 0) + (d.eveningDone ? 1 : 0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Daily check-in',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Build momentum with two simple rituals.',
          style: TextStyle(color: Colors.blueGrey.shade200),
        ),
        const SizedBox(height: 16),
        panel(
          Column(
            children: [
              _RitualTile(
                title: 'Morning intention',
                subtitle: 'Set your direction for today',
                done: d.morningDone,
                onTap: controller.toggleMorning,
              ),
              const SizedBox(height: 10),
              _RitualTile(
                title: 'Evening pulse',
                subtitle: 'Reflect and close your day',
                done: d.eveningDone,
                onTap: controller.toggleEvening,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    if (d.morningDone && d.eveningDone) {
                      await controller.incrementStreak();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Great work. Day completed.'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.celebration_outlined),
                  label: Text(
                    completed == 2
                        ? 'Complete today'
                        : 'Finish both rituals first',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RitualTile extends StatelessWidget {
  const _RitualTile({
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: done ? const Color(0x221A6B4C) : const Color(0x221D2C38),
          border: Border.all(
            color: done ? const Color(0x991A6B4C) : const Color(0x33FFFFFF),
          ),
        ),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done ? Colors.greenAccent : Colors.white70,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JournalPage extends StatelessWidget {
  const JournalPage({super.key, required this.controller});
  final RecoveryController controller;

  @override
  Widget build(BuildContext context) {
    final d = controller.data;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Journal',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'No perfection required. Just honesty.',
          style: TextStyle(color: Colors.blueGrey.shade200),
        ),
        const SizedBox(height: 16),
        panel(
          TextFormField(
            minLines: 10,
            maxLines: 14,
            initialValue: d.journal,
            onChanged: controller.setJournal,
            decoration: const InputDecoration(
              hintText: 'Write what you are feeling right now...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key, required this.controller});
  final RecoveryController controller;

  @override
  Widget build(BuildContext context) {
    final d = controller.data;
    final completed = (d.morningDone ? 1 : 0) + (d.eveningDone ? 1 : 0);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Progress',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetricRow(
                icon: Icons.local_fire_department_outlined,
                label: 'Streak',
                value: '${d.streakDays} days',
              ),
              const SizedBox(height: 8),
              _MetricRow(
                icon: Icons.check_circle_outline,
                label: 'Today',
                value: '$completed / 2 rituals',
              ),
              const SizedBox(height: 8),
              _MetricRow(
                icon: Icons.history_toggle_off,
                label: 'Last updated',
                value: d.updatedAtIso,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey.shade200, size: 18),
        const SizedBox(width: 8),
        Text('$label:', style: TextStyle(color: Colors.blueGrey.shade200)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class SupportPage extends StatelessWidget {
  const SupportPage({super.key, required this.controller});
  final RecoveryController controller;

  @override
  Widget build(BuildContext context) {
    final d = controller.data;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Support',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        panel(
          Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.contacts),
                title: const Text('Emergency contacts'),
                subtitle: Text(
                  d.contacts.isEmpty
                      ? 'No contacts configured'
                      : '${d.contacts.length} saved',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final contacts = await Navigator.of(context)
                      .push<List<EmergencyContact>>(
                        MaterialPageRoute(
                          builder: (_) => EmergencyContactsPage(
                            initialContacts: d.contacts,
                          ),
                        ),
                      );
                  if (contacts != null) await controller.setContacts(contacts);
                },
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Morning reminder'),
                value: d.reminderMorning,
                onChanged: controller.setMorningReminder,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Evening reminder'),
                value: d.reminderEvening,
                onChanged: controller.setEveningReminder,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: controller.syncing
                      ? null
                      : () async {
                          await controller.syncNow();
                          if (context.mounted &&
                              controller.lastSyncMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(controller.lastSyncMessage!),
                              ),
                            );
                          }
                        },
                  icon: controller.syncing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  label: Text(controller.syncing ? 'Syncing...' : 'Sync now'),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pending changes: ${controller.pendingSyncCount}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (controller.lastSyncAtIso != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Last sync: ${controller.lastSyncAtIso}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              if (controller.lastSyncError != null &&
                  controller.lastSyncError!.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Last error: ${controller.lastSyncError}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.redAccent),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key, required this.initialContacts});
  final List<EmergencyContact> initialContacts;

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  late final List<EmergencyContact> contacts = [...widget.initialContacts];
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency contacts'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(contacts),
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          panel(
            Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty ||
                          phoneCtrl.text.trim().isEmpty) {
                        return;
                      }
                      setState(() {
                        contacts.add(
                          EmergencyContact(
                            name: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                          ),
                        );
                        nameCtrl.clear();
                        phoneCtrl.clear();
                      });
                    },
                    child: const Text('Add contact'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...contacts.asMap().entries.map(
            (entry) => Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(entry.value.name),
                subtitle: Text(entry.value.phone),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => contacts.removeAt(entry.key)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
