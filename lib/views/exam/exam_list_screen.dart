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

class _ExamListScreenState extends State<ExamListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().fetchExams();
    });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().user?.role ?? 'student';
    final isAdmin = role == 'admin' || role == 'staff';
    final p = context.watch<ExamProvider>();

    final drafts = p.exams.where((e) => e.status == 'draft').toList();
    final published = p.exams.where((e) => e.status == 'published').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams'),
        actions: [
          if (isAdmin) IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/exams/create')),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => p.fetchExams()),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.drafts, size: 16),
                const SizedBox(width: 6),
                Text('Drafts (${drafts.length})'),
              ])),
            Tab(
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.publish, size: 16),
                const SizedBox(width: 6),
                Text('Published (${published.length})'),
              ])),
          ]),
      ),
      body: p.isLoading
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              // DRAFTS TAB
              RefreshIndicator(
                onRefresh: () => p.fetchExams(),
                child: drafts.isEmpty
                  ? const Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.drafts, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No draft exams',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                      SizedBox(height: 6),
                      Text('Create an exam and save as draft',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: drafts.length,
                      itemBuilder: (ctx, i) => _examCard(
                        ctx, drafts[i], isAdmin, p, isDraft: true))),

              // PUBLISHED TAB
              RefreshIndicator(
                onRefresh: () => p.fetchExams(),
                child: published.isEmpty
                  ? const Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.assignment, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No published exams',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                      SizedBox(height: 6),
                      Text('Publish a draft exam to show here',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: published.length,
                      itemBuilder: (ctx, i) => _examCard(
                        ctx, published[i], isAdmin, p, isDraft: false))),
            ]),
      floatingActionButton: isAdmin ? FloatingActionButton.extended(
        onPressed: () => context.push('/exams/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Exam')) : null,
    );
  }

  Widget _examCard(BuildContext context, dynamic exam, bool isAdmin,
      ExamProvider p, {required bool isDraft}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: isDraft
              ? [Colors.orange.shade400, Colors.orange.shade300]
              : [AppTheme.primaryColor, Colors.blue.shade600]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14))),
          child: Row(children: [
            Icon(isDraft ? Icons.drafts : Icons.assignment,
              color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(exam.title,
              style: const TextStyle(color: Colors.white,
                fontWeight: FontWeight.bold, fontSize: 15))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6)),
              child: Text(isDraft ? 'DRAFT' : 'PUBLISHED',
                style: const TextStyle(color: Colors.white,
                  fontSize: 10, fontWeight: FontWeight.bold))),
          ])),

        // Body
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            Row(children: [
              Expanded(child: _infoRow(Icons.class_, 'Class', exam.className)),
              Expanded(child: _infoRow(Icons.subject, 'Subject', exam.subject)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _infoRow(Icons.calendar_today, 'Date', exam.examDate)),
              Expanded(child: _infoRow(Icons.timer, 'Duration',
                '${exam.duration} min')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _infoRow(Icons.score, 'Total Marks',
                '${exam.totalMarks}')),
              Expanded(child: _infoRow(Icons.check_circle, 'Pass Marks',
                '${exam.passingMarks}')),
            ]),

            // Admin actions
            if (isAdmin) ...[
              const Divider(height: 16),
              Row(children: [
                // Publish button — only for drafts
                if (isDraft) Expanded(child: ElevatedButton.icon(
                  onPressed: () => _publishExam(context, exam, p),
                  icon: const Icon(Icons.publish, size: 16),
                  label: const Text('Publish'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 10)))),
                if (isDraft) const SizedBox(width: 8),

                // Results — only for published
                if (!isDraft) Expanded(child: ElevatedButton.icon(
                  onPressed: () => context.push('/exams/results'),
                  icon: const Icon(Icons.bar_chart, size: 16),
                  label: const Text('Results'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10)))),
                if (!isDraft) const SizedBox(width: 8),

                // Marks entry
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => context.push('/exams/marks/${exam.id}'),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Marks'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10)))),
                const SizedBox(width: 8),

                // Delete
                IconButton(
                  onPressed: () => _deleteExam(context, exam, p),
                  icon: const Icon(Icons.delete_outline, color: Colors.red)),
              ]),
            ],

            // Student view
            if (!isAdmin && !isDraft) ...[
              const Divider(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: () => context.push('/exams/results'),
                icon: const Icon(Icons.bar_chart),
                label: const Text('View My Results'))),
            ],
          ])),
      ]));
  }

  void _publishExam(BuildContext context, dynamic exam, ExamProvider p) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Publish Exam'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.publish, color: Colors.green, size: 48),
        const SizedBox(height: 12),
        Text('Publish "${exam.title}"?',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('Once published, the exam will be visible to students.\nThis action cannot be undone.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel')),
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(ctx);
            final ok = await p.updateExamStatus(exam.id, 'published');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                  ? '"${exam.title}" published successfully!'
                  : 'Failed to publish exam'),
                backgroundColor: ok ? Colors.green : Colors.red));
              if (ok) {
                // Switch to published tab
                _tabController.animateTo(1);
                // Refresh
                await p.fetchExams();
              }
            }
          },
          icon: const Icon(Icons.publish),
          label: const Text('Publish Now'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green)),
      ]));
  }

  void _deleteExam(BuildContext context, dynamic exam, ExamProvider p) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Exam'),
      content: Text('Delete "${exam.title}"? This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Exam deleted'),
                backgroundColor: Colors.red));
            await p.fetchExams();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete')),
      ]));
  }

  Widget _infoRow(IconData icon, String label, String value) =>
    Row(children: [
      Icon(icon, size: 14, color: Colors.grey),
      const SizedBox(width: 4),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w600)),
      ]),
    ]);
}
