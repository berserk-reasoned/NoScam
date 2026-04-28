// lib/features/user_dashboard/presentation/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../native/scam_prevention_channel.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  bool _isUrgencyOverrideActive = false;

  void _testNativeChannel() async {
    final channel = ScamPreventionChannel();
    final result = await channel.checkOtpProximity();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Native Result: $result')),
      );
    }
  }

  void _triggerFakeAlert() async {
    final channel = ScamPreventionChannel();
    await channel.triggerGuardianAlert("Suspicious Link Clicked!");
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alert sent to Guardian!')),
      );
    }
  }

  Widget _buildDashboardTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 4,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  'Protection Active',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('3', 'Unknown\nCalls'),
                    _buildStatItem('12', 'Links\nBlocked'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Urgency Override'),
          subtitle: const Text('Temporarily unblock banking apps for 15 mins.'),
          value: _isUrgencyOverrideActive,
          onChanged: (val) {
            setState(() { _isUrgencyOverrideActive = val; });
            if (val) {
              // Trigger native method to unblock apps
            } else {
              ScamPreventionChannel().blockBankingApps(0); // Restore lock
            }
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.security),
          label: const Text('Test Native OTP Check'),
          onPressed: _testNativeChannel,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.warning, color: Colors.red),
          label: const Text('Simulate Danger (Ping Guardian)'),
          onPressed: _triggerFakeAlert,
        ),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        Text(label, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildHelpTab() {
    return Container(
      color: Colors.red.shade50,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'HELP! I\'M SCAMMED',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildActionStep('1. Freeze Bank Accounts', Icons.account_balance),
          _buildActionStep('2. Call Cyber Police (1930)', Icons.local_police),
          _buildActionStep('3. Block Cards', Icons.credit_card),
        ],
      ),
    );
  }

  Widget _buildActionStep(String text, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Action logic here
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _buildDashboardTab(),
      const Center(child: Text('Search (URL Checker)')),
      const Center(child: Text('Report Community Data')),
      _buildHelpTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scam Prevention'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          )
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.report), label: 'Report'),
          NavigationDestination(icon: Icon(Icons.sos, color: Colors.red), label: 'Help!'),
        ],
      ),
    );
  }
}
