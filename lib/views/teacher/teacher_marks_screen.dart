import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class TeacherMarksScreen extends StatefulWidget {
  const TeacherMarksScreen({super.key});
  @override
  State<TeacherMarksScreen> createState() => _TeacherMarksScreenState();
}

class _TeacherMarksScreenState extends State<TeacherMarksScreen> {
  String _selectedClass = 'Class 1';
  String _selectedExam = 'Mid-Term 2025';
  String _selectedSubject = 'Mathematics';
  bool _saving = false;

  final List<Map<String, dynamic>> _students = [
    {'name': 'Priya Singh', 'roll': 'R002', 'marks': 92.0, 'max': 100},
    {'name': 'Sneha Patel', 'roll': 'R004', 'marks': 88.0, 'max': 100},
    {'name': 'Rahul Kumar', 'roll': 'R001', 'marks': 85.0, 'max': 100},
    {'name': 'Anita Gupta', 'roll': 'R006', 'marks': 78.0, 'max': 100},
    {'name': 'Vijay Verma', 'roll': 'R005', 'marks': 72.0, 'max': 100},
    {'name': 'Amit Sharma', 'roll': 'R003', 'marks': 65.0, 'max': 100},
  ];

  String _getGrade(double marks) {
    if (marks >= 90) return 'A+';
    if (marks >= 80) return 'A';
    if (marks >= 70) return 'B+';
    if (marks >= 60) return 'B';
    if (marks >= 50) return 'C';
    return 'F';
  }

  Color _getGradeColor(double marks) {
    if (marks >= 80) return Colors.green;
    if (marks >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marks Entry'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/dashboard/staff'),
        ),
      ),
      body: Column(children: [
        Container(color: Colors.white, padding: const EdgeInsets.all(14),
          child: Column(children: [
            DropdownButtonFormField<String>(
              value: _selectedClass,
              decoration: const InputDecoration(labelText: 'Class', prefixIcon: Icon(Icons.class_)),
              items: ['Nursery','LKG','UKG','Class 1','Class 2','Class 3','Class 4','Class 5','Class 6','Class 7','Class 8','Class 9','Class 10','Class 11','Class 12']
                .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedClass = v!),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                value: _selectedExam,
                decoration: const InputDecoration(labelText: 'Exam'),
                items: ['Mid-Term 2025','Final 2025','Unit Test 1']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) => setState(() => _selectedExam = v!),
              )),
              const SizedBox(width: 10),
              Expanded(child: DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: const InputDecoration(labelText: 'Subject'),
                items: ['Mathematics','Science','English','Hindi']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) => setState(() => _selectedSubject = v!),
              )),
            ]),
          ])),
        const Divider(height: 1),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: _students.length,
          itemBuilder: (context, i) {
            final s = _students[i];
            final grade = _getGrade(s['marks']);
            final color = _getGradeColor(s['marks']);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(children: [
                  CircleAvatar(radius: 16, backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(s['name'][0], style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('Roll: ${s['roll']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ])),
                  SizedBox(width: 70, child: TextFormField(
                    initialValue: s['marks'].toString(),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      suffixText: '/${s['max']}'),
                    onChanged: (v) {
                      final val = double.tryParse(v) ?? 0;
                      setState(() => _students[i]['marks'] = val.clamp(0, s['max'].toDouble()));
                    },
                  )),
                  const SizedBox(width: 10),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text(grade,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)))),
                ]),
              ),
            );
          },
        )),
        SafeArea(child: Padding(
          padding: const EdgeInsets.all(14),
          child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: _saving ? null : () async {
              setState(() => _saving = true);
              await Future.delayed(const Duration(seconds: 1));
              setState(() => _saving = false);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Marks saved successfully!'), backgroundColor: Colors.green));
            },
            icon: const Icon(Icons.save),
            label: Text(_saving ? 'Saving...' : 'Save Marks'),
          )),
        )),
      ]),
    );
  }
}




