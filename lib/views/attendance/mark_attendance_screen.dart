import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/attendance_provider.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AttendanceProvider>().fetchStudentsForClass());
  }

  Future<void> _pickDate() async {
    final provider = context.read<AttendanceProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) provider.setDate(picked);
  }

  Future<void> _save() async {
    final provider = context.read<AttendanceProvider>();
    final ok = await provider.saveAttendance();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Attendance saved!' : 'Failed to save attendance'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
  }

  Color _btnColor(AttendanceStatus status, AttendanceStatus current) {
    final active = status == current;
    switch (status) {
      case AttendanceStatus.present:
        return active ? Colors.green : Colors.green.withOpacity(0.12);
      case AttendanceStatus.absent:
        return active ? Colors.red : Colors.red.withOpacity(0.12);
      case AttendanceStatus.late:
        return active ? Colors.orange : Colors.orange.withOpacity(0.12);
    }
  }

  String _label(AttendanceStatus s) =>
      s == AttendanceStatus.present ? 'P' : s == AttendanceStatus.absent ? 'A' : 'L';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => context.go((() { final role = context.read<AuthProvider>().user?.role; return role == 'staff' ? '/dashboard/staff' : role == 'student' ? '/dashboard/student' : role == 'parent' ? '/dashboard/parent' : '/dashboard/admin'; })())),title: const Text('Mark Attendance')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today_outlined, size: 18),
                          label: Text(DateFormat('d MMM yyyy').format(provider.selectedDate)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: provider.selectedClass,
                          decoration: const InputDecoration(isDense: true),
                          items: AttendanceProvider.classOptions
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) context.read<AttendanceProvider>().setClass(v);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _summary('Present', provider.presentCount.toString(), Colors.green),
                    _summary('Absent', provider.absentCount.toString(), Colors.red),
                    _summary('Late', provider.lateCount.toString(), Colors.orange),
                    _summary('Total', provider.totalCount.toString(), AppTheme.primaryColor),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.students.length,
                    itemBuilder: (context, index) {
                      final s = provider.students[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: Text(s.name[0],
                                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text(s.rollNo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: AttendanceStatus.values
                                .map(
                                  (status) => Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: InkWell(
                                      onTap: () => context.read<AttendanceProvider>().markStatus(s.id, status),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: _btnColor(status, s.status),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          _label(status),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: status == s.status ? Colors.white : Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(
 'Save Attendance (P: ${provider.presentCount} | A: ${provider.absentCount} | L: ${provider.lateCount})'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _summary(String label, String value, Color color) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      );
}








