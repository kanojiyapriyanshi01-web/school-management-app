import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';

// ─── Parent's child attendance view ──────────────────────────────────────────
// Provider ke savedHistory se real-time sync hoti hai.
// Jab teacher Mark Attendance screen pe save karta hai,
// AttendanceProvider notifyListeners() call karta hai,
// aur yeh screen automatically update ho jaati hai.

class ParentAttendanceScreen extends StatefulWidget {
  const ParentAttendanceScreen({super.key});

  @override
  State<ParentAttendanceScreen> createState() =>
      _ParentAttendanceScreenState();
}

class _ParentAttendanceScreenState
    extends State<ParentAttendanceScreen> {
  bool _loading = true;
  List<_AttendanceDay> _remoteRecords = [];
  String _childName = '';

  // Mock data – backend connect hone tak
  static final List<_AttendanceDay> _mock = [
    _AttendanceDay(
        date: DateTime(2026, 6, 25),
        status: 'present',
        className: 'Class 8-A'),
    _AttendanceDay(
        date: DateTime(2026, 6, 24),
        status: 'absent',
        className: 'Class 8-A'),
    _AttendanceDay(
        date: DateTime(2026, 6, 23),
        status: 'late',
        className: 'Class 8-A'),
    _AttendanceDay(
        date: DateTime(2026, 6, 22),
        status: 'present',
        className: 'Class 8-A'),
    _AttendanceDay(
        date: DateTime(2026, 6, 21),
        status: 'present',
        className: 'Class 8-A'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final auth = context.read<AuthProvider>();
    final studentId = auth.user?.studentId;
    _childName = auth.user?.childName ?? 'Your Child';

    try {
      final uri =
          Uri.parse('${AttendanceProvider.baseUrl}/attendance').replace(
        queryParameters: {
          if (studentId != null) 'student_id': studentId.toString(),
        },
      );
      final res =
          await http.get(uri).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['data'] as List<dynamic>?) ?? [];
        _remoteRecords = list
            .map((r) => _AttendanceDay(
                  date: DateTime.tryParse(
                          r['date'] as String? ?? '') ??
                      DateTime.now(),
                  status: r['status'] as String? ?? 'present',
                  className: r['class_id'] as String? ?? '',
                ))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      } else {
        _remoteRecords = _mock;
      }
    } catch (_) {
      _remoteRecords = _mock;
    }

    if (mounted) setState(() => _loading = false);
  }

  // ── Merge: Provider ke local saved records + remote records ──
  // Provider mein jo teacher ne abhi save kiya woh bhi dikhe
  List<_AttendanceDay> _mergedRecords(
      AttendanceProvider provider) {
    // Provider ke savedHistory ko _AttendanceDay list mein convert karo
    final localDays = <String, _AttendanceDay>{};

    for (final rec in provider.savedHistory) {
      // Har student ka record check karo
      // Parent apne child ka record dekhta hai
      // Abhi sab students dikhate hain (child filter backend pe hoga)
      final dateStr = DateFormat('yyyy-MM-dd').format(rec.date);
      final key = '$dateStr|${rec.className}';

      // Summary: agar koi absent hai toh absent dikhao
      // (real app mein specific child ka status filter hoga)
      final hasAbsent =
          rec.students.any((s) => s.status == AttendanceStatus.absent);
      final hasLate =
          rec.students.any((s) => s.status == AttendanceStatus.late);
      final status = hasAbsent
          ? 'absent'
          : hasLate
              ? 'late'
              : 'present';

      localDays[key] = _AttendanceDay(
        date: rec.date,
        status: status,
        className: rec.className,
        isLocal: true,
      );
    }

    // Remote records se merge karo (remote override kare local ko)
    final merged = Map<String, _AttendanceDay>.from(localDays);
    for (final r in _remoteRecords) {
      final key =
          '${DateFormat('yyyy-MM-dd').format(r.date)}|${r.className}';
      merged[key] = r;
    }

    return merged.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    // Provider watch karo – jab teacher save kare toh auto update ho
    final provider = context.watch<AttendanceProvider>();

    final records = _loading ? <_AttendanceDay>[] : _mergedRecords(provider);
    final total = records.length;
    final presentCount =
        records.where((r) => r.status == 'present').length;
    final absentCount =
        records.where((r) => r.status == 'absent').length;
    final lateCount = records.where((r) => r.status == 'late').length;
    final pct = total == 0 ? 0 : (presentCount / total * 100).round();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.go('/dashboard/parent'),
        ),
        title: Text('$_childName की Attendance'),
        actions: [
          // Manual refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: Column(
                children: [
                  // ── Summary cards ─────────────────────────────────
                  Container(
                    color: Colors.grey.shade50,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Overall % bar
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Overall Attendance: $pct%',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: pct >= 75
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: total == 0
                                          ? 0
                                          : presentCount / total,
                                      backgroundColor:
                                          Colors.red.withOpacity(0.2),
                                      color: pct >= 75
                                          ? Colors.green
                                          : Colors.orange,
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _StatBox(
                                'Present', presentCount, Colors.green),
                            const SizedBox(width: 10),
                            _StatBox('Absent', absentCount, Colors.red),
                            const SizedBox(width: 10),
                            _StatBox('Late', lateCount, Colors.orange),
                            const SizedBox(width: 10),
                            _StatBox('Total', total, Colors.blue),
                          ],
                        ),
                        if (pct < 75)
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber,
                                    color: Colors.red, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Attendance 75% se kam hai. School se contact karen.',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── List header ───────────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        const Text('Daily Records',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text('${records.length} records',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),

                  // ── Records list ──────────────────────────────────
                  Expanded(
                    child: records.isEmpty
                        ? const Center(
                            child: Text('Koi record nahi mila',
                                style:
                                    TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            itemCount: records.length,
                            itemBuilder: (_, i) {
                              final r = records[i];
                              final color = r.status == 'present'
                                  ? Colors.green
                                  : r.status == 'absent'
                                      ? Colors.red
                                      : Colors.orange;
                              final statusLabel =
                                  r.status == 'present'
                                      ? 'Present'
                                      : r.status == 'absent'
                                          ? 'Absent'
                                          : 'Late';

                              return Card(
                                margin:
                                    const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        color.withOpacity(0.15),
                                    child: Text(
                                      statusLabel[0],
                                      style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(
                                    DateFormat('EEEE, d MMM yyyy')
                                        .format(r.date),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(r.className,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey)),
                                      if (r.isLocal) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                  vertical: 1),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.blue.shade50,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    4),
                                          ),
                                          child: const Text(
                                            'New',
                                            style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.blue,
                                                fontWeight:
                                                    FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────

class _AttendanceDay {
  final DateTime date;
  final String status;
  final String className;
  final bool isLocal; // provider se aaya (abhi save hua)

  _AttendanceDay({
    required this.date,
    required this.status,
    required this.className,
    this.isLocal = false,
  });
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatBox(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text('$value',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      );
}
