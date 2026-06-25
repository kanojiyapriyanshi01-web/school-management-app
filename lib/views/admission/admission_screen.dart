import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/admission_provider.dart';
import '../../core/theme/app_theme.dart';

class AdmissionScreen extends StatefulWidget {
  const AdmissionScreen({super.key});
  @override
  State<AdmissionScreen> createState() => _AdmissionScreenState();
}

class _AdmissionScreenState extends State<AdmissionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdmissionProvider>().fetchAdmissions();
    });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdmissionProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admission Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/dashboard/admin'),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: [
            Tab(text: 'All (${p.total})'),
            Tab(text: 'Pending (${p.pending})'),
            Tab(text: 'Approved (${p.approved})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AdmissionList(filter: 'all'),
          _AdmissionList(filter: 'pending'),
          _AdmissionList(filter: 'approved'),
        ],
      ),
    );
  }
}

class _AdmissionList extends StatelessWidget {
  final String filter;
  const _AdmissionList({required this.filter});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdmissionProvider>();
    final list = filter == 'all'
        ? p.admissions
        : p.admissions.where((a) => a.status == filter).toList();

    if (p.isLoading) return const Center(child: CircularProgressIndicator());
    if (list.isEmpty) return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        const Text('No applications found', style: TextStyle(color: Colors.grey)),
      ]),
    );

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final a = list[i];
        final statusColors = {
        'pending':  Colors.orange,
        'approved': Colors.green,
        'rejected': Colors.red,
        'waitlist': Colors.blue,
        };
        final color = statusColors[a.status] ?? Colors.grey;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(a.studentName[0],
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(a.studentName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Class: ${a.applyingClass} - ${a.academicYear}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(a.status.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color))),
              ]),

              if (a.studentId.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3))),
                  child: Row(children: [
                    const Icon(Icons.badge, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Student ID Generated',
                        style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                      Text(a.studentId,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    ]),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.green, size: 18),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Student ID ${a.studentId} copied!'),
                          backgroundColor: Colors.green)),
                    ),
                  ]),
                ),
              ],

              const Divider(height: 14),
              Row(children: [
                Expanded(child: _info('Father', a.fatherName)),
                Expanded(child: _info('Phone', a.parentPhone)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: _info('DOB', a.dob)),
                Expanded(child: _info('Gender', a.gender)),
                Expanded(child: _info('Year', a.academicYear)),
              ]),

              if (a.status == 'pending') ...[
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(context, a.id),
                    icon: const Icon(Icons.close, size: 16, color: Colors.red),
                    label: const Text('Reject', style: TextStyle(color: Colors.red, fontSize: 12)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () => _update(context, a.id, 'waitlist'),
                    icon: const Icon(Icons.list_alt, size: 16, color: Colors.blue),
                    label: const Text('Waitlist', style: TextStyle(color: Colors.blue, fontSize: 12)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blue)),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: ElevatedButton.icon(
                    onPressed: () => _showApproveDialog(context, a),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  )),
                ]),
              ],

              if (a.status == 'approved') ...[
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: OutlinedButton.icon(
                  onPressed: () => _showDetailDialog(context, a),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Full Details'),
                )),
              ],
            ]),
          ),
        );
      },
    );
  }

  void _update(BuildContext context, int id, String status) async {
    await context.read<AdmissionProvider>().updateStatus(id, status);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Application $status!'),
      backgroundColor: status == 'approved' ? Colors.green : Colors.red));
  }

  void _showApproveDialog(BuildContext context, AdmissionModel a) {
    final remarksCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Admission'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.2))),
            child: Column(children: [
              const Icon(Icons.info_outline, color: Colors.green),
              const SizedBox(height: 6),
              Text('Approving admission for ${a.studentName}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('A unique Student ID will be generated automatically.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center),
            ]),
          ),
          const SizedBox(height: 12),
          TextField(controller: remarksCtrl,
            decoration: const InputDecoration(
              labelText: 'Remarks (optional)',
              prefixIcon: Icon(Icons.note))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AdmissionProvider>().updateStatus(
                a.id, 'approved', remarks: remarksCtrl.text);
              final provider = context.read<AdmissionProvider>();
              final updated = provider.admissions.firstWhere(
                (ad) => ad.id == a.id, orElse: () => a);
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (ctx2) => AlertDialog(
                    title: const Row(children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Admission Approved!'),
                    ]),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withOpacity(0.3))),
                        child: Column(children: [
                          const Text('Student ID Generated',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 8),
                          Text(updated.studentId,
                            style: const TextStyle(fontSize: 32,
                              fontWeight: FontWeight.bold, color: Colors.green)),
                          const SizedBox(height: 8),
                          Text(a.studentName,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('${a.applyingClass} - ${a.academicYear}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ]),
                      ),
                    ]),
                    actions: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(ctx2),
                        icon: const Icon(Icons.check),
                        label: const Text('Done'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ],
                  ),
                );
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Approve & Generate ID'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, int id) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Application'),
        content: TextField(controller: reasonCtrl, maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection *',
            prefixIcon: Icon(Icons.info_outline))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AdmissionProvider>().updateStatus(
                id, 'rejected', remarks: reasonCtrl.text);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application rejected'),
                  backgroundColor: Colors.red));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context, AdmissionModel a) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(a.studentName),
        content: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, children: [
            if (a.studentId.isNotEmpty) Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3))),
              child: Row(children: [
                const Icon(Icons.badge, color: Colors.green),
                const SizedBox(width: 8),
                Text(a.studentId, style: const TextStyle(fontSize: 20,
                  fontWeight: FontWeight.bold, color: Colors.green)),
              ])),
            const SizedBox(height: 12),
            _dRow('Class', a.applyingClass),
            _dRow('Academic Year', a.academicYear),
            _dRow('DOB', a.dob),
            _dRow('Gender', a.gender),
            _dRow('Father', a.fatherName),
            _dRow('Mother', a.motherName),
            _dRow('Phone', a.parentPhone),
            _dRow('Email', a.email),
            _dRow('Address', a.address),
            if (a.previousSchool.isNotEmpty) _dRow('Previous School', a.previousSchool),
            if (a.remarks.isNotEmpty) _dRow('Remarks', a.remarks),
          ])),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _dRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 110, child: Text(label,
        style: const TextStyle(color: Colors.grey, fontSize: 12))),
      Expanded(child: Text(value,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12))),
    ]));

  Widget _info(String l, String v) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      Text(v, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis),
    ]);
}

