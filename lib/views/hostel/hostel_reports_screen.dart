// lib/views/hostel/hostel_reports_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HostelReportsScreen extends StatelessWidget {
  const HostelReportsScreen({super.key});

  static const _reports = [
    {'title': 'Occupancy Report', 'sub': 'Room and bed occupancy summary', 'icon': Icons.apartment, 'color': 0xFF1565C0},
    {'title': 'Student Allocation', 'sub': 'List of students with room details', 'icon': Icons.people, 'color': 0xFF2E7D32},
    {'title': 'Fee Collection Report', 'sub': 'Monthly fee payment summary', 'icon': Icons.payments, 'color': 0xFFE65100},
    {'title': 'Pending Fees Report', 'sub': 'Students with due fees', 'icon': Icons.warning, 'color': 0xFFC62828},
    {'title': 'Complaint Report', 'sub': 'All complaints and status', 'icon': Icons.report, 'color': 0xFF6A1B9A},
    {'title': 'Maintenance Report', 'sub': 'Room maintenance history', 'icon': Icons.build, 'color': 0xFF00838F},
    {'title': 'Attendance Report', 'sub': 'Monthly hostel attendance', 'icon': Icons.calendar_today, 'color': 0xFF0288D1},
    {'title': 'Visitor Log Report', 'sub': 'All visitor entries and exits', 'icon': Icons.people_outline, 'color': 0xFFF57F17},
    {'title': 'Deposit Report', 'sub': 'Security deposits collected', 'icon': Icons.account_balance,'color': 0xFF455A64},
    {'title': 'Vacancy Report', 'sub': 'Available rooms and beds', 'icon': Icons.meeting_room, 'color': 0xFF7B1FA2},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Quick stats
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('June 2025 Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _qs('Occupancy', '82%',    Colors.blue),
                _qs('Fee Collected', 'Rs \15K', Colors.green),
                _qs('Complaints', '3',     Colors.orange),
                _qs('Vacancies', '12',     Colors.purple),
              ]),
            ]),
          )),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reports.length,
            itemBuilder: (context, i) {
              final r = _reports[i];
              final color = Color(r['color'] as int);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(r['icon'] as IconData, color: color)),
                  title: Text(r['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text(r['sub'] as String, style: const TextStyle(fontSize: 11)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: Icon(Icons.visibility, color: color, size: 20), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.download, color: Colors.grey, size: 20), onPressed: () {}),
                  ]),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }

  Widget _qs(String label, String val, Color color) => Column(children: [
    Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
  ]);
}

