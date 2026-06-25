import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(user?.name.substring(0, 1) ?? 'P',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      drawer: _drawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hello, ${user?.name ?? 'Parent'} ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Parent Portal', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),

          // Child info card
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              CircleAvatar(radius: 28,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: const Text('R', style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor))),
              const SizedBox(width: 14),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Rahul Kumar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('Class 10-A  Roll No: R001',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
                SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.circle, size: 8, color: Colors.green),
                  SizedBox(width: 4),
                  Text('Active Student', style: TextStyle(fontSize: 11, color: Colors.green)),
                ]),
              ])),
              Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                  child: const Text('ADM001',
                    style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold))),
              ]),
            ]),
          )),
          const SizedBox(height: 12),

          // Attendance + Progress row
          Row(children: [
            Expanded(child: Card(child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                const Text('Attendance', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                const Text('89%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                const Text('42/47 days', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 6),
                ClipRRect(borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: 42/47,
                    color: Colors.green, backgroundColor: Colors.green.withOpacity(0.1), minHeight: 6)),
              ]),
            ))),
            const SizedBox(width: 10),
            Expanded(child: Card(child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                const Text('Academic', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                const Text('83.6%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                const Text('Grade A', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 6),
                ClipRRect(borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: 0.836,
                    color: Colors.blue, backgroundColor: Colors.blue.withOpacity(0.1), minHeight: 6)),
              ]),
            ))),
          ]),
          const SizedBox(height: 12),

          // Quick Access
          const Text('Quick Access', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: [
              _card(context, Icons.payment, 'Fee Status',  const Color(0xFFE65100), '/fees'),
              _card(context, Icons.quiz, 'Results',     const Color(0xFF6A1B9A), '/exams/results'),
              _card(context, Icons.announcement, 'Notices',     const Color(0xFF1565C0), '/notices'),
              _card(context, Icons.schedule, 'Timetable',   const Color(0xFF00838F), '/timetable'),
              _card(context, Icons.directions_bus, 'Transport',   const Color(0xFF0277BD), '/transport'),
              _card(context, Icons.assignment, 'Homework',    const Color(0xFFF57F17), '/parent/homework'),

              _card(context, Icons.chat, 'Message',     const Color(0xFF2E7D32), '/parent/message'),
            ],
          ),
          const SizedBox(height: 16),

          // Fee Status
          const Text('Fee Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(child: Column(children: [
            _feeItem('Tuition Fee', 'Rs 12,500', 'paid', '15 May 2025'),
            _feeItem('Hostel Fee', 'Rs 8,000', 'pending', '10 Jun 2025'),
            _feeItem('Transport Fee', 'Rs 3,500', 'overdue', '01 Jun 2025'),
          ])),
          const SizedBox(height: 16),

          // Recent Notices
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Recent Notices', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            TextButton(onPressed: () => context.go('/notices'), child: const Text('View All')),
          ]),
          ...[
            ['Annual Sports Day', '16 Jun', 'Sports Day on 20 July 2025'],
            ['Exam Schedule', '15 Jun', 'Mid-term exams from 20 June'],
            ['Fee Reminder', '14 Jun', 'Last date for fee: 30 June'],
          ].map((n) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.announcement, color: AppTheme.primaryColor, size: 20)),
              title: Text(n[0], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text(n[2], style: const TextStyle(fontSize: 11)),
              trailing: Text(n[1], style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ),
          )),
          const SizedBox(height: 16),

          // Child's Homework
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Child's Homework", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            TextButton(onPressed: () => context.go('/parent/homework'), child: const Text('View All')),
          ]),
          ...[
            ['Math Assignment', 'Due: 20 Jun', 'pending'],
            ['English Essay', 'Due: 22 Jun', 'pending'],
            ['Science Project', 'Submitted', 'submitted'],
          ].map((h) {
            final color = h[2] == 'submitted' ? Colors.green : Colors.orange;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.assignment, color: color),
                title: Text(h[0], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text(h[1], style: TextStyle(fontSize: 11, color: color)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(h[2].toString().toUpperCase(),
                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold))),
              ),
            );
          }),
        ]),
      ),
    );
  }

  Widget _drawer(BuildContext context) => Drawer(
    child: Column(children: [
      DrawerHeader(
        decoration: const BoxDecoration(color: AppTheme.primaryColor),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end, children: [
          const CircleAvatar(backgroundColor: Colors.white24,
            child: Icon(Icons.family_restroom, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Parent Portal',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const Text('Child: Rahul Kumar - Class 10-A',
            style: TextStyle(color: Colors.white70, fontSize: 11)),
        ]),
      ),
      _dItem(context, Icons.payment, 'Fee Status', '/fees'),
      _dItem(context, Icons.quiz, 'Results', '/exams/results'),
      _dItem(context, Icons.announcement, 'Notices', '/notices'),
      _dItem(context, Icons.schedule, 'Timetable', '/timetable'),
      _dItem(context, Icons.assignment,   "Child's Homework",'/parent/homework'),
      _dItem(context, Icons.chat, 'Message Teacher', '/parent/message'),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text('Logout', style: TextStyle(color: Colors.red)),
        onTap: () async {
          await context.read<AuthProvider>().logout();
          if (context.mounted) context.go('/login');
        },
      ),
    ]),
  );

  Widget _dItem(BuildContext context, IconData icon, String label, String route) =>
    ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label),
      onTap: () { Navigator.pop(context); context.go(route); },
    );

  Widget _card(BuildContext context, IconData icon, String label, Color color, String route) =>
    GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
        ]),
      ),
    );

  Widget _feeItem(String label, String amount, String status, String date) {
    final colors = {'paid': Colors.green, 'pending': Colors.orange, 'overdue': Colors.red};
    final color = colors[status] ?? Colors.grey;
    return ListTile(
      dense: true,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text(date, style: const TextStyle(fontSize: 11)),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(status.toUpperCase(),
            style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold))),
      ]),
    );
  }
}


