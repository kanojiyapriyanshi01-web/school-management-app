import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';

class AddEditStudentScreen extends StatefulWidget {
  final bool isEdit;
  final int? studentId;
  const AddEditStudentScreen({super.key, required this.isEdit, this.studentId});
  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  final Map<String, String?> _uploadedDocs = {};

  final _name = TextEditingController();
  final _dob = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _admissionNo = TextEditingController();
  final _rollNo = TextEditingController();
  final _admissionDate = TextEditingController();
  final _fatherName = TextEditingController();
  final _motherName = TextEditingController();
  final _parentPhone = TextEditingController();
  final _parentEmail = TextEditingController();
  final _parentOccupation = TextEditingController();
  final _emergencyContact = TextEditingController();
  final _medicalInfo = TextEditingController();

  String _gender = 'Male';
  String _bloodGroup = 'A+';
  String _className = 'Class 10';
  String _section = 'A';
  bool _hasTransport = false;
  String _busRoute = 'Route 1';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _generateAdmissionNo();
  }

  void _generateAdmissionNo() {
    final year = DateTime.now().year.toString().substring(2);
    final classCode = _className
      .replaceAll('Class ', 'C')
      .replaceAll('Nursery', 'NUR')
      .replaceAll('LKG', 'LKG')
      .replaceAll('UKG', 'UKG');
    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    _admissionNo.text = 'ADM$year$classCode${random.toString().padLeft(4, '0')}';
    // Roll number manual input
  }

  @override
  void dispose() {
    _tabController.dispose();
    _name.dispose(); _dob.dispose(); _phone.dispose(); _email.dispose();
    _address.dispose(); _admissionNo.dispose(); _rollNo.dispose();
    _admissionDate.dispose(); _fatherName.dispose(); _motherName.dispose();
    _parentPhone.dispose(); _parentEmail.dispose(); _parentOccupation.dispose();
    _emergencyContact.dispose(); _medicalInfo.dispose();
    super.dispose();
  }

  Future<void> _save() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _saving = true);
  final student = StudentModel(
    id: 0,
    admissionNo: _admissionNo.text,
    rollNo: _rollNo.text,
    name: _name.text,
    className: _className,
    section: _section,
    gender: _gender,
    dob: _dob.text,
    bloodGroup: _bloodGroup,
    phone: _phone.text,
    email: _email.text,
    address: _address.text,
    fatherName: _fatherName.text,
    motherName: _motherName.text,
    parentPhone: _parentPhone.text,
    parentEmail: _parentEmail.text,
    parentOccupation: _parentOccupation.text,
    emergencyContact: _emergencyContact.text,
    medicalInfo: _medicalInfo.text,
    transport: _hasTransport ? 'yes' : 'no',
    busRoute: _hasTransport ? _busRoute : '',
    admissionDate: _admissionDate.text,
    status: 'active',
  );
  final ok = await context.read<StudentProvider>().addStudent(student);
  setState(() => _saving = false);
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? (widget.isEdit ? 'Student updated!' : 'Student added successfully!') : 'Failed to add student'),
      backgroundColor: ok ? Colors.green : Colors.red));
    if (ok) context.go('/students');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Student' : 'Add New Student'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/students'),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [Tab(text: 'Personal'), Tab(text: 'Admission'), Tab(text: 'Parent'), Tab(text: 'Documents')],
        ),
      ),
      body: Form(key: _formKey, child: TabBarView(controller: _tabController, children: [
        _personalTab(), _admissionTab(), _parentTab(), _documentsTab(),
      ])),
      bottomNavigationBar: SafeArea(child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(widget.isEdit ? 'Update Student' : 'Add Student'),
        ),
      )),
    );
  }

  Widget _personalTab() => SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
    Center(child: Stack(children: [
      CircleAvatar(radius: 50, backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: const Icon(Icons.person, size: 50, color: AppTheme.primaryColor)),
      Positioned(bottom: 0, right: 0, child: Container(
        decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
        child: IconButton(icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18), onPressed: () {}),
      )),
    ])),
    const SizedBox(height: 20),
    _field(_name, 'Full Name *', Icons.person, required: true),
    const SizedBox(height: 14),
    TextFormField(
  controller: _dob,
  readOnly: true,
  decoration: const InputDecoration(
    labelText: 'Date of Birth *',
    prefixIcon: Icon(Icons.calendar_today),
    hintText: 'DD/MM/YYYY'),
  onTap: () async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2010),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dob.text = '${picked.day.toString().padLeft(2,'0')}/${picked.month.toString().padLeft(2,'0')}/${picked.year}';
      });
    }
  },
  validator: (v) => (v == null || v.isEmpty) ? 'Date of Birth required' : null,
),
    const SizedBox(height: 14),
    DropdownButtonFormField<String>(value: _gender,
      decoration: const InputDecoration(labelText: 'Gender *', prefixIcon: Icon(Icons.people)),
      items: ['Male','Female','Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
      onChanged: (v) => setState(() => _gender = v!)),
    const SizedBox(height: 14),
    DropdownButtonFormField<String>(value: _bloodGroup,
      decoration: const InputDecoration(labelText: 'Blood Group', prefixIcon: Icon(Icons.bloodtype)),
      items: ['A+','A-','B+','B-','O+','O-','AB+','AB-'].map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
      onChanged: (v) => setState(() => _bloodGroup = v!)),
    const SizedBox(height: 14),
    _field(_phone, 'Phone', Icons.phone, type: TextInputType.phone),
    const SizedBox(height: 14),
    _field(_email, 'Email', Icons.email, type: TextInputType.emailAddress),
    const SizedBox(height: 14),
    _field(_address, 'Address *', Icons.location_on, required: true, maxLines: 3),
    const SizedBox(height: 14),
    _field(_medicalInfo, 'Medical Info', Icons.medical_services, maxLines: 2, hint: 'Allergies, conditions...'),
    const SizedBox(height: 14),
    Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('School Transport', style: TextStyle(fontWeight: FontWeight.w600)),
        Switch(value: _hasTransport, onChanged: (v) => setState(() => _hasTransport = v)),
      ]),
      if (_hasTransport) ...[
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(value: _busRoute,
          decoration: const InputDecoration(labelText: 'Bus Route', prefixIcon: Icon(Icons.directions_bus)),
          items: ['Route 1','Route 2','Route 3','Route 4','Route 5'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: (v) => setState(() => _busRoute = v!)),
      ],
    ]))),
  ]));

  Widget _admissionTab() => SingleChildScrollView(
  padding: const EdgeInsets.all(20),
  child: Column(children: [
    // Admission Number - Auto Generated
    TextFormField(
      controller: _admissionNo,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Admission Number (Auto Generated)',
        prefixIcon: const Icon(Icons.badge),
        filled: true,
        fillColor: Colors.grey.shade50,
        suffixIcon: IconButton(
          icon: const Icon(Icons.refresh, color: Colors.blue),
          onPressed: _generateAdmissionNo,
          tooltip: 'Regenerate',
        )),
    ),
    const SizedBox(height: 14),

    TextFormField(
  controller: _rollNo,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
    labelText: 'Roll Number',
    prefixIcon: Icon(Icons.numbers),
    hintText: 'Enter roll number'),
),
    const SizedBox(height: 14),

    // Class selector - updates auto IDs
    DropdownButtonFormField<String>(
      value: _className,
      decoration: const InputDecoration(
        labelText: 'Class *', prefixIcon: Icon(Icons.class_)),
      items: ['Nursery','LKG','UKG','Class 1','Class 2','Class 3',
        'Class 4','Class 5','Class 6','Class 7','Class 8',
        'Class 9','Class 10','Class 11','Class 12']
        .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (v) {
        setState(() => _className = v!);
        _generateAdmissionNo();
      },
      validator: (v) => v == null ? 'Class required' : null,
    ),
    const SizedBox(height: 14),

    DropdownButtonFormField<String>(
      value: _section,
      decoration: const InputDecoration(
        labelText: 'Section *', prefixIcon: Icon(Icons.segment)),
      items: ['A','B','C','D']
        .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) {
        setState(() => _section = v!);
        _generateAdmissionNo();
      },
      validator: (v) => v == null ? 'Section required' : null,
    ),
    const SizedBox(height: 14),

    // Admission Date - Calendar picker
    TextFormField(
      controller: _admissionDate,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Admission Date *',
        prefixIcon: Icon(Icons.date_range)),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2030));
        if (picked != null) {
          setState(() {
            _admissionDate.text =
        '${picked.day.toString().padLeft(2,'0')}/${picked.month.toString().padLeft(2,'0')}/${picked.year}';
          });
        }
      },
      validator: (v) => (v == null || v.isEmpty) ? 'Admission Date required' : null,
    ),
  ]));

  Widget _parentTab() => SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
    _field(_fatherName, "Father's Name *", Icons.person, required: true),
    const SizedBox(height: 14),
    _field(_motherName, "Mother's Name", Icons.person),
    const SizedBox(height: 14),
    _field(_parentPhone, 'Parent Phone *', Icons.phone, required: true, type: TextInputType.phone),
    const SizedBox(height: 14),
    _field(_parentEmail, 'Parent Email', Icons.email, type: TextInputType.emailAddress),
    const SizedBox(height: 14),
    _field(_parentOccupation, 'Occupation', Icons.work),
    const SizedBox(height: 14),
    _field(_emergencyContact, 'Emergency Contact *', Icons.emergency, required: true, type: TextInputType.phone),
  ]));

  Widget _documentsTab() => SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
    const Text('Upload Documents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    const SizedBox(height: 20),
    _docUpload('Birth Certificate', Icons.description),
    _docUpload('Aadhar Card', Icons.credit_card),
    _docUpload('Transfer Certificate', Icons.transfer_within_a_station),
    _docUpload('Previous Report Card', Icons.grade),
    _docUpload('Profile Photo', Icons.photo),
  ]));

 Widget _field(TextEditingController ctrl, String label, IconData icon, {
  bool required = false, String? hint, TextInputType type = TextInputType.text, int maxLines = 1,
}) => TextFormField(
  controller: ctrl, keyboardType: type, maxLines: maxLines,
  maxLength: type == TextInputType.phone ? 10 : null,
  decoration: InputDecoration(
    labelText: label, hintText: hint, prefixIcon: Icon(icon),
    counterText: type == TextInputType.phone ? '' : null),
  validator: required ? (v) {
    if (v == null || v.isEmpty) return '$label is required';
    if (type == TextInputType.phone && v.length != 10) return 'Enter valid 10 digit number';
    return null;
  } : (v) {
    if (type == TextInputType.phone && v != null && v.isNotEmpty && v.length != 10) {
      return 'Enter valid 10 digit number';
    }
    return null;
  },
);

  Widget _docUpload(String label, IconData icon) {
  final uploaded = _uploadedDocs[label];
  return Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: Icon(icon,
        color: uploaded != null ? Colors.green : AppTheme.primaryColor),
      title: Text(label, style: const TextStyle(fontSize: 13)),
      subtitle: Text(
        uploaded != null ? uploaded : 'Tap to upload (PDF, JPG, PNG)',
        style: TextStyle(fontSize: 11,
          color: uploaded != null ? Colors.green : Colors.grey),
        overflow: TextOverflow.ellipsis),
      trailing: uploaded != null
        ? Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 18),
            const SizedBox(width: 4),
            OutlinedButton(
              onPressed: () => setState(() => _uploadedDocs.remove(label)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 8)),
              child: const Text('Remove', style: TextStyle(fontSize: 11)),
            ),
          ])
        : OutlinedButton.icon(
            onPressed: () async {
              try {
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() => _uploadedDocs[label] = image.name);
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            },
            icon: const Icon(Icons.upload, size: 16),
            label: const Text('Upload', style: TextStyle(fontSize: 12)),
          ),
    ),
  );
}
}




