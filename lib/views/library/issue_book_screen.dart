import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/staff_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class IssueBookScreen extends StatefulWidget {
  const IssueBookScreen({super.key});
  @override
  State<IssueBookScreen> createState() => _IssueBookScreenState();
}

class _IssueBookScreenState extends State<IssueBookScreen> {
  String _userType = 'student';
  int? _selectedStudentId;
  int? _selectedStaffId;
  int? _selectedBookId;
  DateTime _issueDate = DateTime.now();
  DateTime? _dueDate;
  bool _saving = false;
  String _userRole = 'student';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userRole = context.read<AuthProvider>().user?.role ?? 'student';
      // Staff login pe default staff select
      if (_userRole == 'staff') {
        setState(() => _userType = 'staff');
      }
      context.read<StudentProvider>().fetchStudents();
      context.read<StaffProvider>().fetchStaff();
      context.read<LibraryProvider>().fetchBooks();
      final p = context.read<LibraryProvider>();
      setState(() => _dueDate = DateTime.now().add(
        Duration(days: _userType == 'student'
          ? p.settings.issueDaysForStudent
          : p.settings.issueDaysForStaff)));
    });
  }

  String _fmt(DateTime d) =>
        '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LibraryProvider>();
    final students = context.watch<StudentProvider>().students;
    final staff = context.watch<StaffProvider>().staffList;
    final availableBooks = p.books.where((b) => b.availableCopies > 0).toList();
    final role = context.watch<AuthProvider>().user?.role ?? 'student';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // User type selector ? only admin sees both options
          if (role == 'admin') ...[
            const Text('Issue To',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _userTypeBtn('student', 'Student',
                Icons.school, p)),
              const SizedBox(width: 12),
              Expanded(child: _userTypeBtn('staff', 'Staff',
                Icons.person, p)),
            ]),
            const SizedBox(height: 16),
          ],

          // Staff sees only staff option
          if (role == 'staff') ...[
            const Text('Issue To',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _userTypeBtn('staff', 'Staff Member', Icons.person, p),
            const SizedBox(height: 16),
          ],

          // Student sees only student option
          if (role == 'student' || role == 'parent') ...[
            const Text('Issue Book For',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _userTypeBtn('student', 'Student', Icons.school, p),
            const SizedBox(height: 16),
          ],

          // Select person
          Card(child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
        'Select ${_userType == 'student' ? 'Student' : 'Staff Member'}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 10),
              _userType == 'student'
                ? students.isEmpty
                  ? const Text('No students found.',
                      style: TextStyle(color: Colors.orange, fontSize: 12))
                  : DropdownButtonFormField<int>(
                      value: _selectedStudentId,
                      isExpanded: true,
                      hint: const Text('Choose student'),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.school)),
                      items: students.map((s) => DropdownMenuItem<int>(
                        value: s.id,
                        child: Text(
        '${s.name} (${s.admissionNo}) - ${s.className}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (v) => setState(() => _selectedStudentId = v),
                    )
                : staff.isEmpty
                  ? const Text('No staff found.',
                      style: TextStyle(color: Colors.orange, fontSize: 12))
                  : DropdownButtonFormField<int>(
                      value: _selectedStaffId,
                      isExpanded: true,
                      hint: const Text('Choose staff'),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person)),
                      items: staff.map((s) => DropdownMenuItem<int>(
                        value: s.id,
                        child: Text(
        '${s.name} (${s.employeeId}) - ${s.designation}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (v) => setState(() => _selectedStaffId = v),
                    ),
            ]),
          )),
          const SizedBox(height: 12),

          // Select Book
          Card(child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Select Book',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 4),
              Text('${availableBooks.length} books available',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 10),
              availableBooks.isEmpty
                ? const Text('No books available.',
                    style: TextStyle(color: Colors.orange, fontSize: 12))
                : DropdownButtonFormField<int>(
                    value: _selectedBookId,
                    isExpanded: true,
                    hint: const Text('Choose book'),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.menu_book)),
                    items: availableBooks.map((b) => DropdownMenuItem<int>(
                      value: b.id,
                      child: Text(
        '${b.title} by ${b.author} [${b.category}]',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) => setState(() => _selectedBookId = v),
                  ),
            ]),
          )),
          const SizedBox(height: 12),

          // Dates
          Card(child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Dates',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _issueDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 7)),
                      lastDate: DateTime.now().add(const Duration(days: 1)));
                    if (d != null) setState(() => _issueDate = d);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.shade200),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue.shade50),
                    child: Row(children: [
                      Icon(Icons.calendar_today, size: 16,
                        color: Colors.blue.shade600),
                      const SizedBox(width: 6),
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        const Text('Issue Date',
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text(_fmt(_issueDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                      ]),
                    ]),
                  ),
                )),
                const SizedBox(width: 10),
                Expanded(child: GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now().add(
                        const Duration(days: 14)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)));
                    if (d != null) setState(() => _dueDate = d);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange.shade200),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.orange.shade50),
                    child: Row(children: [
                      Icon(Icons.event, size: 16,
                        color: Colors.orange.shade600),
                      const SizedBox(width: 6),
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        const Text('Due Date',
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Text(_dueDate != null ? _fmt(_dueDate!) : 'Not set',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                      ]),
                    ]),
                  ),
                )),
              ]),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.info_outline, size: 14, color: Colors.blue),
                  const SizedBox(width: 6),
                  Expanded(child: Text(
        'Loan: ${_userType == 'student' ? p.settings.issueDaysForStudent : p.settings.issueDaysForStaff} days. Fine: Rs ${p.settings.finePerDay.toStringAsFixed(1)}/day after due date.',
                    style: const TextStyle(fontSize: 11, color: Colors.blue))),
                ]),
              ),
            ]),
          )),
          const SizedBox(height: 20),

          // Issue Button
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: (_selectedBookId == null ||
              (_userType == 'student' && _selectedStudentId == null) ||
              (_userType == 'staff' && _selectedStaffId == null) ||
              _saving)
              ? null
              : () => _issueBook(context, p),
            icon: _saving
              ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.menu_book),
            label: Text(_saving ? 'Issuing...' : 'Issue Book'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14)),
          )),
        ]),
      ),
    );
  }

  Widget _userTypeBtn(String type, String label, IconData icon,
      LibraryProvider p) =>
    GestureDetector(
      onTap: () => setState(() {
        _userType = type;
        _selectedStudentId = null;
        _selectedStaffId = null;
        _dueDate = DateTime.now().add(Duration(
          days: type == 'student'
            ? p.settings.issueDaysForStudent
            : p.settings.issueDaysForStaff));
      }),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _userType == type ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _userType == type
              ? AppTheme.primaryColor : Colors.grey.shade300)),
        child: Column(children: [
          Icon(icon,
            color: _userType == type ? Colors.white : Colors.grey,
            size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            color: _userType == type ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w600)),
          Text(
        'Loan: ${type == 'student' ? p.settings.issueDaysForStudent : p.settings.issueDaysForStaff} days',
            style: TextStyle(fontSize: 10,
              color: _userType == type ? Colors.white70 : Colors.grey)),
        ]),
      ),
    );

  Future<void> _issueBook(BuildContext context, LibraryProvider p) async {
    setState(() => _saving = true);
    final ok = await p.issueBook(
      bookId: _selectedBookId!,
      userId: _userType == 'student'
        ? _selectedStudentId! : _selectedStaffId!,
      userType: _userType,
      issueDate: _fmt(_issueDate),
      dueDate: _dueDate != null ? _fmt(_dueDate!) : '',
    );
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Book issued successfully!' : 'Failed to issue book'),
        backgroundColor: ok ? Colors.green : Colors.red));
      if (ok) {
        setState(() {
          _selectedBookId = null;
          _selectedStudentId = null;
          _selectedStaffId = null;
        });
        // Refresh issued books
        p.fetchIssues();
      }
    }
  }
}

