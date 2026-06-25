import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StaffTimetableScreen extends StatelessWidget {
  const StaffTimetableScreen({super.key});

  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  static const _periods = ['P1\n8-9', 'P2\n9-10', 'P3\n10-11', 'P4\n11-12', 'P5\n12-1', 'P6\n2-3'];

  static const _schedule = [
    ['10-A\nMath', '9-B\nMath', 'Free', '8-A\nMath', '10-B\nMath', 'Free'],
    ['Free', '10-A\nMath', '9-A\nMath', 'Free', '8-B\nMath', '9-B\nMath'],
    ['9-A\nMath', 'Free', '10-B\nMath', '9-B\nMath', 'Free', '10-A\nMath'],
    ['10-B\nMath', '8-A\nMath', 'Free', '10-A\nMath', '9-A\nMath', 'Free'],
    ['Free', '9-B\nMath', '10-A\nMath', 'Free', '8-A\nMath', '9-A\nMath'],
    ['8-B\nMath', 'Free', '9-A\nMath', '8-B\nMath', 'Free', 'Free'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => context.go((() { final role = context.read<AuthProvider>().user?.role; return role == 'staff' ? '/dashboard/staff' : role == 'student' ? '/dashboard/student' : role == 'parent' ? '/dashboard/parent' : '/dashboard/admin'; })())),title: const Text('My Timetable')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Info card
          Card(child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Expanded(child: _info('Teacher', 'Amit Verma')),
              Expanded(child: _info('Subject', 'Mathematics')),
              Expanded(child: _info('Classes', '6')),
              Expanded(child: _info('Periods/Week', '22')),
            ]),
          )),
          const SizedBox(height: 16),
          const Text('Weekly Schedule', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          // Timetable grid
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              defaultColumnWidth: const FixedColumnWidth(80),
              children: [
                // Header row
                TableRow(
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1)),
                  children: [
                    _cell('Day/Period', header: true),
                    ..._periods.map((p) => _cell(p, header: true)),
                  ],
                ),
                // Data rows
                ..._days.asMap().entries.map((entry) =>
                  TableRow(
                    decoration: BoxDecoration(
                      color: entry.key % 2 == 0 ? Colors.white : Colors.grey.shade50),
                    children: [
                      _cell(_days[entry.key], header: true),
                      ..._schedule[entry.key].map((cell) => _scheduleCell(cell)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Class Assignment', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ...[
            ['Class 8-A', 'Mathematics', 'Monday, Wednesday, Friday'],
            ['Class 8-B', 'Mathematics', 'Tuesday, Thursday, Saturday'],
            ['Class 9-A', 'Mathematics', 'Monday, Tuesday, Friday'],
            ['Class 9-B', 'Mathematics', 'Wednesday, Thursday, Saturday'],
            ['Class 10-A', 'Mathematics', 'Monday, Tuesday, Wednesday'],
            ['Class 10-B', 'Mathematics', 'Thursday, Friday, Saturday'],
          ].map((row) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: const Icon(Icons.class_, color: AppTheme.primaryColor, size: 20)),
              title: Text(row[0], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text('${row[1]} ??? ${row[2]}', style: const TextStyle(fontSize: 11)),
            ),
          )),
        ]),
      ),
    );
  }

  Widget _info(String label, String value) => Column(children: [
    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
  ]);

  Widget _cell(String text, {bool header = false}) => Padding(
    padding: const EdgeInsets.all(6),
    child: Text(text, textAlign: TextAlign.center,
      style: TextStyle(fontSize: 11, fontWeight: header ? FontWeight.bold : FontWeight.normal)),
  );

  Widget _scheduleCell(String text) {
    final isFree = text == 'Free';
    return Container(
      padding: const EdgeInsets.all(4),
      color: isFree ? Colors.grey.shade100 : AppTheme.primaryColor.withOpacity(0.08),
      child: Text(text, textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, color: isFree ? Colors.grey : AppTheme.primaryColor,
          fontWeight: isFree ? FontWeight.normal : FontWeight.w600)),
    );
  }
}








