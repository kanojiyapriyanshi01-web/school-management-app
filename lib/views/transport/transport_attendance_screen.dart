import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transport_provider.dart';
import '../../core/theme/app_theme.dart';

// ─── Saved record model ────────────────────────────────────────────────────

class _TransportAttRecord {
  final DateTime date;
  final int? vehicleId;
  final String vehicleLabel;
  final String type; // 'Students' or 'Drivers'
  final Map<int, String> statuses;

  _TransportAttRecord({
    required this.date,
    required this.vehicleId,
    required this.vehicleLabel,
    required this.type,
    required this.statuses,
  });

  int get presentCount => statuses.values.where((v) => v == 'P').length;
  int get absentCount  => statuses.values.where((v) => v == 'A').length;
  int get lateCount    => statuses.values.where((v) => v == 'L').length;
}

// ─── Screen ────────────────────────────────────────────────────────────────

class TransportAttendanceScreen extends StatefulWidget {
  const TransportAttendanceScreen({super.key});
  @override
  State<TransportAttendanceScreen> createState() => _TransportAttendanceScreenState();
}

class _TransportAttendanceScreenState extends State<TransportAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  DateTime _selectedDate = DateTime.now();
  int? _selectedVehicleId;
  int _listTab = 0; // 0 = Students, 1 = Drivers

  final Map<int, String> _studentAtt = {};
  final Map<int, String> _driverAtt  = {};
  bool _saving = false;

  // saved records keyed by "vehicleId|date|type"
  final Map<String, _TransportAttRecord> _saved = {};
  final List<_TransportAttRecord> _history = [];

  String get _saveKey =>
      '${_selectedVehicleId ?? "all"}|${DateFormat('yyyy-MM-dd').format(_selectedDate)}|${_listTab == 0 ? "Students" : "Drivers"}';

  bool get _isSaved => _saved.containsKey(_saveKey);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransportProvider>().fetchAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _save(TransportProvider p) async {
    if (_isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Already saved for this selection & date'),
          backgroundColor: Colors.orange));
      return;
    }
    final map = _listTab == 0 ? _studentAtt : _driverAtt;
    if (map.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please mark attendance first'),
          backgroundColor: Colors.orange));
      return;
    }
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 400));

    final vLabel = _selectedVehicleId == null
        ? 'All Vehicles'
        : p.vehicles.firstWhere((v) => v.id == _selectedVehicleId).vehicleNumber;

    final rec = _TransportAttRecord(
      date: _selectedDate,
      vehicleId: _selectedVehicleId,
      vehicleLabel: vLabel,
      type: _listTab == 0 ? 'Students' : 'Drivers',
      statuses: Map<int, String>.from(map),
    );

    setState(() {
      _saved[_saveKey] = rec;
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
    final p = context.watch<TransportProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Transport Attendance'),
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
          _buildMarkTab(p),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  // ─── MARK TAB ────────────────────────────────────────────────────────────

  Widget _buildMarkTab(TransportProvider p) {
    final saved = _isSaved;
    final map   = _listTab == 0 ? _studentAtt : _driverAtt;

    return Column(children: [
      // Filters card
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          // Date + Vehicle row
          Row(children: [
            SizedBox(
              width: 148,
              child: OutlinedButton.icon(
                onPressed: saved ? null : _pickDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text(DateFormat('d MMM yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<int?>(
                value: _selectedVehicleId,
                isExpanded: true,
                decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                    prefixIcon: Icon(Icons.directions_bus, size: 18)),
                hint: const Text('All Vehicles', style: TextStyle(fontSize: 13)),
                items: [
                  const DropdownMenuItem<int?>(value: null,
                      child: Text('All Vehicles', style: TextStyle(fontSize: 13))),
                  ...p.vehicles.map((v) => DropdownMenuItem<int?>(
                        value: v.id,
                        child: Text('${v.vehicleNumber}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13)),
                      )),
                ],
                onChanged: saved ? null : (v) => setState(() => _selectedVehicleId = v),
              ),
            ),
          ]),
          const SizedBox(height: 10),

          // Students / Drivers toggle
          Row(children: [
            Expanded(child: _toggleBtn('Students (${p.students.length})', Icons.school, 0, saved)),
            const SizedBox(width: 8),
            Expanded(child: _toggleBtn(
                'Drivers (${p.vehicles.where((v) => v.driverName.isNotEmpty).length})',
                Icons.person, 1, saved)),
          ]),
        ]),
      ),

      // Stats bar
      Container(
        color: Colors.grey.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(children: [
          _summaryChip('Present', map.values.where((v) => v == 'P').length, Colors.green),
          const SizedBox(width: 8),
          _summaryChip('Absent',  map.values.where((v) => v == 'A').length, Colors.red),
          const SizedBox(width: 8),
          _summaryChip('Late',    map.values.where((v) => v == 'L').length, Colors.orange),
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

      // List
      Expanded(child: _listTab == 0 ? _studentList(p, saved) : _driverList(p, saved)),

      // Save button
      if (!saved)
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : () => _save(p),
              icon: _saving
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(_saving ? 'Saving...' : 'Save Attendance'),
            ),
          ),
        ),
    ]);
  }

  Widget _toggleBtn(String label, IconData icon, int idx, bool locked) =>
      GestureDetector(
        onTap: locked ? null : () => setState(() => _listTab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: _listTab == idx ? AppTheme.primaryColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: _listTab == idx ? Colors.white : Colors.grey),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: _listTab == idx ? Colors.white : Colors.grey)),
          ]),
        ),
      );

  Widget _studentList(TransportProvider p, bool saved) {
    if (p.students.isEmpty) return const Center(
        child: Text('No students assigned to transport', style: TextStyle(color: Colors.grey)));

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: p.students.length,
      itemBuilder: (ctx, i) {
        final s = p.students[i];
        final status = _studentAtt[s.studentId] ?? '';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(s.studentName.isNotEmpty ? s.studentName[0] : 'S',
                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.studentName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Stop: ${s.pickupStop.isEmpty ? "N/A" : s.pickupStop}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ])),
              Row(children: [
                _attBtn('P', Colors.green, status == 'P',
                    saved ? null : () => setState(() => _studentAtt[s.studentId] = 'P')),
                const SizedBox(width: 6),
                _attBtn('A', Colors.red, status == 'A',
                    saved ? null : () => setState(() => _studentAtt[s.studentId] = 'A')),
                const SizedBox(width: 6),
                _attBtn('L', Colors.orange, status == 'L',
                    saved ? null : () => setState(() => _studentAtt[s.studentId] = 'L')),
              ]),
            ]),
          ),
        );
      },
    );
  }

  Widget _driverList(TransportProvider p, bool saved) {
    final drivers = p.vehicles.where((v) => v.driverName.isNotEmpty).toList();
    if (drivers.isEmpty) return const Center(
        child: Text('No drivers found.', style: TextStyle(color: Colors.grey)));

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: drivers.length,
      itemBuilder: (ctx, i) {
        final v = drivers[i];
        final status = _driverAtt[v.id] ?? '';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: Colors.teal.withOpacity(0.1),
                child: Text(v.driverName[0],
                    style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(v.driverName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('${v.vehicleNumber} · ${v.driverPhone}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ])),
              Row(children: [
                _attBtn('P', Colors.green, status == 'P',
                    saved ? null : () => setState(() => _driverAtt[v.id] = 'P')),
                const SizedBox(width: 6),
                _attBtn('A', Colors.red, status == 'A',
                    saved ? null : () => setState(() => _driverAtt[v.id] = 'A')),
                const SizedBox(width: 6),
                _attBtn('L', Colors.orange, status == 'L',
                    saved ? null : () => setState(() => _driverAtt[v.id] = 'L')),
              ]),
            ]),
          ),
        );
      },
    );
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
                Icon(rec.type == 'Students' ? Icons.school : Icons.person,
                    size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('${rec.type} · ${rec.vehicleLabel}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
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

  // ─── Shared helpers ───────────────────────────────────────────────────────

  Widget _attBtn(String label, Color color, bool selected, VoidCallback? onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: selected ? color : color.withOpacity(0.08),
            border: Border.all(color: color, width: selected ? 2 : 1),
            borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.bold, fontSize: 13))),
        ),
      );

  Widget _summaryChip(String label, int count, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Text('$label: $count',
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)));

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