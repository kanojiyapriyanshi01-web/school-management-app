import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../core/theme/app_theme.dart';

class ReturnBookScreen extends StatelessWidget {
  const ReturnBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LibraryProvider>();
    final activeIssues = p.activeIssues;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: activeIssues.isEmpty
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 12),
            Text('No books to return', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: activeIssues.length,
            itemBuilder: (context, i) {
              final issue = activeIssues[i];
              final isOverdue = issue.isOverdue;
              final fine = issue.calculatedFine;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: isOverdue ? Colors.red.shade50 : null,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(child: Text(issue.bookTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                      if (isOverdue) Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Text('OVERDUE', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold))),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(issue.userType == 'student' ? Icons.school : Icons.person,
                        size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${issue.userName} (${issue.admissionOrEmpId})',
                        style: const TextStyle(fontSize: 12)),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Issued: ${issue.issueDate}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(width: 12),
                      Icon(Icons.event, size: 14, color: isOverdue ? Colors.red : Colors.grey),
                      const SizedBox(width: 4),
                      Text('Due: ${issue.dueDate}',
                        style: TextStyle(fontSize: 11,
                          color: isOverdue ? Colors.red : Colors.grey,
                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal)),
                    ]),
                    if (isOverdue) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          const Icon(Icons.warning_amber, color: Colors.red, size: 16),
                          const SizedBox(width: 6),
                          Expanded(child: Text(
        '${issue.overdueDays} day(s) overdue. Fine: Rs ${fine.toStringAsFixed(0)} (Rs 2/day)',
                            style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w500))),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(children: [
                      if (isOverdue) Expanded(child: OutlinedButton.icon(
                        onPressed: () => _confirmReturn(context, p, issue.id, fine, collectFine: false),
                        icon: const Icon(Icons.assignment_return, size: 16, color: Colors.orange),
                        label: const Text('Return (Fine Pending)', style: TextStyle(color: Colors.orange, fontSize: 11)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange)),
                      )),
                      if (isOverdue) const SizedBox(width: 8),
                      Expanded(child: ElevatedButton.icon(
                        onPressed: () => _confirmReturn(context, p, issue.id, fine, collectFine: isOverdue),
                        icon: const Icon(Icons.assignment_return, size: 16),
                        label: Text(isOverdue ? 'Return + Collect Fine' : 'Return Book',
                          style: const TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOverdue ? Colors.red : Colors.green),
                      )),
                    ]),
                  ]),
                ),
              );
            },
          ),
    );
  }

  void _confirmReturn(BuildContext context, LibraryProvider p, int issueId,
    double fine, {required bool collectFine}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Return'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Are you sure you want to return this book?'),
          if (fine > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Fine Amount: Rs ${fine.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                Text(collectFine ? 'Fine will be collected now.' : 'Fine will be marked as pending.',
                  style: const TextStyle(fontSize: 12)),
              ]),
            ),
          ],
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await p.returnBook(issueId, collectFine: collectFine);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(collectFine
                  ? 'Book returned and fine collected!'
                  : 'Book returned successfully!'),
                backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm Return'),
          ),
        ],
      ),
    );
  }
}

