import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models.dart';
import 'recovery_controller.dart';

Widget panel(Widget child) => Container(
      decoration: BoxDecoration(color: const Color(0xFF12313F), borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: child,
    );

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.controller});
  final RecoveryController controller;

  @override
  Widget build(BuildContext context) {
    final d = controller.data;
    final completed = (d.morningDone ? 1 : 0) + (d.eveningDone ? 1 : 0);
    final nextAction = !d.morningDone
        ? 'Start morning intention'
        : !d.eveningDone
            ? 'Close with evening pulse'
            : 'Write a quick gratitude note';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Steps to Recovery', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('One next right move at a time.', style: TextStyle(color: Colors.blueGrey.shade200)),
        const SizedBox(height: 16),
        panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('CURRENT STREAK', style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 12, letterSpacing: 1.1)),
          const SizedBox(height: 6),
          Text('${d.streakDays} days', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Today progress: $completed/2 rituals complete', style: TextStyle(color: Colors.blueGrey.shade100)),
        ])),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.go((!d.morningDone || !d.eveningDone) ? '/checkin' : '/journal'),
          child: Ink(
            decoration: BoxDecoration(color: const Color(0xFF173F50), borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('NEXT ACTION', style: TextStyle(color: Colors.lightBlue.shade100, fontSize: 12, letterSpacing: 1.2)),
              const SizedBox(height: 4),
              Text(nextAction, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ],
    );
  }
}

class CheckinPage extends StatelessWidget {
  const CheckinPage({super.key, required this.controller});
  final RecoveryController controller;

  @override
  Widget build(BuildContext context) {
    final d = controller.data;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Daily check-in', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        panel(Column(children: [
          FilledButton(
            onPressed: controller.toggleMorning,
            child: Text(d.morningDone ? '✓ Morning done' : 'Mark morning done'),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: controller.toggleEvening,
            child: Text(d.eveningDone ? '✓ Evening done' : 'Mark evening done'),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () async {
              if (d.morningDone && d.eveningDone) {
                await controller.incrementStreak();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Great work. Day completed.')));
                }
              }
            },
            child: const Text('Complete today'),
          ),
        ])),
      ],
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
        const Text('Journal', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        panel(TextFormField(
          minLines: 8,
          maxLines: 12,
          initialValue: d.journal,
          onChanged: controller.setJournal,
          decoration: const InputDecoration(hintText: 'Write what you are feeling right now...', border: OutlineInputBorder()),
        )),
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
        const Text('Progress', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Streak: ${d.streakDays} days', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('Completed rituals today: $completed/2', style: const TextStyle(fontSize: 18)),
        ])),
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
        const Text('Support', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        panel(Column(children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.contacts),
            title: const Text('Emergency contacts'),
            subtitle: Text(d.contacts.isEmpty ? 'No contacts configured' : '${d.contacts.length} saved'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final contacts = await Navigator.of(context).push<List<EmergencyContact>>(
                MaterialPageRoute(builder: (_) => EmergencyContactsPage(initialContacts: d.contacts)),
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
        ])),
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
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(contacts), child: const Text('Save'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 8),
          TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return;
              setState(() {
                contacts.add(EmergencyContact(name: nameCtrl.text.trim(), phone: phoneCtrl.text.trim()));
                nameCtrl.clear();
                phoneCtrl.clear();
              });
            },
            child: const Text('Add contact'),
          ),
          const SizedBox(height: 16),
          ...contacts.asMap().entries.map((entry) => ListTile(
                title: Text(entry.value.name),
                subtitle: Text(entry.value.phone),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => contacts.removeAt(entry.key)),
                ),
              )),
        ],
      ),
    );
  }
}
