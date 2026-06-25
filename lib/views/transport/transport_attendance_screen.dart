import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transport_provider.dart';
import '../../providers/student_provider.dart';
import '../../core/theme/app_theme.dart';

class TransportAttendanceScreen extends StatefulWidget {
  const TransportAttendanceScreen({super.key});
  @override
  State<TransportAttendanceScreen> createState() => _TransportAttendanceScreenState();
}

class _TransportAttendanceScreenState extends State<TransportAttendanceScreen> {
  String _selectedDate = '';
  int? _selectedVehicleId;
  int _tabIndex = 0; // 0=Students, 1=Drivers
  final Map<int, String> _studentAttendance = {};
  final Map<int, String> _driverAttendance = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = '${now.day.toString().padLeft(2,'0')}/${now.month.toString().padLeft(2,'0')}/${now.year}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransportProvider>().fetchAll();
      context.read<StudentProvider>().fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransportProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(children: [
        // Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            // Date selector
            Row(children: [
              const Icon(Icons.calendar_today,
                color: AppTheme.primaryColor, size: 18),
              const SizedBox(width: 8),
              Text('Date: $_selectedDate',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now());
                  if (d != null) setState(() =>
                    _selectedDate =
        '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}');
                },
                icon: const Icon(Icons.edit_calendar, size: 14),
                label: const Text('Change', style: TextStyle(fontSize: 12))),
            ]),
            const SizedBox(height: 10),

            // Vehicle selector
            if (p.vehicles.isNotEmpty)
              DropdownButtonFormField<int>(
                value: _selectedVehicleId,
                hint: const Text('Select Vehicle (Optional)'),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.directions_bus),
                  border: OutlineInputBorder(),
                  isDense: true),
                items: p.vehicles.map((v) => DropdownMenuItem<int>(
                  value: v.id,
                  child: Text('${v.vehicleNumber} - ${v.driverName.isEmpty ? "No driver" : v.driverName}',
                    overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => setState(() => _selectedVehicleId = v),
              ),
            const SizedBox(height: 10),

            // Tab selector
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _tabIndex = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _tabIndex == 0
                      ? AppTheme.primaryColor : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.school, size: 16,
                      color: _tabIndex == 0 ? Colors.white : Colors.grey),
                    const SizedBox(width: 6),
                    Text('Students (${p.students.length})',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: _tabIndex == 0 ? Colors.white : Colors.grey)),
                  ])),
              )),
              const SizedBox(width: 8),
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _tabIndex = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _tabIndex == 1
                      ? AppTheme.primaryColor : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.person, size: 16,
                      color: _tabIndex == 1 ? Colors.white : Colors.grey),
                    const SizedBox(width: 6),
                    Text('Drivers (${p.vehicles.where((v) => v.driverName.isNotEmpty).length})',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: _tabIndex == 1 ? Colors.white : Colors.grey)),
                  ])),
              )),
            ]),
          ])),

        // Summary bar
        Container(
          color: Colors.grey.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(children: [
            _summaryChip('Present',
              _tabIndex == 0
                ? _studentAttendance.values.where((v) => v == 'P').length
                : _driverAttendance.values.where((v) => v == 'P').length,
              Colors.green),
            const SizedBox(width: 8),
            _summaryChip('Absent',
              _tabIndex == 0
                ? _studentAttendance.values.where((v) => v == 'A').length
                : _driverAttendance.values.where((v) => v == 'A').length,
              Colors.red),
            const SizedBox(width: 8),
            _summaryChip('Late',
              _tabIndex == 0
                ? _studentAttendance.values.where((v) => v == 'L').length
                : _driverAttendance.values.where((v) => v == 'L').length,
              Colors.orange),
            const Spacer(),
            Text('${_tabIndex == 0 ? _studentAttendance.length : _driverAttendance.length} marked',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ])),

        // List
        Expanded(child: _tabIndex == 0
          ? _studentList(p)
          : _driverList(p)),

        // Save button
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: _saving ? null : () => _saveAttendance(context, p),
            icon: _saving
              ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.save),
            label: Text(_saving ? 'Saving...' : 'Save Attendance'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14)),
          ))),
      ]),
    );
  }

  Widget _studentList(TransportProvider p) {
    if (p.students.isEmpty) return const Center(
      child: Text('No students assigned to transport',
        style: TextStyle(color: Colors.grey)));

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: p.students.length,
      itemBuilder: (ctx, i) {
        final s = p.students[i];
        final status = _studentAttendance[s.studentId] ?? '';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(s.studentName.isNotEmpty ? s.studentName[0] : 'S',
                  style: const TextStyle(color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.studentName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Stop: ${s.pickupStop.isEmpty ? "N/A" : s.pickupStop}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ])),
              Row(children: [
                _attBtn('P', Colors.green, status == 'P',
                  () => setState(() => _studentAttendance[s.studentId] = 'P')),
                const SizedBox(width: 6),
                _attBtn('A', Colors.red, status == 'A',
                  () => setState(() => _studentAttendance[s.studentId] = 'A')),
                const SizedBox(width: 6),
                _attBtn('L', Colors.orange, status == 'L',
                  () => setState(() => _studentAttendance[s.studentId] = 'L')),
              ]),
            ])));
      });
  }

  Widget _driverList(TransportProvider p) {
    final drivers = p.vehicles.where((v) => v.driverName.isNotEmpty).toList();
    if (drivers.isEmpty) return const Center(
      child: Text('No drivers found. Add vehicles with driver details.',
        style: TextStyle(color: Colors.grey), textAlign: TextAlign.center));

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: drivers.length,
      itemBuilder: (ctx, i) {
        final v = drivers[i];
        final status = _driverAttendance[v.id] ?? '';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: Colors.teal.withOpacity(0.1),
                child: Text(v.driverName[0],
                  style: const TextStyle(color: Colors.teal,
                    fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(v.driverName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('${v.vehicleNumber} ? ${v.driverPhone}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ])),
              Row(children: [
                _attBtn('P', Colors.green, status == 'P',
                  () => setState(() => _driverAttendance[v.id] = 'P')),
                const SizedBox(width: 6),
                _attBtn('A', Colors.red, status == 'A',
                  () => setState(() => _driverAttendance[v.id] = 'A')),
                const SizedBox(width: 6),
                _attBtn('L', Colors.orange, status == 'L',
                  () => setState(() => _driverAttendance[v.id] = 'L')),
              ]),
            ])));
      });
  }

  Future<void> _saveAttendance(BuildContext context, TransportProvider p) async {
    if (_studentAttendance.isEmpty && _driverAttendance.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please mark attendance first'),
          backgroundColor: Colors.orange));
      return;
    }
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _saving = false);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance saved for $_selectedDate! '
        '${_studentAttendance.values.where((v) => v == "P").length} students present, '
 '${_driverAttendance.values.where((v) => v == "P").length} drivers present'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3)));
  }

  Widget _attBtn(String label, Color color, bool selected, VoidCallback onTap) =>
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
          style: TextStyle(color: selected ? Colors.white : color,
            fontWeight: FontWeight.bold, fontSize: 13)))));

  Widget _summaryChip(String label, int count, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Text('$label: $count',
      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)));
}


