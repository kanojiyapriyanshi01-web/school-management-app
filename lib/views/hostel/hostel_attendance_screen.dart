// lib/views/hostel/hostel_attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hostel_provider.dart';
import '../../core/theme/app_theme.dart';

class HostelAttendanceScreen extends StatefulWidget {
  const HostelAttendanceScreen({super.key});
  @override
  State<HostelAttendanceScreen> createState() => _HostelAttendanceScreenState();
}

class _HostelAttendanceScreenState extends State<HostelAttendanceScreen> {
  DateTime _date = DateTime.now();
  bool _saving = false;

  final List<Map<String, dynamic>> _attendance = [
    {'name': 'Rahul Kumar', 'room': '101', 'status': 'present'},
    {'name': 'Vijay Verma', 'room': '101', 'status': 'present'},
    {'name': 'Priya Singh', 'room': '201', 'status': 'present'},
    {'name': 'Anita Gupta', 'room': '201', 'status': 'on_leave'},
  ];

  @override
  Widget build(BuildContext context) {
    final present = _attendance.where((a) => a['status'] == 'present').length;
    final absent  = _attendance.where((a) => a['status'] == 'absent').length;
    final onLeave = _attendance.where((a) => a['status'] == 'on_leave').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(children: [
        Container(color: Colors.white, padding: const EdgeInsets.all(14), child: Column(children: [
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(context: context,
                initialDate: _date, firstDate: DateTime(2024), lastDate: DateTime.now());
              if (d != null) setState(() => _date = d);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text('${_date.day}/${_date.month}/${_date.year}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const Icon(Icons.arrow_drop_down),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _sum('Present', present, Colors.green),
            _sum('Absent', absent, Colors.red),
            _sum('On Leave', onLeave, Colors.blue),
            _sum('Total', _attendance.length, Colors.grey),
          ]),
        ])),
        const Divider(height: 1),
        Expanded(child: ListView.builder(
          itemCount: _attendance.length,
          itemBuilder: (context, i) {
            final a = _attendance[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
              child: Row(children: [
                CircleAvatar(radius: 16, backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(a['name'][0], style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('Room: ${a['room']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ])),
                Row(children: [
                  _btn('P', 'present', Colors.green, a, i),
                  const SizedBox(width: 4),
                  _btn('A', 'absent', Colors.red, a, i),
                  const SizedBox(width: 4),
                  _btn('L', 'on_leave', Colors.blue, a, i),
                ]),
              ]),
            );
          },
        )),
        SafeArea(child: Padding(
          padding: const EdgeInsets.all(14),
          child: SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _saving ? null : () async {
              setState(() => _saving = true);
              await Future.delayed(const Duration(seconds: 1));
              setState(() => _saving = false);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Attendance saved!'), backgroundColor: Colors.green));
            },
            child: _saving
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Save Attendance'),
          )),
        )),
      ]),
    );
  }

  Widget _sum(String label, int count, Color color) => Column(children: [
    Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
  ]);

  Widget _btn(String label, String val, Color color, Map a, int i) {
    final sel = a['status'] == val;
    return GestureDetector(
      onTap: () => setState(() => _attendance[i]['status'] = val),
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: sel ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: sel ? color : Colors.grey.shade300)),
        child: Center(child: Text(label,
          style: TextStyle(color: sel ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 11))),
      ),
    );
  }
}

