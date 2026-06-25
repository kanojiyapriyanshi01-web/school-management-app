import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/exam_provider.dart';
import '../../core/theme/app_theme.dart';

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({super.key});
  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  int _currentStep = 0;

  // Exam Details
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _examType = 'Unit Test';
  String _academicYear = '2025-26';
  String _status = 'draft';
  String _selectedClass = 'Class 10';
  String _selectedSection = 'A';
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();

  // Subjects
  final List<Map<String, dynamic>> _subjects = [
    {'name': 'Mathematics', 'maxMarks': 100, 'passingMarks': 35,
        'hasTheory': true, 'hasPractical': false, 'hasViva': false,
        'hasInternal': false, 'selected': true},
    {'name': 'Science', 'maxMarks': 100, 'passingMarks': 35,
        'hasTheory': true, 'hasPractical': true, 'hasViva': false,
        'hasInternal': false, 'selected': true},
    {'name': 'English', 'maxMarks': 100, 'passingMarks': 35,
        'hasTheory': true, 'hasPractical': false, 'hasViva': false,
        'hasInternal': true, 'selected': true},
    {'name': 'Hindi', 'maxMarks': 100, 'passingMarks': 35,
        'hasTheory': true, 'hasPractical': false, 'hasViva': false,
        'hasInternal': false, 'selected': true},
    {'name': 'Social Science', 'maxMarks': 100, 'passingMarks': 35,
        'hasTheory': true, 'hasPractical': false, 'hasViva': false,
        'hasInternal': false, 'selected': true},
    {'name': 'Computer', 'maxMarks': 100, 'passingMarks': 35,
        'hasTheory': true, 'hasPractical': true, 'hasViva': false,
        'hasInternal': false, 'selected': false},
  ];

  // Grading
  String _gradingSystem = 'marks_grade';
  final List<Map<String, dynamic>> _gradeTable = [
    {'min': 91, 'max': 100, 'grade': 'A+', 'gpa': 10.0},
    {'min': 81, 'max': 90, 'grade': 'A', 'gpa': 9.0},
    {'min': 71, 'max': 80, 'grade': 'B+', 'gpa': 8.0},
    {'min': 61, 'max': 70, 'grade': 'B', 'gpa': 7.0},
    {'min': 51, 'max': 60, 'grade': 'C', 'gpa': 6.0},
    {'min': 35, 'max': 50, 'grade': 'D', 'gpa': 5.0},
    {'min': 0, 'max': 34, 'grade': 'F', 'gpa': 0.0},
  ];

  final _examTypes = [
 'Weekly Test', 'Unit Test', 'Monthly Test',
 'Quarterly Exam', 'Half-Yearly Exam', 'Annual Exam',
 'Practical Exam', 'Viva', 'Project Assessment',
 'Internal Assessment', 'Board Preparation Test', 'Pre-Board',
  ];
  final _classes = [
        'Nursery','LKG','UKG',
        'Class 1','Class 2','Class 3','Class 4','Class 5',
        'Class 6','Class 7','Class 8',
        'Class 9','Class 10','Class 11','Class 12',
  ];

  String _getStage(String cls) {
    if (['Nursery','LKG','UKG','Class 1','Class 2'].contains(cls))
      return 'foundational';
    if (['Class 3','Class 4','Class 5'].contains(cls))
      return 'preparatory';
    if (['Class 6','Class 7','Class 8'].contains(cls))
      return 'middle';
    return 'secondary';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() => _currentStep = _tabController.index));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose(); _descCtrl.dispose();
    _startCtrl.dispose(); _endCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final ok = await context.read<ExamProvider>().createExam(
      name: _nameCtrl.text,
      classId: 0,
      startDate: _startCtrl.text,
      endDate: _endCtrl.text,
      examType: _examType,
      academicYear: _academicYear,
      className: _selectedClass,
      section: _selectedSection,
      description: _descCtrl.text,
      status: _status,
    );
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Exam created successfully!' : 'Failed to create exam'),
        backgroundColor: ok ? Colors.green : Colors.red));
      if (ok) context.go('/exams');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stage = _getStage(_selectedClass);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Exam'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/exams')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '1. Details'),
            Tab(text: '2. Subjects'),
            Tab(text: '3. Grading'),
            Tab(text: '4. Publish'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(children: [
          // Progress
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            color: AppTheme.primaryColor,
            backgroundColor: Colors.grey.shade200,
            minHeight: 4),

          Expanded(child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _detailsTab(),
              _subjectsTab(stage),
              _gradingTab(stage),
              _publishTab(),
            ],
          )),

          // Navigation
          SafeArea(child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              if (_currentStep > 0) ...[
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _tabController.animateTo(_currentStep - 1),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Previous'))),
                const SizedBox(width: 10),
              ],
              Expanded(child: _currentStep < 3
                ? ElevatedButton.icon(
                    onPressed: () => _tabController.animateTo(_currentStep + 1),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Next'))
                : ElevatedButton.icon(
                    onPressed: _saving ? null : _submit,
                    icon: _saving
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save, size: 16),
                    label: Text(_saving ? 'Creating...' : 'Create Exam'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green))),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _detailsTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _header('Exam Details', Icons.quiz),
      const SizedBox(height: 14),
      TextFormField(
        controller: _nameCtrl,
        decoration: const InputDecoration(
          labelText: 'Exam Name *', prefixIcon: Icon(Icons.quiz)),
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _examType,
        decoration: const InputDecoration(
          labelText: 'Exam Type *', prefixIcon: Icon(Icons.category)),
        isExpanded: true,
        items: _examTypes.map((t) =>
          DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: (v) => setState(() => _examType = v!),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _academicYear,
        decoration: const InputDecoration(
          labelText: 'Academic Year *', prefixIcon: Icon(Icons.school)),
        items: ['2024-25','2025-26','2026-27'].map((y) =>
          DropdownMenuItem(value: y, child: Text(y))).toList(),
        onChanged: (v) => setState(() => _academicYear = v!),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: DropdownButtonFormField<String>(
          value: _selectedClass,
          decoration: const InputDecoration(labelText: 'Class *'),
          isExpanded: true,
          items: _classes.map((c) =>
            DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _selectedClass = v!),
        )),
        const SizedBox(width: 10),
        Expanded(child: DropdownButtonFormField<String>(
          value: _selectedSection,
          decoration: const InputDecoration(labelText: 'Section *'),
          items: ['A','B','C','D','All'].map((s) =>
            DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _selectedSection = v!),
        )),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: TextFormField(
          controller: _startCtrl, readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Start Date *', prefixIcon: Icon(Icons.calendar_today)),
          onTap: () async {
            final d = await showDatePicker(context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime(2030));
            if (d != null) _startCtrl.text =
        '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
          },
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        )),
        const SizedBox(width: 10),
        Expanded(child: TextFormField(
          controller: _endCtrl, readOnly: true,
          decoration: const InputDecoration(
            labelText: 'End Date *', prefixIcon: Icon(Icons.calendar_today)),
          onTap: () async {
            final d = await showDatePicker(context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030));
            if (d != null) _endCtrl.text =
        '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
          },
        )),
      ]),
      const SizedBox(height: 12),
      TextFormField(
        controller: _descCtrl, maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Description / Instructions',
          prefixIcon: Icon(Icons.description),
          alignLabelWithHint: true),
      ),
      const SizedBox(height: 14),
      // NEP Stage info
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.withOpacity(0.2))),
        child: Row(children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(
            _getStageInfo(_getStage(_selectedClass)),
            style: const TextStyle(fontSize: 12, color: Colors.blue))),
        ]),
      ),
    ]),
  );

  Widget _subjectsTab(String stage) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _header('Subjects & Marks Setup', Icons.book),
      const SizedBox(height: 8),
      if (stage == 'foundational') ...[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10)),
          child: const Text(
        'Foundational Stage: Observation-based assessment with emoji ratings, skill evaluation and teacher remarks.',
            style: TextStyle(fontSize: 12, color: Colors.orange))),
        const SizedBox(height: 14),
        ..._buildFoundationalSubjects(),
      ] else ...[
        ..._subjects.map((s) => _subjectCard(s, stage)),
      ],
    ]),
  );

  List<Widget> _buildFoundationalSubjects() {
    final skills = [
      {'name': 'Communication Skills', 'icon': Icons.record_voice_over},
      {'name': 'Social Interaction', 'icon': Icons.people},
      {'name': 'Motor Skills', 'icon': Icons.accessibility},
      {'name': 'Creativity', 'icon': Icons.palette},
      {'name': 'Behaviour', 'icon': Icons.sentiment_satisfied},
      {'name': 'Activity Assessment', 'icon': Icons.sports},
    ];
    return skills.map((s) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(s['icon'] as IconData, color: Colors.orange),
        title: Text(s['name'] as String,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        '','','',''].map((e) => Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(e, style: const TextStyle(fontSize: 18)))).toList()),
      ),
    )).toList();
  }

  Widget _subjectCard(Map<String, dynamic> s, String stage) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(s['name'] as String,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Switch(
            value: s['selected'] as bool,
            onChanged: (v) => setState(() => s['selected'] = v)),
        ]),
        if (s['selected'] as bool) ...[
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _markField('Max Marks', s['maxMarks'].toString(),
              (v) => s['maxMarks'] = int.tryParse(v) ?? 100)),
            const SizedBox(width: 8),
            Expanded(child: _markField('Pass Marks', s['passingMarks'].toString(),
              (v) => s['passingMarks'] = int.tryParse(v) ?? 35)),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            if (stage != 'foundational')
              _checkbox('Theory', s['hasTheory'] as bool,
                (v) => setState(() => s['hasTheory'] = v!)),
            if (stage == 'middle' || stage == 'secondary')
              _checkbox('Practical', s['hasPractical'] as bool,
                (v) => setState(() => s['hasPractical'] = v!)),
            if (stage == 'secondary')
              _checkbox('Viva', s['hasViva'] as bool,
                (v) => setState(() => s['hasViva'] = v!)),
            _checkbox('Internal', s['hasInternal'] as bool,
              (v) => setState(() => s['hasInternal'] = v!)),
          ]),
        ],
      ]),
    ),
  );

  Widget _gradingTab(String stage) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _header('Grading System', Icons.grade),
      const SizedBox(height: 12),
      if (stage == 'foundational') ...[
        _gradingOption('star', 'Star Rating (Nursery?Class 2)',
          Icons.star, Colors.amber),
        const SizedBox(height: 8),
      ],
      _gradingOption('marks_grade', 'Marks + Grade',
        Icons.score, Colors.blue),
      const SizedBox(height: 8),
      _gradingOption('gpa', 'GPA / CGPA',
        Icons.analytics, Colors.green),
      const SizedBox(height: 8),
      _gradingOption('marks_only', 'Marks Only',
        Icons.numbers, Colors.purple),
      const SizedBox(height: 16),
      _header('Grade Table', Icons.table_chart),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
            child: const Row(children: [
              Expanded(flex: 2, child: Text('Marks Range',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              Expanded(child: Text('Grade',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              Expanded(child: Text('GPA',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            ])),
          ..._gradeTable.map((g) {
            final color = g['grade'] == 'F' ? Colors.red
              : g['gpa'] >= 9 ? Colors.green
              : g['gpa'] >= 7 ? Colors.blue
              : Colors.orange;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade100))),
              child: Row(children: [
                Expanded(flex: 2, child: Text('${g['min']} - ${g['max']}',
                  style: const TextStyle(fontSize: 12))),
                Expanded(child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)),
                  child: Text(g['grade'] as String,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold,
                      fontSize: 12)))),
                Expanded(child: Text('${g['gpa']}',
                  style: const TextStyle(fontSize: 12))),
              ]),
            );
          }),
        ]),
      ),
    ]),
  );

  Widget _publishTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _header('Review & Publish', Icons.publish),
      const SizedBox(height: 14),

      // Summary
      Card(child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Exam Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Divider(),
          _reviewRow('Exam Name', _nameCtrl.text.isEmpty ? 'Not set' : _nameCtrl.text),
          _reviewRow('Type', _examType),
          _reviewRow('Academic Year', _academicYear),
          _reviewRow('Class', '$_selectedClass - $_selectedSection'),
          _reviewRow('Dates', '${_startCtrl.text} to ${_endCtrl.text}'),
          _reviewRow('NEP Stage', _getStage(_selectedClass).toUpperCase()),
          _reviewRow('Grading', _gradingSystem),
          _reviewRow('Subjects',
        '${_subjects.where((s) => s['selected'] as bool).length} selected'),
        ]),
      )),
      const SizedBox(height: 14),

      // Status
      _header('Publication Status', Icons.settings),
      const SizedBox(height: 8),
      ...['draft','published'].map((s) => RadioListTile<String>(
        value: s,
        groupValue: _status,
        onChanged: (v) => setState(() => _status = v!),
        title: Text(s == 'draft' ? 'Save as Draft' : 'Publish Now',
          style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(s == 'draft'
          ? 'Save for later editing before publishing'
          : 'Publish and notify students/parents',
          style: const TextStyle(fontSize: 12)),
        secondary: Icon(s == 'draft' ? Icons.save : Icons.publish,
          color: s == 'draft' ? Colors.grey : Colors.green),
      )),
      const SizedBox(height: 14),

      // Checklist
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.withOpacity(0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Checklist', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...[
            ['Exam name set', _nameCtrl.text.isNotEmpty],
            ['Start date set', _startCtrl.text.isNotEmpty],
            ['Class selected', true],
            ['Subjects configured', _subjects.any((s) => s['selected'] as bool)],
            ['Grading system set', true],
          ].map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              Icon(item[1] as bool ? Icons.check_circle : Icons.cancel,
                color: item[1] as bool ? Colors.green : Colors.red, size: 16),
              const SizedBox(width: 8),
              Text(item[0] as String, style: const TextStyle(fontSize: 12)),
            ]),
          )),
        ]),
      ),
    ]),
  );

  Widget _gradingOption(String value, String label, IconData icon, Color color) =>
    InkWell(
      onTap: () => setState(() => _gradingSystem = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _gradingSystem == value
            ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _gradingSystem == value ? color : Colors.grey.shade200,
            width: _gradingSystem == value ? 2 : 1)),
        child: Row(children: [
          Icon(icon, color: _gradingSystem == value ? color : Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(label,
            style: TextStyle(
              fontWeight: _gradingSystem == value
                ? FontWeight.bold : FontWeight.normal,
              color: _gradingSystem == value ? color : Colors.black87))),
          if (_gradingSystem == value)
            Icon(Icons.check_circle, color: color, size: 20),
        ]),
      ),
    );

  Widget _markField(String label, String initial, Function(String) onChange) =>
    TextFormField(
      initialValue: initial,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
      onChanged: onChange,
    );

  Widget _checkbox(String label, bool value, Function(bool?) onChange) =>
    Row(mainAxisSize: MainAxisSize.min, children: [
      Checkbox(value: value, onChanged: onChange, materialTapTargetSize:
        MaterialTapTargetSize.shrinkWrap),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);

  Widget _reviewRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      SizedBox(width: 110, child: Text(label,
        style: const TextStyle(fontSize: 12, color: Colors.grey))),
      Expanded(child: Text(value,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
    ]));

  Widget _header(String title, IconData icon) => Row(children: [
    Container(width: 4, height: 18,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Icon(icon, color: AppTheme.primaryColor, size: 18),
    const SizedBox(width: 6),
    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
  ]);

  String _getStageInfo(String stage) {
    switch (stage) {
      case 'foundational': return 'NEP 2020: Foundational Stage - Observation-based assessment with emoji/star ratings for holistic development.';
      case 'preparatory': return 'NEP 2020: Preparatory Stage - Subject-wise marks with grades, oral assessment and activity scores.';
      case 'middle': return 'NEP 2020: Middle Stage - Theory + Practical + Internal assessment with GPA and percentage.';
      default: return 'NEP 2020: Secondary Stage - Board pattern with Theory, Practical, Viva, CGPA and stream-wise subjects.';
    }
  }
}


