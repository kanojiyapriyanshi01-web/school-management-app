import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});
  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedClass = 'Class 10';
  String _selectedSection = 'A';
  String _selectedDay = 'Monday';

  final _classes = ['Nursery','LKG','UKG','Class 1','Class 2','Class 3',
        'Class 4','Class 5','Class 6','Class 7','Class 8',
        'Class 9','Class 10','Class 11','Class 12'];
  final _days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];

  // Stage ke hisaab se subjects
  String _getStage(String cls) {
    if (['Nursery','LKG','UKG','Class 1','Class 2'].contains(cls)) return 'foundational';
    if (['Class 3','Class 4','Class 5'].contains(cls)) return 'preparatory';
    if (['Class 6','Class 7','Class 8'].contains(cls)) return 'middle';
    return 'secondary';
  }

  List<String> _getSubjects(String cls) {
    final stage = _getStage(cls);
    switch (stage) {
      case 'foundational':
        return ['English Rhymes','Number Play','Drawing & Art','Story Time','Activity','Break','Lunch'];
      case 'preparatory':
        return ['English','Mathematics','EVS','Hindi','Drawing','Physical Ed.','Break','Lunch'];
      case 'middle':
        return ['English','Mathematics','Science','Social Science','Hindi','Sanskrit','Computer','Physical Ed.','Break','Lunch'];
      case 'secondary':
        if (cls == 'Class 11' || cls == 'Class 12') {
          return ['Physics','Chemistry','Mathematics','Biology','English','Computer Science','Physical Ed.','Break','Lunch'];
        }
        return ['English','Mathematics','Science','Social Science','Hindi','Sanskrit','Computer','Physical Ed.','Break','Lunch'];
      default:
        return ['English','Mathematics','Science','Hindi','Break','Lunch'];
    }
  }

  List<Map<String, String>> _getPeriods(String cls, String day) {
    final stage = _getStage(cls);
    final subjects = _getSubjects(cls).where((s) => s != 'Break' && s != 'Lunch').toList();

    final teachers = {
        'English': 'Mrs. Priya',
        'Mathematics': 'Mr. Ravi Sharma',
        'Science': 'Mr. Kumar',
        'Social Science': 'Mr. Singh',
        'Hindi': 'Mrs. Gupta',
        'Sanskrit': 'Mrs. Devi',
        'Computer': 'Mr. Tech',
        'Computer Science':'Mr. Tech',
        'Physical Ed.': 'Mr. Sports',
        'EVS': 'Mrs. Green',
        'Drawing & Art': 'Mrs. Art',
        'Drawing': 'Mrs. Art',
        'Physics': 'Mr. Physics',
        'Chemistry': 'Mr. Chem',
        'Biology': 'Mrs. Bio',
        'English Rhymes': 'Mrs. Priya',
        'Number Play': 'Mrs. Math',
        'Story Time': 'Mrs. Priya',
        'Activity': 'Mrs. Activity',
    };

    // Day ke hisaab se subject order rotate karo
    final dayIndex = _days.indexOf(day);
    final rotated = [...subjects.skip(dayIndex % subjects.length), ...subjects.take(dayIndex % subjects.length)];

    List<Map<String, String>> periods = [];

    if (stage == 'foundational') {
      // Shorter day for foundational
      periods = [
        {'subject': rotated[0 % rotated.length], 'time': '8:00 - 8:45', 'teacher': teachers[rotated[0 % rotated.length]] ?? '', 'type': 'class'},
        {'subject': rotated[1 % rotated.length], 'time': '8:45 - 9:30', 'teacher': teachers[rotated[1 % rotated.length]] ?? '', 'type': 'class'},
        {'subject': 'Break', 'time': '9:30 - 9:45', 'teacher': '', 'type': 'break'},
        {'subject': rotated[2 % rotated.length], 'time': '9:45 - 10:30', 'teacher': teachers[rotated[2 % rotated.length]] ?? '', 'type': 'class'},
        {'subject': rotated[3 % rotated.length], 'time': '10:30 - 11:15','teacher': teachers[rotated[3 % rotated.length]] ?? '', 'type': 'class'},
        {'subject': 'Lunch', 'time': '11:15 - 12:00','teacher': '', 'type': 'break'},
        {'subject': rotated[4 % rotated.length], 'time': '12:00 - 12:45','teacher': teachers[rotated[4 % rotated.length]] ?? '', 'type': 'class'},
      ];
    } else {
      // Full day for other stages
      periods = [
        {'subject': rotated[0 % rotated.length], 'time': '8:00 - 8:45', 'teacher': teachers[rotated[0 % rotated.length]] ?? '', 'type': 'class'},
        {'subject': rotated[1 % rotated.length], 'time': '8:45 - 9:30', 'teacher': teachers[rotated[1 % rotated.length]] ?? '', 'type': 'class'},
        {'subject': rotated[2 % rotated.length], 'time': '9:30 - 10:15', 'teacher': teachers[rotated[2 % rotated.length]] ?? '', 'type': 'class'},
        {'subject': 'Break', 'time': '10:15 - 10:30', 'teacher': '', 'type': 'break'},
        {'subject': rotated[3 % rotated.length], 'time': '10:30 - 11:15', 'teacher': teachers[rotated[3 % rotated.length]] ?? '', 'type': 'class'},
        {'subject': rotated[4 % rotated.length], 'time': '11:15 - 12:00', 'teacher': teachers[rotated[4 % rotated.length]] ?? '', 'type': 'class'},
        {'subject': rotated[5 % rotated.length], 'time': '12:00 - 12:45', 'teacher': teachers[rotated[5 % rotated.length]] ?? '', 'type': 'class'},
        {'subject': 'Lunch', 'time': '12:45 - 1:30', 'teacher': '', 'type': 'break'},
        {'subject': rotated[6 % rotated.length], 'time': '1:30 - 2:15', 'teacher': teachers[rotated[6 % rotated.length]] ?? '', 'type': 'class'},
      ];
    }

    // Saturday shorter
    if (day == 'Saturday') {
      periods = periods.take(stage == 'foundational' ? 4 : 6).toList();
    }

    return periods;
  }

  final _subjectColors = <String, Color>{
        'Mathematics':    Colors.blue,
        'Science':        Colors.green,
        'English':        Colors.purple,
        'Hindi':          Colors.orange,
        'Social Science': Colors.teal,
        'Computer':       Colors.indigo,
        'Computer Science': Colors.indigo,
        'Physical Ed.':   Colors.red,
        'Drawing & Art':  Colors.pink,
        'Drawing':        Colors.pink,
        'EVS':            Colors.lightGreen,
        'Sanskrit':       Colors.deepOrange,
        'English Rhymes': Colors.purple,
        'Number Play':    Colors.blue,
        'Story Time':     Colors.amber,
        'Activity':       Colors.cyan,
        'Physics':        Colors.blue,
        'Chemistry':      Colors.green,
        'Biology':        Colors.lightGreen,
        'Break':          Colors.grey,
        'Lunch':          Colors.amber,
  };

  @override
  void initState() {
    super.initState();
    final role = context.read<AuthProvider>().user?.role;
    _tabController = TabController(length: role == 'admin' ? 2 : 1, vsync: this);
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().user?.role;
    final isAdmin = role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            final r = context.read<AuthProvider>().user?.role;
            context.go(r == 'student' ? '/dashboard/student'
              : r == 'staff' ? '/dashboard/staff'
              : r == 'parent' ? '/dashboard/parent'
              : '/dashboard/admin');
          },
        ),
        actions: isAdmin ? [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddPeriodDialog(context)),
        ] : null,
        bottom: isAdmin ? TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [Tab(text: 'View'), Tab(text: 'Manage')],
        ) : null,
      ),
      body: isAdmin
        ? TabBarView(controller: _tabController, children: [_timetableView(isAdmin), _manageView()])
        : _timetableView(isAdmin),
    );
  }

  Widget _timetableView(bool isAdmin) {
    final periods = _getPeriods(_selectedClass, _selectedDay);
    final stage = _getStage(_selectedClass);
    final stageColors = {
        'foundational': Colors.green,
        'preparatory':  Colors.blue,
        'middle':       Colors.orange,
        'secondary':    Colors.purple,
    };
    final stageNames = {
        'foundational': 'Foundational Stage',
        'preparatory': 'Preparatory Stage',
        'middle': 'Middle Stage',
        'secondary': 'Secondary Stage',
    };

    return Column(children: [
      Container(color: Colors.white, padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            Expanded(child: DropdownButtonFormField<String>(
              value: _selectedClass,
              decoration: const InputDecoration(labelText: 'Class',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
              items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c,
                style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: (v) => setState(() => _selectedClass = v!),
            )),
            const SizedBox(width: 10),
            Expanded(child: DropdownButtonFormField<String>(
              value: _selectedSection,
              decoration: const InputDecoration(labelText: 'Section',
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
              items: ['A','B','C','D'].map((s) =>
                DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _selectedSection = v!),
            )),
          ]),
          const SizedBox(height: 8),
          // Stage badge
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: stageColors[stage]!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: stageColors[stage]!.withOpacity(0.3))),
              child: Row(children: [
                Icon(Icons.school, size: 14, color: stageColors[stage]),
                const SizedBox(width: 4),
                Text(stageNames[stage]!,
                  style: TextStyle(fontSize: 11, color: stageColors[stage], fontWeight: FontWeight.w600)),
              ])),
            const SizedBox(width: 8),
            Text('${_getSubjects(_selectedClass).where((s) => s != 'Break' && s != 'Lunch').length} subjects',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
          const SizedBox(height: 8),
          // Day chips
          SizedBox(height: 36, child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(_days[i].substring(0, 3), style: const TextStyle(fontSize: 11)),
                selected: _selectedDay == _days[i],
                onSelected: (_) => setState(() => _selectedDay = _days[i]),
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: _selectedDay == _days[i] ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600),
              ),
            ),
          )),
        ])),
      const Divider(height: 1),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: periods.length,
        itemBuilder: (context, i) {
          final p = periods[i];
          final isBreak = p['type'] == 'break';
          final color = _subjectColors[p['subject']] ?? Colors.blue;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isBreak ? Colors.grey.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isBreak ? Colors.grey.shade200 : color.withOpacity(0.2)),
            ),
            child: Row(children: [
              Container(width: 4, height: isBreak ? 40 : 70,
                decoration: BoxDecoration(
                  color: isBreak ? Colors.grey.shade300 : color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)))),
              Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p['subject']!,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,
                        color: isBreak ? Colors.grey : Colors.black87)),
                    Text(p['time']!,
                      style: TextStyle(fontSize: 12, color: isBreak ? Colors.grey.shade400 : Colors.grey)),
                    if (!isBreak && p['teacher']!.isNotEmpty)
                      Text(p['teacher']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ])),
                  if (!isBreak) Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.person_outline, color: color, size: 20)),
                ]),
              )),
            ]),
          );
        },
      )),
    ]);
  }

  Widget _manageView() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DropdownButtonFormField<String>(
        value: _selectedClass,
        decoration: const InputDecoration(labelText: 'Select Class', prefixIcon: Icon(Icons.class_)),
        items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: (v) => setState(() => _selectedClass = v!),
      ),
      const SizedBox(height: 16),
      const Text('Subjects for this class',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8,
        children: _getSubjects(_selectedClass)
          .where((s) => s != 'Break' && s != 'Lunch')
          .map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (_subjectColors[s] ?? Colors.blue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: (_subjectColors[s] ?? Colors.blue).withOpacity(0.3))),
            child: Text(s, style: TextStyle(
              fontSize: 12, color: _subjectColors[s] ?? Colors.blue,
              fontWeight: FontWeight.w500)),
          )).toList()),
      const SizedBox(height: 20),
      const Text('Weekly Schedule',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(height: 10),
      ..._days.map((day) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(day.substring(0,3),
              style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)))),
          title: Text(day, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          subtitle: Text(
        '${_getPeriods(_selectedClass, day).where((p) => p['type'] == 'class').length} periods',
            style: const TextStyle(fontSize: 11)),
          trailing: TextButton(
            onPressed: () => setState(() { _selectedDay = day; _tabController.animateTo(0); }),
            child: const Text('View'),
          ),
        ),
      )),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: ElevatedButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timetable saved!'), backgroundColor: Colors.green)),
        icon: const Icon(Icons.save),
        label: const Text('Save Timetable'),
      )),
    ]),
  );

  void _showAddPeriodDialog(BuildContext context) {
    final subjects = _getSubjects(_selectedClass).where((s) => s != 'Break' && s != 'Lunch').toList();
    String subject = subjects.first;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Period'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              value: subject,
              decoration: const InputDecoration(labelText: 'Subject'),
              items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setS(() => subject = v!),
            ),
            const SizedBox(height: 10),
            TextFormField(decoration: const InputDecoration(labelText: 'From Time (e.g. 8:00 AM)')),
            const SizedBox(height: 10),
            TextFormField(decoration: const InputDecoration(labelText: 'To Time (e.g. 8:45 AM)')),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Period added!'), backgroundColor: Colors.green));
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}


