import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class StudentIdCardScreen extends StatelessWidget {
  const StudentIdCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital ID Card'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/dashboard/student'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ID Card downloaded!'), backgroundColor: Colors.green));
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // ID Card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.school, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('SCHOOL MANAGEMENT SYSTEM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('Affiliated to CBSE ? New Delhi', style: TextStyle(color: Colors.white70, fontSize: 10)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Text('2025-26', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
              ]),
              const Divider(color: Colors.white24, height: 24),
              Row(children: [
                // Photo
                Container(
                  width: 80, height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white30, width: 2)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(user?.name.substring(0,1) ?? 'R',
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user?.name ?? 'Rahul Kumar',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  _idRow('Class', 'Class 10-A'),
                  _idRow('Roll No', 'R001'),
                  _idRow('Adm No', 'ADM001'),
                  _idRow('DOB', '15 Mar 2009'),
                  _idRow('Blood', 'B+'),
                ])),
              ]),
              const Divider(color: Colors.white24, height: 24),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _idRow('Father', 'Suresh Kumar'),
                  _idRow('Phone', '9876543210'),
                  _idRow('Address', '123 MG Road, Delhi'),
                ])),
                // QR placeholder
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.qr_code, size: 40, color: Color(0xFF1565C0)),
                    const Text('Scan', style: TextStyle(fontSize: 9, color: Color(0xFF1565C0))),
                  ]),
                ),
              ]),
              const Divider(color: Colors.white24, height: 20),
              const Text('Valid for Academic Year 2025-26 only',
                style: TextStyle(color: Colors.white70, fontSize: 10)),
            ]),
          ),
          const SizedBox(height: 20),

          // Student Details
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Student Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Divider(),
              _row('Full Name',        user?.name ?? 'Rahul Kumar'),
              _row('Admission No', 'ADM001'),
              _row('Class & Section', 'Class 10-A'),
              _row('Roll Number', 'R001'),
              _row('Date of Birth', '15 Mar 2009'),
              _row('Gender', 'Male'),
              _row('Blood Group', 'B+'),
              _row('Email',            user?.email ?? 'rahul@school.com'),
            ]),
          )),
          const SizedBox(height: 12),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Emergency Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Divider(),
              _row('Father Name', 'Suresh Kumar'),
              _row('Phone', '9876543210'),
              _row('Alt Phone', '9876543211'),
              _row('Blood Group', 'B+'),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _idRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(children: [
      Text('$label: ', style: const TextStyle(color: Colors.white60, fontSize: 10)),
      Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis)),
    ]),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12))),
    ]),
  );
}


