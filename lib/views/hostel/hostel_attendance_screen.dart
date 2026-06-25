import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

// ─── Models ────────────────────────────────────────────────────────────────

class _HostelStudent {
  final int id;
  final String name;
  final String room;
  String status; // 'P', 'A', 'L'

  _HostelStudent({required this.id, required this.name, required this.room, this.status = 'P'});
}

class _HostelAttRecord {
  final DateTime date;
  final List<_HostelStudent> students;
  final int presentCount;
  final int absentCount;
  final int lateCount;

  _HostelAttRecord({
    required this.date,
    required this.students,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
  });
}

// ─── Screen ────────────────────────────────────────────────────────────────

class HostelAttendanceScreen extends StatefulWidget {
  const HostelAttendanceScreen({super.key});
  @override
  State<HostelAttendanceScreen> createState() => _HostelAttendanceScreenState();
}

class _HostelAttendanceScreenState extends State<HostelAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  DateTime _date = DateTime.now();
  bool _saving = false;

  // saved map keyed by date string
  final Map<String, _HostelAttRecord> _saved = {};
  final List<_HostelAttRecord> _history = [];

  List<_HostelStudent> _students = [
    _HostelStudent(id: 1, name: 'Rahul Kumar',  room: '101'),
    _HostelStudent(id: 2, name: 'Vijay Verma',  room: '101'),
    _HostelStudent(id: 3, name: 'Priya Singh',  room: '201'),
    _HostelStudent(id: 4, name: 'Anita Gupta',  room: '201', status: 'L'),
    _HostelStudent(id: 5, name: 'Mohit Sharma', room: '102'),
    _HostelStudent(id: 6, name: 'Sneha Rao',    room: '202'),
  ];

  String get _dateKey => DateFormat('yyyy-MM-dd').format(_date);
  bool get _isSaved => _saved.containsKey(_dateKey);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() {
        _date = d;
        // If that date was already saved, load its data (read-only)
        if (_saved.containsKey(DateFormat('yyyy-MM-dd').format(d))) {
          _students = List<_HostelStudent>.from(
              _saved[DateFormat('yyyy-MM-dd').format(d)]!.students);
        } else {
          // reset to default for new date
          _students = [
            _HostelStudent(id: 1, name: 'Rahul Kumar',  room: '101'),
            _HostelStudent(id: 2, name: 'Vijay Verma',  room: '101'),
            _HostelStudent(id: 3, name: 'Priya Singh',  room: '201'),
            _HostelStudent(id: 4, name: 'Anita Gupta',  room: '201'),
            _HostelStudent(id: 5, name: 'Mohit Sharma', room: '102'),
            _HostelStudent(id: 6, name: 'Sneha Rao',    room: '202'),
          ];
        }
      });
    }
  }

  Future<void> _save() async {
    if (_isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Already saved for this date'),
          backgroundColor: Colors.orange));
      return;
    }
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 400));

    final rec = _HostelAttRecord(
      date: _date,
      students: List<_HostelStudent>.from(_students),
      presentCount: _students.where((s) => s.status == 'P').length,
      absentCount:  _students.where((s) => s.status == 'A').length,
      lateCount:    _students.where((s) => s.status == 'L').length,
    );

    setState(() {
      _saved[_dateKey] = rec;
      _history.insert(0, rec);
      _saving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance saved!'), backgroundColor: Colors.green));
      _tabController.animateTo(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Hostel Attendance'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            const Tab(text: 'Mark'),
            Tab(text: 'History (${_history.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMarkTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  // ─── MARK TAB ────────────────────────────────────────────────────────────

  Widget _buildMarkTab() {
    final saved    = _isSaved;
    final present  = _students.where((s) => s.status == 'P').length;
    final absent   = _students.where((s) => s.status == 'A').length;
    final late     = _students.where((s) => s.status == 'L').length;

    return Column(children: [
      // Header card
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          // Date picker
          Row(children: [
            SizedBox(
              width: 180,
              child: OutlinedButton.icon(
                onPressed: saved ? null : _pickDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text(DateFormat('d MMM yyyy').format(_date),
                    style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          // Stats row
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _sum('Present', present, Colors.green),
            _sum('Absent',  absent,  Colors.red),
            _sum('Late',    late,    Colors.orange),
            _sum('Total',   _students.length, Colors.grey),
          ]),
        ]),
      ),

      // Saved banner
      if (saved)
        Container(
          margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(children: [
            Icon(Icons.lock_outline, color: Colors.green.shade700, size: 18),
            const SizedBox(width: 8),
            Text('Saved Attendance — view only',
                style: TextStyle(color: Colors.green.shade800,
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        ),

      const Divider(height: 1),

      // Student list
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _students.length,
          itemBuilder: (context, i) {
            final s = _students[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(s.name[0],
                        style: const TextStyle(color: AppTheme.primaryColor,
                            fontSize: 13, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('Room: ${s.room}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ])),
                  Row(children: [
                    _attBtn('P', Colors.green, s.status == 'P',
                        saved ? null : () => setState(() => s.status = 'P')),
                    const SizedBox(width: 5),
                    _attBtn('A', Colors.red, s.status == 'A',
                        saved ? null : () => setState(() => s.status = 'A')),
                    const SizedBox(width: 5),
                    _attBtn('L', Colors.orange, s.status == 'L',
                        saved ? null : () => setState(() => s.status = 'L')),
                  ]),
                ]),
              ),
            );
          },
        ),
      ),

      // Save button
      if (!saved)
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_saving ? 'Saving...' : 'Save Attendance'),
              ),
            ),
          ),
        ),
    ]);
  }

  // ─── HISTORY TAB ─────────────────────────────────────────────────────────

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text('No saved attendance yet', style: TextStyle(color: Colors.grey)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final rec = _history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text('Hostel Attendance',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
                _savedBadge(),
              ]),
              const SizedBox(height: 4),
              Text(DateFormat('d MMM yyyy').format(rec.date),
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 10),
              Row(children: [
                _histStat('✅ ${rec.presentCount} Present', Colors.green),
                const SizedBox(width: 8),
                _histStat('❌ ${rec.absentCount} Absent', Colors.red),
                if (rec.lateCount > 0) ...[
                  const SizedBox(width: 8),
                  _histStat('⏰ ${rec.lateCount} Late', Colors.orange),
                ],
              ]),
              const SizedBox(height: 8),
              const Text('Edit not allowed after saving',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
            ]),
          ),
        );
      },
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Widget _sum(String label, int count, Color color) => Column(children: [
        Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ]);

  Widget _attBtn(String label, Color color, bool selected, VoidCallback? onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: selected ? color : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: color, width: selected ? 2 : 1)),
          child: Center(child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.bold, fontSize: 12)))));

  Widget _savedBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.lock_outline, size: 12, color: Colors.green.shade700),
          const SizedBox(width: 4),
          Text('Saved',
              style: TextStyle(fontSize: 11,
                  color: Colors.green.shade700, fontWeight: FontWeight.w600)),
        ]));

  Widget _histStat(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)));
}