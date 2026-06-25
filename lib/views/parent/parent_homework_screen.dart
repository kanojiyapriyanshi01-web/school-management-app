import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class ParentHomeworkScreen extends StatelessWidget {
  const ParentHomeworkScreen({super.key});

  final _homework = const [
    {'subject': 'Mathematics', 'title': 'Ch.5 Assignment', 'due': '20 Jun 2025', 'teacher': 'Mr. Ravi Sharma', 'status': 'pending'},
    {'subject': 'English', 'title': 'Essay Writing', 'due': '22 Jun 2025', 'teacher': 'Mrs. Priya', 'status': 'pending'},
    {'subject': 'Science', 'title': 'Lab Report', 'due': '25 Jun 2025', 'teacher': 'Mr. Kumar', 'status': 'pending'},
    {'subject': 'Hindi', 'title': 'Nibandh Lekhan', 'due': '15 Jun 2025', 'teacher': 'Mrs. Gupta', 'status': 'submitted'},
    {'subject': 'Mathematics', 'title': 'Ch.4 Practice', 'due': '10 Jun 2025', 'teacher': 'Mr. Ravi Sharma', 'status': 'submitted'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Child's Homework"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/dashboard/parent'),
        ),
      ),
      body: Column(children: [
        Container(color: Colors.white, padding: const EdgeInsets.all(14),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _sum('Pending', '${_homework.where((h) => h['status'] == 'pending').length}',   Colors.orange),
            _sum('Submitted', '${_homework.where((h) => h['status'] == 'submitted').length}', Colors.green),
            _sum('Total', '${_homework.length}',                                          Colors.blue),
          ])),
        const Divider(height: 1),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: _homework.length,
          itemBuilder: (context, i) {
            final h = _homework[i];
            final color = h['status'] == 'submitted' ? Colors.green : Colors.orange;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.assignment, color: color)),
                title: Text(h['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text('${h['subject']} - ${h['teacher']}\nDue: ${h['due']}',
                  style: const TextStyle(fontSize: 11)),
                isThreeLine: true,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text((h['status'] as String).toUpperCase(),
                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold))),
              ),
            );
          },
        )),
      ]),
    );
  }

  Widget _sum(String label, String val, Color color) => Column(children: [
    Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
  ]);
}


