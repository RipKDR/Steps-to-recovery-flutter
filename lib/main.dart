import 'package:flutter/material.dart';

void main() {
  runApp(const StepsRecoveryApp());
}

class StepsRecoveryApp extends StatelessWidget {
  const StepsRecoveryApp({super.key});

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
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  bool _morningDone = false;
  bool _eveningDone = false;
  String _journal = '';
  int _streakDays = 12;

  String get nextAction {
    if (!_morningDone) return 'Start morning intention';
    if (!_eveningDone) return 'Close with evening pulse';
    return 'Write a quick gratitude note';
  }

  int get completedToday => (_morningDone ? 1 : 0) + (_eveningDone ? 1 : 0);

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
              Text('$_streakDays days', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Today progress: $completedToday/2 rituals complete', style: TextStyle(color: Colors.blueGrey.shade100)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _index = (!_morningDone || !_eveningDone) ? 1 : 2),
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
                text: _morningDone ? '✓ Morning done' : 'Mark morning done',
                onPressed: () => setState(() => _morningDone = !_morningDone),
              ),
              const SizedBox(height: 10),
              _filledButton(
                text: _eveningDone ? '✓ Evening done' : 'Mark evening done',
                onPressed: () => setState(() => _eveningDone = !_eveningDone),
              ),
              const SizedBox(height: 10),
              _filledButton(
                text: 'Complete today',
                color: const Color(0xFF1A6B4C),
                onPressed: () {
                  if (_morningDone && _eveningDone) {
                    setState(() => _streakDays += 1);
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
          child: TextField(
            minLines: 8,
            maxLines: 12,
            onChanged: (v) => setState(() => _journal = v),
            decoration: const InputDecoration(
              hintText: 'Write what you are feeling right now...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Characters: ${_journal.length}', style: TextStyle(color: Colors.blueGrey.shade200)),
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
              Text('Streak: $_streakDays days', style: const TextStyle(fontSize: 18)),
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
            children: const [
              Text('Companion: available', style: TextStyle(fontSize: 17)),
              SizedBox(height: 8),
              Text('Emergency contacts: configure in v2', style: TextStyle(fontSize: 17)),
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
