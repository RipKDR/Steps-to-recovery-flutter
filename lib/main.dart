import 'package:flutter/material.dart';

import 'local_store.dart';
import 'models.dart';

void main() {
  runApp(const StepsRecoveryApp());
}

class StepsRecoveryApp extends StatefulWidget {
  const StepsRecoveryApp({super.key});

  @override
  State<StepsRecoveryApp> createState() => _StepsRecoveryAppState();
}

class _StepsRecoveryAppState extends State<StepsRecoveryApp> {
  final _store = LocalStore();
  RecoveryData? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await _store.load();
    if (!mounted) return;
    setState(() => _data = loaded);
  }

  Future<void> _update(RecoveryData next) async {
    setState(() => _data = next);
    await _store.save(next);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steps to Recovery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2B8CC4),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1B24),
        useMaterial3: true,
      ),
      home: _data == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : HomeShell(data: _data!, onChanged: _update),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.data, required this.onChanged});

  final RecoveryData data;
  final ValueChanged<RecoveryData> onChanged;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  String get nextAction {
    if (!widget.data.morningDone) return 'Start morning intention';
    if (!widget.data.eveningDone) return 'Close with evening pulse';
    return 'Write a quick gratitude note';
  }

  int get completedToday => (widget.data.morningDone ? 1 : 0) + (widget.data.eveningDone ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _buildHomePage(),
      _buildCheckinPage(),
      _buildJournalPage(),
      _buildProgressPage(),
      _buildSupportPage(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.check_circle_outline), selectedIcon: Icon(Icons.check_circle), label: 'Check-in'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Journal'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent), label: 'Support'),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Steps to Recovery', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('One next right move at a time.', style: TextStyle(color: Colors.blueGrey.shade200)),
        const SizedBox(height: 16),
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CURRENT STREAK', style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 12, letterSpacing: 1.1)),
              const SizedBox(height: 6),
              Text('${widget.data.streakDays} days', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Today progress: $completedToday/2 rituals complete', style: TextStyle(color: Colors.blueGrey.shade100)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _index = (!widget.data.morningDone || !widget.data.eveningDone) ? 1 : 2),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFF173F50),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEXT ACTION', style: TextStyle(color: Colors.lightBlue.shade100, fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text(nextAction, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                color: const Color(0xFF2276B2),
                title: 'Companion',
                subtitle: 'Talk it through',
                onTap: () => setState(() => _index = 4),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionCard(
                color: const Color(0xFFC13A4F),
                title: 'Emergency',
                subtitle: 'Get help now',
                onTap: () => setState(() => _index = 4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckinPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Daily check-in', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        _panel(
          child: Column(
            children: [
              _filledButton(
                text: widget.data.morningDone ? '✓ Morning done' : 'Mark morning done',
                onPressed: () => widget.onChanged(widget.data.copyWith(morningDone: !widget.data.morningDone)),
              ),
              const SizedBox(height: 10),
              _filledButton(
                text: widget.data.eveningDone ? '✓ Evening done' : 'Mark evening done',
                onPressed: () => widget.onChanged(widget.data.copyWith(eveningDone: !widget.data.eveningDone)),
              ),
              const SizedBox(height: 10),
              _filledButton(
                text: 'Complete today',
                color: const Color(0xFF1A6B4C),
                onPressed: () {
                  if (widget.data.morningDone && widget.data.eveningDone) {
                    widget.onChanged(widget.data.copyWith(streakDays: widget.data.streakDays + 1));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Great work. Day completed.')));
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJournalPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Journal', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        _panel(
          child: TextFormField(
            minLines: 8,
            maxLines: 12,
            initialValue: widget.data.journal,
            onChanged: (v) => widget.onChanged(widget.data.copyWith(journal: v)),
            decoration: const InputDecoration(
              hintText: 'Write what you are feeling right now...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Characters: ${widget.data.journal.length}', style: TextStyle(color: Colors.blueGrey.shade200)),
      ],
    );
  }

  Widget _buildProgressPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Progress', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Streak: ${widget.data.streakDays} days', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Completed rituals today: $completedToday/2', style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Support', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.contacts),
                title: const Text('Emergency contacts'),
                subtitle: Text(widget.data.contacts.isEmpty ? 'No contacts configured' : '${widget.data.contacts.length} saved'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final contacts = await Navigator.of(context).push<List<EmergencyContact>>(
                    MaterialPageRoute(
                      builder: (_) => EmergencyContactsPage(initialContacts: widget.data.contacts),
                    ),
                  );
                  if (contacts != null) {
                    widget.onChanged(widget.data.copyWith(contacts: contacts));
                  }
                },
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Morning reminder'),
                value: widget.data.reminderMorning,
                onChanged: (v) => widget.onChanged(widget.data.copyWith(reminderMorning: v)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Evening reminder'),
                value: widget.data.reminderEvening,
                onChanged: (v) => widget.onChanged(widget.data.copyWith(reminderEvening: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12313F),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _actionCard({required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle),
          ],
        ),
      ),
    );
  }

  Widget _filledButton({required String text, required VoidCallback onPressed, Color? color}) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: color),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(text),
        ),
      ),
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
  late final List<EmergencyContact> _contacts = [...widget.initialContacts];

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency contacts'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_contacts),
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () {
              if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) return;
              setState(() {
                _contacts.add(EmergencyContact(name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim()));
                _nameCtrl.clear();
                _phoneCtrl.clear();
              });
            },
            child: const Text('Add contact'),
          ),
          const SizedBox(height: 16),
          ..._contacts.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;
            return Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(c.name),
                subtitle: Text(c.phone),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => _contacts.removeAt(i)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
