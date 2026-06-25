import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class StudentLeaveScreen extends StatefulWidget {
  const StudentLeaveScreen({super.key});
  @override
  State<StudentLeaveScreen> createState() => _StudentLeaveScreenState();
}

class _StudentLeaveScreenState extends State<StudentLeaveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _reasonCtrl = TextEditingController();
  String _leaveType = 'Sick Leave';
  bool _saving = false;

  final _leaves = [
    {'type': 'Sick Leave', 'from': '10 May 2025', 'to': '11 May 2025', 'days': 2, 'reason': 'Fever', 'status': 'approved'},
    {'type': 'Family Event', 'from': '25 Apr 2025', 'to': '25 Apr 2025', 'days': 1, 'reason': 'Sister marriage', 'status': 'approved'},
    {'type': 'Medical', 'from': '15 Jun 2025', 'to': '15 Jun 2025', 'days': 1, 'reason': 'Doctor appointment', 'status': 'pending'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabController.dispose(); _reasonCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Application'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/dashboard/student'),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'Apply Leave'), Tab(text: 'My Leaves')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_applyForm(), _leaveHistory()],
      ),
    );
  }

  Widget _applyForm() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Balance
      Row(children: [
        _balance('Sick', '8', '10', Colors.orange),
        const SizedBox(width: 10),
        _balance('Casual', '5', '8',  Colors.blue),
        const SizedBox(width: 10),
        _balance('Medical','3', '5',  Colors.green),
      ]),
      const SizedBox(height: 20),
      DropdownButtonFormField<String>(
        value: _leaveType,
        decoration: const InputDecoration(labelText: 'Leave Type', prefixIcon: Icon(Icons.event_busy)),
        items: ['Sick Leave','Casual Leave','Medical Leave','Family Event','Emergency']
          .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: (v) => setState(() => _leaveType = v!),
      ),
      const SizedBox(height: 12),
      TextFormField(readOnly: true,
        decoration: const InputDecoration(labelText: 'From Date', prefixIcon: Icon(Icons.calendar_today)),
        onTap: () async {
          await showDatePicker(context: context,
            initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2026));
        },
      ),
      const SizedBox(height: 12),
      TextFormField(readOnly: true,
        decoration: const InputDecoration(labelText: 'To Date', prefixIcon: Icon(Icons.calendar_today)),
        onTap: () async {
          await showDatePicker(context: context,
            initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2026));
        },
      ),
      const SizedBox(height: 12),
      TextField(controller: _reasonCtrl, maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Reason *', prefixIcon: Icon(Icons.info_outline),
          alignLabelWithHint: true)),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, child: ElevatedButton.icon(
        onPressed: _saving ? null : () async {
          setState(() => _saving = true);
          await Future.delayed(const Duration(seconds: 1));
          setState(() => _saving = false);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Leave application submitted!'), backgroundColor: Colors.green));
        },
        icon: const Icon(Icons.send),
        label: Text(_saving ? 'Submitting...' : 'Submit Leave Application'),
      )),
    ]),
  );

  Widget _leaveHistory() => _leaves.isEmpty
    ? const Center(child: Text('No leave history', style: TextStyle(color: Colors.grey)))
    : ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: _leaves.length,
        itemBuilder: (context, i) {
          final l = _leaves[i];
          final color = l['status'] == 'approved' ? Colors.green
            : l['status'] == 'pending' ? Colors.orange : Colors.red;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                l['status'] == 'approved' ? Icons.check_circle
                  : l['status'] == 'pending' ? Icons.pending : Icons.cancel,
                color: color),
              title: Text(l['type'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text('${l['from']} to ${l['to']} (${l['days']} day${(l['days'] as int) > 1 ? 's' : ''})\n${l['reason']}',
                style: const TextStyle(fontSize: 11)),
              isThreeLine: true,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text((l['status'] as String).toUpperCase(),
                  style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold))),
            ),
          );
        },
      );

  Widget _balance(String label, String used, String total, Color color) =>
    Expanded(child: Card(child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        Text(total, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text('$label Left', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text('Used: $used/$total', style: TextStyle(fontSize: 9, color: color)),
      ]),
    )));
}


