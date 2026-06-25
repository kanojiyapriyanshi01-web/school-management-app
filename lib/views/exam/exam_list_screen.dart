import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exam_provider.dart';
import '../../core/theme/app_theme.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});
  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().fetchExams();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExamProvider>();
    final role = context.read<AuthProvider>().user?.role;
    final isAdmin = role == 'admin' || role == 'staff';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go(
            role == 'student' ? '/dashboard/student'
            : role == 'parent' ? '/dashboard/parent'
            : role == 'staff' ? '/dashboard/staff'
            : '/dashboard/admin')),
        title: const Text('Exams & Results'),
        actions: isAdmin ? [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddExamDialog(context),
            tooltip: 'Add Exam'),
        ] : null,
      ),
      body: p.isLoading
        ? const Center(child: CircularProgressIndicator())
        : p.exams.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.quiz, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              const Text('No exams found', style: TextStyle(color: Colors.grey)),
              if (isAdmin) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _showAddExamDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exam')),
              ],
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: p.exams.length,
              itemBuilder: (context, i) {
                final exam = p.exams[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(exam.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.class_, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(exam.className.isEmpty ? 'All Classes' : exam.className,
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ]),
                        ])),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                          child: const Text('SCHEDULED',
                            style: TextStyle(fontSize: 10, color: Colors.green,
                              fontWeight: FontWeight.bold))),
                      ]),
                      const Divider(height: 14),
                      Row(children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${exam.startDate} - ${exam.endDate}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: OutlinedButton.icon(
                          onPressed: () => context.go('/exams/results'),
                          icon: const Icon(Icons.bar_chart, size: 16),
                          label: const Text('View Results',
                            style: TextStyle(fontSize: 12)),
                        )),
                        if (isAdmin) ...[
                          const SizedBox(width: 8),
                          Expanded(child: ElevatedButton.icon(
                            onPressed: () => context.go('/exams/marks'),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Enter Marks',
                              style: TextStyle(fontSize: 12)),
                          )),
                        ],
                      ]),
                    ]),
                  ),
                );
              },
            ),
    );
  }

  void _showAddExamDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Exam'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Exam Name *', prefixIcon: Icon(Icons.quiz))),
          const SizedBox(height: 12),
          TextFormField(
            controller: startCtrl, readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Start Date *',
              prefixIcon: Icon(Icons.calendar_today)),
            onTap: () async {
              final d = await showDatePicker(context: ctx,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030));
              if (d != null) startCtrl.text =
        '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: endCtrl, readOnly: true,
            decoration: const InputDecoration(
              labelText: 'End Date *',
              prefixIcon: Icon(Icons.calendar_today)),
            onTap: () async {
              final d = await showDatePicker(context: ctx,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030));
              if (d != null) endCtrl.text =
        '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
            },
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              final ok = await context.read<ExamProvider>().createExam(
                name: nameCtrl.text,
                classId: 0,
                startDate: startCtrl.text,
                endDate: endCtrl.text,
              );
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? 'Exam created!' : 'Failed to create exam'),
                  backgroundColor: ok ? Colors.green : Colors.red));
            },
            icon: const Icon(Icons.save),
            label: const Text('Create Exam'),
          ),
        ],
      ),
    );
  }
}

