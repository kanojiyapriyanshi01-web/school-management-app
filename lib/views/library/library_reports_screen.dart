import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../core/theme/app_theme.dart';

class LibraryReportsScreen extends StatelessWidget {
  const LibraryReportsScreen({super.key});

  static const _reports = [
    {'title': 'Books Issued Report', 'sub': 'All issued books with details', 'icon': Icons.book, 'color': 0xFF1565C0},
    {'title': 'Overdue Books Report', 'sub': 'Books past due date', 'icon': Icons.warning, 'color': 0xFFC62828},
    {'title': 'Fine Collection Report', 'sub': 'Fines collected and pending', 'icon': Icons.payments, 'color': 0xFF2E7D32},
    {'title': 'Return History', 'sub': 'All returned books history', 'icon': Icons.assignment_return,'color': 0xFF00838F},
    {'title': 'Student Issue Report', 'sub': 'Books issued to students', 'icon': Icons.school, 'color': 0xFF6A1B9A},
    {'title': 'Staff Issue Report', 'sub': 'Books issued to staff members', 'icon': Icons.person, 'color': 0xFFE65100},
    {'title': 'Book Inventory Report', 'sub': 'Complete book stock summary', 'icon': Icons.inventory, 'color': 0xFF0288D1},
    {'title': 'Category-wise Report', 'sub': 'Books grouped by category', 'icon': Icons.category, 'color': 0xFFF57F17},
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LibraryProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('June 2025 Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _qs('Total Books', '${p.totalBooks}',  Colors.blue),
                _qs('Issued', '${p.issuedBooks}', Colors.orange),
                _qs('Overdue', '${p.overdueCount}',Colors.red),
                _qs('Fine Pending','Rs ${p.totalFinePending.toStringAsFixed(0)}', Colors.purple),
              ]),
            ]),
          )),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: _reports.length,
            itemBuilder: (context, i) {
              final r = _reports[i];
              final color = Color(r['color'] as int);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Container(width: 44, height: 44,
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(r['icon'] as IconData, color: color)),
                  title: Text(r['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
    Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
  ]);
}

