import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class StaffAttendanceScreen extends StatefulWidget {
  const StaffAttendanceScreen({super.key});
  @override
  State<StaffAttendanceScreen> createState() =>
      _StaffAttendanceScreenState();
}

class _StaffAttendanceScreenState extends State<StaffAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _date = DateTime.now();
  bool _saving = false;

  // ✅ Saved records — date ke hisaab se lock
  final Map<String, List<Map<String, dynamic>>> _savedRecords = {};

  final List<Map<String, dynamic>> _staffList = [
    {
      'name': 'Dr. Rajesh Kumar',
      'id': 'EMP001',
      'status': 'present',
      'checkIn': '08:15',
      'checkOut': '--'
    },
    {
      'name': 'Priya Sharma',
      'id': 'EMP002',
      'status': 'present',
      'checkIn': '08:30',
      'checkOut': '--'
    },
    {
      'name': 'Amit Verma',
      'id': 'EMP003',
      'status': 'absent',
      'checkIn': '--',
      'checkOut': '--'
    },
    {
      'name': 'Sunita Patel',
      'id': 'EMP004',
      'status': 'present',
      'checkIn': '09:00',
      'checkOut': '--'
    },
    {
      'name': 'Ravi Singh',
      'id': 'EMP005',
      'status': 'half',
      'checkIn': '08:45',
      'checkOut': '13:00'
    },
    {
      'name': 'Meena Gupta',
      'id': 'EMP006',
      'status': 'present',
      'checkIn': '08:50',
      'checkOut': '--'
    },
    {
      'name': 'Suresh Driver',
      'id': 'EMP007',
      'status': 'present',
      'checkIn': '07:00',
      'checkOut': '--'
    },
    {
      'name': 'Kavita Joshi',
      'id': 'EMP008',
      'status': 'leave',
      'checkIn': '--',
      'checkOut': '--'
    },
  ];

  String get _dateKey =>
      DateFormat('yyyy-MM-dd').format(_date);

  bool get _isCurrentSaved => _savedRecords.containsKey(_dateKey);

  int get _present =>
      _staffList.where((s) => s['status'] == 'present').length;
  int get _absent =>
      _staffList.where((s) => s['status'] == 'absent').length;
  int get _half =>
      _staffList.where((s) => s['status'] == 'half').length;
  int get _onLeave =>
      _staffList.where((s) => s['status'] == 'leave').length;

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

  void _saveAttendance() async {
    if (_isCurrentSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Is din ki attendance pehle se save ho chuki hai'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate API

    // Deep copy save karo
    _savedRecords[_dateKey] =
        _staffList.map((s) => Map<String, dynamic>.from(s)).toList();

    setState(() => _saving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance Saved ✅'),
          backgroundColor: Colors.green,
        ),
      );
      // Switch to history tab
      _tabController.animateTo(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin =
        context.watch<AuthProvider>().user?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Staff Attendance' : 'My Attendance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            final r = context.read<AuthProvider>().user?.role;
            context.go(
                r == 'staff' ? '/dashboard/staff' : '/dashboard/admin');
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: isAdmin ? 'Daily Mark' : 'My Record'),
            Tab(text: 'History (${_savedRecords.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          isAdmin ? _adminDailyTab() : _staffViewTab(),
          _historyTab(),
        ],
      ),
    );
  }

  // ── Admin tab ────────────────────────────────────────────────────
  Widget _adminDailyTab() => Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Date picker
                GestureDetector(
                  onTap: _isCurrentSaved
                      ? null
                      : () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2024),
                            lastDate: DateTime.now(),
                          );
                          if (d != null) {
                            setState(() => _date = d);
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16,
                            color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('d MMM yyyy').format(_date),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _sum('Present', _present, Colors.green),
                    _sum('Absent', _absent, Colors.red),
                    _sum('Half Day', _half, Colors.orange),
                    _sum('On Leave', _onLeave, Colors.blue),
                  ],
                ),
              ],
            ),
          ),

          // ✅ Saved banner
          if (_isCurrentSaved)
            Container(
              width: double.infinity,
              color: Colors.green.shade50,
              padding: const EdgeInsets.symmetric(
                  vertical: 6, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      size: 15, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Attendance Saved ✅',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _staffList.length,
              itemBuilder: (context, i) {
                final s = _staffList[i];
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: Colors.grey.shade100),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            AppTheme.primaryColor.withOpacity(0.1),
                        child: Text(
                          s['name'][0],
                          style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(s['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            Text(
                              '${s['id']} • In: ${s['checkIn']}  Out: ${s['checkOut']}',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _statusBtn('P', 'present', Colors.green, s, i),
                          const SizedBox(width: 4),
                          _statusBtn('A', 'absent', Colors.red, s, i),
                          const SizedBox(width: 4),
                          _statusBtn('H', 'half', Colors.orange, s, i),
                          const SizedBox(width: 4),
                          _statusBtn('L', 'leave', Colors.blue, s, i),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ✅ Save button — sirf tab jab saved nahi
          if (!_isCurrentSaved)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Save Attendance',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
        ],
      );

  // ── History tab ───────────────────────────────────────────────────
  Widget _historyTab() {
    if (_savedRecords.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Abhi tak koi attendance save nahi hui',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final entries = _savedRecords.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final entry = entries[i];
        final date =
            DateTime.tryParse(entry.key) ?? DateTime.now();
        final records = entry.value;
        final presentC =
            records.where((s) => s['status'] == 'present').length;
        final absentC =
            records.where((s) => s['status'] == 'absent').length;
        final halfC =
            records.where((s) => s['status'] == 'half').length;
        final leaveC =
            records.where((s) => s['status'] == 'leave').length;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ExpansionTile(
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('d').format(date),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue),
                  ),
                  Text(
                    DateFormat('MMM').format(date),
                    style: const TextStyle(
                        fontSize: 10, color: Colors.blue),
                  ),
                ],
              ),
            ),
            title: Text(
              DateFormat('EEEE, d MMM yyyy').format(date),
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                _miniChip('${presentC}P', Colors.green),
                const SizedBox(width: 4),
                _miniChip('${absentC}A', Colors.red),
                const SizedBox(width: 4),
                _miniChip('${halfC}H', Colors.orange),
                const SizedBox(width: 4),
                _miniChip('${leaveC}L', Colors.blue),
              ],
            ),
            trailing: const Icon(Icons.lock,
                size: 16, color: Colors.grey),
            children: [
              const Divider(height: 1),
              ...records.map((s) {
                final color = s['status'] == 'present'
                    ? Colors.green
                    : s['status'] == 'absent'
                        ? Colors.red
                        : s['status'] == 'half'
                            ? Colors.orange
                            : Colors.blue;
                final label = s['status'] == 'present'
                    ? 'Present'
                    : s['status'] == 'absent'
                        ? 'Absent'
                        : s['status'] == 'half'
                            ? 'Half Day'
                            : 'Leave';
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: color.withOpacity(0.15),
                    child: Text(s['name'][0],
                        style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                  title: Text(s['name'],
                      style: const TextStyle(fontSize: 13)),
                  subtitle: Text(s['id'],
                      style: const TextStyle(fontSize: 11)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ── Staff view tab (non-admin) ────────────────────────────────────
  Widget _staffViewTab() => Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('June 2026 Summary',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [
                    _sum('Present', 20, Colors.green),
                    _sum('Absent', 1, Colors.red),
                    _sum('Half Day', 1, Colors.orange),
                    _sum('Leave', 0, Colors.blue),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 20 / 22,
                    backgroundColor:
                        Colors.red.withOpacity(0.2),
                    color: Colors.green,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Attendance: 90.9%',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                const Text('Recent Attendance',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                ...[
                  ['17 Jun 2026', 'present', '08:15', '04:30 PM'],
                  ['16 Jun 2026', 'present', '08:20', '04:30 PM'],
                  ['15 Jun 2026', 'absent', '--', '--'],
                  ['14 Jun 2026', 'present', '08:10', '04:30 PM'],
                  ['13 Jun 2026', 'half', '08:30', '01:00 PM'],
                  ['12 Jun 2026', 'present', '08:25', '04:30 PM'],
                ].map((a) {
                  final statusColor = a[1] == 'present'
                      ? Colors.green
                      : a[1] == 'absent'
                          ? Colors.red
                          : Colors.orange;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        a[1] == 'present'
                            ? Icons.check_circle
                            : a[1] == 'absent'
                                ? Icons.cancel
                                : Icons.timelapse,
                        color: statusColor,
                      ),
                      title: Text(a[0],
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                      subtitle: a[1] != 'absent'
                          ? Text('In: ${a[2]}  •  Out: ${a[3]}',
                              style:
                                  const TextStyle(fontSize: 11))
                          : null,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              statusColor.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: Text(
                          a[1].toUpperCase(),
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      );

  Widget _monthlyTab() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {}),
                const Text('June 2026',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {}),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                      AppTheme.primaryColor.withOpacity(0.1)),
                  columns: const [
                    DataColumn(
                        label: Text('Name',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12))),
                    DataColumn(
                        label: Text('Present',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12))),
                    DataColumn(
                        label: Text('Absent',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12))),
                    DataColumn(
                        label: Text('Half',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12))),
                    DataColumn(
                        label: Text('%',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12))),
                  ],
                  rows: [
                    _dataRow('Dr. Rajesh Kumar', '20', '1', '1',
                        '90.9%', Colors.green),
                    _dataRow('Priya Sharma', '19', '2', '0',
                        '86.4%', Colors.green),
                    _dataRow('Amit Verma', '18', '3', '1',
                        '81.8%', Colors.orange),
                    _dataRow('Sunita Patel', '21', '1', '0',
                        '95.5%', Colors.green),
                    _dataRow('Ravi Singh', '17', '2', '2',
                        '77.3%', Colors.orange),
                    _dataRow('Meena Gupta', '20', '2', '0',
                        '90.9%', Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  DataRow _dataRow(String name, String p, String a, String h,
          String pct, Color color) =>
      DataRow(cells: [
        DataCell(Text(name,
            style: const TextStyle(fontSize: 11))),
        DataCell(Text(p,
            style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 11))),
        DataCell(Text(a,
            style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 11))),
        DataCell(Text(h,
            style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 11))),
        DataCell(Text(pct,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11))),
      ]);

  Widget _sum(String label, int count, Color color) => Column(
        children: [
          Text('$count',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style:
                  const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      );

  Widget _statusBtn(String label, String val, Color color,
      Map s, int i) {
    final sel = s['status'] == val;
    // ✅ Saved hone ke baad buttons disabled
    final locked = _isCurrentSaved;
    return GestureDetector(
      onTap: locked
          ? null
          : () => setState(() => _staffList[i]['status'] = val),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: locked
              ? (sel ? color.withOpacity(0.5) : Colors.grey.shade100)
              : (sel ? color : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
              color: sel ? color : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
                color: sel ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 10),
          ),
        ),
      ),
    );
  }

  Widget _miniChip(String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold)),
      );
}