class _AdmissionForm extends StatefulWidget {
  const _AdmissionForm();
  @override
  State<_AdmissionForm> createState() => _AdmissionFormState();
}

class _AdmissionFormState extends State<_AdmissionForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _dob = TextEditingController();
  final _fatherName = TextEditingController();
  final _motherName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _prevSchool = TextEditingController();
  String _gender = 'Male';
  String _class = 'Class 1';
  String _year = '2025-26';
  bool _saving = false;
  final Map<int, String> _uploadedFileNames = {};

  final List<Map<String, dynamic>> _documents = [
    {'name': 'Birth Certificate', 'icon': Icons.description, 'uploaded': false},
    {'name': 'Aadhar Card', 'icon': Icons.credit_card, 'uploaded': false},
    {'name': 'Transfer Certificate', 'icon': Icons.transfer_within_a_station, 'uploaded': false},
    {'name': 'Previous Report Card', 'icon': Icons.grade, 'uploaded': false},
    {'name': 'Passport Photo', 'icon': Icons.photo, 'uploaded': false},
  ];

  final _classes = [
        'Nursery','LKG','UKG','Class 1','Class 2','Class 3','Class 4',
        'Class 5','Class 6','Class 7','Class 8','Class 9',
        'Class 10','Class 11','Class 12',
  ];

  @override
  void dispose() {
    _name.dispose(); _dob.dispose(); _fatherName.dispose();
    _motherName.dispose(); _phone.dispose(); _email.dispose();
    _address.dispose(); _prevSchool.dispose();
    super.dispose();
  }

  void _pickFile(int index) {
    setState(() {
      _documents[index]['uploaded'] = true;
      _uploadedFileNames[index] = '${_documents[index]['name']}.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${_documents[index]['name']} selected!'),
      backgroundColor: Colors.green));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final ok = await context.read<AdmissionProvider>().submitAdmission(
      studentName: _name.text, dob: _dob.text, gender: _gender,
      applyingClass: _class, academicYear: _year,
      fatherName: _fatherName.text, motherName: _motherName.text,
      parentPhone: _phone.text, email: _email.text,
      address: _address.text, previousSchool: _prevSchool.text,
    );
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Application submitted successfully!' : 'Failed to submit'),
        backgroundColor: ok ? Colors.green : Colors.red));
      if (ok) {
        _name.clear(); _dob.clear(); _fatherName.clear();
        _motherName.clear(); _phone.clear(); _email.clear();
        _address.clear(); _prevSchool.clear();
        setState(() {
          for (var doc in _documents) doc['uploaded'] = false;
          _uploadedFileNames.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadedCount = _documents.where((d) => d['uploaded'] == true).length;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _title('Student Information'),
          _f(_name, 'Full Name *', Icons.person, req: true),
          const SizedBox(height: 12),
          _f(_dob, 'Date of Birth *', Icons.cake, req: true, hint: 'DD/MM/YYYY'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(labelText: 'Gender *', prefixIcon: Icon(Icons.people)),
            items: ['Male','Female','Other']
              .map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (v) => setState(() => _gender = v!)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _class,
            decoration: const InputDecoration(labelText: 'Applying Class *', prefixIcon: Icon(Icons.class_)),
            items: _classes
              .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _class = v!)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _year,
            decoration: const InputDecoration(labelText: 'Academic Year *', prefixIcon: Icon(Icons.calendar_today)),
            items: ['2024-25','2025-26','2026-27']
              .map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
            onChanged: (v) => setState(() => _year = v!)),
          const SizedBox(height: 20),

          _title('Parent / Guardian Information'),
          _f(_fatherName, "Father's Name *", Icons.person, req: true),
          const SizedBox(height: 12),
          _f(_motherName, "Mother's Name", Icons.person),
          const SizedBox(height: 12),
          _f(_phone, 'Parent Phone *', Icons.phone, req: true, type: TextInputType.phone),
          const SizedBox(height: 12),
          _f(_email, 'Email Address', Icons.email, type: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _f(_address, 'Home Address *', Icons.location_on, req: true, lines: 2),
          const SizedBox(height: 20),

          _title('Previous School'),
          _f(_prevSchool, 'Previous School Name', Icons.school),
          const SizedBox(height: 20),

          _title('Upload Documents'),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.2))),
            child: Column(children: [
              ..._documents.asMap().entries.map((entry) {
                final i = entry.key;
                final doc = entry.value;
                final isUploaded = doc['uploaded'] as bool;
                final fileName = _uploadedFileNames[i];

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUploaded ? Colors.green.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isUploaded ? Colors.green.withOpacity(0.3) : Colors.grey.shade200)),
                  child: Row(children: [
                    Icon(doc['icon'] as IconData,
                      color: isUploaded ? Colors.green : Colors.grey, size: 22),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(doc['name'] as String,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                          color: isUploaded ? Colors.green.shade700 : Colors.black87)),
                      if (isUploaded && fileName != null)
                        Text(fileName,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                          overflow: TextOverflow.ellipsis),
                    ])),
                    const SizedBox(width: 8),
                    if (isUploaded)
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => setState(() {
                            _documents[i]['uploaded'] = false;
                            _uploadedFileNames.remove(i);
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 14, color: Colors.red)),
                        ),
                      ])
                    else
                      ElevatedButton.icon(
                        onPressed: () => _pickFile(i),
                        icon: const Icon(Icons.upload_file, size: 14),
                        label: const Text('Choose File', style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                      ),
                  ]),
                );
              }),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: uploadedCount / _documents.length,
                  color: Colors.green,
                  backgroundColor: Colors.grey.shade200,
                  minHeight: 6)),
              const SizedBox(height: 4),
              Text('$uploadedCount/${_documents.length} documents uploaded',
                style: TextStyle(fontSize: 12,
                  color: uploadedCount == _documents.length ? Colors.green : Colors.grey)),
            ]),
          ),
          const SizedBox(height: 24),

          SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.send),
              label: Text(_saving ? 'Submitting...' : 'Submit Application'),
            )),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _title(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Container(width: 4, height: 20,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _f(TextEditingController c, String label, IconData icon, {
    bool req = false, String? hint,
    TextInputType type = TextInputType.text, int lines = 1,
  }) => TextFormField(
    controller: c, keyboardType: type, maxLines: lines,
    decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon)),
    validator: req ? (v) => (v == null || v.isEmpty) ? '$label required' : null : null,
  );
}

